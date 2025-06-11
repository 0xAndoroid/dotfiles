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
create_link ~/.dotfiles/.p10k.zsh ~/.p10k.zsh
create_link ~/.dotfiles/.gitconfig ~/.gitconfig
create_link ~/.dotfiles/.rustfmt.toml ~/.rustfmt.toml
create_link ~/.dotfiles/.skhdrc ~/.skhdrc
create_link ~/.dotfiles/.yabairc ~/.yabairc
create_link ~/.dotfiles/claude/settings.json ~/.claude/settings.json
create_link ~/.dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md

# Config directory dotfiles
create_link ~/.dotfiles/nvim ~/.config/nvim
create_link ~/.dotfiles/lazygit ~/.config/lazygit
create_link ~/.dotfiles/sketchybar ~/.config/sketchybar
create_link ~/.dotfiles/alacritty ~/.config/alacritty
create_link ~/.dotfiles/ghostty ~/.config/ghostty
create_link ~/.dotfiles/claude/commands ~/.claude/commands
create_link ~/.dotfiles/git-hooks ~/.git-hooks
