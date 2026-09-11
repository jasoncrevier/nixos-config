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
    xcbutil          # libxcb-util.so.1
    xcbutilcursor    # libxcb-cursor.so.0
    glib             # libglib-2.0.so.0, libgobject-2.0.so.0
    cairo            # libcairo.so.2
    pango            # libpango-1.0.so.0, libpangocairo, libpangoft2
    harfbuzz         # libharfbuzz.so.0
    libGL
    libxkbcommon
    fontconfig
    freetype
    stdenv.cc.cc.lib
    libsm            # libSM.so.6
    libxcursor       # libXcursor.so.1
    libxrandr        # libXrandr.so.2
  ];
}