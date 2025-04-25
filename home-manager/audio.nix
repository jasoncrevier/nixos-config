{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwig-studio
    #mixxx #Broken 19-04-24
    qpwgraph
    reaper
    sfizz
    vital
    yabridge
    yabridgectl
  ];
}
