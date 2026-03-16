{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (catppuccin-papirus-folders.override { flavor = "mocha"; accent = "teal"; })
    (catppuccin-gtk.override { accents = [ "teal" ]; variant = "mocha"; })
    #(catppuccin-kde.override { flavour = [ "mocha" ]; accents = [ "teal" ]; })
  ];

  programs.plasma = {
    enable = true;
    workspace = {
      colorScheme = "CatppuccinMochaTeal";
      cursor.theme = "catppuccin-mocha-dark-cursors";
      iconTheme = "Papirus-Dark";
      theme = "CatppuccinMochaTeal";
      windowDecorations.library = "org.kde.breeze";
      windowDecorations.theme = "Breeze";
    };
  };

  programs.konsole = {
    enable = true;
    defaultProfile = "Catppuccin";
    profiles.Catppuccin.colorScheme = "CatppuccinMochaTeal";
    customColorSchemes = {
      CatppuccinMochaTeal = ../misc/Catppuccin-Mocha-Konsole.colorscheme;
    }; 
  };
}