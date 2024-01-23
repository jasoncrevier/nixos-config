# Enable firewall, open SSH port, and enable the OpenSSH daemon

{ config, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
}