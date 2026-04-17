# Configuration for my Surface

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./surface-hardware-configuration.nix
      
      ../common.nix
      ../flatpak.nix
      ../intel.nix
      ../musnix.nix
      ../gnome.nix
      ../ssh.nix
      ../steam.nix
      ../systemd-boot.nix
      ../tailscale.nix
      ../workstation.nix
    ];

  #~Hostname~
  networking.hostName = "surface";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # 2. Add the necessary tools to your system
  environment.systemPackages = with pkgs; [
    iptsd
    surface-control
    libinput
  ];

  # 3. Manually define the systemd service since the built-in one is missing
  systemd.services.iptsd = {
    description = "Surface Touch Service (Manual)";
    documentation = [ "https://github.com/linux-surface/iptsd" ];
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.iptsd}/bin/iptsd";
      Restart = "on-failure";
      Type = "simple";
    };
  };

  # 4. Load the bridge drivers so the binary can find the hardware
  boot.kernelModules = [ 
    "intel_vsec" 
    "surface_hid" 
    "surface_aggregator" 
    "surface_aggregator_registry"
  ];

  # 5. Required firmware for the sensor
  hardware.enableRedistributableFirmware = true;
}
