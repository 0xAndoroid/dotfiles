. "$HOME/.cargo/env"

export PATH="$PATH:/Users/andoroid/.foundry/bin"

alias vim=nvim
alias vi=nvim
alias cat=bat
alias ls='eza --icons'
alias ll='eza --icons -l'
alias la='eza --icons -la'
alias du='dust'
export PATH="/Applications/Racket v8.10/bin:$PATH"
export VISUAL=nvim
export EDITOR="$VISUAL"

# bun completions
[ -s "/Users/andoroid/.bun/_bun" ] && source "/Users/andoroid/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="/Users/andoroid/.local/share/solana/install/active_release/bin:$PATH"

# Setting PATH for Python 3.11
export PATH="/Library/Frameworks/Python.framework/Versions/3.11/bin:$PATH"

source /Users/andoroid/.docker/init-zsh.sh || true # Added by Docker Desktop
