{ config, pkgs, ... }:

{
  imports =
    [
      ../audio.nix
      ../chat.nix
      ../fish.nix
      ../games.nix
      ../git.nix
      ../gnome.nix
      ../graphics.nix
      ../misc.nix
      ../theme.nix
      ../vscode.nix
      ../web.nix
    ];
  home.username = "jason";
  home.homeDirectory = "/home/jason";

  # Don't change this (I think)
  home.stateVersion = "24.05";
}