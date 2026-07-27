{ pkgs, config, ... }:

{
  boot.kernelParams = [ 
    "processor.max_cstate=1" 
    "intel_idle.max_cstate=1" 
    "usbcore.autosuspend=-1" 
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;

    extraConfig.pipewire = {
      "10-clock-rate" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [ 44100 48000 ];
          "default.clock.min-quantum" = 128;
          "default.clock.max-quantum" = 1024;
        };
      };
      "99-disable-bluez-midi" = {
        "bluez5.msbc-support" = false;
        "bluez5.midi.service" = false;
      };
    };

    wireplumber.extraConfig = {
      "99-disable-v4l2" = {
        "monitor.v4l2.properties" = {
          "v4l2.enabled" = false;
        };
      };
      "99-disable-bluez-midi-wp" = {
        "wireplumber.profiles" = {
          "main" = {
            "monitor.bluez-midi" = "disabled";
          };
        };
      };
    };
  };
}