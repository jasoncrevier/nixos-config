#!/usr/bin/env bash

# Single monitor at 1600x1200 (4:3)
kscreen-doctor \
    output.HDMI-A-1.enable \
    output.HDMI-A-1.mode.1920x1080@75 \
    output.HDMI-A-1.scale.1.25 \
    output.DP-1.disable \
    output.DP-2.disable
