{ config, pkgs, lib, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      userSettings = {
        "editor.fontSize" = lib.mkForce 12;
        "terminal.integrated.fontSize" = lib.mkForce 12;
        "remote.SSH.useLocalServer" = false;
        "terminal.integrated.shellIntegration.enabled" = false;
        "window.zoomLevel" = 1;
        "chat.editor.fontSize" = lib.mkForce 12;
        "chat.fontSize" = 12;
        "debug.console.fontSize" = lib.mkForce 12;
        "scm.inputFontSize" = lib.mkForce 12;
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
