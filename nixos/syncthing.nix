# Enable Syncthing

{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Every Syncthing device. Each machine shares with all of the others.
  allDevices = {
    "office" = {
      id = "3BUNMEZ-TWPP4MZ-Z2G7BAO-ZY5ZLSX-ENN5YON-AINIIGZ-CG4LHSI-VUESUQ2";
    };
    "thinkpad" = {
      id = "ZYUMO4O-YCWCXF7-LIH7DDZ-7XDHXVW-A6P4FZD-XQVER3U-QIGAVCO-7V36XQL";
    };
    "tower" = {
      id = "QMSNAMC-4WPXC3P-SGVM42Z-IT3E3TD-DTMXTIN-QCX42SW-PI4IEWB-TDWXYQU";
    };
  };
  devices = lib.filterAttrs (name: _: name != config.networking.hostName) allDevices;
  shareWith = builtins.attrNames devices;
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true; # TCP/UDP 22000 UDP 21027
    systemService = true;
    user = "jason";
    group = "users";
    dataDir = "/home/jason/syncthing";
    configDir = "/home/jason/.config/syncthing";

    overrideDevices = false;
    overrideFolders = false;

    settings = {
      options.urAccepted = -1;
      inherit devices;
      folders = {
        "home_dot_BitwigStudio" = {
          path = "/home/jason/.BitwigStudio";
          devices = shareWith;
        };
        "home_Bitwig_Studio" = {
          path = "/home/jason/Bitwig Studio";
          devices = shareWith;
        };
        # Claude Code's notes for this repo, shared between the NixOS machines only
        "claude_memory_nixos_config" = {
          path = "/home/jason/.claude/projects/-home-jason-nixos-config/memory";
          devices = builtins.filter (name: name != "tower") shareWith;
        };
      };
    };
  };
  environment.systemPackages = with pkgs; [
    syncthingtray
  ];
}
