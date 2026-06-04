# Enable Syncthing

{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true; # TCP/UDP 22000 UDP 21027
    systemService = true;
    user = "jason";
    group = "users";
    dataDir = "/home/jason/syncthing";
    configDir = "/home/jason/.config/syncthing";

    overrideDevices = false;
    overrideFolders = false;

    settings.options.urAccepted = -1;
  };
  environment.systemPackages = with pkgs; [
    syncthingtray
  ];
}