# Enable Sunshine and Moonlight

{ lib, ... }:

{
  services.sunshine = {
    enable = true;
    autoStart = lib.mkDefault false;
    capSysAdmin = true;
    openFirewall = true;
  };
}
