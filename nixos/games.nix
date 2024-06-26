# Steam settings

{ config, pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  #hardware.opengl.driSupport32Bit = true; # Enables support for 32bit libs that steam uses

  environment.systemPackages = with pkgs; [
    heroic
    lutris
  ];
}