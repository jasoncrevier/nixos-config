{ ... }:

{
  imports = [ ./backups.nix ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  # Users, watch history and settings. Metadata and images are fetched again on a rescan.
  backups.paths = [ "/var/lib/jellyfin" ];
  backups.exclude = [
    "/var/lib/jellyfin/metadata"
    "/var/lib/jellyfin/transcodes"
  ];
}
