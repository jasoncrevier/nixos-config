# Enable Navidrome

{ config, ... }:

{
  imports = [ ./backups.nix ];

  sops.secrets.navidrome_url.owner = "navidrome";

  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      MusicFolder = "/mnt/Media/Music";
      EnableSharing = true;
      Address = "0.0.0.0";
      Scanner.Schedule = "0 * * * *";
      Scanner.PurgeMissing = "always";
    };
  };

  systemd.services.navidrome.environment = {
    ND_PLUGINS_FOLDER = "/var/lib/navidrome/plugins";
  };

  systemd.services.navidrome.serviceConfig.EnvironmentFile = config.sops.secrets.navidrome_url.path;

  # Users, playlists, stars and play counts. The music itself is on the NAS.
  backups.paths = [ "/var/lib/navidrome" ];
  backups.exclude = [ "/var/lib/navidrome/cache" ];
}
