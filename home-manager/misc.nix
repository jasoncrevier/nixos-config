{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    neofetch
    obsidian
    onlyoffice-bin
    spotify
    vlc
    wineWowPackages.staging
    winetricks
  ];

  # Fix for "command-not-found being" found. Beyond my understanding but it fixed
  # an issue I was having so I'll work on understanding it later.
  programs.nix-index = {
    enable=true;
    enableBashIntegration = true;
  };
}