# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Setup Commands

```bash
./scripts/install_all.sh        # Rust, Homebrew, packages, Neovim, Zsh plugins, Claude Code, Bun
./scripts/setup_links.sh        # Symlink configs into system locations
./scripts/setup_macos.sh        # macOS system preferences
./scripts/install_yabai_skhd.sh # Yabai + skhd window management
./scripts/update_all.sh         # Update Homebrew, npm, Cargo, Zsh plugins
```

## Architecture

### Symlink-Based Config Management

`scripts/setup_links.sh` is the source of truth for what gets linked where. All configs live in this repo and symlink into their expected system locations (`~/.config/`, `~/.claude/`, `~/.codex/`, etc.). Also builds and installs `NvimEdit.app` (opens files in Ghostty+Neovim).

### AI Tool Configuration (Claude + Codex)

Both tools configure MCP servers separately, with Perplexity enabled in each tool:

- **Claude**: `claude/mcp.json` (JSON), `claude/settings.json` (permissions/hooks), `claude/hooks/` (hook scripts)
- **Codex**: `codex/config.toml` (TOML with `[mcp_servers.*]` sections), `codex/hooks.json`

Claude skills live in `claude/skills/<name>/SKILL.md`, rules in `claude/rules/`. Codex skills symlink to `claude/skills/`.

### 3-Layer Navigation System (skhd → Zellij → Neovim → Yabai)

Ctrl+hjkl navigates seamlessly across Neovim splits, Zellij panes, and Yabai windows. See `nvim/CLAUDE.md` for the full flow diagram. Key files:

- `.skhdrc` — routes keypresses based on Ghostty window title
- `zellij/config.kdl` — locked default mode, `zellij-nav` WASM plugin for Nvim detection
- `nvim/lua/plugins/smart-splits.lua` — edge detection cascades to Zellij then Yabai

### Zellij Plugins

- `zellij-nav` — custom WASM plugin for Ctrl+hjkl navigation across Neovim/Zellij/Yabai
- `zellaude` — Zellij plugin for Claude Code agent team support (with `zellaude-hook.sh`)
- `zellij-tmux-shim` — sourced in `.zshrc` when inside Zellij, enables tmux-dependent tools

### Shell

`.zshrc` defines tool aliases (`cld`, `cdx`, `ls`→eza, `cat`→bat, `rm`→rip, `vim`→nvim). API keys sourced from `~/.keysrc` at shell init. Daily auto-pull of this repo on interactive login. Worktrunk shell init when available.

### Git

- `git-hooks/pre-commit` — universal Rust hook (fmt check + typos), configurable per-repo via `pre-commit-config.toml`
- `git-hooks/post-commit` — post-commit hook
- Applied globally via `.gitconfig` `core.hooksPath = ~/.git-hooks`
- Diffs: difftastic (`diff.external = difft`)
- Merges: mergiraf merge driver, `diff3` conflict style
- `.gitconfig` alias `pushall` — force-with-lease pushes main + a16z + homeserver branches

### Change Handoff Workflow

**Default: stage intended changes, do not commit or push unless explicitly asked.**

1. Work on the current branch unless the user asks for a branch change
2. Inspect `git status --short` and the relevant diff
3. Stage only the files that belong to the requested task, using explicit paths
4. Report staged files and verification performed
5. Do not commit, push, rebase, or switch branches unless explicitly asked

### Commit Workflow

**Only when explicitly asked to commit:** commit to `main` unless explicitly told otherwise. Steps:

1. `git checkout main`
2. Stage and commit changes on main
3. `git checkout <original-branch> && git rebase main` — rebase the branch on top of main
4. `git checkout main && git pushall` — pushes main, then force-with-lease pushes a16z/homeserver
5. `git checkout <original-branch>` — return to the branch you started on
