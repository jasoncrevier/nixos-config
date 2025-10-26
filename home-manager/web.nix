{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    #nextcloud-client
    (callPackage ../pkgs/nextcloud4.nix {})
  ];
}