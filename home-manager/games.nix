{ config, pkgs, ... }:

# Steam is enabled through nixos config, not home-manager.
# It requires config that doesn't work with home-manager.

{
  home.packages = with pkgs; [
    gamemode
    heroic
    lutris
    moonlight-qt
    prismlauncher
    protonup-qt
  ];
}