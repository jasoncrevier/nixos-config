# Enable the GNOME Desktop Environment.

{ pkgs, ... }:

{
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.systemPackages = with pkgs; [
    remmina
  ];
  environment.gnome.excludePackages = (with pkgs; [
    kgx
  ]);
}