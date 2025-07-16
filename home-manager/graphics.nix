{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
  #gimp Broken 15-7-25
  inkscape
  ];
}
