{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
  discord
  element-desktop
  mumble
  nextcloud-talk-desktop
  signal-desktop
  telegram-desktop
  ];
}
