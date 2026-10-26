# Configuration for my Thinkpad

{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./thinkpad-hardware-configuration.nix
      
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


  # Better power management for Intel laptops
  services.thermald.enable = true;

  #~Hostname~
  networking.hostName = "thinkpad";

  environment = {
    systemPackages = with pkgs; [
      libinput
    ];
  };

  # The NixOS release this machine was first installed with. Don't change it
  # without reading the release notes: it controls how existing state is handled.
  system.stateVersion = "23.05";
}
