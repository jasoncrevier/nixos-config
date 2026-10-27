# Configuration for my Surface

{
  lib,
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
    ../systemd-boot.nix
    ../tailscale.nix
    ../workstation.nix
  ];

  #~Hostname~
  networking.hostName = "surface";

  zramSwap.enable = true;

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
