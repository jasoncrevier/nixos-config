{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwig-studio
    mixxx
    qpwgraph
    reaper
    sfizz
    vital
    yabridge
    yabridgectl
  ];
}
