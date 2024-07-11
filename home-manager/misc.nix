{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwarden-desktop
    bottles
    neofetch
    obsidian
    onlyoffice-bin
    spotify
    soulseekqt
    vlc
    winetricks
    wineWowPackages.staging
  ];

  # Fix for "command-not-found being" found. Beyond my understanding but it fixed
  # an issue I was having so I'll work on understanding it later.
  programs.nix-index = {
    enable=true;
    enableBashIntegration = true;
  };
}