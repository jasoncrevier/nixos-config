{ pkgs, inputs, ... }:

{
  # bw-backup: password-protected Bitwarden export → tower (run by hand, monthly)
  imports = [ ./bitwarden-backup.nix ];

  # Enable printing and printer discovery
  services.printing = {
    enable = true;
    drivers = [ pkgs.cnijfilter2 ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  hardware.sane.enable = true;

  # Claude desktop app (unofficial Linux build)
  environment.systemPackages = [
    inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
