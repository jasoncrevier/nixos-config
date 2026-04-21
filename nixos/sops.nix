# Set sops defaults

{ config, pkgs, ... }:

{
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.defaultSopsFile = ../secrets.yaml;
}