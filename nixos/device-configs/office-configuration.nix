# Configuration for my office workstation

{ config, pkgs, ... }:

{
  imports =
    [
      ./office-hardware-configuration.nix

      ../common.nix
      ../flatpak.nix
      ../musnix.nix
      ../plasma.nix
      ../ssh.nix
      ../steam.nix
      ../syncthing.nix
      ../tailscale.nix
    ];

  #~Networking~
  networking.hostName = "office";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [  80 443 22 ];
    allowedUDPPorts = [ 80 443 22 ];
  };

  #~Users~
  users.users.jason = {
    isNormalUser = true;
    description = "Jason Crevier";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "audio" "docker" "adbusers" "kvm" ];
  };

  system.stateVersion = "23.05";
}