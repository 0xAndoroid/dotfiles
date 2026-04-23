# shellcheck disable=SC1091
ZSH_PLUGINS="${XDG_DATA_HOME:-$HOME/.local/share}/zsh-plugins"

fpath=("$HOME/.docker/completions" $fpath)

autoload -Uz compinit
() {
  local zcd="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ -n "$zcd"(#qN.mh+24) ]] || [[ ! -f "$zcd" ]]; then
    compinit -d "$zcd"
    touch "$zcd"
  else
    compinit -C -d "$zcd"
  fi
}

# shellcheck disable=SC1091
source "$ZSH_PLUGINS/zsh-defer/zsh-defer.plugin.zsh"

eval "$(starship init zsh)"

autoload -Uz add-zsh-hook
_zsh_title_precmd() { print -Pn "\e]0;%n@%m:%~\a" }
_zsh_title_preexec() { print -Pn "\e]0;%n@%m:%~ > ${1%% *}\a" }
add-zsh-hook precmd _zsh_title_precmd
add-zsh-hook preexec _zsh_title_preexec

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY
setopt AUTO_CD INTERACTIVE_COMMENTS EXTENDED_GLOB NO_BEEP

# shellcheck disable=SC1091
zsh-defer source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
# shellcheck disable=SC1091
zsh-defer source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

alias ls='eza --icons'
alias l='eza --icons -la'
alias ll='eza --icons -l'
alias la='eza --icons -la'
alias vim=nvim
alias vi=nvim
alias v=nvim
alias cat=bat
rm() {
  local args=()
  for arg in "$@"; do
    [[ "$arg" != -* ]] && args+=("$arg")
  done
  rip "${args[@]}"
}
alias du='dust'
alias copilot='gh copilot'
alias gcs='gh copilot suggest'
alias gce='gh copilot explain'
alias coffee='caffeinate -d'
alias z='zellij'

alias cld='caffeinate -i command claude --dangerously-skip-permissions --mcp-config ~/.dotfiles/claude/mcp.json'
alias cdx='caffeinate -i command codex --dangerously-bypass-approvals-and-sandbox'
export VISUAL=nvim
export EDITOR="$VISUAL"

if [[ $- == *i* ]] && [[ -z "$CLAUDE_CODE_SESSION" ]]; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# shellcheck disable=SC1090
source <(fzf --zsh)

# shellcheck disable=SC1091
[ -f ~/.keysrc ] && source ~/.keysrc

# shellcheck disable=SC1091
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

_dotfiles_daily_pull() {
  local stamp="$HOME/.cache/.dotfiles-last-pull"
  local today
  today=$(date +%Y-%m-%d)
  [[ -f "$stamp" ]] && [[ "$(< "$stamp")" == "$today" ]] && return
  mkdir -p "$(dirname "$stamp")"
  (git -C "$HOME/.dotfiles" pull --ff-only --quiet &>/dev/null &)
  echo "$today" > "$stamp"
}

export CLAUDE_CODE_EFFORT_LEVEL=max

if [[ $- == *i* ]] && [[ -z "$CLAUDE_CODE_SESSION" ]]; then
  zsh-defer _dotfiles_daily_pull
fi

if [[ -n "$ZELLIJ" ]]; then
    _shim="${XDG_DATA_HOME:-$HOME/.local/share}/zellij-tmux-shim/activate.sh"
    # shellcheck disable=SC1090
    [[ -f "$_shim" ]] && source "$_shim"
    unset _shim
fi
