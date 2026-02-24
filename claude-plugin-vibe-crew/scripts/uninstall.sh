#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# uninstall.sh — Clean removal of VibeCrew plugin files
# =============================================================================
# Removes the claude-plugin-vibe-crew directory and optionally the .vibecrew/
# project state directory. Never touches project source code.
#
# Usage: ./scripts/uninstall.sh
#
# Environment:
#   CLAUDE_PLUGIN_ROOT  (optional) — Override plugin root detection
# =============================================================================

# --- Colors for output -------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

info()  { printf "${BOLD}[VibeCrew]${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}[VibeCrew]${NC} %s\n" "$1"; }
error() { printf "${RED}[VibeCrew]${NC} %s\n" "$1" >&2; }
ok()    { printf "${GREEN}[VibeCrew]${NC} %s\n" "$1"; }

# --- Step 1: Detect plugin root ----------------------------------------------
if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
  PLUGIN_DIR="$CLAUDE_PLUGIN_ROOT"
else
  # Resolve relative to this script's location (scripts/ is one level inside plugin root)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

# Validate the plugin directory looks correct
if [[ ! -d "$PLUGIN_DIR" ]]; then
  error "Plugin directory does not exist: $PLUGIN_DIR"
  exit 1
fi

if [[ ! -d "$PLUGIN_DIR/scripts" ]] && [[ ! -d "$PLUGIN_DIR/.claude-plugin" ]]; then
  error "Directory does not look like a VibeCrew plugin: $PLUGIN_DIR"
  error "Expected to find scripts/ or .claude-plugin/ subdirectory."
  exit 1
fi

# Safety check: refuse to remove filesystem root or home directory
case "$PLUGIN_DIR" in
  /|"$HOME"|"$HOME/")
    error "Refusing to remove root or home directory: $PLUGIN_DIR"
    exit 1
    ;;
esac

# --- Step 2: Detect project root ----------------------------------------------
PROJECT_DIR=""
if command -v git &>/dev/null; then
  PROJECT_DIR="$(git -C "$PLUGIN_DIR" rev-parse --show-toplevel 2>/dev/null || true)"
fi

if [[ -z "$PROJECT_DIR" ]]; then
  # Fall back to the parent of the plugin directory
  PROJECT_DIR="$(cd "$PLUGIN_DIR/.." && pwd)"
  warn "Not inside a git repository. Using parent directory as project root: $PROJECT_DIR"
fi

VIBECREW_STATE_DIR="$PROJECT_DIR/.vibecrew"

# --- Step 3: Show what will be removed ----------------------------------------
echo ""
info "VibeCrew Uninstaller"
echo "  =================================================="
echo ""
info "The following plugin directory will be removed:"
echo ""
echo "    $PLUGIN_DIR"
echo ""

if [[ -d "$VIBECREW_STATE_DIR" ]]; then
  warn "Project state directory found at:"
  echo ""
  echo "    $VIBECREW_STATE_DIR"
  echo ""
  warn "This contains your config, backlog, session logs, and scores."
  warn "It will be handled separately (you will be asked)."
  echo ""
fi

# --- Step 4: Ask for confirmation (plugin directory) --------------------------
printf "${BOLD}Remove the plugin directory?${NC} [y/N]: "
read -r confirm_plugin
confirm_plugin="${confirm_plugin:-N}"

if [[ ! "$confirm_plugin" =~ ^[Yy]$ ]]; then
  info "Aborted. No files were removed."
  exit 0
fi

# --- Step 5: Remove the plugin directory --------------------------------------
if [[ -d "$PLUGIN_DIR" ]]; then
  rm -rf "$PLUGIN_DIR"
  ok "Removed plugin directory: $PLUGIN_DIR"
else
  warn "Plugin directory already removed: $PLUGIN_DIR"
fi

# --- Step 6: Ask about .vibecrew/ state directory --------------------------------
if [[ -d "$VIBECREW_STATE_DIR" ]]; then
  echo ""
  warn "The .vibecrew/ directory contains project state:"
  echo "    - config.json    (terminal preferences, notification settings)"
  echo "    - backlog.json   (feature backlog with specs)"
  echo "    - sessions/      (session logs)"
  echo "    - scores/        (Vibe Score breakdowns)"
  echo "    - releases/      (release notes data)"
  echo ""
  printf "${BOLD}Remove .vibecrew/ project state?${NC} [y/N]: "
  read -r confirm_state
  confirm_state="${confirm_state:-N}"

  # --- Step 7: Conditionally remove .vibecrew/ ----------------------------------
  if [[ "$confirm_state" =~ ^[Yy]$ ]]; then
    rm -rf "$VIBECREW_STATE_DIR"
    ok "Removed project state directory: $VIBECREW_STATE_DIR"
  else
    info "Keeping project state directory: $VIBECREW_STATE_DIR"
  fi
fi

# --- Step 8: Success message --------------------------------------------------
echo ""
ok "VibeCrew has been uninstalled."
info "Your project source code was not modified."
echo ""
