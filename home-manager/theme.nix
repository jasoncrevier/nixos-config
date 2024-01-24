{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    catppuccin-cursors.mochaDark
    (catppuccin-papirus-folders.override { flavor = "mocha"; accent = "teal"; })
    (catppuccin-gtk.override { accents = [ "teal" ]; variant = "mocha"; })
  ];

  #~Fish~
  # Run: fish_config theme save "Catppuccin Mocha"
  home.file."/.config/fish/themes/Catppuccin Mocha.theme".source = ./catpuccin-mocha-fish-theme;
  
  #~Gnome~
  home.file."catppuccin-mocha-gradience-theme.json".source = ./catppuccin-mocha-gradience-theme;
  dconf.settings = {
    "org/gnome/shell/extensions/user-theme" = {
      name = "Catppuccin-Mocha-Standard-Teal-Dark";
    };
  };
}