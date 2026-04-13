# Configuration for my Thinkpad

{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./thinkpad-hardware-configuration.nix
      ./thinkpad-syncthing.nix
      
      ../common.nix
      ../flatpak.nix
      ../intel.nix
      ../musnix.nix
      ../plasma.nix
      ../ssh.nix
      ../steam.nix
      ../syncthing.nix
      ../tailscale.nix
      ../workstation.nix
    ];

  # Remote Build Configuration
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "nix-server";
        system = "x86_64-linux";
        sshUser = "jason";
        maxJobs = 8; # Adjust this based on your server's CPU threads
        speedFactor = 2;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      }
    ];
  };

  # Enable Wayland for SDDM
  services = {
    displayManager.sddm.wayland.enable = true;
  };

  # Realtime kernels often break suspend/resume on laptops and cause lag.
  # We keep musnix enabled for other optimizations but disable the RT kernel.
  musnix.kernel.realtime = lib.mkForce false;

  # Better power management for Intel laptops
  services.thermald.enable = true;

  #~Hostname~
  networking.hostName = "thinkpad";

  environment = {
    systemPackages = with pkgs; [
      libinput
    ];
  };
}
