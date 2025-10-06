{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwarden-desktop
    chromium
    freetube
    heynote
    #jellyfin-media-player Broken 28-08-25
    kdePackages.kasts
    micro
    neofetch
    nicotine-plus
    obsidian
    onlyoffice-bin
    spotify
    supersonic
    tutanota-desktop
    vlc
    #(callPackage ../pkgs/amplitude.nix {})
  ];

  # Fix for "command-not-found being" found. Beyond my understanding but it fixed
  # an issue I was having so I'll work on understanding it later.
  programs.nix-index = {
    enable=true;
    enableBashIntegration = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
