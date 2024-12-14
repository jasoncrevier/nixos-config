{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwig-studio
    mixxx # Build error 12-06-24 (Could not resolve host: launchpad.net)
    qpwgraph
    reaper
    sfizz
    yabridge
    yabridgectl
  ];
}
