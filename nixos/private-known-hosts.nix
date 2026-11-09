# Host keys of servers this public repo shouldn't name, kept encrypted in
# workstation-secrets.yaml and trusted next to the generated known hosts (ssh.nix)

{ config, ... }:

{
  # Public keys, so any user's ssh may read them
  sops.secrets.private_known_hosts = {
    sopsFile = ../workstation-secrets.yaml;
    mode = "0444";
  };

  # extraConfig comes before the generated "Host *" block and the first value wins,
  # so this replaces the generated GlobalKnownHostsFile line
  programs.ssh.extraConfig = ''
    GlobalKnownHostsFile /etc/ssh/ssh_known_hosts ${config.sops.secrets.private_known_hosts.path}
  '';
}
