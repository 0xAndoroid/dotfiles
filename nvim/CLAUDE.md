# Neovim-Yabai Navigation Integration

## Overview
Smart navigation system that seamlessly switches between neovim windows and yabai-managed windows using Ctrl+hjkl.

## How it works

### Components
1. **smart-splits.lua** (`lua/plugins/smart-splits.lua`): Configures smart-splits with yabai `at_edge` handler
2. **skhd config** (`../.skhdrc`): Uses title filtering to detect nvim

### Flow
1. Ctrl+hjkl pressed
2. skhd checks window title for "nvim" (using forked skhd with title filtering)
3. If nvim detected: key passes through to nvim
4. If not nvim: skhd runs yabai directly (no passthrough)
5. Inside nvim, smart-splits moves within nvim windows or calls yabai at edges via `at_edge` handler

### skhd syntax (forked version)
```
ctrl - h [
    "Ghostty" title~="nvim" ~    # passthrough when title contains "nvim"
    * : yabai -m window --focus west
]
```

## smart-splits yabai integration
Uses smart-splits plugin with custom `at_edge` function that calls yabai when cursor is at the edge of nvim splits.
