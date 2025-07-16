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

  #~Hostname~
  networking.hostName = "office";
}