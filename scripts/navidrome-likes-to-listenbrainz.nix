{ config, pkgs, ... }:

let
  tokenFile = config.sops.secrets.listenbrainz_token.path;
  dbPath = "/var/lib/navidrome/navidrome.db";

  navidromeSyncScript = pkgs.writers.writePython3Bin "navidrome-to-listenbrainz" {
    libraries = [ pkgs.python3Packages.requests ];
  } ''
    import sqlite3
    import requests
    import time
    import os
    from datetime import datetime, timedelta

    # --------------------------------------------------
    # CONFIG
    # --------------------------------------------------
    DB_PATH = "${dbPath}"
    TOKEN_FILE = "${tokenFile}"
    LOOKBACK_MINUTES = 35
    FEEDBACK_URL = "https://api.listenbrainz.org/1/feedback/recording-feedback"
    REQUEST_DELAY = 0.25
    MAX_RETRIES = 6
    RETRY_DELAY = 1.5


    def query_loved_tracks(db_path, start_date, end_date):
        """Query starred tracks from Navidrome."""
        conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
        cursor = conn.cursor()

        query = """
        SELECT
            mf.mbz_recording_id, mf.artist, mf.title, mf.album, a.starred_at
        FROM media_file mf
        JOIN annotation a ON a.item_id = mf.id
        WHERE a.starred = TRUE
          AND (
                (a.starred_at IS NOT NULL AND a.starred_at BETWEEN ? AND ?)
                OR a.starred_at IS NULL
              )
        ORDER BY mf.artist, mf.title
        """

        cursor.execute(query, (start_date, end_date))
        rows = cursor.fetchall()
        conn.close()
        return rows


    def submit_loved_tracks(rows, token):
        """Submit feedback to ListenBrainz."""
        headers = {
            "Authorization": f"Token {token}",
            "Content-Type": "application/json"
        }

        loved, skipped, failed = 0, 0, 0

        for mbid, artist, title, album, starred_at in rows:
            if not mbid or not mbid.strip():
                skipped += 1
                print(f"⏭ Skipped (no MBID): {artist} – {title}")
                continue

            payload = {"recording_mbid": mbid, "score": 1}

            for attempt in range(1, MAX_RETRIES + 1):
                try:
                    res = requests.post(
                        FEEDBACK_URL, headers=headers, json=payload, timeout=10
                    )

                    if res.status_code == 200:
                        loved += 1
                        print(f"❤️ Loved: {artist} – {title}")
                        break
                    else:
                        failed += 1
                        print(f"❌ Failed: {artist} | Status: {res.status_code}")
                        break
                except Exception as e:
                    if attempt < MAX_RETRIES:
                        time.sleep(RETRY_DELAY)
                    else:
                        failed += 1
                        print(f"❌ Error: {artist} | {e}")

            time.sleep(REQUEST_DELAY)

        print("\n---------------- SUMMARY ----------------")
        print(f"❤️ Loved: {loved} | ⏭ Skipped: {skipped} | ❌ Failed: {failed}")


    def main():
        """Main execution loop."""
        if not os.path.exists(TOKEN_FILE):
            print(f"Error: Secret file not found at {TOKEN_FILE}")
            return

        with open(TOKEN_FILE, 'r') as f:
            token = f.read().strip()

        # Using local time to match Navidrome's DB storage
        now = datetime.now()
        start_dt = now - timedelta(minutes=LOOKBACK_MINUTES)
        end_dt = now + timedelta(minutes=5)

        start_str = start_dt.strftime('%Y-%m-%d %H:%M:%S')
        end_str = end_dt.strftime('%Y-%m-%d %H:%M:%S')

        if not os.path.exists(DB_PATH):
            print(f"Error: Database not found at {DB_PATH}")
            return

        print(f"Checking for stars between {start_str} and {end_str}...")
        rows = query_loved_tracks(DB_PATH, start_str, end_str)
        print(f"Found {len(rows)} starred tracks.")

        if rows:
            submit_loved_tracks(rows, token)


    if __name__ == "__main__":
        main()
  '';
in
{
  sops.secrets.listenbrainz_token.owner = "navidrome";

  environment.systemPackages = [ navidromeSyncScript ];

  systemd.services.navidrome-listenbrainz-sync = {
    description = "Sync Navidrome Stars to ListenBrainz";
    after = [ "network-online.target" "navidrome.service" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "navidrome";
      ExecStart = "${navidromeSyncScript}/bin/navidrome-to-listenbrainz";
    };
  };

  systemd.timers.navidrome-listenbrainz-sync = {
    description = "Run Navidrome to ListenBrainz sync every 30 mins";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "30min";
      Persistent = true;
    };
  };
}