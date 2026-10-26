# Configuration for my Surface

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./surface-hardware-configuration.nix
      
      ../desktop.nix
      ../remote-builder.nix
      ../flatpak.nix
      ../intel.nix
      #../musnix.nix
      ../gnome.nix
      ../ssh.nix
      ../steam.nix
      ../systemd-boot.nix
      ../tailscale.nix
      ../workstation.nix
    ];

  #~Hostname~
  networking.hostName = "surface";

  zramSwap.enable = true;

}
