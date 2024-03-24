{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
  ollama
  gpt4all
  ];
}
