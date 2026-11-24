# Enable Minecraft (Java Edition) server

{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [ ./backups.nix ];

  # whitelist.json contents (a JSON list of { "name": ..., "uuid": ... }).
  # Kept in sops because the module's own `whitelist` option lands in the world-readable store.
  sops.secrets.minecraft_whitelist = {
    owner = "minecraft";
    restartUnits = [ "minecraft-server.service" ];
  };

  # The server list's MOTD, kept in sops so this public repo doesn't name the domain
  sops.secrets.minecraft_motd = {
    owner = "minecraft";
    restartUnits = [ "minecraft-server.service" ];
  };

  # Runs after the module's preStart, which links whitelist.json to an empty store file
  # and copies server.properties from the store (with the placeholder MOTD below)
  systemd.services.minecraft-server.preStart = lib.mkAfter ''
    ln -sf ${config.sops.secrets.minecraft_whitelist.path} whitelist.json
    motd=$(cat ${config.sops.secrets.minecraft_motd.path})
    sed -i "s|^motd=.*|motd=$motd|" server.properties
  '';

  services.minecraft-server = {
    enable = true;
    # Pinned so `nix flake update` can't move the world to a new release; bump manually
    package = pkgs.minecraftServers.vanilla-26-3;
    # Setting this means you accept Mojang's EULA: https://aka.ms/MinecraftEULA
    eula = true;
    openFirewall = true; # TCP 25565

    # server.properties is generated from the options below, so in-game
    # changes to it are overwritten on restart. The world lives in /var/lib/minecraft.
    declarative = true;
    serverProperties = {
      server-port = 25565;
      motd = "set from the minecraft_motd secret";
      difficulty = "normal";
      gamemode = "survival";
      max-players = 10;
      view-distance = 12;
      # Players come from the minecraft_whitelist secret above
      white-list = true;
      enforce-whitelist = true;
    };

    jvmOpts = "-Xms2G -Xmx4G";
  };

  # The world. Flush it to disk first so the snapshot has the latest chunks.
  backups.paths = [ "/var/lib/minecraft" ];
  backups.prepareCommands = ''
    if systemctl is-active --quiet minecraft-server; then
      echo "save-all flush" > ${config.systemd.sockets.minecraft-server.socketConfig.ListenFIFO}
      sleep 10
    fi
  '';
}
