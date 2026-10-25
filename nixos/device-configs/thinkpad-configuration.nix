# Configuration for my Thinkpad

{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./thinkpad-hardware-configuration.nix
      ./thinkpad-syncthing.nix
      
      ../desktop.nix
      ../remote-builder.nix
      ../flatpak.nix
      ../gnome.nix
      ../intel.nix
      ../musnix.nix
      ../ssh.nix
      ../steam.nix
      ../syncthing.nix
      ../systemd-boot.nix
      ../tailscale.nix
      ../workstation.nix
    ];


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
