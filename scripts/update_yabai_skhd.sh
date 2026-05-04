#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

YABAI_REPO="${YABAI_REPO:-https://github.com/0xAndoroid/yabai.git}"
YABAI_REF="${YABAI_REF:-fix-arc-fs-new}"
SKHD_REPO="${SKHD_REPO:-https://github.com/0xAndoroid/skhd.git}"
SKHD_REF="${SKHD_REF:-feat/title-filter}"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

print_section() {
  echo -e "\n${BLUE}==== $1 ====${NC}\n"
}

print_success() {
  echo -e "${GREEN}$1${NC}"
}

print_warn() {
  echo -e "${YELLOW}$1${NC}"
}

print_error() {
  echo -e "${RED}$1${NC}" >&2
}

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    print_error "Missing required command: $command_name"
    exit 1
  fi
}

existing_or_default_bin() {
  local name="$1"
  local existing

  existing="$(command -v "$name" || true)"
  if [ -n "$existing" ]; then
    echo "$existing"
  else
    echo "$INSTALL_DIR/$name"
  fi
}

clone_ref() {
  local repo="$1"
  local ref="$2"
  local target_dir="$3"

  if ! git clone --depth 1 --branch "$ref" "$repo" "$target_dir"; then
    print_warn "Shallow clone failed for $ref; retrying with full clone"
    rm -rf "$target_dir"
    git clone "$repo" "$target_dir"
    git -C "$target_dir" checkout "$ref"
  fi
}

build_and_install() {
  local name="$1"
  local repo="$2"
  local ref="$3"
  local bin_path="$4"
  local source_dir="$WORK_DIR/$name"
  local built_bin="$source_dir/bin/$name"

  echo "Cloning $name from $repo ($ref)..."
  clone_ref "$repo" "$ref" "$source_dir"

  echo "Building $name..."
  make -C "$source_dir" install

  echo "Signing $name..."
  make -C "$source_dir" sign

  if [ ! -x "$built_bin" ]; then
    print_error "Build did not produce expected binary: $built_bin"
    exit 1
  fi

  echo "Installing $name to $bin_path (requires sudo)..."
  sudo mkdir -p "$(dirname "$bin_path")"
  sudo install -m 0755 "$built_bin" "$bin_path"
}

configure_yabai_sudoers() {
  local yabai_bin="$1"
  local checksum
  local sudoers_tmp

  checksum="$(shasum -a 256 "$yabai_bin" | awk '{print $1}')"
  sudoers_tmp="$(mktemp)"

  printf "%s ALL=(root) NOPASSWD: sha256:%s %s --load-sa\n" "$(whoami)" "$checksum" "$yabai_bin" > "$sudoers_tmp"

  echo "Updating yabai sudoers checksum (requires sudo)..."
  if ! sudo visudo -cf "$sudoers_tmp" >/dev/null; then
    rm -f "$sudoers_tmp"
    exit 1
  fi
  sudo install -m 0440 "$sudoers_tmp" /private/etc/sudoers.d/yabai
  rm -f "$sudoers_tmp"
}

restart_service() {
  local name="$1"
  local bin_path="$2"

  echo "Restarting $name service..."
  if "$bin_path" --restart-service >/dev/null 2>&1; then
    print_success "$name service restarted"
  else
    print_warn "Could not restart $name automatically; run: $bin_path --restart-service"
  fi
}

require_command git
require_command make
require_command sudo
require_command shasum
require_command awk

YABAI_BIN="${YABAI_BIN:-$(existing_or_default_bin yabai)}"
SKHD_BIN="${SKHD_BIN:-$(existing_or_default_bin skhd)}"

print_section "Yabai"
build_and_install "yabai" "$YABAI_REPO" "$YABAI_REF" "$YABAI_BIN"
configure_yabai_sudoers "$YABAI_BIN"
restart_service "yabai" "$YABAI_BIN"

print_section "skhd"
build_and_install "skhd" "$SKHD_REPO" "$SKHD_REF" "$SKHD_BIN"
restart_service "skhd" "$SKHD_BIN"

print_section "skhd space bindings"
"$SCRIPT_DIR/sync_skhd_space_bindings.sh" || true

print_success "Yabai and skhd update complete"
