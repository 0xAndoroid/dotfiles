#!/bin/bash

sketchybar --add item keyboard right \
           --set keyboard update_freq=1 \
                        icon=⌨️ \
                        script="$PLUGIN_DIR/keyboard.sh" \
           --subscribe keyboard system_woke input_change