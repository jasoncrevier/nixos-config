# Nightly restic backup to Backblaze B2 (S3 API). Service modules add their data with
# backups.paths; a host turns it on with backups.enable and points backups.sopsFile at a
# file only it (and you) can decrypt, so one host can't read another's backups.
#
# That sops file needs:
#   restic_repository  s3:https://s3.<region>.backblazeb2.com/<bucket>
#   restic_password    the repo password (also keep it in Bitwarden)
#   restic_b2_env      AWS_ACCESS_KEY_ID=<keyID> and AWS_SECRET_ACCESS_KEY=<applicationKey>,
#                      from a B2 application key limited to that one bucket
#
# SQLite databases under the paths are copied with `sqlite3 .backup` first, so the snapshot
# never holds a half-written database: the copy is under /var/lib/restic-sqlite/<original path>
# and the live file is left out. To restore one, copy it back over the original.
#
# Run by hand: sudo systemctl start restic-backups-b2
# Browse:      sudo restic-b2 snapshots / sudo restic-b2 ls latest

{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.backups;
  sqliteDir = "/var/lib/restic-sqlite";
  sqliteExcludes = "/run/restic-sqlite-excludes";

  # Finds SQLite files by their header (names vary: .db, .sqlite, none), copies each
  # one with .backup and lists the originals and their -wal/-shm files for --exclude-file
  dumpSqlite = pkgs.writeShellApplication {
    name = "restic-dump-sqlite";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.diffutils
      pkgs.findutils
      pkgs.sqlite
    ];
    text = ''
      rm -rf "${sqliteDir}"
      : > "${sqliteExcludes}"

      # Skip paths that don't exist yet, e.g. a service that has never started
      existing=()
      for p in "$@"; do
        if [ -e "$p" ]; then existing+=("$p"); fi
      done
      [ ''${#existing[@]} -gt 0 ] || exit 0

      while IFS= read -r -d "" f; do
        cmp -s -n 15 <(printf 'SQLite format 3') "$f" || continue
        mkdir -p "${sqliteDir}$(dirname "$f")"
        # Databases in rollback-journal mode (e.g. Zomboid's, Karakeep's queue) lock out
        # readers while they write, so wait for the writer instead of failing at once
        if ! sqlite3 -cmd ".timeout 60000" "$f" ".backup '${sqliteDir}$f'"; then
          echo "Couldn't copy $f (still locked after 60s?)" >&2
          exit 1
        fi
        printf '%s\n%s-wal\n%s-shm\n' "$f" "$f" "$f" >> "${sqliteExcludes}"
      done < <(find "''${existing[@]}" -xdev -type f -size +0 -print0)
    '';
  };

  # The module runs backupPrepareCommand without set -e, so a failed dump would go unnoticed
  prepare = pkgs.writeShellApplication {
    name = "restic-prepare";
    runtimeInputs = [ pkgs.systemd ];
    text = ''
      ${cfg.prepareCommands}

      # Only restart what was running. The trap starts them again even if the copy fails.
      units=(${lib.escapeShellArgs cfg.stopServices})
      stopped=()
      for unit in "''${units[@]}"; do
        if systemctl is-active --quiet "$unit"; then stopped+=("$unit"); fi
      done
      if [ ''${#stopped[@]} -gt 0 ]; then
        trap 'systemctl start "''${stopped[@]}"' EXIT
        systemctl stop "''${stopped[@]}"
      fi

      ${dumpSqlite}/bin/restic-dump-sqlite ${lib.escapeShellArgs cfg.paths}
    '';
  };
in
{
  imports = [ ./failure-alerts.nix ];

  options.backups = {
    enable = lib.mkEnableOption "the nightly restic backup to B2";

    sopsFile = lib.mkOption {
      type = lib.types.path;
      description = "sops file with this host's restic_repository, restic_password and restic_b2_env.";
    };

    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Directories to back up. Use real paths, not /var/lib/<name> symlinks to /var/lib/private.";
    };

    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "restic --exclude patterns (caches and anything that can be re-downloaded).";
    };

    prepareCommands = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Run as root before each backup, e.g. to dump a database into a backed-up path.";
    };

    stopServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "music-assistant" ];
      description = "Services stopped while SQLite files are copied (for apps that lock their databases exclusively), then started again before the upload.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = lib.genAttrs [ "restic_repository" "restic_password" "restic_b2_env" ] (_: {
      inherit (cfg) sopsFile;
    });

    services.restic.backups.b2 = {
      initialize = true;
      repositoryFile = config.sops.secrets.restic_repository.path;
      passwordFile = config.sops.secrets.restic_password.path;
      environmentFile = config.sops.secrets.restic_b2_env.path;
      createWrapper = true; # restic-b2 command for browsing and restores

      paths = cfg.paths ++ [ sqliteDir ];
      # Also leave out copies of excluded databases (e.g. a cache.db) from the SQLite step
      exclude = cfg.exclude ++ map (p: sqliteDir + p) (lib.filter (lib.hasPrefix "/") cfg.exclude);
      extraBackupArgs = [ "--exclude-file=${sqliteExcludes}" ];

      backupPrepareCommand = "${prepare}/bin/restic-prepare";
      backupCleanupCommand = "rm -rf ${sqliteDir}";

      # Before fleet-prebuild (04:00), which fills nix-server's disk and CPU
      timerConfig = {
        OnCalendar = "03:00";
        RandomizedDelaySec = "15m";
        Persistent = true;
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
      ];
      runCheck = true;
    };

    failureAlerts.services = [ "restic-backups-b2" ];
  };
}
