{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Removing temp due to build error
    #catppuccin-cursors.mochaDark
  ];

  #~Fish~
  # Run: fish_config theme save "Catppuccin Mocha"
  home.file."/.config/fish/themes/Catppuccin Mocha.theme".source = ./catpuccin-mocha-fish-theme;
}