# Commercial/unpackaged native Linux plugins, taken from the linux-plugins flake input
# (Nextcloud "Audio plugins/Linux"). Every .zip there is unpacked and every .vst3 bundle
# and .clap file inside it, or loose in the folder, is installed and patched.
# Add or update a plugin: drop its Linux archive (or bare .vst3/.clap) in the folder,
# then `plugins-update` (also copies it to nix-server for the binary cache). Keep files there non-executable: Nextcloud doesn't
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
  fetchurl,
  openssl,
  pango,
  wayland,
}:

let
  # PitchNet links against this exact release (versioned symbols), so nixpkgs' onnxruntime won't do.
  # From NuGet: github.com/microsoft/onnxruntime went 404 on 2026-11-22, taking its release
  # tarballs with it. The NuGet package's library is the same build (identical code and symbols).
  onnxruntime-1_19 = stdenv.mkDerivation rec {
    pname = "onnxruntime-bin";
    version = "1.19.2";
    src = fetchurl {
      url = "https://api.nuget.org/v3-flatcontainer/microsoft.ml.onnxruntime/${version}/microsoft.ml.onnxruntime.${version}.nupkg";
      hash = "sha256-+hM8j+YjhEWg3T6ER7qlx9FvQYyqjldsfiU7p3snths=";
    };
    nativeBuildInputs = [
      autoPatchelfHook
      unzip
    ];
    buildInputs = [ stdenv.cc.cc.lib ];
    unpackPhase = ''
      unzip -q "$src" 'runtimes/linux-x64/native/*'
    '';
    # Same layout as the old GitHub tarball: the real file, plus the soname and dev links
    installPhase = ''
      mkdir -p "$out/lib"
      cd runtimes/linux-x64/native
      cp libonnxruntime.so "$out/lib/libonnxruntime.so.${version}"
      ln -s "libonnxruntime.so.${version}" "$out/lib/libonnxruntime.so.1"
      ln -s "libonnxruntime.so.1" "$out/lib/libonnxruntime.so"
      cp libonnxruntime_providers_shared.so "$out/lib/"
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
