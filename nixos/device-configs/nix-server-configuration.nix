# Configuration for my home server

{ config, pkgs, ... }:

{
  imports = [ 
    ./nix-server-hardware-configuration.nix
    
    ../ai.nix
    ../nvidia.nix
    ../common.nix
    ../docker.nix
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

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 81 2052 3000 9443 8083 ];
    allowedUDPPortRanges = [
      { from = 80; to = 81; }
      { from = 2052; to = 2052; }
      { from = 3000; to = 3000; }
      { from = 9443; to = 9443; }
      { from = 8083; to = 8083; }
    ];
  };

}
