# Enable Music Assistant

{ ... }:

{
  services.music-assistant = {
    enable = true;
    openFirewall = true;
    providers = [
      "opensubsonic"
      "chromecast"
    ];
  };

  # openFirewall only opens the stream port (8097), not the web UI
  networking.firewall.allowedTCPPorts = [ 8095 ];
}
