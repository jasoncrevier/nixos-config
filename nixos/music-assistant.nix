# Enable Music Assistant

{ pkgs, config, ... }:

{
    services.music-assistant = {
        enable = true;
        openFirewall = true;
        providers = [ "opensubsonic" "chromecast" ];
    };
}