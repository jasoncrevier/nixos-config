# Enable Navidrome

{ config, pkgs, ... }:

{
  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      MusicFolder = "/mnt/Media/Music";
      BaseUrl = "https://navidrome.nullvoid.club";
      EnableSharing = true;
      Address = "0.0.0.0";
      Scanner.Schedule = "0 * * * *";
      Scanner.PurgeMissing = "always";
    };
  };
}
