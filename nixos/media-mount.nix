# Mount the NAS media share at /mnt/Media.
# Import as (import ../media-mount.nix { readOnly = false; }) to allow writes.

{
  readOnly ? true,
}:

{ lib, ... }:

{
  fileSystems."/mnt/Media" = {
    device = "//192.168.3.101/media";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "guest"
      "uid=1000"
      "gid=100"
    ]
    ++ lib.optional readOnly "ro";
  };
}
