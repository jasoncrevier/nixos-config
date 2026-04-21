# Enable Navidrome

{ config, pkgs, ... }:

{
  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      MusicFolder = "/mnt/Media/Music";
      BaseUrl = config.sops.secrets.navidrome_url.path;
      EnableSharing = true;
      Address = "0.0.0.0";
      Scanner.Schedule = "0 * * * *";
      Scanner.PurgeMissing = "always";
    };
  };
}
