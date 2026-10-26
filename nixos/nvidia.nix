# Load nvidia driver for Xorg and Wayland

{ config, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
	  # Enable power management (do not disable this unless you have a reason to).
	  # Likely to cause problems on laptops and with screen tearing if disabled.
	  powerManagement.enable = true;

    # Use the NVidia open source kernel module (which isn't “nouveau”).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = false;

    # Beta on purpose: it gets Wayland fixes sooner than the production driver.
    package = config.boot.kernelPackages.nvidiaPackages.beta;

    # Fix screen tearing (adds input lag)
    #forceFullCompositionPipeline = true;
  };
}