# Enable Syncthing

{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true; # TCP/UDP 22000 UDP 21027
    systemService = true;
    user = "jason";
    group = "wheel";
    dataDir = "/home/jason/syncthing";
    configDir = "/home/jason/.config/syncthing";
  };
  environment.systemPackages = with pkgs; [
    syncthingtray
  ];
}