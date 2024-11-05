# Configuration for my home server

{ config, pkgs, ... }:

{
  imports = [ 
    ./server-hardware-configuration.nix

    ../common.nix
    ../ssh.nix
    ../tailscale.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  #~Hostname~
  networking.hostName = "nixos-server";
}