{ config, pkgs, ... }:

{
  imports =
    [
      ../fish.nix
      ../games.nix
      ../git.nix
      ../plasma.nix
      ../theme.nix
      ../vscode.nix
    ];
}
