# Enable the OpenSSH daemon (services.openssh opens port 22 in the firewall by default)

{ config, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
}
