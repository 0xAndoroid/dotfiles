#!/bin/bash

# Get the current input source using inputsource CLI tool if available
if command -v inputsource >/dev/null 2>&1; then
  CURRENT_INPUT=$(inputsource)
else
  # Fallback method using defaults
  CURRENT_INPUT=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | grep -A 3 "KeyboardLayout Name" | awk -F'"' '/KeyboardLayout Name/{print $4}')
fi

# If nothing found, try alternative method
if [ -z "$CURRENT_INPUT" ]; then
  CURRENT_INPUT=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID | awk -F '.' '{print $NF}')
fi

# Map to display names
case "$CURRENT_INPUT" in
  *"Dvorak"*|*"US"*|*"ABC"*|*"U.S."*)
    LABEL="EN"
    ;;
  *"Russian"*)
    LABEL="RU"
    ;;
  *"Ukrainian"*)
    LABEL="UA"
    ;;
  *)
    # Default case for any other layouts
    LABEL="$CURRENT_INPUT"
    ;;
esac

sketchybar --set "$NAME" label="$LABEL"