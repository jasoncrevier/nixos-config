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
}
