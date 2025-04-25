# Enables Tailscale. Use "sudo tailscale up" after enabling.

{ config, pkgs, ... }:

{
  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [
    tailscale-systray
  ];
}