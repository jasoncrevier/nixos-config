{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    catppuccin-cursors.mochaDark
    (catppuccin-papirus-folders.override { flavor = "mocha"; accent = "teal"; })
    (catppuccin-gtk.override { accents = [ "teal" ]; variant = "mocha"; })
  ];
}