# Inspired by pkgs/applications/editors/uivonim/default.nix
# and pkgs/by-name/in/indiepass-desktop/package.nix
{ lib, buildNpmPackage, fetchFromGitHub, electron }:

buildNpmPackage rec {
  pname = "Heynote";
  version = "1.8.0";

  src = fetchFromGitHub {
        owner = "heyman";
        repo = "heynote";
        rev = "v${version}";
        hash = "sha256-L6hxmWBYgNyeWSw7kBDKTocv0BHGGcuXvY8RZAWfXto=";
    };

  npmDepsHash = "sha256-zSlnb6iLKA3/zxvp04pDpkkd8ldCocKxlULup6qtrGM="; # you will get an error about mismatching hash the first time. Just copy the hash here

  # Useful for debugging, just run "nix-shell" and then "electron ."
  nativeBuildInputs = [
    electron
  ];

  # Otherwise it will try to run a build phase (via npm build) that we don't have or need, with an error:
  # Missing script: "build"
  # This method is used in pkgs/by-name/in/indiepass-desktop/package.nix
  dontNpmBuild = true;

  # Needed, otherwise you will get an error:
  # RequestError: getaddrinfo EAI_AGAIN github.com
  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };
  
  # The node_modules/XXX is such that XXX is the "name" in package.json
  # The path might differ, for instance in electron-forge you need build/main/main.js
  postInstall = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags --type=module $out/lib/node_modules/${pname}/src/main.js
  '';

}