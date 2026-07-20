{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      vtk = prev.vtk.overrideAttrs (oldAttrs: {
        env = (oldAttrs.env or { }) // {
          NIX_CFLAGS_COMPILE = "${oldAttrs.env.NIX_CFLAGS_COMPILE or ""} -fpermissive";
        };
      });
    })
  ];

  home.packages = with pkgs; [
    cura-appimage
    f3d
  ];
}