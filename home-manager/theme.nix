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
    vscode.profiles.default.enable = true;
  };

  stylix.targets.vscode.enable = false;

  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
  };
}