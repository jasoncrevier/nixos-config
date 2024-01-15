# Enable firewall, open SSH port, and enable the OpenSSH daemon

{ config, pkgs, ... }:

{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 22 ];
    allowedUDPPorts = [ 80 443 22 ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
}