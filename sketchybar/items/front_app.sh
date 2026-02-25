#!/bin/bash

sketchybar --add item front_app q \
           --set front_app       background.color="$ACCENT_COLOR" \
                                 icon.color="$BAR_COLOR" \
                                 icon.font="sketchybar-app-font:Regular:16.0" \
                                 label.color="$BAR_COLOR" \
                                 script="$PLUGIN_DIR/front_app.sh" \
                                 padding_right=20 \
           --subscribe front_app front_app_switched
