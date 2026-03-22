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
    yabridge
    yabridgectl
  ];
  home.file.".vst3/Vital.vst3".source = "${pkgs.vital}/lib/vst3/Vital.vst3";
}
