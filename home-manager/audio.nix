{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    (callPackage ../pkgs/amplitude/default.nix { })
    (callPackage ../pkgs/bitwig-studio6.nix { })
    (callPackage ../pkgs/native-plugins.nix { src = inputs.linux-plugins; })
    cardinal
    mixxx
    qpwgraph
    reaper
    sfizz
    vital
    yabridge
    yabridgectl
  ];
  # Plugins in home.packages need no links: NixOS puts the profile's lib/{vst,vst3,clap,lv2}
  # on VST_PATH, VST3_PATH, CLAP_PATH and LV2_PATH, which Bitwig reads.
  # Reaper ignores those, so add the /etc/profiles/per-user/jason/lib/* folders in its preferences.
}
