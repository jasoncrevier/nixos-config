{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "favorite-folders";
        publisher = "Artelin";
        version = "1.3.1";
        sha256 = "sha256-pnzxhDSgnxGD2fd4MrCgBo/sRW6qjTJqE4J+ia9lJdA=";
      }
    ];
  };
}
