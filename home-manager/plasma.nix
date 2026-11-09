{ pkgs, ... }:

let
  # KDE Connect leaves a dead sshfs mount behind when the phone drops off,
  # and every later mount fails on it until it's unmounted
  sshfsCleanupScript = pkgs.writeShellScript "sshfs-stale-cleanup" ''
    ${pkgs.util-linux}/bin/findmnt -rn -t fuse.sshfs -o TARGET | while read -r mnt; do
      case "$mnt" in /run/user/$UID/*) ;; *) continue ;; esac
      if ! ${pkgs.coreutils}/bin/stat "$mnt" >/dev/null 2>&1; then
        /run/wrappers/bin/fusermount3 -uz "$mnt" && echo "Unmounted stale $mnt"
      fi
    done
  '';
in
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
      # Copied on its own so the path only changes when the image does,
      # not on every commit to the repo
      appearance.wallpaper = builtins.path {
        path = ../wallpaper.png;
        name = "wallpaper.png";
      };
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

  systemd.user.services.sshfs-stale-cleanup = {
    Unit.Description = "Unmount dead KDE Connect sshfs mounts";
    Service = {
      Type = "oneshot";
      ExecStart = "${sshfsCleanupScript}";
      # stat can hang on a live mount while the phone is briefly unreachable
      TimeoutStartSec = "30s";
    };
  };

  systemd.user.timers.sshfs-stale-cleanup = {
    Unit.Description = "Check for dead KDE Connect sshfs mounts every minute";
    Timer = {
      OnStartupSec = "1min";
      OnUnitActiveSec = "1min";
    };
    Install.WantedBy = [ "timers.target" ];
  };

  stylix.targets.gtk.enable = true;

  gtk.gtk2.force = true;

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
