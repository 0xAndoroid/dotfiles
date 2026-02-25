#!/bin/bash

if [ "$SENDER" = "space_windows_change" ]; then
  space="$(echo "$INFO" | jq -r '.space')"
  
  # Get all apps in the current space using yabai, filtering out sticky windows
  current_space_windows=$(/usr/local/bin/yabai -m query --windows --space "$space")
  non_sticky_windows=$(echo "$current_space_windows" | jq '[.[] | select(."is-sticky"==false)]')
  
  # Extract unique app names from non-sticky windows
  apps=$(echo "$non_sticky_windows" | jq -r '.[].app' | sort | uniq)

  icon_strip=" "
  if [ -n "$apps" ]; then
    while read -r app; do
      if [ -n "$app" ]; then
        icon_strip+=" $("$CONFIG_DIR"/plugins/icon_map_fn.sh "$app")"
      fi
    done <<<"$apps"
  else
    icon_strip=" —"
  fi

  sketchybar --set space."$space" label="$icon_strip"
fi
