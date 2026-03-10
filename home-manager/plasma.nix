{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (catppuccin-papirus-folders.override { flavor = "mocha"; accent = "teal"; })
    (catppuccin-gtk.override { accents = [ "teal" ]; variant = "mocha"; })
  ];

  programs.plasma = {
    enable = true;
    workspace = {
      colorScheme = "Catppuccin Mocha Teal";
      cursor.theme = "catppuccin-mocha-dark-cursors";
      iconTheme = "Papirus-Dark";
      lookAndFeel = "org.kde.breezedark.desktop";
      theme = "default";
    };
  };
}