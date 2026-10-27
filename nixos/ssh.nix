# Enable the OpenSSH daemon (services.openssh opens port 22 in the firewall by default)

{ ... }:

{
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  # Keys that can log in as jason. Additive: ~/.ssh/authorized_keys still works too.
  users.users.jason.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOM3I5nkJqOFe2vlsQtmT6MoctIsLlZVRDIPB4LeKfgS jason@office"
  ];

  # Host keys of every machine, so SSH (including root's, for remote builds) trusts them without prompting
  programs.ssh.knownHosts = {
    office.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDU9ytfmI9nXW8SFssc/TdStJdzpzwRuP/UZ5B4KgFQl";
    nix-server.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9+bmfWcqCCzTJKH9wwOm1a0Lru6vKljwu5XxKPa3on";
    grunt.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPhPeVA4i7joMom/IzJGsKQ4k1bZ2WJ8QMNGlKW0j03l";
    thinkpad.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpm9GBOD62WQepV8CEbZOt7YL9q/M8GHTtZhugwT7R+";
    surface.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIANp+NWsyrIvAhhT8Z5ZBsZZZEFZVPZj/XlqK05wRPW5";
  };
}
