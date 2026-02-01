# Enable Navidrome

{ config, pkgs, ... }:

{
  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      MusicFolder = "/mnt/Media/Music";
    };
  };
}
