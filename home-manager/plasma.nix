{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    (catppuccin-papirus-folders.override { flavor = "mocha"; accent = "teal"; })
  ];

  programs.plasma.enable = true;

  stylix.targets.gtk.enable = false;

  programs.konsole = {
    enable = true;
    defaultProfile = "Catppuccin";
    profiles.Catppuccin.colorScheme = "CatppuccinMochaTeal";
    customColorSchemes = {
      CatppuccinMochaTeal = ../misc/Catppuccin-Mocha-Konsole.colorscheme;
    };
  };
}