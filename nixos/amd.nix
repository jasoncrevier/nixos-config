# Load AMD driver

{ config, ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" ];
}