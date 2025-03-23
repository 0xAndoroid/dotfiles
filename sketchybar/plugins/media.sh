#!/bin/bash

STATE="$(echo "$INFO" | jq -r '.state')"
if [ "$STATE" = "playing" ]; then
  if [ "$(echo "$INFO" | jq -r '.title')" != "" ]; then
    MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"
    sketchybar --set "$NAME" label="$MEDIA" drawing=on
  else 
    sketchybar --set "$NAME" drawing=on
  fi
else
  sketchybar --set "$NAME" drawing=off
fi
