# Nextcloud app password for syncing tasks over CalDAV (see home-manager/tasks.nix).
# Kept in its own sops file so the workstations can't decrypt the server secrets.

{ ... }:

{
  sops.secrets.nextcloud_tasks_password = {
    sopsFile = ../workstation-secrets.yaml;
    owner = "jason";
  };
}
