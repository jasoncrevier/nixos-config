# Mount the NAS media share at /mnt/Media.
# Import as (import ../media-mount.nix { readOnly = false; }) to allow writes.
# Guests may only read media on tower, so writing logs in as tower's jason account
# (tower_smb_credentials in workstation-secrets.yaml: "username=jason" and "password=..." lines).

{
  readOnly ? true,
}:

{ config, lib, ... }:

{
  sops.secrets.tower_smb_credentials = lib.mkIf (!readOnly) {
    sopsFile = ../workstation-secrets.yaml;
  };

  fileSystems."/mnt/Media" = {
    device = "//192.168.3.101/media";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "uid=1000"
      "gid=100"
    ]
    ++ (
      if readOnly then
        [
          "guest"
          "ro"
        ]
      else
        [ "credentials=${config.sops.secrets.tower_smb_credentials.path}" ]
    );
  };

  # While tower reboots, a burst of accesses (Jellyfin retrying playback) fails the mount 5 times
  # in 10 s; systemd's default start limit then fails the automount for good, and /mnt/Media stays
  # an empty folder until someone runs `systemctl reset-failed`. Without the limit, each access
  # just tries again (failing within the 5 s timeout) until tower's share is back.
  systemd.units."mnt-Media.mount" = {
    overrideStrategy = "asDropin";
    text = ''
      [Unit]
      StartLimitIntervalSec=0
    '';
  };
}
