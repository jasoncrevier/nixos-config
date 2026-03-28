{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    catppuccin-cursors.mochaDark
  ];

  catppuccin = {
    flavor = "mocha";
    accent = "teal";
    enable = true;
    cursors.enable = false; # Let Stylix handle cursors to avoid conflicts
    vscode.enable = false;  # Let Stylix handle VS Code to avoid conflicts
  };
}