# Enables Tailscale. Use "sudo tailscale up" after enabling.

{
  config,
  pkgs,
  lib,
  ...
}:

let
  ip = "${pkgs.iproute2}/bin/ip";
  # Tailscale's table 52 (rule 5270) holds the orangepizero3 subnet route for the
  # home LAN, and it's consulted before main, so machines that accept routes
  # relayed even their own LAN's traffic through the Pi. This rule checks main
  # first, but suppress_prefixlength 0 ignores its default route: it only
  # matches while the LAN is directly connected, so away from home the
  # subnet route still applies.
  homeLanRule = "priority 5200 to 192.168.3.0/24 lookup main suppress_prefixlength 0";
in
{
  services.tailscale.enable = true;

  systemd.services.home-lan-direct = {
    description = "Reach the home LAN directly instead of through the Tailscale subnet router";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-pre.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "-${ip} rule del ${homeLanRule}";
      ExecStart = "${ip} rule add ${homeLanRule}";
      ExecStop = "${ip} rule del ${homeLanRule}";
    };
  };

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
