{ config, pkgs, lib, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      userSettings = {
        "workbench.colorTheme" = "Catppuccin Mocha";
        "catppuccin.accentColor" = "teal";
        "editor.fontSize" = lib.mkForce 13;
        "terminal.integrated.fontSize" = lib.mkForce 13;
        "remote.SSH.useLocalServer" = false;
        "terminal.integrated.shellIntegration.enabled" = false;
        "window.zoomLevel" = 0.8;
        "chat.editor.fontSize" = lib.mkForce 13;
        "chat.fontSize" = 13;
        "debug.console.fontSize" = lib.mkForce 13;
        "scm.inputFontSize" = lib.mkForce 13;
        "remote.SSH.remotePlatform" = {
          "nix-server" = "linux";
        };
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
    package = pkgs.vscode.override {
      commandLineArgs = "--disable-features=WaylandWpColorManagerV1";
    };
  };
}
