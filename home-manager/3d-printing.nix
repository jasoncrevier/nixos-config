{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    cura-appimage
    f3d
  ];
}