# Use: nix-shell patch-vst.nix --run "autoPatchelf \"/path/to/plugin\""
# Add additional buildInputs to the list below if the plugin has additional dependencies that need to be patched

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.autoPatchelfHook
  ];
  buildInputs = with pkgs; [
    wayland
    dbus
    libx11
    libxcb
    libxcb-wm
    libGL
    libxkbcommon
    fontconfig
    freetype
    stdenv.cc.cc.lib
    xorg.libXcursor
    xorg.libXrandr
  ];
}
