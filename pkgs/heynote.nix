{ lib, appimageTools, fetchurl, desktop-file-utils, nix-update-script }:

  let
    pname = "heynote";
    version = "2.1.3";

    src = fetchurl {
        url = "https://github.com/heyman/heynote/releases/download/v${version}/Heynote_${version}_x86_64.AppImage";
        sha256 = "sha256-O8loDE2GzXQofh3iNQeP5OAWh7i0QCSxl4I++ERcjbU=";
    };
    
    appimageContents = appimageTools.extractType2 {
      inherit version pname src;
    };

  in

  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
    mkdir -p $out/share/pixmaps $out/share/licenses/heynote
    cp ${appimageContents}/heynote.png $out/share/pixmaps/
    cp ${appimageContents}/heynote.desktop $out
    cp ${appimageContents}/LICENSE.electron.txt $out/share/licenses/heynote/LICENSE
    mv $out/bin/${pname} $out/bin/heynote-temp
    mv $out/bin/heynote-temp $out/bin/heynote
    ${desktop-file-utils}/bin/desktop-file-install --dir $out/share/applications \
      --set-key Exec --set-value $out/bin/heynote \
      --set-key Comment --set-value "Heynote" \
      --delete-original $out/heynote.desktop
    '';

    passthru.updateScript = nix-update-script { };

    meta = with lib; {
      description = "A dedicated scratchpad for developers";
      homepage = "https://heynote.com/";
      license = with licenses; [ mit commons-clause ];
      maintainers = with maintainers; [ jasoncrevier ];
      platforms = platforms.x86_64;
    };

  }