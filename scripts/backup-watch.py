"""Daily check that no restic repo on B2 has suddenly lost snapshots.

The backup hosts' B2 keys can't delete, but an attacker on a host can still run restic's own
`forget --prune`: the snapshot files are only hidden (and come back with restic-b2-rollback
within 30 days), the repo stays consistent, and the nightly `restic check` passes. This catches
that by listing each repo's live snapshots/ files with a list-only key (no repo password).

A repo alerts when, compared with the last good run:
  - its snapshot count dropped by more than MAX_DROP,
  - its oldest snapshot (B2 upload time) jumped forward by more than MAX_OLDEST_JUMP_DAYS:
    normal pruning moves it by about a month at most, so wiping old history trips this even if
    fresh snapshots pad the count,
  - or its count is below the repo's floor (or zero).
A repo that alerts keeps its old baseline, so it alerts again every day until accepted with
`backup-watch --accept <label>` (after checking, e.g. a deliberate retention change).

Each run pings the Uptime Kuma push URL: up with a summary, or down naming the repos. A run that
never happens shows up as missing pings.

    backup-watch [--accept LABEL ...] [--no-push]

Repos file, one per line (# comments allowed):  <label> <bucket>[/<prefix>] [<floor>]
Credentials come from AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY. Nothing secret is printed.
"""

import argparse
import json
import os
import sys
import urllib.parse
import urllib.request
from datetime import datetime, timedelta, timezone

import boto3

MAX_DROP = 2
MAX_OLDEST_JUMP_DAYS = 32
ENDPOINT = "https://s3.us-west-004.backblazeb2.com"
REGION = "us-west-004"


def read_repos(path):
    repos = []
    with open(path) as f:
        for line in f:
            line = line.split("#", 1)[0].strip()
            if not line:
                continue
            parts = line.split()
            label, loc = parts[0], parts[1]
            floor = int(parts[2]) if len(parts) > 2 else 1
            bucket, _, prefix = loc.partition("/")
            if prefix and not prefix.endswith("/"):
                prefix += "/"
            repos.append({"label": label, "bucket": bucket, "prefix": prefix, "floor": floor})
    return repos


def snapshots(s3, bucket, prefix):
    """Count of live snapshot files and the oldest one's upload time (hidden files aren't listed)."""
    count, oldest = 0, None
    pages = s3.get_paginator("list_objects_v2").paginate(Bucket=bucket, Prefix=prefix + "snapshots/")
    for page in pages:
        for obj in page.get("Contents", []):
            count += 1
            if oldest is None or obj["LastModified"] < oldest:
                oldest = obj["LastModified"]
    return count, oldest


def push(url, status, msg):
    # Drop the ?status=up&msg=OK the stored URL carries and send our own
    base = url.split("?", 1)[0]
    query = urllib.parse.urlencode({"status": status, "msg": msg[:250], "ping": ""})
    for attempt in range(3):
        try:
            with urllib.request.urlopen(f"{base}?{query}", timeout=30) as r:
                r.read()
            return True
        except OSError as e:
            err = e
    print(f"Kuma push failed: {type(err).__name__}", file=sys.stderr)
    return False


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--repos", default=os.environ.get("BACKUP_WATCH_REPOS"), help="repos file")
    ap.add_argument("--state", default=os.environ.get("BACKUP_WATCH_STATE", "/var/lib/backup-watch/state.json"))
    ap.add_argument("--push-url-file", default=os.environ.get("BACKUP_WATCH_PUSH_URL_FILE"))
    ap.add_argument("--accept", action="append", default=[], metavar="LABEL",
                    help="take this repo's current count and oldest snapshot as its new baseline")
    ap.add_argument("--no-push", action="store_true", help="don't ping Kuma (for test runs)")
    args = ap.parse_args()

    repos = read_repos(args.repos)
    unknown = set(args.accept) - {r["label"] for r in repos}
    if unknown:
        sys.exit(f"--accept: no repo called {', '.join(sorted(unknown))}")

    try:
        with open(args.state) as f:
            state = json.load(f)
    except FileNotFoundError:
        state = {}

    s3 = boto3.client("s3", endpoint_url=ENDPOINT, region_name=REGION)
    now = datetime.now(timezone.utc)
    problems, lines = [], []

    for r in repos:
        label = r["label"]
        try:
            count, oldest = snapshots(s3, r["bucket"], r["prefix"])
        except Exception as e:  # one unreadable repo mustn't hide the others
            problems.append(f"{label}: listing failed ({type(e).__name__})")
            lines.append(f"{label:<20} listing failed: {e}")
            continue

        prev = state.get(label)
        bad = []
        if count == 0:
            bad.append("no snapshots")
        elif count < r["floor"]:
            bad.append(f"{count} snapshots, below floor {r['floor']}")
        if prev and label not in args.accept:
            if prev["count"] - count > MAX_DROP:
                bad.append(f"{prev['count']} -> {count} snapshots")
            if oldest and prev.get("oldest"):
                jump = oldest - datetime.fromisoformat(prev["oldest"])
                if jump > timedelta(days=MAX_OLDEST_JUMP_DAYS):
                    bad.append(f"oldest snapshot {jump.days} days newer")

        oldest_txt = oldest.strftime("%Y-%m-%d") if oldest else "-"
        was = f"(was {prev['count']}, oldest {prev['oldest'][:10]})" if prev else "(new baseline)"
        alert = f"  ALERT: {'; '.join(bad)}" if bad else ""
        lines.append(f"{label:<20} {count:>4} snapshots, oldest {oldest_txt} {was}{alert}")
        if bad:
            problems.append(f"{label}: {'; '.join(bad)}")
        else:
            # Only a good result becomes the baseline, so an alert repeats until accepted
            state[label] = {"count": count, "oldest": oldest.isoformat() if oldest else None,
                            "checked": now.isoformat(timespec="seconds")}

    print("\n".join(lines))

    os.makedirs(os.path.dirname(args.state), exist_ok=True)
    tmp = args.state + ".tmp"
    with open(tmp, "w") as f:
        json.dump(state, f, indent=1, sort_keys=True)
    os.replace(tmp, args.state)

    if problems:
        msg = "Snapshots lost? " + " | ".join(problems)
    else:
        msg = f"OK: {len(repos)} repos, {sum(state[r['label']]['count'] for r in repos)} snapshots"
    print(msg)

    if not args.no_push:
        with open(args.push_url_file) as f:
            url = f.read().strip()
        push(url, "down" if problems else "up", msg)

    sys.exit(1 if problems else 0)


if __name__ == "__main__":
    main()
