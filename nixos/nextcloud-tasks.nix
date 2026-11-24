# Nextcloud app password and CalDAV URL for syncing tasks (see home-manager/tasks.nix).
# The URL is a secret too, so this public repo doesn't name the server.
# Kept in its own sops file so the workstations can't decrypt the server secrets.

{ ... }:

{
  sops.secrets.nextcloud_tasks_password = {
    sopsFile = ../workstation-secrets.yaml;
    owner = "jason";
  };
  sops.secrets.nextcloud_caldav_url = {
    sopsFile = ../workstation-secrets.yaml;
    owner = "jason";
  };
}
