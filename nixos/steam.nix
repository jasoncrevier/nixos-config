# Enable Steam and open remote play ports

{ lib, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = lib.mkDefault true; # Open ports in the firewall for Steam Remote Play
  };
}
