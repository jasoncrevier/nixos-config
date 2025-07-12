{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    winetricks
    wineWowPackages.staging
  ];
}