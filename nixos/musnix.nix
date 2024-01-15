# Musnix settings

{ config, pkgs, ... }:

{
  musnix = {
    enable = true;
    kernel.packages = true;
  };
}