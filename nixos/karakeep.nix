 # Enable Karakeep
 
{ config, pkgs, ... }: 

{
  sops.defaultSopsFile = ../secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.secrets = {
    karakeep_nextauth = {
      owner = "karakeep";
    };
    meili_master_key = {
      owner = "meilisearch";
    };
  };
  services.karakeep = {
    enable = true;
    host = "0.0.0.0";
    extraEnvironment = {
      NEXTAUTH_URL = "https://karakeep.nullvoid.club";
      NEXTAUTH_SECRET = config.sops.secrets.karakeep_nextauth.path;
      MEILI_MASTER_KEY = config.sops.secrets.meili_master_key.path;
      DISABLE_SIGNUPS = true;
      OPENAI_API_KEY = ollama;
      OPENAI_BASE_URL = http://0.0.0.0:11434;
      INFERENCE_TEXT_MODEL = gemma4:e2b;
      INFERENCE_IMAGE_MODEL = llava;
    };
  };
} 