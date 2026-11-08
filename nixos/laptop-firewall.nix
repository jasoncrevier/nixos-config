# Laptops join untrusted networks (public Wi-Fi), so only open ports on the tailnet

{ ... }:

{
  # The laptops only connect to Remote Play hosts (office, nix-server), they don't host
  programs.steam.remotePlay.openFirewall = false;

  # Syncthing still syncs without inbound ports by dialing out to office/tower;
  # peers on the tailnet can also connect directly
  services.syncthing.openDefaultPorts = false;
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 22000 ];
  };
}
