# Configuration for my office workstation

{ ... }:

{
  imports = [
    ./office-hardware-configuration.nix
    (import ../media-mount.nix { readOnly = false; })

    ../amd.nix
    ../audio.nix
    ../desktop.nix
    ../flatpak.nix
    ../musnix.nix
    ../plasma.nix
    ../ssh.nix
    ../steam.nix
    ../sunshine.nix
    ../syncthing.nix
    ../systemd-boot.nix
    ../tailscale.nix
    ../workstation.nix
  ];

  # Enable Wayland for SDDM
  services.displayManager.sddm.wayland.enable = true;

  #~Hostname~
  networking.hostName = "office";

  # Realtime kernel for audio work. Left off on the laptops, where it tends to
  # break suspend/resume.
  musnix.kernel.realtime = true;

  # Script to ensure monitor layout in sddm matched plasma
  system.activationScripts.sddmCopyDisplayConfig = {
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

  services.pipewire.wireplumber.extraConfig = {
    "50-minifuse-driver-fix" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "node.name" = "alsa_output.usb-ARTURIA_MiniFuse_1_8830400743360506-00.pro-output-0";
            }
          ];
          actions = {
            update-props = {
              "priority.driver" = 20000;
            };
          };
        }
        {
          matches = [
            {
              "node.name" = "alsa_input.usb-ARTURIA_MiniFuse_1_8830400743360506-00.pro-input-0";
            }
          ];
          actions = {
            update-props = {
              "node.passive" = true;
              "priority.driver" = 0;
            };
          };
        }
      ];
    };
  };

  environment.sessionVariables = {
    WEBKIT_DISABLE_DMABUF_RENDERER = "1";
  };

  # The NixOS release this machine was first installed with. Don't change it
  # without reading the release notes: it controls how existing state is handled.
  system.stateVersion = "23.05";
}
