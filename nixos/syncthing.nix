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
    settings = {
        devices = {
            "Tower" = { id = "RNAGDUN-OK6H2AR-KYHHFVM-267VUXN-ZP2RMUU-72LSU54-2ANRCUH-EMAFIQL"; };
            };
        };
    };
}