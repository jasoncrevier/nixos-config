{ pkgs, ... }:

{
  home.packages = with pkgs; [
    discord
    (element-desktop.override {
      commandLineArgs = "--ozone-platform=x11";
    })
    mumble
    telegram-desktop
    zulip
  ];
}
