# Neovim-Yabai Navigation Integration

## Overview
Smart navigation system that seamlessly switches between neovim windows and yabai-managed windows using Ctrl+hjkl.

## How it works

### Components
1. **astrocore.lua** (`lua/plugins/astrocore.lua`): Contains `smart_navigation` function
2. **skhd config** (`../.skhdrc`): Uses title filtering to detect nvim

### Flow
1. Ctrl+hjkl pressed
2. skhd checks window title for "nvim" (using forked skhd with title filtering)
3. If nvim detected: key passes through to nvim
4. If not nvim: skhd runs yabai directly (no passthrough)
5. Inside nvim, `smart_navigation` moves within nvim windows or calls yabai at edges

### skhd syntax (forked version)
```
ctrl - h [
    "Ghostty" title~="nvim" ~    # passthrough when title contains "nvim"
    * : yabai -m window --focus west
]
```

## smart_navigation function
Tries to move within nvim windows first. If already at edge (window doesn't change), calls yabai to focus the adjacent macOS window.
