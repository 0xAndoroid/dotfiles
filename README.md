# dotfiles

Personal dotfiles for macOS with Zsh, Neovim, Yabai, and other tools.

## Installation

```bash
git clone https://github.com/yourusername/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install_stuff.sh
./create_links.sh
```

## Font Decryption

The Berkeley Mono Nerd Font is encrypted. To decrypt:

```bash
./decrypt_font.sh
# Enter password when prompted
```

This uses OpenSSL with AES-256-CBC encryption and PBKDF2 key derivation.

## Components

- **Shell**: Zsh with Oh My Zsh and Powerlevel10k
- **Editor**: Neovim with AstroNvim
- **Window Manager**: Yabai with SKHD
- **Terminal**: Ghostty
- **Package Manager**: Homebrew
- **Version Control**: Git with SSH signing
- **AI Assistant**: Claude integration

## Key Features

- Modern CLI tools (eza, bat, dust, zoxide, fzf)
- Custom git hooks for Rust formatting
- Automated macOS preferences
- Window management with space labels
- Claude permissions system for safe AI assistance

## Requirements

- macOS
- Homebrew
- Git
- Zsh

## Custom Scripts

- `install_stuff.sh`: Installs dependencies and sets macOS defaults
- `create_links.sh`: Creates symlinks for dotfiles
- `is_nvim_window.sh`: Helper for Yabai to detect Neovim windows