# Configuration for my home server

{ config, pkgs, ... }:

{
  imports = [ 
    ./server-hardware-configuration.nix

    ../common.nix
    ../nvidia.nix
    ../plasma.nix
    ../ssh.nix
    ../steam.nix
    ../sunshine.nix
    ../tailscale.nix
  ];

  #~Hostname~
  networking.hostName = "nixos-server";
}