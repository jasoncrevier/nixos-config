# Configuration for my Surface

{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./surface-hardware-configuration.nix

    ../desktop.nix
    ../remote-builder.nix
    ../flatpak.nix
    ../intel.nix
    #../musnix.nix
    ../gnome.nix
    ../ssh.nix
    ../steam.nix
    ../syncthing.nix
    ../systemd-boot.nix
    ../tailscale.nix
    ../workstation.nix
  ];

  #~Hostname~
  networking.hostName = "surface";

  zramSwap.enable = true;

  # Pen and touchscreen input. The kernel's IPTS driver only passes raw digitizer data;
  # iptsd turns it into input events. nixos-hardware's surface-common doesn't enable it
  # (only the per-device profiles do, and there's none for the Surface Book).
  services.iptsd = {
    enable = true;
    # Palm rejection: ignore touch while the pen is near the screen
    config.Touchscreen.DisableOnStylus = true;
  };
  # iptsd's own udev rule only matches "add". Starting iptsd resets the digitizer, which
  # sends a "change" event that drops the rule's systemd tag, so systemd considers the
  # device gone and stops iptsd a second after boot. Re-apply the rule on "change" too.
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ACTION=="change", TAG+="systemd", \
      PROGRAM="${pkgs.iptsd}/bin/iptsd-check-device --quiet $env{DEVNAME}", \
      PROGRAM="${pkgs.systemd}/bin/systemd-escape --path $env{DEVNAME}", \
      ENV{SYSTEMD_WANTS}+="iptsd@$result.service"
  '';

  # Temp fix: the linux-surface 6.19.8 kernel's Rust support doesn't build with nixpkgs'
  # rustc 1.99 ("invalid rustc abi: 'x86-softfloat'"). Nothing here needs kernel Rust
  # (it only adds the QR code on panic screens), so build without it until linux-surface catches up.
  boot.kernelPatches = [
    {
      name = "no-rust";
      patch = null;
      structuredExtraConfig = with lib.kernel; {
        RUST = lib.mkForce no;
        DRM_PANIC_SCREEN_QR_CODE = lib.mkForce no;
      };
    }
  ];

  # The NixOS release this machine was first installed with. Don't change it
  # without reading the release notes: it controls how existing state is handled.
  system.stateVersion = "23.05";
}
