# Configuration for my Surface

{ config, pkgs, ... }:

{
  imports =
    [
      ./surface-hardware-configuration.nix
      
      ../common.nix
      ../flatpak.nix
      ../intel.nix
      ../musnix.nix
      ../gnome.nix
      ../ssh.nix
      ../steam.nix
      ../tailscale.nix
      ../workstation.nix
    ];

  #~Hostname~
  networking.hostName = "surface";
}
