# Enable whisper and piper

{ ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      ctranslate2 = prev.ctranslate2.override {
        withCUDA = true;
        withCuDNN = true;
      };
    })
  ];

  services.wyoming.faster-whisper = {
    servers.knight = {
      enable = true;
      # see https://github.com/rhasspy/rhasspy3/blob/master/programs/asr/faster-whisper/script/download.py
      model = "base-int8";
      language = "en";
      uri = "tcp://0.0.0.0:10300";
      device = "cuda";
    };
  };

  services.wyoming.piper = {
    servers.knight = {
      enable = true;
      # https://rhasspy.github.io/piper-samples/
      voice = "en_US-hfc_male-medium";
      uri = "tcp://0.0.0.0:10200";
    };
  };

  # Tailnet only: Home Assistant is on the tailnet (100.70.144.121), so its Wyoming
  # integrations use nix-server's Tailscale IP, 100.123.35.99. A native service, so
  # nixos-fw gates it even though it listens on 0.0.0.0.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    10200 # piper
    10300 # faster-whisper
  ];
}
