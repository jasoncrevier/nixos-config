# Configuration for my office workstation

{ config, pkgs, ... }:

{
  imports =
    [
      ./office-hardware-configuration.nix

      ../amd.nix
      ../audio.nix
      ../common.nix
      ../flatpak.nix
      ../musnix.nix
      ../plasma.nix
      ../ssh.nix
      ../steam.nix
      ../sunshine.nix
      ../syncthing.nix
      ../tailscale.nix
      ../theme.nix
      ../workstation.nix
    ];

  # Enable Wayland for SDDM
  services.displayManager.sddm.wayland.enable = true;

  #~Hostname~
  networking.hostName = "office";
}