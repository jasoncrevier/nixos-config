{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwig-studio
    mixxx
    qpwgraph
    reaper
    sfizz
    vital
    # Broken -- 04-05-2024 -- needs Wine update
    #yabridge
    #yabridgectl
  ];
}
