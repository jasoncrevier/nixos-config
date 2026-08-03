 # Enable whisper and piper
 
{ config, pkgs, ... }: 

{
  nixpkgs.config.allowUnfree = true;

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

  networking.firewall.allowedTCPPorts = [ 10200 10300 ];
}