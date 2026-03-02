#!/usr/bin/env bash
# scripts/sandbox.sh
# Shared module: source from other hook scripts
# Usage: source "${CLAUDE_PLUGIN_ROOT}/scripts/sandbox.sh"

# Load cross-platform helpers
_SANDBOX_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_SANDBOX_SCRIPT_DIR/lib/compat.sh"

SANDBOX_PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SANDBOX_PROJECT_ROOT=$(_compat_readlink_f "$SANDBOX_PROJECT_ROOT") || {
  echo "ERROR: Cannot resolve project root" >&2; return 1
}

# --- Path Canonicalization ---
sandbox_canonicalize() {
  local path="$1"
  path="${path/#\~/$HOME}"
  [[ "$path" != /* ]] && path="$SANDBOX_PROJECT_ROOT/$path"
  if [[ -e "$path" ]]; then
    _compat_readlink_f "$path"
  else
    local parent=$(dirname "$path")
    local name=$(basename "$path")
    if [[ -d "$parent" ]]; then
      echo "$(_compat_readlink_f "$parent")/$name"
    else
      _compat_realpath "$path"
    fi
  fi
}

# --- Project Root Check ---
sandbox_check_path() {
  local path="$1"
  local canonical=$(sandbox_canonicalize "$path")
  if [[ "$canonical" != "$SANDBOX_PROJECT_ROOT" && "$canonical" != "$SANDBOX_PROJECT_ROOT/"* ]]; then
    return 1
  fi
  local current="$canonical"
  while [[ "$current" != "$SANDBOX_PROJECT_ROOT" && "$current" != "/" ]]; do
    if [[ -L "$current" ]]; then
      local target=$(_compat_readlink_f "$current")
      if [[ "$target" != "$SANDBOX_PROJECT_ROOT" && "$target" != "$SANDBOX_PROJECT_ROOT/"* ]]; then
        return 1
      fi
    fi
    current=$(dirname "$current")
  done
  return 0
}

# --- Sensitive File Check ---
sandbox_check_sensitive_file() {
  local path="$1"
  local canonical=$(sandbox_canonicalize "$path")
  local basename=$(basename "$canonical")
  local sensitive_patterns=(
    ".env" ".env.local" ".env.production" ".env.staging" ".env.development"
    "credentials.json" "service-account.json"
    "id_rsa" "id_ed25519" "id_ecdsa"
    ".npmrc" ".pypirc"
  )
  for pattern in "${sensitive_patterns[@]}"; do
    if [[ "$basename" == "$pattern" ]]; then
      return 1
    fi
  done
  if [[ "$canonical" == *"/.git/"* || "$canonical" == *"/.git" ]]; then
    return 1
  fi
  if [[ "$canonical" == *"/.ssh/"* || "$canonical" == *"/.aws/"* ]]; then
    return 1
  fi
  return 0
}

# --- Combined Validation ---
sandbox_validate_write() {
  local path="$1"
  if ! sandbox_check_path "$path"; then
    echo "SANDBOX VIOLATION: Write target outside project root"
    echo "  Path: $path"
    echo "  Resolved: $(sandbox_canonicalize "$path")"
    echo "  Project: $SANDBOX_PROJECT_ROOT"
    return 1
  fi
  if ! sandbox_check_sensitive_file "$path"; then
    echo "SANDBOX VIOLATION: Write target is a sensitive file"
    echo "  Path: $path"
    echo "  Sensitive files (.env, .ssh/, .aws/, .git/) cannot be modified by agents."
    echo "  If you need to modify this file, do it manually."
    return 1
  fi
  return 0
}
