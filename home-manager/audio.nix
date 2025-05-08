{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwig-studio
    cardinal
    mixxx
    qpwgraph
    reaper
    sfizz
    vital
    yabridge
    yabridgectl
  ];
}
