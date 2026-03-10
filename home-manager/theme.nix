{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    catppuccin-cursors.mochaDark
  ];
  
  catppuccin = {
    flavor = "mocha";
    accent = "teal";
    enable = true;
  };
  programs.fish.shellInit = ''
    fish_config theme choose "Catppuccin Mocha"
  '';
  home.file."/.config/fish/themes/Catppuccin Mocha.theme".source = ./catppuccin-mocha-fish-theme;
}