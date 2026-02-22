{ config, pkgs, ... }:

{
  imports =
    [
      ../arduino.nix
      ../audio.nix
      ../chat.nix
      ../fish.nix
      ../games.nix
      ../git.nix
      ../graphics.nix
      ../misc.nix
      ../plasma.nix
      ../theme.nix
      ../video.nix
      ../vscode.nix
      ../web.nix
      ../wine.nix
    ];
  home.username = "jason";
  home.homeDirectory = "/home/jason";

  # Don't change this (I think)
  home.stateVersion = "24.05";
}
