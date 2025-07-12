{ pkgs, config, ... }:

{
  # Enable printing and printer discovery
  services.printing.enable = true;

  services.avahi = {
  enable = true;
  nssmdns4 = true;
  openFirewall = true;
  };
}