{
  lib,
  buildDotnetModule,
  dotnet-sdk_10,
  fetchFromGitHub,
  nix-update-script,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  icoutils,
  makeWrapper,
  xorg,
  libxkbcommon,
  fontconfig,
  glib,
  alsa-lib,
  alsa-plugins,
  libpulseaudio,
  xclip,
  xsel,
  wl-clipboard,
}:

buildDotnetModule (finalAttrs: {
  pname = "amplitude-soundboard";
  version = "2.13.1";

  dotnet-sdk = dotnet-sdk_10;

  DOTNET_NUGET_SIGNATURE_VERIFICATION = "false";

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
    icoutils
    makeWrapper
  ];

  buildInputs = [
    xorg.libXtst
    xorg.libXt
    xorg.libX11
    xorg.libXinerama
    xorg.libXi
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXext
    xorg.libXrender
    xorg.libXfixes
    libxkbcommon
    fontconfig
    glib
    alsa-lib
    alsa-plugins
    libpulseaudio
  ];

  executables = [ "amplitude_soundboard" ];

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    icotool -x -w 256 $src/Assets/Icon.ico -o $out/share/icons/hicolor/256x256/apps/amplitude-soundboard.png || true
  '';

  postFixup = ''
    wrapProgram $out/bin/amplitude_soundboard \
      --prefix PATH : "${lib.makeBinPath [ xclip xsel wl-clipboard ]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        alsa-lib
        alsa-plugins
        libpulseaudio
        xorg.libX11
        xorg.libXext
        xorg.libXi
        xorg.libXcursor
        xorg.libXinerama
        xorg.libXrandr
        xorg.libXrender
        xorg.libXfixes
        xorg.libXtst
        libxkbcommon
        glib
      ]}" \
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
      categories = [ "AudioVideo" "Audio" "Player" ];
      terminal = false;
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A sleek, cross-platform soundboard, available for Windows, MacOS, and Linux";
    homepage = "https://github.com/dan0v/AmplitudeSoundboard";
    changelog = "https://github.com/dan0v/AmplitudeSoundboard/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "amplitude_soundboard";
    platforms = lib.platforms.linux;
  };
})