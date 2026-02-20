# Enable Navidrome

{ config, pkgs, ... }:

{
  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      MusicFolder = "/mnt/Media/Music";
      Address = "0.0.0.0";
      Port = 4533;
      Scanner.Schedule = "0 * * * *";
      Sannder.PurgeMissing = "always";
    };
  };
}
