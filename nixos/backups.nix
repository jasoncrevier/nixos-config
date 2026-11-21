# Nightly restic backup to Backblaze B2 (S3 API). Service modules add their data with
# backups.paths; a host turns it on with backups.enable and points backups.sopsFile at a
# file only it (and you) can decrypt, so one host can't read another's backups.
#
# That sops file needs:
#   restic_repository  s3:https://s3.<region>.backblazeb2.com/<bucket>
#   restic_password    the repo password (also keep it in Bitwarden)
#   restic_b2_env      AWS_ACCESS_KEY_ID=<keyID> and AWS_SECRET_ACCESS_KEY=<applicationKey>,
#                      from a B2 application key limited to that one bucket and WITHOUT
#                      deleteFiles (listBuckets,listFiles,readFiles,writeFiles; the web console
#                      can't make one, use `b2 key create`)
#   restic_heartbeat_url  only with backups.heartbeat: the Uptime Kuma push URL
#                      (https://<kuma>/api/push/<token>?status=up&msg=OK)
#
# Failed runs alert through failure-alerts.nix. A run that never happens (timer gone, box
# off) can't alert itself, so with backups.heartbeat each fully successful run (backup,
# prune, check) pings a Kuma push monitor, and Kuma alerts when the pings stop.
#
# Ransomware: without deleteFiles, every delete restic makes (lock removal, forget, prune) only
# hides the file in B2, so a compromised host can't destroy its own repo. The bucket's lifecycle
# rule "Keep prior versions for 30 days" removes hidden versions after 30 days. That rule is what
# frees pruned space, and it's also the window for rolling the bucket back to a point before an
# attack: on a workstation, `restic-b2-rollback <bucket> <time before the attack>` with a
# temporary key that has deleteFiles (dry run first, then --apply).
#
# On the 1st of each month restic-check-b2 also reads back 5% of the repo's data, which
# the nightly `restic check` doesn't (that one only checks the repo's structure).
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

  # The URL goes to curl on stdin, so the push token never shows up in the process list
  heartbeat = pkgs.writeShellApplication {
    name = "restic-heartbeat";
    runtimeInputs = [ pkgs.curl ];
    text = ''
      url=$(cat "${config.sops.secrets.restic_heartbeat_url.path}")
      printf 'url = "%s"\n' "$url" \
        | curl --fail --silent --show-error --retry 3 --max-time 30 --output /dev/null --config -
    '';
  };

  restic = config.services.restic.backups.b2;
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

    heartbeat = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Ping the Uptime Kuma push URL in restic_heartbeat_url (in sopsFile) after each successful run, so Kuma notices runs that stop happening.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = lib.genAttrs (
      [
        "restic_repository"
        "restic_password"
        "restic_b2_env"
      ]
      ++ lib.optional cfg.heartbeat "restic_heartbeat_url"
    ) (_: { inherit (cfg) sopsFile; });

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

    # Runs only when every ExecStart step succeeded. The leading "-" keeps a Kuma outage
    # from marking the backup itself as failed.
    systemd.services.restic-backups-b2.serviceConfig.ExecStartPost = lib.mkIf cfg.heartbeat [
      "-${heartbeat}/bin/restic-heartbeat"
    ];

    # Monthly read-back of 5% of the pack files, picked at random, so over time a damaged
    # upload or a bucket problem shows up before a restore needs it
    systemd.services.restic-check-b2 = {
      description = "Read back a sample of the restic repo's data";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      environment = {
        RESTIC_REPOSITORY_FILE = restic.repositoryFile;
        RESTIC_PASSWORD_FILE = restic.passwordFile;
        RESTIC_CACHE_DIR = "/var/cache/restic-backups-b2";
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe restic.package} check --read-data-subset=5%";
        EnvironmentFile = restic.environmentFile;
        CacheDirectory = "restic-backups-b2";
        CacheDirectoryMode = "0700";
        PrivateTmp = true;
        Nice = 10;
        IOSchedulingClass = "idle";
      };
    };
    # Midday on the 1st: clear of the 03:00 backup and nix-server's 04:00 fleet-prebuild
    systemd.timers.restic-check-b2 = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-01 13:00";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
    };

    failureAlerts.services = [
      "restic-backups-b2"
      "restic-check-b2"
    ];
  };
}
