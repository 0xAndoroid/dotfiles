# Neovim-Zellij-Yabai Navigation Integration

## Overview
Three-layer navigation system that seamlessly switches between neovim splits, zellij panes, and yabai-managed windows using Ctrl+hjkl.

## Architecture

```
User presses Ctrl+H
       ↓
   [skhd] checks Ghostty title
       ↓
  title = "* | *"?  (zellij format: "session | pane_title")
    ├─ YES → Pass to zellij
    │           ↓
    │    [zellij-nav plugin] (custom WASM, src in zellij/plugins/zellij-nav/)
    │           ↓
    │      current pane is nvim?  (checks client running_command + pane title)
    │        ├─ YES → write_chars(Ctrl+h) to pane
    │        │           ↓
    │        │    [smart-splits.nvim]
    │        │        ↓
    │        │   at nvim split edge?
    │        │     ├─ NO  → Move nvim split
    │        │     └─ YES → at_edge handler
    │        │                ↓
    │        │         zellij pipe → nvim_at_edge → plugin
    │        │           ├─ at zellij edge → yabai focus window
    │        │           └─ not at edge   → zellij MoveFocus
    │        │
    │        └─ NO → at zellij edge?
    │                  ├─ YES → yabai focus window
    │                  └─ NO  → zellij MoveFocus
    │
    └─ NO (title = "*- Nvim"?)
          ├─ YES → Pass to nvim (direct, no zellij)
          │           ↓
          │    [smart-splits.nvim] → at_edge → yabai
          │
          └─ NO → yabai -m window --focus directly
```

## Components

1. **skhd** (`../.skhdrc`): OS-level hotkey daemon with title filtering
2. **zellij-nav**: Custom WASM plugin (`../zellij/plugins/zellij-nav/src/main.rs`), compiled to `zellij-nav.wasm`
3. **zellij** (`../zellij/config.kdl`): `default_mode "normal"`, Ctrl+hjkl bound in both locked and `shared_except "locked"`
4. **smart-splits.nvim** (`lua/plugins/smart-splits.lua`): `multiplexer_integration = false`, custom `at_edge` handler pipes back to zellij-nav

## Configuration Files

### skhd (`.skhdrc`)
```
ctrl - h [
    "Ghostty" title="* | *" ~       # zellij: passthrough (session | pane_title format)
    "Ghostty" title="*- Nvim" ~      # nvim direct: passthrough
    * : yabai -m window --focus west # default: yabai
]
```

### zellij-nav plugin
- Nvim detection: `client.running_command` match → fallback to `pane.title` match
- Edge detection: compares pane position against tab display area
- Yabai invocation: `run_command` from WASM sandbox

### smart-splits.nvim
- `multiplexer_integration = false` — zellij-nav handles pane movement
- Custom `at_edge` handler: if `$ZELLIJ` set → `zellij pipe --name nvim_at_edge`, else → yabai directly

## Shell Integration

oh-my-zsh (via `lib/termsupport.zsh`) sets terminal title:
- precmd: `user@host:path` (e.g., `andoroid@Mac:~/.dotfiles`)
- preexec: includes command name (e.g., `nvim filename`)

Zellij composes Ghostty window title as: `<session_name> | <pane_title>`

## Known Limitation

SSH: remote nvim's `at_edge` handler can't pipe back to local zellij (no `$ZELLIJ` / IPC path on remote). Ctrl+hjkl navigates remote nvim splits (detected via terminal title propagation), but edge→zellij/yabai navigation doesn't work over SSH.
