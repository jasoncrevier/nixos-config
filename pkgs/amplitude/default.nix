{
  lib,
  buildDotnetModule,
  dotnet-sdk_10,
  fetchFromGitHub,
  nix-update-script,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  imagemagick,
  makeWrapper,
  libxkbcommon,
  fontconfig,
  glib,
  alsa-lib,
  alsa-plugins,
  libpulseaudio,
  xclip,
  xsel,
  wl-clipboard,
  libX11,
  libXext,
  libXfixes,
  libXi,
  libXinerama,
  libXrandr,
  libXrender,
  libXt,
  libXtst,
}:

buildDotnetModule (finalAttrs: {
  pname = "amplitude-soundboard";
  version = "2.13.1";

  dotnet-sdk = dotnet-sdk_10;

  src = fetchFromGitHub {
    owner = "dan0v";
    repo = "AmplitudeSoundboard";
    tag = finalAttrs.version;
    hash = "sha256-VRWa1jL23wlGU1Q/C1gOz9ycuOOCOV/oeU9/NJGALVU=";
  };

  projectFile = "AmplitudeSoundboard.csproj";
  nugetDeps = ./deps.json;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    imagemagick
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    alsa-plugins
    fontconfig
    glib
    libpulseaudio
    libX11
    libXext
    libXfixes
    libXi
    libXinerama
    libxkbcommon
    libXrandr
    libXrender
    libXt
    libXtst
  ];

  executables = [ "amplitude_soundboard" ];

  postInstall = ''
    tmpdir=$(mktemp -d)
    magick "$src/Assets/Icon.ico" "$tmpdir/icon.png"
    for img in "$tmpdir"/icon*.png; do
      [ -f "$img" ] || continue
      size=$(magick identify -format "%wx%h" "$img")
      mkdir -p "$out/share/icons/hicolor/$size/apps"
      cp "$img" "$out/share/icons/hicolor/$size/apps/amplitude-soundboard.png"
    done
    rm -rf "$tmpdir"
  '';

  postFixup = ''
    wrapProgram $out/bin/amplitude_soundboard \
      --prefix PATH : "${
        lib.makeBinPath [
          xclip
          xsel
          wl-clipboard
        ]
      }" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          alsa-lib
          alsa-plugins
          glib
          libpulseaudio
          libX11
          libXext
          libXfixes
          libXi
          libXinerama
          libxkbcommon
          libXrandr
          libXrender
          libXtst
        ]
      }" \
      --set AVALONIA_X11_USE_DBUS_MENU 0 \
      --set AVALONIA_X11_WM_OVERRIDE_REDIRECT 0
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "amplitude-soundboard";
      exec = "amplitude_soundboard";
      icon = "amplitude-soundboard";
      desktopName = "Amplitude Soundboard";
      genericName = "Soundboard";
      comment = "A sleek, cross-platform soundboard";
      categories = [
        "AudioVideo"
        "Audio"
        "Player"
      ];
      terminal = false;
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A sleek, cross-platform soundboard, available for Windows, MacOS, and Linux";
    homepage = "https://github.com/dan0v/AmplitudeSoundboard";
    changelog = "https://github.com/dan0v/AmplitudeSoundboard/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ jasoncrevier ];
    mainProgram = "amplitude_soundboard";
    platforms = lib.platforms.linux;
  };
})