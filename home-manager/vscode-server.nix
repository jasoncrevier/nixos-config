# Remote-SSH target: VS Code's server loads extensions from ~/.vscode-server/extensions.
# Point that at a read-only Nix-built set so nothing gets installed or
# auto-updated from the Marketplace on this machine.
{ pkgs, ... }:

let
  extensions = import ./vscode-extensions.nix pkgs;

  # Same layout Home Manager builds for ~/.vscode/extensions, including the
  # extensions.json VS Code >= 1.74 reads to know what's installed.
  extensionsDir = pkgs.buildEnv {
    name = "vscode-server-extensions";
    paths = extensions ++ [
      (pkgs.writeTextFile {
        name = "vscode-server-extensions-json";
        destination = "/share/vscode/extensions/extensions.json";
        text = pkgs.vscode-utils.toExtensionJson extensions;
      })
    ];
  };
in
{
  home.file.".vscode-server/extensions".source = "${extensionsDir}/share/vscode/extensions";
}
