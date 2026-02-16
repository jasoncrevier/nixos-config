{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
  element-desktop
  mumble
  signal-desktop-bin
  telegram-desktop
  zulip
  ];
}
