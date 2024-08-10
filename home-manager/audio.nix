{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    mixxx
    qpwgraph
    reaper
    sfizz
    yabridge
    yabridgectl
  ];
}
