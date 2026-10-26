# Configuration for my home server

{ config, pkgs, ... }:

{
  imports = [ 
    ./nix-server-hardware-configuration.nix
    
    ../ai.nix
    ../desktop.nix
    ../jellyfin.nix
    ../karakeep.nix
    ../music-assistant.nix
    ../navidrome.nix
    ../nvidia.nix
    ../plasma.nix
    ../project-zomboid.nix
    ../sops.nix
    ../ssh.nix
    ../steam.nix
    ../sunshine.nix
    ../systemd-boot.nix
    ../tailscale.nix
    ../valheim.nix
    ../wyoming.nix

    ../../scripts/mood-tracker-notification.nix
    ../../scripts/navidrome-likes-to-listenbrainz.nix
    ../../scripts/thought-record-notification.nix
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

  services.displayManager.defaultSession = "plasma";

  #~Hostname~
  networking.hostName = "nix-server";

  networking.firewall.allowedTCPPorts = [
    8083  # Open WebUI
    11434 # Ollama
    8095  # Music Assistant web UI
    3030  # Karakeep
  ];
}
