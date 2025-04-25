{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
  discord
  element-desktop
  mumble
  signal-desktop-bin
  telegram-desktop
  ];
}
