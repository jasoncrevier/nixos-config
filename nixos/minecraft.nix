# Enable Minecraft (Java Edition) server

{
  pkgs,
  lib,
  config,
  ...
}:

{
  # whitelist.json contents (a JSON list of { "name": ..., "uuid": ... }).
  # Kept in sops because the module's own `whitelist` option lands in the world-readable store.
  sops.secrets.minecraft_whitelist = {
    owner = "minecraft";
    restartUnits = [ "minecraft-server.service" ];
  };

  # Runs after the module's preStart, which links whitelist.json to an empty store file
  systemd.services.minecraft-server.preStart = lib.mkAfter ''
    ln -sf ${config.sops.secrets.minecraft_whitelist.path} whitelist.json
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
      motd = "nullvoid.club";
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
}
