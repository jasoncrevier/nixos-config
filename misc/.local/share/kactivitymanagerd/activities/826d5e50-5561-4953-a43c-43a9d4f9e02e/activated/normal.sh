#!/usr/bin/env bash

# Normal 3 monitor setup
kscreen-doctor \
    output.DP-1.enable \
    output.DP-1.mode.1 \
    output.DP-1.rotation.right \
    output.DP-1.position.0,0 \
    output.HDMI-A-1.enable \
    output.HDMI-A-1.mode.2560x1080@100 \
    output.HDMI-A-1.position.1080,420 \
    output.HDMI-A-1.scale.1 \
    output.DP-2.enable \
    output.DP-2.mode.1920x1080@75 \
    output.DP-2.position.3640,420
