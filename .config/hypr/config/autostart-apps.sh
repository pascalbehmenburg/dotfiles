#!/bin/sh
# Launches the daily apps on their home workspaces at login.
#
# Workspaces 1-5 are bound to the external main screen (see
# handle_monitor_connect.sh, which pins them to whichever one is attached).
# External displays register a moment after Hyprland starts, so launching the
# apps immediately drops them on the laptop panel (their bound monitor isn't up
# yet). Wait for the main screen first, then launch - the apps land on it
# natively.
#
# Falls through after ~10s so a laptop-only session still gets its apps.

LAPTOP="eDP-1"

for _ in $(seq 1 40); do
  # Any connected display that isn't the built-in panel counts as the main
  # screen, so this works at home, at work, and on an unfamiliar dock alike.
  [ "$(hyprctl monitors -j | jq --arg laptop "$LAPTOP" \
        '[.[] | select(.name != $laptop)] | length')" -gt 0 ] && break
  sleep 0.25
done

hyprctl dispatch exec "[workspace 1 silent] zen-browser"
hyprctl dispatch exec "[workspace 2 silent] t3code"
hyprctl dispatch exec "[workspace 3 silent] obsidian"
# Workspace comes from a class rule in windowrules.conf: chromium hands the
# launch to an already running instance, so a PID-bound rule would miss it.
hyprctl dispatch exec "gtk-launch mdg-intranet"
hyprctl dispatch exec "[workspace 4 silent] thunderbird"
hyprctl dispatch exec "[workspace 5 silent] discord"
