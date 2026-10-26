{ config, pkgs, ... }:

{
  imports =
    [
      ../3d-printing.nix
      ../arduino.nix
      ../audio.nix
      ../chat.nix
      ../fish.nix
      ../games.nix
      ../git.nix
      ../graphics.nix
      ../misc.nix
      ../plasma.nix
      ../tempopad.nix
      ../theme.nix
      ../video.nix
      ../vscode.nix
      ../web.nix
      ../wine.nix
    ];
}
