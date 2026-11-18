# Enable Homebox (home inventory: what we own, where it is, receipts for insurance), tailnet only

{ ... }:

{
  imports = [ ./backups.nix ];

  services.homebox = {
    enable = true;
    settings = {
      # Off since Jason's account exists (2026-11-18). Sian and anyone else join with an
      # invite link (Profile → Invite), which works with registration off. Rebuilding from
      # an empty /var/lib/homebox needs this "true" again for the first account.
      HBOX_OPTIONS_ALLOW_REGISTRATION = "false";
      HBOX_WEB_PORT = "7745";
    };
  };

  # A native service, so nixos-fw does gate it: open on the tailnet only, never the LAN
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 7745 ];

  # SQLite database (copied safely by backups.nix), attachments, and the API key pepper
  backups.paths = [ "/var/lib/homebox" ];
}
