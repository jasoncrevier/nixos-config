"""Roll a B2 bucket (or one prefix of it) back to how it was at a given time.

The backup hosts' B2 keys have no deleteFiles, so anything restic or an attacker "deletes"
there is only hidden (a hide marker on top), and an overwrite only adds a newer version. The
bucket keeps hidden and older versions for 30 days (lifecycle rule). Deleting every version and
hide marker newer than the cutoff therefore puts each file back exactly as it was: hidden files
reappear, overwritten ones get their old content back, files added since disappear.

    restic-b2-rollback <bucket> <cutoff> [--prefix repo/] [--apply]

The cutoff is ISO 8601 (2026-11-21T19:48:00Z, or local time without a zone). Without --apply
it only shows what it would remove. It asks for a key that has deleteFiles (make a temporary
bucket-scoped one from the master key and delete it afterwards). Nothing secret is printed.
Afterwards: restic unlock, then restic check --read-data, before restoring anything.
"""

import argparse
import getpass
import sys
from collections import Counter
from datetime import datetime, timezone

import boto3


def parse_cutoff(text):
    t = datetime.fromisoformat(text.replace("Z", "+00:00"))
    if t.tzinfo is None:
        t = t.astimezone()  # local time
    return t.astimezone(timezone.utc)


def folder(key, prefix):
    rest = key[len(prefix):]
    return rest.split("/", 1)[0] if "/" in rest else rest


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("bucket")
    ap.add_argument("cutoff", help="ISO 8601; without a zone it's local time")
    ap.add_argument("--prefix", default="", help="only this repo inside a shared bucket, e.g. host1/")
    ap.add_argument("--endpoint", default="https://s3.us-west-004.backblazeb2.com")
    ap.add_argument("--apply", action="store_true", help="really delete (default: dry run)")
    args = ap.parse_args()

    cutoff = parse_cutoff(args.cutoff)
    print(f"Bucket {args.bucket}{' prefix ' + args.prefix if args.prefix else ''}, "
          f"rolling back to {cutoff.isoformat()} (UTC)")

    key_id = input("B2 key ID (needs deleteFiles): ").strip()
    key = getpass.getpass("B2 application key (not shown): ").strip()
    region = args.endpoint.split("//", 1)[-1].split(".")[1]
    s3 = boto3.client("s3", endpoint_url=args.endpoint, region_name=region,
                      aws_access_key_id=key_id, aws_secret_access_key=key)
    del key

    doomed = []
    markers, versions, sizes = Counter(), Counter(), Counter()
    pages = s3.get_paginator("list_object_versions").paginate(Bucket=args.bucket, Prefix=args.prefix)
    for page in pages:
        for m in page.get("DeleteMarkers", []):
            if m["LastModified"] > cutoff:
                doomed.append({"Key": m["Key"], "VersionId": m["VersionId"]})
                markers[folder(m["Key"], args.prefix)] += 1
        for v in page.get("Versions", []):
            if v["LastModified"] > cutoff:
                doomed.append({"Key": v["Key"], "VersionId": v["VersionId"]})
                f = folder(v["Key"], args.prefix)
                versions[f] += 1
                sizes[f] += v.get("Size", 0)

    if not doomed:
        print("Nothing newer than the cutoff: the bucket already looks as it did then.")
        return 0
    print("Would remove (everything created after the cutoff):")
    for f in sorted(set(markers) | set(versions)):
        print(f"  {f + '/':12} {markers[f]:6} hide markers  {versions[f]:6} newer versions "
              f"({sizes[f] / 1048576:.1f} MiB)")
    if not args.apply:
        print("Dry run. Run again with --apply to remove them.")
        return 0
    if input(f"Remove these {len(doomed)} versions and markers for good? Type yes: ").strip() != "yes":
        print("Nothing removed.")
        return 1

    failed = 0
    for i in range(0, len(doomed), 1000):
        res = s3.delete_objects(Bucket=args.bucket, Delete={"Objects": doomed[i:i + 1000], "Quiet": True})
        for err in res.get("Errors", []):
            failed += 1
            print(f"  failed: {err['Key']} ({err.get('Code')}: {err.get('Message')})", file=sys.stderr)
    print(f"Removed {len(doomed) - failed} of {len(doomed)}.")
    print("Next: restic unlock, then restic check --read-data, then restore. "
          "Delete the temporary key afterwards.")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
