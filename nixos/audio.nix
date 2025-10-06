# Enable audio

{ pkgs, config, ... }:

{
  services.pipewire = {
    enable = true;
    #alsa.enable = true;
    #pulse.enable = true;
    jack.enable = true;
  };
  #programs.noisetorch.enable = true;
    environment.systemPackages = with pkgs; [
      easyeffects
  ];
}