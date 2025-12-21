{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ "amdgpu" ];
    };
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  fileSystems = {

    "/mnt/Games_HDD" = {
      device = "/dev/disk/by-uuid/8575ae67-7e62-4f00-bb00-63022d128831";
      fsType = "ext4";
    };

    "/mnt/Main_storage" = {
      device = "/dev/disk/by-uuid/c765f3f4-c218-4baa-ab51-20edd0b67454";
      fsType = "ext4";
    };

    "/" = {
      device = "/dev/disk/by-uuid/de2dde35-8114-41e6-bd6e-b848b5bfe7a3";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/4733-716E";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    "/mnt/Media" = {
      device = "//192.168.3.101/media";
      fsType = "cifs";
      options = let
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
        in ["${automount_opts},guest,uid=1000,gid=100"];
    };
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
