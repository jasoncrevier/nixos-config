{ config, pkgs, ... }:

{
  imports =
    [
      ../audio.nix
      ../chat.nix
      ../fish.nix
      ../games.nix
      ../git.nix
      ../graphics.nix
      ../misc.nix
      ../gnome.nix
      ../theme.nix
      ../vscode.nix
      ../web.nix
      ../wine.nix
    ];

  # Don't change this (I think)
  home.stateVersion = "24.05";
}
