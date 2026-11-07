# Enable Music Assistant

{ ... }:

{
  imports = [ ./backups.nix ];

  services.music-assistant = {
    enable = true;
    openFirewall = true;
    providers = [
      "opensubsonic"
      "chromecast"
    ];
  };

  # openFirewall only opens the stream port (8097), not the web UI
  networking.firewall.allowedTCPPorts = [ 8095 ];

  # Settings and library. DynamicUser: /var/lib/music-assistant is a symlink into /var/lib/private.
  backups.paths = [ "/var/lib/private/music-assistant" ];
  # No XDG_CACHE_HOME, so its cache (cache.db, artwork) is in a .cache folder under the data dir
  backups.exclude = [ "/var/lib/private/music-assistant/**/.cache" ];
  # Its databases use locking_mode=exclusive, so nothing else can read them while it runs
  backups.stopServices = [ "music-assistant" ];
}
