# Enable Navidrome

{ config, pkgs, ... }:

{
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

  systemd.services.navidrome.serviceConfig.EnvironmentFile = config.sops.secrets.navidrome_url.path;
}
