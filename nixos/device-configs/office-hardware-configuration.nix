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

    "/mnt/Games_HDD" = {
      device = "/dev/disk/by-uuid/8575ae67-7e62-4f00-bb00-63022d128831";
      fsType = "ext4";
    };

    "/mnt/Games_SSD" = {
      device = "/dev/disk/by-uuid/9cf976f6-754f-474b-bc49-56dd5705b640";
      fsType = "ext4";
    };

    "/mnt/Main_storage" = {
      device = "/dev/disk/by-uuid/c765f3f4-c218-4baa-ab51-20edd0b67454";
      fsType = "ext4";
    };

    "/" = {
      device = "/dev/disk/by-uuid/a22f94c0-9605-4df3-90d8-da1271d927bf";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/C9C5-B882";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}