# Musnix settings

{ config, pkgs, ... }:

{
  musnix = {
    enable = true;
    kernel.realtime = true;
    rtcqs.enable = true;
  };
}