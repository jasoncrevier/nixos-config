# Configuration for the server: Grunt

{ config, pkgs, lib, ... }:

{
  imports = [ 
    ./grunt-hardware-configuration.nix
    
    ../base.nix
    ../remote-builder.nix
    ../kosync.nix
    ../sops.nix
    ../ssh.nix
    ../tailscale.nix
    ../wallabag.nix
  ];
 
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  
  #~Hostname~
  networking.hostName = "grunt";

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
  };
  
  services.logind.settings.Login.HandleLidSwitch = "ignore"; # Disable sleep when laptop lid is closed

}
