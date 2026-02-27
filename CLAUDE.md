# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Setup Commands

```bash
# Full install (Rust, Homebrew, packages, Neovim, Zsh plugins, Claude Code, Bun)
./scripts/install_all.sh

# Create symlinks from repo to system locations
./scripts/setup_links.sh

# Install MCP servers (PAL from BeehiveInnovations/pal-mcp-server)
./scripts/install_mcp.sh

# macOS system preferences
./scripts/setup_macos.sh

# Yabai + SKHD window management
./scripts/install_yabai_skhd.sh
```

## Architecture

### Symlink-Based Config Management

`scripts/setup_links.sh` is the source of truth for what gets linked where. All configs live in this repo and symlink into their expected system locations (`~/.config/`, `~/.claude/`, `~/.codex/`, etc.).

### AI Tool Configuration (Claude + Codex)

Both tools share the same MCP server ecosystem but use different config formats:

- **Claude**: `claude/mcp.json` (JSON), `claude/settings.json` (permissions/hooks)
- **Codex**: `codex/config.toml` (TOML with `[mcp_servers.*]` sections)

MCP servers configured: PAL (reasoning via local Python server), Perplexity (search), Nanobanana (image gen), Ref (docs).

PAL server installs to `~/.claude/mcp/pal-mcp-server/` — model definitions in `claude/pal_mcp_openai_models.json` get copied to its `conf/` dir.

Claude skills live in `claude/skills/<name>/SKILL.md`, rules in `claude/rules/`. Codex skills mirror some of these in `codex/skills/`.

### 3-Layer Navigation System (skhd → Zellij → Neovim → Yabai)

Ctrl+hjkl navigates seamlessly across Neovim splits, Zellij panes, and Yabai windows. See `nvim/CLAUDE.md` for the full flow diagram. Key files:

- `.skhdrc` — routes keypresses based on Ghostty window title
- `zellij/config.kdl` — locked default mode, `zellij-nav` plugin for Nvim detection
- `nvim/lua/plugins/smart-splits.lua` — edge detection cascades to Zellij then Yabai

### Shell

`.zshrc` defines tool aliases (`cld`, `cdx`, `ls`→eza, `cat`→bat, `rm`→rip, `vim`→nvim). API keys sourced from `~/.keysrc` at shell init.

### Git Hooks

`git-hooks/pre-commit` is a universal Rust hook (fmt check + typos). Configurable per-repo via `pre-commit-config.toml`. Applied globally via `.gitconfig` `core.hooksPath`.

`.gitconfig` alias `pushall` force-with-lease pushes main + a16z + homeserver branches.
