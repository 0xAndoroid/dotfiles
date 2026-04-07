# dotfiles

Personal macOS dotfiles — Zsh, Neovim, Zellij, Yabai, Ghostty, Claude Code, Codex.

## Installation

```bash
git clone https://github.com/0xAndoroid/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/install_all.sh   # Rust, Homebrew, packages, Neovim, Zsh plugins, Claude Code, Bun
./scripts/setup_links.sh   # Symlink configs into system locations
./scripts/install_mcp.sh   # PAL MCP server for Claude/Codex
./scripts/setup_macos.sh   # macOS system preferences
```

## Components

- **Shell**: Zsh + Oh My Zsh + Powerlevel10k (`zsh-defer` for fast startup)
- **Editor**: Neovim via `bob`, custom Lua config
- **Multiplexer**: Zellij with custom WASM plugins (`zellij-nav`, `zellaude`)
- **Window Manager**: Yabai + skhd
- **Terminal**: Ghostty with Iosevka Custom Nerd Font
- **AI**: Claude Code (MCP servers, hooks, skills, rules) + Codex
- **Git**: SSH signing, difftastic diffs, mergiraf merge driver, global Rust pre-commit hook
- **Packages**: Homebrew (`Brewfile`), Cargo, npm

## Navigation

Ctrl+hjkl navigates seamlessly across Neovim splits → Zellij panes → Yabai windows. See `nvim/CLAUDE.md` for the full flow diagram.

skhd intercepts keypresses → routes based on Ghostty window title → `zellij-nav` WASM plugin detects Neovim → `smart-splits.nvim` handles edge cascading back through the stack.

## Structure

```
.zshrc / .zshenv / .zprofile   Shell config (aliases, zoxide, fzf, daily auto-pull)
.gitconfig                      Git config (SSH signing, difftastic, pushall alias)
.skhdrc / .yabairc              Window management
nvim/                           Neovim config (Lua)
zellij/                         Zellij config + WASM plugins (zellij-nav, zellaude)
ghostty/                        Ghostty terminal config
lazygit/                        Lazygit config
claude/                         Claude Code settings, MCP, hooks, skills, rules
codex/                          Codex config (shares skills with Claude)
git-hooks/                      Global pre-commit (Rust fmt + typos) and post-commit
scripts/                        Install, setup, and update scripts
IosevkaCustom/                  Custom Iosevka Nerd Font family
wallpapers/                     Desktop wallpapers
Brewfile                        Homebrew package manifest
```

## Maintenance

```bash
./scripts/update_all.sh   # Update Homebrew, npm, Cargo, Zsh plugins
```

The shell auto-pulls this repo daily on interactive login (`_dotfiles_daily_pull` in `.zshrc`).