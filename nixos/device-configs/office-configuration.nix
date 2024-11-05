# Configuration for my office workstation

{ config, pkgs, ... }:

{
  imports =
    [
      ./office-hardware-configuration.nix

      ../common.nix
      ../flatpak.nix
      ../musnix.nix
      ../plasma.nix
      ../ssh.nix
      ../steam.nix
      ../syncthing.nix
      ../tailscale.nix
    ];

  #~Hostname~
  networking.hostName = "office";
}