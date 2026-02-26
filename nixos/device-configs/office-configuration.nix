# Configuration for my office workstation

{ config, pkgs, ... }:

{
  imports =
    [
      ./office-hardware-configuration.nix
      ./office-syncthing.nix

      ../amd.nix
      ../audio.nix
      ../common.nix
      ../flatpak.nix
      ../musnix.nix
      ../plasma.nix
      ../ssh.nix
      ../steam.nix
      # Broken ../sunshine.nix 
      ../syncthing.nix
      ../tailscale.nix
      ../theme.nix
      ../workstation.nix
    ];

  # Enable Wayland for SDDM
  services.displayManager.sddm.wayland.enable = true;

  #~Hostname~
  networking.hostName = "office";

  system.activationScripts.sddmCopyDisplayConfig = {
  # We use a high priority to make sure this runs late in the activation process.
  # The name must be unique, like 'sddmCopyDisplayConfig'.
  text = ''
    # Define the source and destination paths
    SOURCE_FILE="/home/jason/.config/kwinoutputconfig.json"
    DEST_DIR="/var/lib/sddm/.config"
    DEST_FILE="$DEST_DIR/kwinoutputconfig.json"

    # Ensure the destination directory exists
    if [ ! -d "$DEST_DIR" ]; then
        mkdir -p "$DEST_DIR"
        chown sddm:sddm "$DEST_DIR"
    fi

    # Copy the file only if it exists
    if [ -f "$SOURCE_FILE" ]; then
        cp "$SOURCE_FILE" "$DEST_FILE"
        chown sddm:sddm "$DEST_FILE"
    fi
    '';
  };
}