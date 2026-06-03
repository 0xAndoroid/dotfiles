# Neovim Navigation

Nvim does not participate in global Ctrl+hjkl navigation.

## Current Rules

- `ctrl+h/j/k/l`: reserved for cmux pane focus when cmux is frontmost, otherwise Yabai window focus through skhd.
- `alt+h/j/k/l`: Nvim split focus, configured in `lua/plugins/astrocore.lua`.
- Zellij is not part of Nvim edge navigation.

## Rationale

Nvim split navigation is intentionally local and simple. There is no split-navigation plugin, Zellij pipe, title detection, or Yabai fallback from inside Nvim.
