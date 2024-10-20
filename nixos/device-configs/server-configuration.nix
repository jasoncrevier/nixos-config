# Configuration for my home server

{ config, pkgs, ... }:

{
  imports = [ 
    ./server-hardware-configuration.nix

    ../ssh.nix
    ../tailscale.nix
  ];
  environment.systemPackages = with pkgs; [
    git
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  #~Networking~
  networking.hostName = "nixos-server";
  # For SSH
  networking.firewall = {
   enable = true;
   allowedTCPPorts = [ 80 443 22 ];
   allowedUDPPorts = [ 80 443 22 ];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  #~Users~
  users.users.jason = {
    isNormalUser = true;
    description = "Jason Crevier";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "23.05";
}