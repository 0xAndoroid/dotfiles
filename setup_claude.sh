#!/bin/bash

# Claude MCP Server Setup Script

set -e

echo "Setting up Claude MCP Server..."

# Create ~/.mcp directory
if [ ! -d ~/.mcp ]; then
    echo "Creating ~/.mcp directory..."
    mkdir -p ~/.mcp
else
    echo "Directory ~/.mcp already exists"
fi

# Clone zen-mcp-server
if [ ! -d ~/.mcp/zen-mcp-server ]; then
    echo "Cloning zen-mcp-server..."
    cd ~/.mcp
    git clone git@github.com:BeehiveInnovations/zen-mcp-server.git
else
    echo "zen-mcp-server already cloned, pulling latest changes..."
    cd ~/.mcp/zen-mcp-server
    git pull
fi

# Create symlink
if [ ! -L /usr/local/mcp ]; then
    echo "Creating symlink /usr/local/mcp -> ~/.mcp..."
    sudo ln -sf ~/.mcp /usr/local/mcp
else
    echo "Symlink /usr/local/mcp already exists"
fi

# Run the server setup
echo "Running server setup..."
cd ~/.mcp/zen-mcp-server
./run-server.sh

# Update Claude configuration
echo "Updating Claude configuration..."
if [ -f ~/.claude.json ]; then
    # Check if paths already use the symlink
    if grep -q '"/usr/local/mcp/zen-mcp-server' ~/.claude.json; then
        echo "Claude configuration already uses symlink paths"
    else
        # Backup the original file only if we're making changes
        cp ~/.claude.json ~/.claude.json.bak
        
        # Update paths to use the new alias
        # This will replace absolute paths to the MCP server with the symlink
        sed -i '' 's|"[^"]*\.mcp\/zen-mcp-server|"/usr/local/mcp/zen-mcp-server|g' ~/.claude.json
        
        echo "Claude configuration updated. Original backed up to ~/.claude.json.bak"
    fi
else
    echo "Warning: ~/.claude.json not found. Please configure Claude manually."
fi

echo "Setup complete!"
