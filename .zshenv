# bun
export BUN_INSTALL="$HOME/.bun"

. "$HOME/.cargo/env"

# For Lazygit path
export XDG_CONFIG_HOME="$HOME/.config"

# Consolidated PATH management
export PATH="$HOME/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

export PATH="$PATH:$HOME/.config/.foundry/bin"
