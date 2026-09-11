# Enable Karakeep

{ config, pkgs, lib, ... }: 

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

  # Explicitly supply required module paths while overriding upstream default settings
  services.meilisearch.settings = lib.mkForce {
    db_path = "/var/lib/meilisearch";
    dump_dir = "/var/lib/meilisearch/dumps";
    snapshot_dir = "/var/lib/meilisearch/snapshots";
  };

  # Allow Meilisearch to automatically perform database schema upgrades on startup
  systemd.services.meilisearch.environment = {
    MEILI_UPGRADE_DB = "true";
  };
}