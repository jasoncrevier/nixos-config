# Configuration for the server: Grunt

{ config, pkgs, ... }:

{
  imports = [ 
    ./grunt-hardware-configuration.nix
    
    ../common.nix
    ../docker.nix
    ../ssh.nix
    ../tailscale.nix
  ];

  #~Hostname~
  networking.hostName = "grunt";
}
