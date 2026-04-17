{ config, pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    plymouth.enable = true;
    initrd.systemd.enable = true;
    kernelParams = ["quiet"];
    kernelModules = [ "ntsync" ];
  };
}
