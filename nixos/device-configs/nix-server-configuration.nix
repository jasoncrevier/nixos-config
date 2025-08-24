# Configuration for my home server

{ config, pkgs, ... }:

{
  imports = [ 
    ./nix-server-hardware-configuration.nix

    ../nvidia.nix
    ../common.nix
    ../plasma.nix
    ../ssh.nix
    ../steam.nix
    ../sunshine.nix
    ../tailscale.nix
  ];

  # Autologin
  services.displayManager.autoLogin = {
    enable = true;
    user = "jason";
  };

  # Disable Wayland for SDDM
  services = {
    displayManager.sddm.wayland.enable = false;
  };

  # Use X11 instead of Wayland
  services.displayManager.defaultSession = "plasmax11";

  #~Hostname~
  networking.hostName = "nix-server";
}
