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

  # Prebuilt CUDA packages (ollama-cuda, ctranslate2), which cache.nixos.org
  # doesn't carry because CUDA is unfree
  nix.settings = {
    substituters = [ "https://cache.nixos-cuda.org" ];
    trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
  };
}