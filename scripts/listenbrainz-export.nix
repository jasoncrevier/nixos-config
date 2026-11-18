# Nightly export of every ListenBrainz listen and loved/hated track into
# /var/lib/private/listenbrainz-export, which restic → B2 picks up at 03:00.
# Listens are merged into the existing file rather than replaced, so a wiped or
# broken ListenBrainz account can't empty the backup. Sits next to the Navidrome
# sync because it uses the same token; it doesn't need Navidrome itself.
{ config, pkgs, ... }:

let
  exportScript =
    pkgs.writers.writePython3Bin "listenbrainz-export"
      {
        libraries = [ pkgs.python3Packages.requests ];
        flakeIgnore = [ "E501" ];
      }
      ''
        import json
        import os
        import sys
        import time

        import requests

        API = "https://api.listenbrainz.org/1"
        TOKEN_FILE = os.path.join(os.environ["CREDENTIALS_DIRECTORY"], "token")
        OUT_DIR = os.environ["STATE_DIRECTORY"]
        LISTENS = os.path.join(OUT_DIR, "listens.jsonl")
        FEEDBACK = os.path.join(OUT_DIR, "feedback.json")
        PAGE = 1000


        def get(session, path, **params):
            """GET with retries; waits out ListenBrainz's rate limit."""
            for attempt in range(8):
                try:
                    res = session.get(f"{API}{path}", params=params, timeout=30)
                except requests.RequestException as e:
                    print(f"{path}: {e}, retrying", file=sys.stderr)
                    time.sleep(5 * (attempt + 1))
                    continue
                if res.status_code == 429 or res.status_code >= 500:
                    wait = int(res.headers.get("X-RateLimit-Reset-In", 5 * (attempt + 1)))
                    print(f"{path}: HTTP {res.status_code}, waiting {wait}s", file=sys.stderr)
                    time.sleep(wait + 1)
                    continue
                res.raise_for_status()
                if res.headers.get("X-RateLimit-Remaining") == "0":
                    time.sleep(int(res.headers.get("X-RateLimit-Reset-In", 1)) + 1)
                return res.json()
            sys.exit(f"{path}: giving up after repeated errors")


        def key(listen):
            return (listen["listened_at"], listen.get("recording_msid") or json.dumps(listen["track_metadata"], sort_keys=True))


        def fetch_listens(session, user):
            """Every listen, newest first, paging back with max_ts."""
            listens = {}
            max_ts = None
            while True:
                params = {"count": PAGE}
                if max_ts is not None:
                    # max_ts is exclusive; +1 so listens sharing the boundary second aren't skipped
                    params["max_ts"] = max_ts + 1
                page = get(session, f"/user/{user}/listens", **params)["payload"]["listens"]
                new = [li for li in page if key(li) not in listens]
                for li in new:
                    listens[key(li)] = li
                if not new:
                    return listens
                max_ts = min(li["listened_at"] for li in page)


        def fetch_feedback(session, user):
            feedback, offset = [], 0
            while True:
                page = get(session, f"/feedback/user/{user}/get-feedback", count=PAGE, offset=offset, metadata="true")
                feedback += page["feedback"]
                offset += len(page["feedback"])
                if not page["feedback"] or offset >= page["total_count"]:
                    return feedback


        def write_atomic(path, text):
            tmp = path + ".tmp"
            with open(tmp, "w") as f:
                f.write(text)
            os.replace(tmp, path)


        def main():
            with open(TOKEN_FILE) as f:
                token = f.read().strip()
            session = requests.Session()
            session.headers["Authorization"] = f"Token {token}"
            session.headers["User-Agent"] = "listenbrainz-export (personal backup)"

            check = get(session, "/validate-token")
            if not check.get("valid"):
                sys.exit("ListenBrainz says the token is not valid")
            user = check["user_name"]

            listens = {}
            if os.path.exists(LISTENS):
                with open(LISTENS) as f:
                    for line in f:
                        li = json.loads(line)
                        listens[key(li)] = li
            before = len(listens)

            fetched = fetch_listens(session, user)
            listens.update(fetched)
            ordered = sorted(listens.values(), key=lambda li: li["listened_at"])
            write_atomic(LISTENS, "".join(json.dumps(li, sort_keys=True) + "\n" for li in ordered))

            feedback = fetch_feedback(session, user)
            write_atomic(FEEDBACK, json.dumps(feedback, indent=1, sort_keys=True) + "\n")

            print(f"{user}: {len(fetched)} listens on ListenBrainz, {len(listens) - before} new, "
                  f"{len(listens)} in the export; {len(feedback)} feedback entries")


        if __name__ == "__main__":
            main()
      '';
in
{
  imports = [ ../nixos/backups.nix ];

  backups.paths = [ "/var/lib/private/listenbrainz-export" ];

  systemd.services.listenbrainz-export = {
    description = "Export ListenBrainz listens and feedback for the restic backup";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${exportScript}/bin/listenbrainz-export";
      DynamicUser = true;
      StateDirectory = "listenbrainz-export";
      LoadCredential = "token:${config.sops.secrets.listenbrainz_token.path}";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };

  # Before the 03:00 backup; Persistent catches up a night the server was off
  systemd.timers.listenbrainz-export = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "02:30";
      Persistent = true;
    };
  };
}
