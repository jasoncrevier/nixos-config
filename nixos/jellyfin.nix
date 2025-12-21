{ pkgs, config, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "jason";
  };
}