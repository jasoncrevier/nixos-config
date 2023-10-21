{ config, pkgs, ... }:

{
  #~Hardware~
  imports =
    [ # Include the results of the hardware scan
      ./hardware-configuration.nix
      <musnix>
    ];

  #~Bootloader~
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sdc";
  boot.loader.grub.useOSProber = true;

  #~Networking~
  networking.hostName = "nixos-office"; # Define your hostname
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  services.tailscale.enable = true;

  # Mount Samples SMB share for Reaper
  fileSystems."/mnt/Samples" = {
      device = "//192.168.3.101/Samples";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
  };

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
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
  };

  #~Graphics~
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  #~Users~
  # Don't forget to set a password with ‘passwd’.
  users.users.jason = {
    isNormalUser = true;
    description = "Jason Crevier";
    extraGroups = [ "networkmanager" "wheel" "audio" ];
    packages = with pkgs; [];
  };

  #~Packages~

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  # Audio
  easyeffects
  reaper
  yabridge
  yabridgectl
  # Chat
  discord
  element-desktop
  telegram-desktop
  # Development
  git
  micro
  vscode
  # Theme
  adwaita-qt
  catppuccin-cursors.mochaDark
  (catppuccin-papirus-folders.override { flavor = "mocha"; accent = "teal"; })
  qt5ct
  # Web
  firefox
  nextcloud-client
  # Misc
  cifs-utils
  cmatrix
  deluge
  fd
  feh
  google-fonts
  inkscape
  kcalc
  kcolorchooser
  killall
  libsForQt5.discover
  libsForQt5.packagekit-qt
  libportal-qt5
  libsForQt5.qtkeychain
  neofetch
  obsidian
  spotify
  wineWowPackages.staging
  winetricks
  ];

  # Extra programs
  programs.gnome-disks.enable = true;
  services.udisks2.enable = true;
  programs.kdeconnect.enable = true;
  musnix.enable = true;
  services.flatpak.enable = true;
  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Fish settings
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # KDE Plasma settings
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  # Exclude some default KDE packages
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
    oxygen
    khelpcenter
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}