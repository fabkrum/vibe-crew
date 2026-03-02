#!/usr/bin/env bash
# install.sh — Bootstrap script for VibeCrew dependencies
#
# Usage:
#   ./install.sh          # Interactive (prompts before installing)
#   ./install.sh --yes    # Non-interactive (auto-confirm)
#
# Installs missing required and optional dependencies:
#   Required:  Git 2.30+, Node.js 18+, jq
#   Optional:  GitHub CLI (gh), GitLab CLI (glab), terminal-notifier (macOS)
#
# Does NOT install Claude Code itself — you must already have it.
# Idempotent: safe to run multiple times.

set -euo pipefail

AUTO_YES=false
for arg in "$@"; do
  case "$arg" in
    --yes|-y) AUTO_YES=true ;;
    --help|-h)
      echo "Usage: $0 [--yes]"
      echo "  --yes  Skip confirmation prompt"
      exit 0
      ;;
  esac
done

# --- Detect OS and package manager ---

OS="unknown"
PKG_MGR="unknown"

case "$(uname -s)" in
  Darwin*)
    OS="macos"
    if command -v brew &>/dev/null; then
      PKG_MGR="brew"
    fi
    ;;
  Linux*)
    OS="linux"
    if command -v apt-get &>/dev/null; then
      PKG_MGR="apt"
    elif command -v dnf &>/dev/null; then
      PKG_MGR="dnf"
    elif command -v yum &>/dev/null; then
      PKG_MGR="yum"
    fi
    ;;
esac

if [[ "$PKG_MGR" == "unknown" ]]; then
  if [[ "$OS" == "macos" ]]; then
    echo "ERROR: Homebrew is required on macOS. Install it from https://brew.sh"
  else
    echo "ERROR: No supported package manager found (apt, dnf, yum)."
  fi
  exit 1
fi

echo "VibeCrew Dependency Installer"
echo "============================="
echo "OS: $OS | Package manager: $PKG_MGR"
echo ""

# --- Check each dependency ---

MISSING_REQUIRED=()
MISSING_OPTIONAL=()
INSTALL_CMDS=()

check() {
  local name="$1" cmd="$2" level="$3"
  local brew_pkg="${4:-$cmd}" apt_pkg="${5:-$cmd}"

  if command -v "$cmd" &>/dev/null; then
    local version
    version=$("$cmd" --version 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    echo "  [ok]  $name (${version:-installed})"
  else
    echo "  [--]  $name (missing)"
    case "$PKG_MGR" in
      brew) INSTALL_CMDS+=("brew install $brew_pkg") ;;
      apt)  INSTALL_CMDS+=("sudo apt-get install -y $apt_pkg") ;;
      dnf)  INSTALL_CMDS+=("sudo dnf install -y $apt_pkg") ;;
      yum)  INSTALL_CMDS+=("sudo yum install -y $apt_pkg") ;;
    esac
    if [[ "$level" == "required" ]]; then
      MISSING_REQUIRED+=("$name")
    else
      MISSING_OPTIONAL+=("$name")
    fi
  fi
}

echo "Checking dependencies..."
check "Git"                "git"                 "required" "git"                "git"
check "Node.js"            "node"                "required" "node"               "nodejs"
check "jq"                 "jq"                  "required" "jq"                 "jq"
check "GitHub CLI"         "gh"                  "optional" "gh"                 "gh"
check "GitLab CLI"         "glab"                "optional" "glab"               "glab"
check "terminal-notifier"  "terminal-notifier"   "optional" "terminal-notifier"  "terminal-notifier"
echo ""

# --- Nothing to install ---

if [[ ${#INSTALL_CMDS[@]} -eq 0 ]]; then
  echo "All dependencies are installed."
  echo ""

  # Check gh auth
  if command -v gh &>/dev/null && ! gh auth status &>/dev/null 2>&1; then
    echo "Note: GitHub CLI is installed but not authenticated."
    echo "  Run: gh auth login"
    echo ""
  fi

  if command -v glab &>/dev/null && ! glab auth status &>/dev/null 2>&1; then
    echo "Note: GitLab CLI is installed but not authenticated."
    echo "  Run: glab auth login"
    echo ""
  fi

  echo "Open Claude Code in your project and run /setup"
  exit 0
fi

# --- Consolidate brew commands ---

consolidate_brew_cmds() {
  local packages=()
  local other_cmds=()
  for cmd in "${INSTALL_CMDS[@]}"; do
    if [[ "$cmd" == "brew install "* ]]; then
      packages+=("${cmd#brew install }")
    else
      other_cmds+=("$cmd")
    fi
  done
  INSTALL_CMDS=()
  if [[ ${#packages[@]} -gt 0 ]]; then
    INSTALL_CMDS+=("brew install ${packages[*]}")
  fi
  for cmd in "${other_cmds[@]}"; do
    INSTALL_CMDS+=("$cmd")
  done
}

if [[ "$PKG_MGR" == "brew" ]]; then
  consolidate_brew_cmds
fi

# --- Show what will be installed ---

echo "Missing required: ${MISSING_REQUIRED[*]:-none}"
echo "Missing optional: ${MISSING_OPTIONAL[*]:-none}"
echo ""
echo "Commands to run:"
for cmd in "${INSTALL_CMDS[@]}"; do
  echo "  $cmd"
done
echo ""

if [[ ${#MISSING_REQUIRED[@]} -eq 0 ]]; then
  echo "Only optional dependencies are missing — VibeCrew works without them."
  echo "  GitHub CLI: enables PR automation for GitHub repos (/review, gh pr create)"
  echo "  GitLab CLI: enables MR automation for GitLab repos (glab mr create)"
  echo "  terminal-notifier: enables desktop notifications"
  echo ""
fi

# --- Confirm ---

if [[ "$AUTO_YES" != "true" ]]; then
  read -rp "Install now? [Y/n] " REPLY
  if [[ "$REPLY" =~ ^[Nn] ]]; then
    echo "Skipped. Install manually and run /setup in Claude Code."
    exit 0
  fi
fi

# --- Install ---

echo ""
for cmd in "${INSTALL_CMDS[@]}"; do
  echo "Running: $cmd"
  eval "$cmd"
  echo ""
done

# --- Post-install: gh auth ---

if command -v gh &>/dev/null && ! gh auth status &>/dev/null 2>&1; then
  echo "GitHub CLI installed. Authenticate now for PR features:"
  echo "  gh auth login"
  echo ""
fi

if command -v glab &>/dev/null && ! glab auth status &>/dev/null 2>&1; then
  echo "GitLab CLI installed. Authenticate now for MR features:"
  echo "  glab auth login"
  echo ""
fi

# --- Done ---

echo "All dependencies installed."
echo "Open Claude Code in your project and run /setup"
exit 0
