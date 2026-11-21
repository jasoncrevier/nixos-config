# Daily check that no restic repo on B2 has suddenly lost snapshots (scripts/backup-watch.py).
# The no-delete keys in backups.nix stop a compromised host from destroying its repo, but not
# from running restic's own `forget --prune`, which leaves a consistent repo that passes
# `restic check`. This lists every repo's snapshots/ with a list-only key and pings an Uptime
# Kuma push monitor: down with the repo's name when snapshots vanish, so there's time to roll
# the bucket back (restic-b2-rollback) inside the 30-day window.
#
# server-secrets.yaml needs (bucket names stay out of this public repo):
#   backup_watch_repos     one repo per line: <label> <bucket>[/<prefix>] [<floor>]
#   backup_watch_b2_env    AWS_ACCESS_KEY_ID=<keyID> and AWS_SECRET_ACCESS_KEY=<applicationKey>
#                          from a B2 key with only listBuckets,listFiles on those buckets
#   backup_watch_push_url  the Kuma push URL (https://<kuma>/api/push/<token>?status=up&msg=OK)
#
# Run by hand:   sudo systemctl start backup-watch; journalctl -u backup-watch
# After a real, deliberate drop (e.g. a retention change), take it as the new baseline:
#   sudo backup-watch --accept <label>

{ config, pkgs, ... }:

let
  sopsFile = ../server-secrets.yaml;
  secrets = config.sops.secrets;

  backup-watch = pkgs.writers.writePython3Bin "backup-watch" {
    libraries = [ pkgs.python3Packages.boto3 ];
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ../scripts/backup-watch.py);

  env = {
    BACKUP_WATCH_REPOS = secrets.backup_watch_repos.path;
    BACKUP_WATCH_PUSH_URL_FILE = secrets.backup_watch_push_url.path;
    BACKUP_WATCH_STATE = "/var/lib/backup-watch/state.json";
  };

  # For --accept and test runs from a shell: the same secrets and state as the service
  wrapper = pkgs.writeShellApplication {
    name = "backup-watch";
    text = ''
      set -a
      # shellcheck source=/dev/null
      . ${secrets.backup_watch_b2_env.path}
      set +a
      ${builtins.concatStringsSep "\n" (
        map (n: "export ${n}=${env.${n}}") (builtins.attrNames env)
      )}
      exec ${backup-watch}/bin/backup-watch "$@"
    '';
  };
in
{
  sops.secrets = {
    backup_watch_repos = { inherit sopsFile; };
    backup_watch_b2_env = { inherit sopsFile; };
    backup_watch_push_url = { inherit sopsFile; };
  };

  environment.systemPackages = [ wrapper ];

  systemd.services.backup-watch = {
    description = "Alert when a restic repo on B2 loses snapshots";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    environment = env;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${backup-watch}/bin/backup-watch";
      EnvironmentFile = secrets.backup_watch_b2_env.path;
      StateDirectory = "backup-watch";
      StateDirectoryMode = "0700";
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
    };
  };

  # After the backup window (03:00 to about 05:30 across the hosts, prunes included)
  systemd.timers.backup-watch = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "07:00";
      RandomizedDelaySec = "15m";
      Persistent = true;
    };
  };
}
