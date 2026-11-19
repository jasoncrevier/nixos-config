# `bw-backup`: a password-protected export of the Bitwarden vault, copied to tower.
# Run it by hand (nix-server sends a monthly ntfy reminder, scripts/bitwarden-backup-reminder.nix).
# It stores nothing: it asks for the master password (and 2FA on first login) and for an
# export password every run. The export is written to $XDG_RUNTIME_DIR (RAM), copied to
# tower's backups share, where tower's restic → B2 job picks it up, and then deleted here.
#
# 'Password protected', not 'account restricted': it imports into any Bitwarden account,
# which matters when the account itself is what's lost. Keep the export password
# somewhere physical, not only in Bitwarden. Exports skip file attachments and Sends;
# the script warns if any item has attachments.
{ pkgs, ... }:

let
  bwBackup = pkgs.writeShellApplication {
    name = "bw-backup";
    # The ssh commands are built locally on purpose (paths and counts expand before sending)
    excludeShellChecks = [ "SC2029" ];
    runtimeInputs = [
      pkgs.bitwarden-cli
      pkgs.jq
      pkgs.openssh
      pkgs.coreutils
    ];
    text = ''
      DEST_HOST=root@tower
      DEST_DIR=/mnt/user/backups/bitwarden
      KEEP=12

      TMP=$(mktemp -d "''${XDG_RUNTIME_DIR:-/tmp}/bw-backup.XXXXXX")
      chmod 700 "$TMP"
      cleanup() {
        rm -rf "$TMP"
        bw lock >/dev/null 2>&1 || true
        unset BW_SESSION
      }
      trap cleanup EXIT

      echo "== Checking tower is reachable"
      ssh -o ConnectTimeout=10 "$DEST_HOST" "install -d -m 700 -o root -g root '$DEST_DIR'" \
        || { echo "Can't reach $DEST_HOST; nothing exported" >&2; exit 1; }

      echo "== Unlocking the vault"
      case "$(bw status | jq -r .status)" in
        unauthenticated) BW_SESSION=$(bw login --raw) ;;
        *) BW_SESSION=$(bw unlock --raw) ;;
      esac
      [ -n "$BW_SESSION" ] || { echo "Unlock failed" >&2; exit 1; }
      export BW_SESSION
      bw sync >/dev/null

      vault=$(bw list items)
      items=$(jq length <<< "$vault")
      with_attachments=$(jq '[.[] | select((.attachments // []) | length > 0)] | length' <<< "$vault")
      echo "$items items in your vault"
      if [ "$with_attachments" -gt 0 ]; then
        echo "WARNING: $with_attachments item(s) have file attachments, which exports don't include:"
        jq -r '.[] | select((.attachments // []) | length > 0) | "  - " + .name' <<< "$vault"
        echo "Save those files somewhere else by hand."
      fi

      echo
      echo "== Export password (NOT your master password; the one you keep written down)"
      while true; do
        read -rsp "Export password: " pw1; echo
        read -rsp "Again: " pw2; echo
        if [ "$pw1" != "$pw2" ]; then echo "They don't match, try again"; continue; fi
        if [ "''${#pw1}" -lt 12 ]; then echo "Use at least 12 characters"; continue; fi
        break
      done
      unset pw2 vault

      stamp=$(date +%Y-%m-%d)
      files=()
      out="$TMP/bitwarden-$stamp.json"
      bw export --format encrypted_json --password "$pw1" --output "$out" >/dev/null
      files+=("$out")

      # Organization vaults export separately
      while IFS=$'\t' read -r org_id org_name; do
        [ -n "$org_id" ] || continue
        o="$TMP/bitwarden-$stamp-org-$(echo "$org_name" | tr -c 'A-Za-z0-9\n' '-').json"
        bw export --organizationid "$org_id" --format encrypted_json --password "$pw1" --output "$o" >/dev/null
        files+=("$o")
      done < <(bw list organizations | jq -r '.[] | [.id, .name] | @tsv')
      unset pw1

      for f in "''${files[@]}"; do
        if ! jq -e '.encrypted == true and .passwordProtected == true and (.data | length > 0)' "$f" >/dev/null; then
          echo "$(basename "$f") isn't a password-protected export; not copying anything" >&2
          exit 1
        fi
      done

      echo "== Copying to $DEST_HOST:$DEST_DIR"
      for f in "''${files[@]}"; do
        name=$(basename "$f")
        sum=$(sha256sum "$f" | cut -d' ' -f1)
        ssh "$DEST_HOST" "umask 077; cat > '$DEST_DIR/$name.tmp' && mv '$DEST_DIR/$name.tmp' '$DEST_DIR/$name'" < "$f"
        remote=$(ssh "$DEST_HOST" "sha256sum '$DEST_DIR/$name'" | cut -d' ' -f1)
        [ "$sum" = "$remote" ] || { echo "Checksum mismatch for $name on tower" >&2; exit 1; }
        echo "  $name ($(du -h "$f" | cut -f1)), checksum verified"
      done

      # Keep the newest $KEEP exports of the personal vault (and the same dates' org exports)
      ssh "$DEST_HOST" "cd '$DEST_DIR' && ls -1 bitwarden-????-??-??.json | sort -r | tail -n +$((KEEP + 1)) | while read -r f; do rm -f \"\$f\" \"\''${f%.json}\"-org-*.json; done; ls -l"

      echo
      echo "Done. tower's nightly restic run (05:30) takes it off-site."
    '';
  };
in
{
  environment.systemPackages = [ bwBackup ];
}
