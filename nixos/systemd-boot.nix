{ ... }:

{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10; # Keep /boot from filling up
      };
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    plymouth.enable = true;
    kernelParams = [ "quiet" ];
    kernelModules = [ "ntsync" ];
  };
}
