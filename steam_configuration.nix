{ config, pkgs, ... }:

let
  steam_autostart = (pkgs.makeAutostartItem { name = "steam"; package = steam; });

in
{
  #~Hardware~
  imports =
    [ # Include the results of the hardware scan
      ./hardware-configuration.nix
    ];
  
  #~Bootloader~
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sdb";
  boot.loader.grub.useOSProber = true;
  
  #~Networking~
  networking.hostName = "steam"; # Define your hostname
  
  # Enable networking
  networking.networkmanager.enable = true;
  
  #~Localization~
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";
  
  #~Keymapping~
  services.xserver = {
    layout = "us";
    xkbVariant = "";
    enable = true;
  };
  
  #~Sound~
  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];
  
  #~Graphics~
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is needed most of the time
    modesetting.enable = true;

	  # Enable power management (do not disable this unless you have a reason to).
	  # Likely to cause problems on laptops and with screen tearing if disabled.
	  powerManagement.enable = true;

    # Use the NVidia open source kernel module (which isn't “nouveau”).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = false;

    # Enable the Nvidia settings menu,
	  # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Fix screen tearing
    # forceFullCompositionPipeline = true;
  };
  
  #~Users~
  # Don't forget to set a password with ‘passwd’.
  users.users.jason = {
    isNormalUser = true;
    description = "steam";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };
  
  #~Packages~

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  git
  micro
  steam_autostart
  ];
  
  service.getty.autologinUser = "steam";

  # Fish settings
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Xbox controller
  boot.extraModprobeConfig = '' options bluetooth disable_ertm=1 '';

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm = {
    enable = true;
    autoLogin = {
      enable = true;
      user = "steam";
    };
  };
  services.xserver.desktopManager.plasma5.enable = true;
}