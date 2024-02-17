{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    mixxx
    reaper
    sfizz
    yabridge
    yabridgectl
  ];
}
