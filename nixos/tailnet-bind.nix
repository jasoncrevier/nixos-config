# For services that publish a port on this host's Tailscale IP (podman containers kept off
# the LAN that way). tailscaled reports "started" a moment before tailscale0 has its address,
# so a bind at boot failed, sent an ntfy alert, and only worked on the retry. The listed
# services now wait for the address first; their own Restart= stays as a fallback.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  waitForTailnetIp = pkgs.writeShellApplication {
    name = "wait-for-tailnet-ip";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.iproute2
    ];
    text = ''
      # Long enough for a slow boot; past that, failing (and alerting) is right
      for _ in $(seq 90); do
        if ip -4 -o addr show dev tailscale0 2>/dev/null | grep -q " inet "; then exit 0; fi
        sleep 1
      done
      echo "tailscale0 has no IPv4 address after 90s" >&2
      exit 1
    '';
  };
in
{
  options.tailnetBind.services = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [ "podman-kitchenowl" ];
    description = "Services that bind to this host's Tailscale IP and so must wait for it.";
  };

  config.systemd.services = lib.genAttrs config.tailnetBind.services (_: {
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    serviceConfig.ExecStartPre = [ "${waitForTailnetIp}/bin/wait-for-tailnet-ip" ];
  });
}
