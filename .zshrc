# shellcheck disable=SC1091
source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-defer/zsh-defer.plugin.zsh

export ZSH="$HOME/.oh-my-zsh"

# shellcheck disable=SC2034
ZSH_THEME="powerlevel10k/powerlevel10k"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 14

# shellcheck disable=SC2034
DISABLE_UNTRACKED_FILES_DIRTY="true"

# shellcheck disable=SC2034
plugins=(git web-search zsh-defer)

# docker completions must be in fpath before oh-my-zsh's compinit
# shellcheck disable=SC2206
fpath=("$HOME/.docker/completions" $fpath)

source "$ZSH"/oh-my-zsh.sh

zsh-defer source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
zsh-defer source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

# shellcheck disable=SC1090
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias ls='eza --icons'
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

# shellcheck disable=SC1090
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
if [[ $- == *i* ]] && [[ -z "$CLAUDE_CODE_SESSION" ]]; then
  zsh-defer _dotfiles_daily_pull
fi

# --- Zellij-tmux-shim (Claude Code agent teams in zellij) ---
if [[ -n "$ZELLIJ" ]]; then
    _shim="${XDG_DATA_HOME:-$HOME/.local/share}/zellij-tmux-shim/activate.sh"
    # shellcheck disable=SC1090
    [[ -f "$_shim" ]] && source "$_shim"
    unset _shim
fi
