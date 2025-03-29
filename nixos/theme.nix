# Enable Flatpak

{ pkgs, config, ... }:

{
  catppuccin = {
    flavor = "mocha";
    accent = "teal";
    enable = true;
  };
}