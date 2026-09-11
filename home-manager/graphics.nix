{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    blender
    drawy
    freecad
    gimp
    krita
    inkscape
  ];
}
