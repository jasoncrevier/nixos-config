# Configuration for my Thinkpad

{ config, pkgs, ... }:

{
  imports =
    [
      ./thinkpad-hardware-configuration.nix
      
      ../common.nix
      ../gnome.nix
      ../musnix.nix
      ../ssh.nix
      ../steam.nix
      ../syncthing.nix
      ../tailscale.nix
      ../theme.nix
    ];

  #~Hostname~
  networking.hostName = "thinkpad";
}
