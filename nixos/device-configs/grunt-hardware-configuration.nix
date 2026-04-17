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

    "/mnt/Media" = {
      device = "//192.168.3.101/media";
      fsType = "cifs";
      options = let
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
        in ["${automount_opts},guest,uid=1000,gid=100,ro"];
    };
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
