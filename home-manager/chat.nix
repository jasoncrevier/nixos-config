{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
  element-desktop
  mumble
  telegram-desktop
  zulip
  ];
}
