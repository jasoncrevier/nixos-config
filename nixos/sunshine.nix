# Enable Sunshine and Moonlight

{ ... }:

{
  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true;
    openFirewall = true;
  };
}
