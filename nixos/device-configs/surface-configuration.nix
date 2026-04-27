# Configuration for my Surface

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./surface-hardware-configuration.nix
      
      ../common.nix
      ../flatpak.nix
      ../intel.nix
      #../musnix.nix
      ../gnome.nix
      ../ssh.nix
      ../steam.nix
      ../systemd-boot.nix
      ../tailscale.nix
      ../workstation.nix
    ];

  #~Hostname~
  networking.hostName = "surface";

  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

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
