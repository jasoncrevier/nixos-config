{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (catppuccin-papirus-folders.override { flavor = "mocha"; accent = "teal"; })
    (catppuccin-gtk.override { accents = [ "teal" ]; variant = "mocha"; })
  ];

  programs.plasma = {
    enable = true;
    configFile."kdeglobals" = {
      "KDE"."SingleClick" = false;
      "Icons"."Theme" = "Papirus-Dark";
      "General"."ColorScheme" = "Catppuccin Mocha Teal";
    };
    workspace = {
      colorScheme = "Catppuccin Mocha Teal";
      cursor.theme = "Catppuccin-Mocha-Dark-Cursors";
      iconTheme = "Papirus-Dark";
      lookAndFeel = "Catppuccin-Mocha-Teal";
    };
  };
}