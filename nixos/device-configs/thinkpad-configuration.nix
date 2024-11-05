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
    ];

  #~Hostname~
  networking.hostName = "thinkpad";

  # Global patch -- using to fix blurry electron apps when using fractional scaling
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

}
