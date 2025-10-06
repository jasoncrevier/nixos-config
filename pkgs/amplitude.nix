{ lib
, fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
, ...
}:

let
  pname = "amplitude_soundboard";
  version = "2.11.0";
in

buildDotnetModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "dan0v";
    repo = "AmplitudeSoundboard";
    rev = version;
    sha256 = "1gnvcx9g340xbvzjq9n3l8y8f3akix97fcnmvvyxca60g38ikar3";
    stripRoot = true;
  };

  projectFile = "AmplitudeSoundboard.csproj";

  # Pre-declared NuGet dependencies for a hermetic build
  nugetDeps = [
    "Avalonia/11.0.0"
    "Avalonia.Desktop/11.0.0"
    "Avalonia.ReactiveUI/11.0.0"
    "Avalonia.Themes.Fluent/11.0.0"
    "Avalonia.Controls.ColorPicker/11.0.0"
    "ManagedBass/2.5.0"
    "ManagedBass.Flac/1.2.0"
    "ManagedBass.Mix/1.3.0"
    "ManagedBass.Opus/1.1.0"
    "SharpHook/2.0.0"
  ];

  # Use supported .NET SDK 8.0
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  executables = [ "AmplitudeSoundboard" ];

  extraInstallCommands = ''
    mkdir -p $out/share/applications $out/share/icons/hicolor/256x256/apps

    # Install .DirIcon if it exists
    if [ -f "$DOTNET_SRC/.DirIcon" ]; then
      install -Dm444 $DOTNET_SRC/.DirIcon $out/share/icons/hicolor/256x256/apps/${pname}.png
    fi

    # Install .desktop file if it exists
    if [ -f "$DOTNET_SRC/AmplitudeSoundboard/AmplitudeSoundboard.desktop" ]; then
      desktop_out="$out/share/applications/${pname}.desktop"
      install -Dm644 $DOTNET_SRC/AmplitudeSoundboard/AmplitudeSoundboard.desktop "$desktop_out"

      substituteInPlace "$desktop_out" \
        --replace-fail 'Exec=AmplitudeSoundboard' "Exec=${pname} %U" || true \
        --replace-fail 'Icon=app' "Icon=${pname}" || true
    fi
  '';

  meta = with lib; {
    description = "Amplitude Soundboard (built from source with .NET 8, hermetic)";
    homepage = "https://amplitude-soundboard.dan0v.com/";
    license = licenses.mit;
    maintainers = [ maintainers.jasoncrevier ];
    platforms = platforms.linux;
  };
}
