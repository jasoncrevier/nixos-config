 # Enable Karakeep
 
{ config, pkgs, ... }: 

let
  karakeep_env = config.sops.secrets.karakeep_env.path;
in
{
  sops.secrets.karakeep_env.owner = "karakeep";
  services.karakeep = {
    enable = true;
    environmentFile = karakeep_env;
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