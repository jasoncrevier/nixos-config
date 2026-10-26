# Configuration for my home server

{ config, pkgs, ... }:

{
  imports = [ 
    ./nix-server-hardware-configuration.nix
    (import ../media-mount.nix {})
    
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

    ../../scripts/navidrome-likes-to-listenbrainz.nix
    ../../scripts/obsidian-notifications.nix
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

  # The NixOS release this machine was first installed with. Don't change it
  # without reading the release notes: it controls how existing state is handled.
  system.stateVersion = "23.05";
}
