#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_DIR="$HOME/.claude/mcp"

echo "Installing MCP servers..."

mkdir -p "$MCP_DIR"

install_pal() {
    local repo="https://github.com/BeehiveInnovations/pal-mcp-server.git"
    local dest="$MCP_DIR/pal-mcp-server"

    echo "Installing PAL MCP server..."

    if [[ -d "$dest" ]]; then
        echo "  Updating existing installation..."
        git -C "$dest" pull --quiet
    else
        echo "  Cloning repository..."
        git clone --quiet "$repo" "$dest"
    fi

    if [[ ! -f "$dest/.env" ]]; then
        echo "  Creating .env from template..."
        cp "$DOTFILES_DIR/mcp/pal/.env.template" "$dest/.env"
        echo "  WARNING: Edit $dest/.env and add your API keys"
    fi

    echo "  Running setup..."
    cd "$dest"
    ./run-server.sh

    echo "  PAL MCP server installed"
}

install_pal

echo ""
echo "MCP server installation complete!"
echo ""
echo "Next steps:"
echo "  1. Edit ~/.claude/mcp/pal-mcp-server/.env with your API keys"
echo "  2. Restart Claude to pick up the new MCP servers"
