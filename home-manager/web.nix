{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    nextcloud-client
    (wrapFirefox (firefox-unwrapped.override { pipewireSupport = true;}) {})
  ];
}