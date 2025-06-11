# Neovim-Yabai Navigation Integration

## Overview
This codebase implements a smart navigation system that seamlessly switches between neovim windows and yabai-managed windows using Ctrl+hjkl.

## How it works

### Components
1. **astrocore.lua** (`lua/plugins/astrocore.lua:1-116`): Contains `smart_navigation` function that handles window navigation
2. **skhd config** (`../.skhdrc:8-11`): Intercepts Ctrl+hjkl and checks if nvim should handle it
3. **is_nvim_window.sh** (`../is_nvim_window.sh:1-19`): Determines if current window is nvim based on lock file

### Flow
1. When nvim gains focus, it creates `/tmp/nvim_edge_move_lock` 
2. When Ctrl+hjkl is pressed:
   - skhd checks if lock file exists via `is_nvim_window.sh`
   - If yes, the keypress passes through to nvim
   - If no, skhd handles the yabai window focus
3. Inside nvim, `smart_navigation` tries to move within nvim windows
4. If at edge window, nvim calls yabai directly

## Known Issues

### <C-l> Sometimes Fails at Rightmost Window
Potential causes:
1. **Async timing**: Original code uses `detach = true` for yabai calls
2. **Focus events unreliable**: FocusGained/FocusLost autocmds may not fire properly in:
   - Terminal multiplexers (tmux)
   - Quick space/display switches
   - Certain terminal emulators
3. **Lock file stale**: If focus event doesn't fire, lock file remains when it shouldn't
4. **Event loop blocking**: During heavy processing, vim.system calls may be delayed

## Debugging

### Debug Commands
- `:NavigationDebug` - Show last 20 navigation attempts from log
- `:NavigationDebugClear` - Clear the debug log

### Debug Log Location
`/tmp/nvim_navigation_debug.log`

### Log Format
Each navigation attempt logs:
- Timestamp
- Direction attempted (h/j/k/l)
- Yabai direction (west/south/north/east)
- Window count in nvim
- Current buffer name
- Whether navigation succeeded within nvim or went to yabai
- Yabai command exit codes and errors

### Quick Fixes to Try
1. Change `detach = true` to `detach = false` in original smart_navigation
2. Check if `/tmp/nvim_edge_move_lock` exists when issue occurs
3. Manually remove lock file: `rm /tmp/nvim_edge_move_lock`

## Current Implementation (with debugging)
The `smart_navigation` function now includes:
- Detailed logging of each navigation attempt
- Synchronous yabai execution with timeout
- Retry mechanism with delay if first attempt fails
- Debug commands for inspection