{ ... }:

{
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

  stylix.targets.vscode.enable = false;

  # Stylix only auto-enables its Qt target when Home Manager runs as a NixOS module.
  # It would pick a different Qt style than catppuccin's Kvantum theme and trip
  # catppuccin's assertion, so leave Qt to catppuccin/the desktop as before.
  stylix.targets.qt.enable = false;
}
