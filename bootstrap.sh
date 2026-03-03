#!/usr/bin/env bash
# bootstrap.sh — One-command VibeCrew installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/fabkrum/vibe-crew/main/bootstrap.sh | bash
#
# Or with a custom install location:
#   VIBECREW_DIR=~/my-plugins/vibe-crew curl -fsSL ... | bash
#
# What it does:
#   1. Installs Homebrew on macOS if missing (which also installs Xcode CLT and Git)
#   2. Clones VibeCrew (or git pulls if already cloned)
#   3. Runs install.sh to handle Node.js, jq, and optional tools
#
# Idempotent: safe to run multiple times.

set -euo pipefail

VIBECREW_DIR="${VIBECREW_DIR:-$HOME/claude-plugins/vibe-crew}"
PLUGIN_DIR="$VIBECREW_DIR/claude-plugin-vibe-crew"

echo ""
echo "  VibeCrew Bootstrap"
echo "  =================="
echo ""

# --- macOS: ensure Homebrew is installed ---

if [[ "$(uname -s)" == "Darwin" ]]; then
  if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew (this also installs Xcode CLT and Git)..."
    echo ""
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for the rest of this script
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    echo ""
  else
    echo "Homebrew: already installed"
  fi
fi

# --- Clone or update VibeCrew ---

if [[ -d "$VIBECREW_DIR/.git" ]]; then
  echo "VibeCrew: updating existing installation at $VIBECREW_DIR"
  git -C "$VIBECREW_DIR" pull --ff-only
else
  echo "VibeCrew: cloning to $VIBECREW_DIR"
  mkdir -p "$(dirname "$VIBECREW_DIR")"
  git clone https://github.com/fabkrum/vibe-crew.git "$VIBECREW_DIR"
fi
echo ""

# --- Run the dependency installer ---

echo "Running dependency installer..."
echo ""
bash "$PLUGIN_DIR/install.sh" --yes
echo ""

# --- Done ---

echo "==============================="
echo "  VibeCrew is ready!"
echo "==============================="
echo ""
echo "  Next steps:"
echo ""
echo "  1. Open your project:"
echo "     cd ~/my-project && claude --plugin-dir $PLUGIN_DIR"
echo ""
echo "  2. Inside Claude Code, run:"
echo "     /setup"
echo "     /profile"
echo ""
echo "  To update later, just run this script again."
echo ""
