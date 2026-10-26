# Load Intel driver

{ pkgs, ... }:

{
  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
}
