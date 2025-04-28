#!/bin/bash

if [ -f /tmp/nvim_edge_move_lock ]; then
  exit 0
fi

WINDOW_INFO=$(yabai -m query --windows --window)

WINDOW_TITLE=$(echo "$WINDOW_INFO" | jq -r '.title')
APP_NAME=$(echo "$WINDOW_INFO" | jq -r '.app')

if [[ "$APP_NAME" == "iTerm2" || "$APP_NAME" == "Terminal" || "$APP_NAME" == "Ghostty" || "$APP_NAME" == "Alacritty" ]]; then
  if [[ "$WINDOW_TITLE" == *"Nvim"* || "$WINDOW_TITLE" == *"neovim"* ]]; then
    exit 0 
  fi
fi

exit 1
