
export PATH="$PATH:$HOME/.foundry/bin"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
export PATH="$HOME/.solana/bin:$PATH"

# Setting PATH for Python 3.11
export PATH="/Library/Frameworks/Python.framework/Versions/3.11/bin:$PATH"

. "$HOME/.cargo/env"

export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

export GOPRIVATE='github.com/zircuit-labs/*'
