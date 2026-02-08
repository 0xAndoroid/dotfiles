#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
MCP_DIR="$HOME/.claude/mcp"

echo "Installing MCP servers..."

mkdir -p "$MCP_DIR"

copy_pal_settings() {
    local dest="$1"

    echo "  Copying openai_models.json to conf/..."
    mkdir -p "$dest/conf"
    cp "$DOTFILES_DIR/claude/pal_mcp_openai_models.json" "$dest/conf/openai_models.json"
}

install_pal() {
    local repo="https://github.com/BeehiveInnovations/pal-mcp-server.git"
    local dest="$MCP_DIR/pal-mcp-server"

    if [[ -d "$dest" ]]; then
        echo "Updating PAL MCP server..."
        git -C "$dest" stash --quiet
        git -C "$dest" pull --quiet
        git -C "$dest" stash pop --quiet 2>/dev/null || true
        copy_pal_settings "$dest"
        echo "  PAL MCP server updated"
    else
        echo "Installing PAL MCP server..."
        git clone --quiet "$repo" "$dest"
        copy_pal_settings "$dest"
        echo "  Running initial setup..."
        cd "$dest"
        ./run-server.sh
        echo "  PAL MCP server installed"
    fi
}

install_pal

echo ""
echo "MCP server installation complete!"
echo ""
echo "Next steps:"
echo "  1. Edit ~/.keysrc with your API keys"
echo "  2. Restart Claude to pick up the new MCP servers"
