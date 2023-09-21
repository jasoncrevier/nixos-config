let
  steam_autostart = (pkgs.makeAutostartItem { name = "steam"; package = steam; });

in
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  nixpkgs.config.allowUnfree = true;

  # Xbox controller
  boot.extraModprobeConfig = '' options bluetooth disable_ertm=1 '';

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];

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