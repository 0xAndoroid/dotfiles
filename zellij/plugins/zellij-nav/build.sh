#!/bin/bash
set -e

cd "$(dirname "$0")"

# Ensure wasm32-wasip1 target is installed
rustup target add wasm32-wasip1 2>/dev/null || true

# Build the plugin (target specified in .cargo/config.toml)
cargo build --release -q

# Copy to plugins directory
cp target/wasm32-wasip1/release/zellij-nav.wasm ../zellij-nav.wasm

echo "Built: ~/.dotfiles/zellij/plugins/zellij-nav.wasm"
