# Set sops defaults

{ config, pkgs, ... }:

{
  sops.defaultSopsFile = ../secrets.yaml;
}