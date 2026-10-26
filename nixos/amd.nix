# Load AMD driver

{ ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" ];
}
