# Commercial/unpackaged native Linux plugins, taken from the linux-plugins flake input
# (Nextcloud "Audio plugins/Linux"). Every .zip there is unpacked and every .vst3 bundle
# and .clap file inside it, or loose in the folder, is installed and patched.
# Add or update a plugin: drop its Linux archive (or bare .vst3/.clap) in the folder,
# then `nix flake update linux-plugins`. Keep files there non-executable: Nextcloud doesn't
# sync the exec bit, and the lock's hash includes it, so a stray +x breaks other machines.
# If the build stops on a missing library, add it to buildInputs.

{
  lib,
  stdenv,
  autoPatchelfHook,
  unzip,
  src,
  alsa-lib,
  cairo,
  curl,
  dbus,
  fontconfig,
  freetype,
  glib,
  harfbuzz,
  libGL,
  libice,
  libsm,
  libx11,
  libxcb,
  libxcb-cursor,
  libxcb-keysyms,
  libxcb-util,
  libxcb-wm,
  libxcursor,
  libxext,
  libxkbcommon,
  libxrandr,
  fetchzip,
  openssl,
  pango,
  wayland,
}:

let
  # PitchNet links against this exact release (versioned symbols), so nixpkgs' onnxruntime won't do
  onnxruntime-1_19 = stdenv.mkDerivation rec {
    pname = "onnxruntime-bin";
    version = "1.19.2";
    src = fetchzip {
      url = "https://github.com/microsoft/onnxruntime/releases/download/v${version}/onnxruntime-linux-x64-${version}.tgz";
      hash = "sha256-tnOg0KwlPBQl2r/Dli+MwhHB/88e4a/Ird2nidIGwEg=";
    };
    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ stdenv.cc.cc.lib ];
    installPhase = ''
      mkdir -p "$out/lib"
      cp -P lib/*.so* "$out/lib/"
    '';
  };
in
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
    cairo
    curl
    dbus
    fontconfig
    freetype
    glib
    harfbuzz
    libGL
    libice
    libsm
    libx11
    libxcb
    libxcb-cursor
    libxcb-keysyms
    libxcb-util
    libxcb-wm # libxcb-icccm.so.4
    libxcursor
    libxext
    libxkbcommon
    libxrandr
    onnxruntime-1_19
    openssl # libcrypto
    pango
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
    cp -r "$src"/*.clap "$src"/*.vst3 work/ 2>/dev/null || true
    chmod -R u+w work # store copies are read-only, and autoPatchelf edits in place
  '';

  installPhase = ''
    mkdir -p "$out/lib/vst3" "$out/lib/clap"
    find work -type d -name '*.vst3' -prune -exec cp -r {} "$out/lib/vst3/" \;
    find work -type f -name '*.clap' -exec cp {} "$out/lib/clap/" \;
  '';

  meta.platforms = [ "x86_64-linux" ];
}
