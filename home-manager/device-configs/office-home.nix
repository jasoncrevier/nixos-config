{ config, pkgs, ... }:

{
  imports =
    [
      ../ai.nix
      ../audio.nix
      ../chat.nix
      ../fish.nix
      ../games.nix
      ../git.nix
      ../graphics.nix
      ../misc.nix
      ../plasma.nix
      ../vscode.nix
      ../web.nix
      ../wine.nix
      ../theme.nix
    ];
  home.username = "jason";
  home.homeDirectory = "/home/jason";

  # Don't change this (I think)
  home.stateVersion = "24.05";
}
