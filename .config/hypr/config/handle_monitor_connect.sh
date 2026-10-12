#!/bin/sh
# Pins each workspace to its home monitor. Runs once at login and again on every
# monitor (dis)connect, so a slow-to-wake external display or docking/undocking
# the laptop can't leave workspaces stranded on the wrong screen.

LAPTOP="eDP-1"              # built-in laptop panel
MAIN_WORKSPACES="1 2 3 4 5" # live on the external main screen
LAPTOP_WORKSPACES="8 9"     # always stay on the built-in panel

# The main screen is whichever connected display isn't the laptop panel; with
# more than one attached, the widest wins. Detecting it by shape rather than by
# port name means docking somewhere new (home HDMI, work DP, a different dock
# handing out DP-2) needs no config change.
main_monitor() {
  hyprctl monitors -j \
    | jq -r --arg laptop "$LAPTOP" \
        '[.[] | select(.name != $laptop)] | sort_by(-.width) | .[0].name // empty'
}

arrange() {
  main=$(main_monitor)

  if [ -n "$main" ]; then
    for ws in $MAIN_WORKSPACES; do
      # Rebind the rule as well as moving the workspace, so windows opened from
      # here on land on the main screen natively instead of being shuffled over
      # after the fact.
      hyprctl keyword workspace "$ws, monitor:$main, persistent:true"
      hyprctl dispatch moveworkspacetomonitor "$ws $main"
    done
  fi

  # Laptop-only mode: leave 1-5 wherever they are (the panel is the only screen).
  for ws in $LAPTOP_WORKSPACES; do
    hyprctl dispatch moveworkspacetomonitor "$ws $LAPTOP"
  done
}

# Initial pass: covers the login race where autostart apps open before the
# external display has registered.
arrange

# Re-arrange on every monitor add/remove (e.g. docking the laptop).
#
# `-u` (unidirectional: socket -> stdout) is required, not cosmetic. With a bare
# `-`, socat treats stdio as a second data channel and exits as soon as stdin
# hits EOF. Under `exec-once` stdin is already closed, so the listener died
# immediately at login and only the single `arrange` pass above ever ran - which
# left docking and undocking unhandled for the rest of the session.
socat -u "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" - \
  | while read -r line; do
      case $line in
        monitoradded*|monitorremoved*) arrange ;;
      esac
    done
