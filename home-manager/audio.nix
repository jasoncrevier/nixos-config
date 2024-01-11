{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
  reaper
  mixxx
  yabridge
  yabridgectl
  ];
}
