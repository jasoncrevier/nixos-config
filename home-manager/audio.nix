{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    #bitwig-studio
    (callPackage ../pkgs/bitwig-studio6.nix {})
    cardinal
    mixxx
    qpwgraph
    reaper
    sfizz
    vital
    #yabridge - Broken 05-01-26
    #yabridgectl - Broken 05-01-26
  ];
}
