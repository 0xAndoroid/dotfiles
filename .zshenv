. "$HOME/.cargo/env"

export PATH="$PATH:/Users/andoroid/.foundry/bin"

alias vim=nvim
alias vi=nvim
alias cat=bat
alias du='dust'
alias copilot='gh copilot'
alias gcs='gh copilot suggest'
alias gce='gh copilot explain'
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
