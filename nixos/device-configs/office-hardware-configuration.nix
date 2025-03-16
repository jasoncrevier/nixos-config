{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ "amdgpu" ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems = {

    "/mnt/Storage_SSD" = {
      device = "/dev/disk/by-uuid/6d20d237-a5db-4cc4-aed4-bd75affac80c";
      fsType = "ext4";
    };
    
    "/mnt/Gaming_SSD" = {
      device = "/dev/disk/by-uuid/2ddb6b4b-f630-4763-9e0c-b678168e41d4";
      fsType = "ext4";
    };

    "/mnt/Storage_HDD" = {
      device = "/dev/disk/by-uuid/97edc4de-2734-4bb4-9784-b3ba1fd84d4c";
      fsType = "ext4";
    };

    "/" = {
      device = "/dev/disk/by-uuid/7c9db782-85d0-417a-8682-60cb4296b843";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/172C-B05B";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
