# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

. "$HOME/.cargo/env"

# For Lazygit path
export XDG_CONFIG_HOME="$HOME/.config"

# Consolidated PATH management
export PATH="$HOME/bin:/usr/local/bin:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
export PATH="$HOME/.solana/bin:$PATH"
export PATH="/Library/Frameworks/Python.framework/Versions/3.11/bin:$PATH"
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
export PATH="$PATH:/Users/andoroid/.config/.foundry/bin"
export PATH="$PATH:/Users/andoroid/.huff/bin"
