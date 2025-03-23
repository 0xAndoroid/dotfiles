#!/bin/bash

if [ "$SENDER" = "space_windows_change" ]; then
  space="$(echo "$INFO" | jq -r '.space')"
  apps="$(echo "$INFO" | jq -r '.apps | keys[]')"

  # Get all apps in the current space using yabai
  current_space_windows=$(/usr/local/bin/yabai -m query --windows --space "$space")

  # Check if the only Arc window in this space is AXSystemDialog
  arc_windows=$(echo "$current_space_windows" | jq '[.[] | select(.app=="Arc")]')
  arc_system_dialogs=$(echo "$arc_windows" | jq '[.[] | select(.subrole=="AXSystemDialog")]')

  # If all Arc windows are AXSystemDialogs, remove Arc from the apps list
  if [ "$(echo "$arc_windows" | jq 'length')" -gt 0 ] && [ "$(echo "$arc_windows" | jq 'length')" = "$(echo "$arc_system_dialogs" | jq 'length')" ]; then
    # Filter out Arc from the apps list
    apps=$(echo "$apps" | grep -v "^Arc$")
  fi

  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app; do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
    done <<<"${apps}"
  else
    icon_strip=" —"
  fi

  sketchybar --set space.$space label="$icon_strip"
fi
