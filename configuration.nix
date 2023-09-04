# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
    enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jason = {
    isNormalUser = true;
    description = "Jason Crevier";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  micro
  librewolf
  #alacritty
  #polybar
  killall
  fd
  vscode
  git
  qt5ct
  adwaita-qt
  lxappearance
  nextcloud-client
  feh
  libsForQt5.qtkeychain
  #pavucontrol
  telegram-desktop
  neofetch
  cmatrix
  papirus-icon-theme
  obsidian
  catppuccin-kde
  ];

  nixpkgs.config = {
  	catppuccin-kde = {
  	  flavour = "mocha";
  	  accents = "blue";	
  	};
  };

  fonts.fonts = with pkgs; [
    cantarell-fonts
  ];
  # Extra programs
  programs.gnome-disks.enable = true;
  services.udisks2.enable = true;

  # Keyring settings
  services.gnome.gnome-keyring.enable = true;
  
  ## Thunar settings
  #services.gvfs.enable = true;
  #programs.file-roller.enable = true;
  #programs.thunar.enable = true;
  #programs.thunar.plugins = with pkgs.xfce; [
  #  thunar-archive-plugin
  #  thunar-volman
  #];
  
  #services.xserver.displayManager = {
  #  defaultSession = "none+i3";
  #};

  # fish settings
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # KDE Plasma settings
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  ## i3 settings
  #services.xserver.windowManager.i3 = {
  #  enable = true;
  #  extraPackages = with pkgs; [
  #    rofi
  #    i3status
  #    i3lock
  #    i3blocks
  #  ];
  #};

  ## picom settings
  #services.picom = {
  #	enable = true;
  #	activeOpacity = 1;
  #	inactiveOpacity = 1;
  #	backend = "glx";
  #	fade = true;
  #	fadeDelta = 5;
  #};

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
    forceFullCompositionPipeline = true;
  };

  # Pipewire settings
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    #alsa.enable = true;
    #alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
