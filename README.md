# dotfiles

Personal macOS dotfiles — Zsh, Neovim, Zellij, Yabai, Ghostty, cmux, Claude Code, Codex.

## Installation

```bash
git clone https://github.com/0xAndoroid/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/install_all.sh   # Rust, Homebrew, packages, Neovim, Zsh plugins, Claude Code, Bun
./scripts/setup_links.sh   # Symlink configs into system locations
./scripts/setup_macos.sh   # macOS system preferences
```

## Components

- **Shell**: Zsh + Oh My Zsh + Powerlevel10k (`zsh-defer` for fast startup)
- **Editor**: Neovim via `bob`, custom Lua config
- **Multiplexer**: cmux for pane focus and agent workflows; Zellij config remains for compatibility
- **Window Manager**: Yabai + skhd
- **Terminal**: Ghostty with Berkeley Mono Nerd Font
- **AI**: Claude Code (Perplexity MCP, hooks, skills, rules) + Codex
- **Git**: SSH signing, plain Git diffs, standard Git merges, global Rust pre-commit hook
- **Packages**: Homebrew (`Brewfile`), Cargo, npm

## Navigation

Ctrl+hjkl is owned by the active outer layer:

- cmux frontmost: skhd passes through; cmux focuses panes natively.
- Anything else: skhd focuses Yabai windows.

Nvim no longer participates in global navigation. Use `alt+hjkl` inside Nvim for split focus.

## Structure

```
.zshrc / .zshenv / .zprofile   Shell config (aliases, zoxide, fzf, daily auto-pull)
.gitconfig                      Git config (SSH signing, pushall alias)
.skhdrc / .yabairc              Window management
nvim/                           Neovim config (Lua)
zellij/                         Zellij config + agent plugins
ghostty/                        Ghostty terminal config
cmux/                           cmux app config
hunk/                           Hunk diff viewer config
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
./scripts/update_all.sh        # Update Homebrew, npm, Cargo, Zsh plugins
./scripts/update_yabai_skhd.sh # Rebuild and reinstall Yabai + skhd from source repos
```

The shell auto-pulls this repo daily on interactive login (`_dotfiles_daily_pull` in `.zshrc`).
