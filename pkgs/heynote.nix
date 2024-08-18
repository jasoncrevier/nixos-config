{ appimageTools, fetchurl }:

    let
      pname = "heynote";
      version = "1.8.0";

      src = fetchurl {
        url = "https://github.com/heyman/heynote/releases/download/v${version}/Heynote_${version}_x86_64.AppImage";
        sha256 = "sha256-NzrXV8HmCPYE+D3tEwVv3rBkLF0/FKW6uJdqhKmH8uw=";
      };
    in

    appimageTools.wrapType2 {
      inherit pname version src;
    }