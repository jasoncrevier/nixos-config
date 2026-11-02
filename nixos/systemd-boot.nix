{ ... }:

{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10; # Keep /boot from filling up
        editor = false; # Editing the kernel command line at boot (init=/bin/sh) gives a root shell
      };
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    plymouth.enable = true;
    kernelParams = [ "quiet" ];
    kernelModules = [ "ntsync" ];
  };
}
