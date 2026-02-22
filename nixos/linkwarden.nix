 # Enable Linkwarden 
 
{ config, pkgs, ... }: 

{
  sops.defaultSopsFile = ../secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.secrets = {
    linkwarden_nextauth = {
      owner = "linkwarden";
    };
    admin_email = {
      owner = "linkwarden";
    };
    admin_password = {
      owner = "linkwarden";
    };
  };
  services.linkwarden = {
    enable = true;
    openFirewall = true;
    host = "0.0.0.0";
    secretFiles = { 
      NEXTAUTH_SECRET = config.sops.secrets.linkwarden_nextauth.path;
    };
    environment = {
      NEXTAUTH_URL = "https://linkwarden.nullvoid.club";
    };
  };
} 