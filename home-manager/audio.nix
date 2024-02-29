{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    mixxx
    qjackctl
    reaper
    sfizz
    yabridge
    yabridgectl
  ];
}
