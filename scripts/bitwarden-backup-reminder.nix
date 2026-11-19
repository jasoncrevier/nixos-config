# Monthly ntfy reminder to run `bw-backup` on a workstation (nixos/bitwarden-backup.nix).
# The export needs the master password, so it can't run unattended; this is the nudge.
{ config, pkgs, ... }:

let
  reminder = pkgs.writeShellApplication {
    name = "bitwarden-backup-reminder";
    runtimeInputs = [
      pkgs.curl
    ];
    text = ''
      TOKEN=$(cat "${config.sops.secrets.ntfy_token.path}")
      URL=$(cat "${config.sops.secrets.ntfy_url.path}")

      curl --fail --silent --show-error -o /dev/null \
        -H "Authorization: Bearer $TOKEN" \
        -H "Title: Bitwarden: monthly vault backup" \
        -H "Tags: key" \
        -d "Run bw-backup on office, thinkpad or surface. It saves a password-protected export to tower (backups/bitwarden), which goes off-site with tower's restic run." \
        "$URL/misc"
    '';
  };
in
{
  systemd.services.bitwarden-backup-reminder = {
    description = "Monthly reminder to back up the Bitwarden vault";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${reminder}/bin/bitwarden-backup-reminder";
    };
  };

  systemd.timers.bitwarden-backup-reminder = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # First Saturday of the month, mid-morning
      OnCalendar = "Sat *-*-01..07 10:00";
      Persistent = true;
    };
  };
}
