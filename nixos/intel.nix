# Load Intel driver

{ config, pkgs, ... }:

{
  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
  services.xserver = {
    videoDrivers = [ "modesetting" ];
  };
}