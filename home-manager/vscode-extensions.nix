# VS Code extensions that run on the machine holding the code. Shared by the
# desktop VS Code (vscode.nix) and the Remote-SSH server dir on the servers
# (vscode-server.nix), so remotes run the same pinned builds as the desktops
# instead of whatever the Marketplace serves that day.
pkgs:
with pkgs.vscode-extensions;
[
  anthropic.claude-code
  jnoortheen.nix-ide
  ms-python.python
  ms-azuretools.vscode-docker
]
