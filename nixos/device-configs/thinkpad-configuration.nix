# Configuration for my Thinkpad

{ config, pkgs, ... }:

{
  imports =
    [
      ./thinkpad-hardware-configuration.nix
      
      ../common.nix
      ../flatpak.nix
      ../intel.nix
      ../musnix.nix
      ../plasma.nix
      ../ssh.nix
      ../steam.nix
      ../syncthing.nix
      ../tailscale.nix
      ../theme.nix
      ../workstation.nix
    ];

  # Enable Wayland for SDDM
  services = {
    displayManager.sddm.wayland.enable = true;
  };

  #~Hostname~
  networking.hostName = "thinkpad";
}
