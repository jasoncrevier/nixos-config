{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci" ];
      kernelModules = [ "kvm-intel" ];
    };
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  fileSystems = {

    "/" = {
      device = "/dev/disk/by-uuid/255a6598-6f58-48bd-8200-ac2f2dc42904";
      fsType = "ext4";
    };

  };

  swapDevices = [{
    device = "/swapfile";
    size = 2 * 1024; # 2GB
  }];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
