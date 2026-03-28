{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      userSettings = {
        "remote.SSH.useLocalServer" = false;
        "terminal.integrated.shellIntegration.enabled" = false;
      };
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        ms-python.python
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "favorite-folders";
          publisher = "Artelin";
          version = "1.3.1";
          sha256 = "sha256-pnzxhDSgnxGD2fd4MrCgBo/sRW6qjTJqE4J+ia9lJdA=";
        }
      ];
    };
  };
}
