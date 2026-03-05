{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    blender
    drawy
    gimp
    krita
    inkscape
  ];
}
