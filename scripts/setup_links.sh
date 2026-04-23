#!/bin/bash

# Create symbolic links to dotfiles

create_link() {
    source="$1"
    target="$2"

    # Check if target already exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        # Check if it's already the correct link
        if [ "$(readlink "$target")" = "$source" ]; then
            echo "✓ Link already exists: $target -> $source"
        else
            echo "⚠️  Cannot create link: $target already exists and points elsewhere"
        fi
    else
        # Create the directory if it doesn't exist
        mkdir -p "$(dirname "$target")"

        # Create the symbolic link
        ln -s "$source" "$target"
        echo "✅ Created link: $target -> $source"
    fi
}

# Home directory dotfiles
create_link ~/.dotfiles/.zshrc ~/.zshrc
create_link ~/.dotfiles/.zshenv ~/.zshenv
create_link ~/.dotfiles/.zprofile ~/.zprofile
create_link ~/.dotfiles/.gitconfig ~/.gitconfig
create_link ~/.dotfiles/.skhdrc ~/.skhdrc
create_link ~/.dotfiles/.yabairc ~/.yabairc
create_link ~/.dotfiles/claude/settings.json ~/.claude/settings.json
create_link ~/.dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md

# Codex configuration
create_link ~/.dotfiles/codex/config.toml ~/.codex/config.toml
create_link ~/.dotfiles/codex/instructions.md ~/.codex/instructions.md
create_link ~/.dotfiles/codex/hooks.json ~/.codex/hooks.json

# Codex skills (symlinked to claude skills in repo, then linked to ~/.codex)
create_link ~/.dotfiles/codex/skills ~/.codex/skills

# Config directory dotfiles
create_link ~/.dotfiles/nvim ~/.config/nvim
create_link ~/.dotfiles/lazygit ~/.config/lazygit
create_link ~/.dotfiles/ghostty ~/.config/ghostty
create_link ~/.dotfiles/claude/skills ~/.claude/skills
create_link ~/.dotfiles/claude/rules ~/.claude/rules
create_link ~/.dotfiles/git-hooks ~/.git-hooks
create_link ~/.dotfiles/wallpapers ~/Pictures/wallpaper
create_link ~/.dotfiles/zellij ~/.config/zellij
create_link ~/.dotfiles/starship/starship.toml ~/.config/starship.toml

# Build and install NvimEdit.app (opens text/code files in Ghostty+Neovim)
~/.dotfiles/scripts/install_nvimedit.sh

# Ensure skhd dynamic bindings file exists and is synced to current yabai capability.
touch ~/.dotfiles/.skhdrc.space-bindings.active
~/.dotfiles/scripts/sync_skhd_space_bindings.sh || true
