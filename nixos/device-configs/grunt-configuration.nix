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
 
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  
  #~Hostname~
  networking.hostName = "grunt";

  services.logind.settings.Login.HandleLidSwitch = "ignore"; # Disable sleep when laptop lid is closed  
}
