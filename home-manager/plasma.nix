{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (catppuccin-papirus-folders.override { flavor = "mocha"; accent = "teal"; })
  ];

  programs.plasma = {
    enable = true;
  };

  programs.konsole = {
    enable = true;
  };
}