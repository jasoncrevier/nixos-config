{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (catppuccin-papirus-folders.override {
      flavor = "mocha";
      accent = "teal";
    })
  ];

  # Settings shared by every Plasma machine. Only these keys are managed;
  # anything else set in System Settings is left alone.
  programs.plasma = {
    enable = true;

    session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";

    kscreenlocker = {
      autoLock = false;
      appearance.wallpaper = ../wallpaper.png;
    };

    configFile = {
      # Set directly: kwin.virtualDesktops would rename the desktop's ID,
      # which resets the KWin tiling layouts saved under it.
      kwinrc.Desktops = {
        Number = 1;
        Rows = 1;
      };

      # Don't nag about browser integration or auto-mount drives
      kded5rc.Module-browserintegrationreminder.autoload = false;
      kded5rc.Module-device_automounter.autoload = false;

      plasmaparc.General.RaiseMaximumVolume = true;

      kcminputrc.Mouse.X11LibInputXAccelProfileFlat = true;
      # The trailing space is part of the device name
      kcminputrc."Libinput/13364/53296/Keychron  Keychron Link ".NaturalScroll = true;
    };
  };

  stylix.targets.gtk.enable = true;

  programs.konsole = {
    enable = true;
    defaultProfile = "Catppuccin";
    profiles.Catppuccin.colorScheme = "CatppuccinMochaTeal";
    profiles.Catppuccin.font.name = "IBM Plex Mono";
    customColorSchemes = {
      CatppuccinMochaTeal = ../misc/Catppuccin-Mocha-Konsole.colorscheme;
    };
  };
}
