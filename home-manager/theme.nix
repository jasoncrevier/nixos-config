{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    catppuccin-cursors.mochaDark
  ];

  catppuccin = {
    flavor = "mocha";
    accent = "teal";
    enable = true;
    autoEnable = true; # Silences enrollment warnings
    cursors.enable = false; # Let Stylix handle cursors to avoid conflicts
    vscode.profiles.default.enable = true;
  };

  # Silence Hyprland config warning (triggered by catppuccin module evaluation)
  wayland.windowManager.hyprland.configType = "hyprlang";

  home.pointerCursor.enable = true;

  stylix.targets.vscode.enable = false;
}