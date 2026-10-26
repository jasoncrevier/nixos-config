# Enables Tailscale. Use "sudo tailscale up" after enabling.

{ config, pkgs, lib, ... }:

{
  services.tailscale.enable = true;

  # Tray app only on machines with a desktop
  environment.systemPackages = lib.mkIf config.services.xserver.enable [
    pkgs.catppuccin-tailscale-systray
  ];
  
  nixpkgs.overlays = [
    (final: prev: {
      catppuccin-tailscale-systray = prev.tailscale-systray.overrideAttrs (previousAttrs: {
        src = ../pkgs/catppuccin-tailscale-systray;
      });
    })
  ];

}