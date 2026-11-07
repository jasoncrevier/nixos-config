# Enable kosync

{ ... }:
{
  imports = [ ./backups.nix ];

  services.kosync = {
    enable = true;
  };

  # Reading progress for every KOReader device (kosync.db)
  backups.paths = [ "/var/lib/kosync" ];
}
