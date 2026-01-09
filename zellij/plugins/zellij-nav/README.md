# zellij-nav

Custom Zellij plugin for seamless navigation between Neovim, Zellij panes, and Yabai windows.

## Features

- Three-layer navigation: nvim splits → zellij panes → yabai windows
- Detects Neovim via running command or pane title
- Coordinates with nvim's smart-splits via pipe messaging

## Build

```bash
./build.sh
```

Requires:
- Rust with `wasm32-wasip1` target (`rustup target add wasm32-wasip1`)

## Usage

Configured in `~/.dotfiles/zellij/config.kdl`:

```kdl
bind "Ctrl h" {
    MessagePlugin "file:~/.dotfiles/zellij/plugins/zellij-nav.wasm" {
        name "move_focus";
        payload "left";
    };
}
```

## Architecture

```
Ctrl+H pressed in zellij
       ↓
   [zellij-nav: move_focus]
       ↓
  current pane is nvim?
    ├─ YES → write Ctrl+H to nvim
    │           ↓
    │    [smart-splits.nvim]
    │        ↓
    │   at nvim split edge?
    │     ├─ NO  → move nvim split (done)
    │     └─ YES → at_edge handler
    │                ↓
    │         [zellij pipe nvim_at_edge]
    │                ↓
    │         [zellij-nav: nvim_at_edge]
    │                ↓
    │         at zellij pane edge?
    │           ├─ NO  → zellij move_focus
    │           └─ YES → yabai focus window
    │
    └─ NO  → at zellij edge?
              ├─ YES → yabai focus window
              └─ NO  → zellij move_focus
```
