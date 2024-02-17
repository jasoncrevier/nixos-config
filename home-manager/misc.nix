{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    bottles
    neofetch
    obsidian
    spotify
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