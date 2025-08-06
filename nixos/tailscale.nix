# Enables Tailscale. Use "sudo tailscale up" after enabling.

{ config, pkgs, ... }:

{
  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [
    catppuccin-tailscale-systray
  ];
  
  nixpkgs.overlays = [
    (final: prev: {
      catppuccin-tailscale-systray = prev.tailscale-systray.overrideAttrs (previousAttrs: {
        src = ../pkgs/catppuccin-tailscale-systray;
      });
    })
  ];

}