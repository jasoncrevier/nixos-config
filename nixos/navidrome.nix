# Enable Navidrome

{ config, pkgs, ... }:

let
  navidrome_url = config.sops.secrets.navidrome_url.path;
in
{
  sops.secrets.navidrome_url.owner = "navidrome";
  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      MusicFolder = "/mnt/Media/Music";
      BaseUrl = navidrome_url;
      EnableSharing = true;
      Address = "0.0.0.0";
      Scanner.Schedule = "0 * * * *";
      Scanner.PurgeMissing = "always";
    };
  };
}
