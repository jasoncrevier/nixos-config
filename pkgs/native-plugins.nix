# Commercial/unpackaged native Linux plugins, taken from the linux-plugins flake input
# (Nextcloud "Audio plugins/Linux"). Every .zip there is unpacked and every .vst3 bundle
# and .clap file inside it, or loose in the folder, is installed and patched.
# Add or update a plugin: drop its Linux archive in the folder, then `nix flake update linux-plugins`.
# If the build stops on a missing library, add it to buildInputs.

{
  lib,
  stdenv,
  autoPatchelfHook,
  unzip,
  src,
  alsa-lib,
  curl,
  dbus,
  fontconfig,
  freetype,
  libGL,
  libx11,
  libxcb,
  libxcb-wm,
  libxcursor,
  libxext,
  libxrandr,
  wayland,
}:

stdenv.mkDerivation {
  pname = "native-plugins";
  version = "0";
  inherit src;
  # Just unzipping and patching; no point shipping the archives to a remote builder
  preferLocalBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];
  buildInputs = [
    alsa-lib
    dbus
    fontconfig
    freetype
    libGL
    libx11
    libxcb
    libxcb-wm # libxcb-icccm.so.4
    libxcursor
    libxext
    libxrandr
    stdenv.cc.cc.lib # libstdc++, libatomic
    wayland
  ];
  # Loaded with dlopen, so autoPatchelf can't see them (runtimeDependencies only covers executables)
  appendRunpaths = [
    "${lib.getLib curl}/lib" # Tape Fiasco 2 license activation
  ];

  unpackPhase = ''
    mkdir work
    for zip in "$src"/*.zip; do
      unzip -q "$zip" -d "work/$(basename "$zip" .zip)"
    done
    cp "$src"/*.clap work/ 2>/dev/null || true
  '';

  installPhase = ''
    mkdir -p "$out/lib/vst3" "$out/lib/clap"
    find work -type d -name '*.vst3' -prune -exec cp -r {} "$out/lib/vst3/" \;
    find work -type f -name '*.clap' -exec cp {} "$out/lib/clap/" \;
  '';

  meta.platforms = [ "x86_64-linux" ];
}
