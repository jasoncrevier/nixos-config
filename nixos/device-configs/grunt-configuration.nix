# Configuration for the server: Grunt

{ config, pkgs, lib, ... }:

{
  imports = [ 
    ./grunt-hardware-configuration.nix
    
    ../common.nix
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
    allowedTCPPorts = [ 80 ];
  };
  
  services.xserver.enable = lib.mkForce false;
  services.logind.settings.Login.HandleLidSwitch = "ignore"; # Disable sleep when laptop lid is closed

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "nix-server";
        system = "x86_64-linux";
        sshUser = "jason";
        maxJobs = 8;
        speedFactor = 2;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      }
    ];
  };
}
