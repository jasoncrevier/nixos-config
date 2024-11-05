# Configuration for my Thinkpad

{ config, pkgs, ... }:

{
  imports =
    [
      ./thinkpad-hardware-configuration.nix
      
      ../common.nix
      ../gnome.nix
      ../musnix.nix
      ../steam.nix
      ../syncthing.nix
      ../tailscale.nix
    ];

  #~Networking~
  networking.hostName = "thinkpad";
  # For SSH
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 22 ];
    allowedUDPPorts = [ 80 443 22 ];
  };

  #~Users~
  users.users.jason = {
    isNormalUser = true;
    description = "Jason Crevier";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "audio" ];
  };

  # Global patch -- using to fix blurry electron apps when using fractional scaling
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  system.stateVersion = "23.05";
}
