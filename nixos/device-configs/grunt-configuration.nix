# Configuration for the server: Grunt

{ config, pkgs, lib, ... }:

{
  imports = [ 
    ./grunt-hardware-configuration.nix
    (import ../media-mount.nix {})
    
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
  boot.loader.grub.configurationLimit = 10; # Keep /boot from filling up
  
  #~Hostname~
  networking.hostName = "grunt";

  networking.firewall.checkReversePath = "loose";
  
  services.logind.settings.Login.HandleLidSwitch = "ignore"; # Disable sleep when laptop lid is closed

  # The NixOS release this machine was first installed with. Don't change it
  # without reading the release notes: it controls how existing state is handled.
  system.stateVersion = "23.05";
}
