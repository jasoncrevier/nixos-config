 # Enable Karakeep
 
{ config, pkgs, ... }: 

{
  sops.defaultSopsFile = ../secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.secrets.karakeep_env = {
    owner = "karakeep";
  };
  services.karakeep = {
    enable = true;
    environmentFile = "/run/secrets/karakeep_env";
    extraEnvironment = {
      PORT = "3030";
      DISABLE_SIGNUPS = "true";
      OPENAI_API_KEY = "ollama";
      OPENAI_BASE_URL = "http://127.0.0.1:11434/v1";
      INFERENCE_TEXT_MODEL = "gemma2:2b";
      INFERENCE_IMAGE_MODEL = "llava";
      SEARCH_JOB_TIMEOUT_SEC = "300";
    };
  };
} 