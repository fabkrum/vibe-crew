#!/usr/bin/env bash
# scripts/lib/compat.sh
# Cross-platform compatibility helpers for macOS, Linux, and WSL.
# Source from other scripts: source "$(dirname "$0")/lib/compat.sh"

# --- Open URL in browser ---
# Usage: _compat_open_url "https://example.com"
_compat_open_url() {
  local url="$1"
  if command -v open &>/dev/null; then
    open "$url"
  elif command -v xdg-open &>/dev/null; then
    xdg-open "$url"
  elif command -v wslview &>/dev/null; then
    wslview "$url"
  else
    echo "Open in browser: $url" >&2
  fi
}

# --- Resolve symlinks fully (like GNU readlink -f) ---
# Usage: _compat_readlink_f "/some/symlink/path"
# Fixes security bug: macOS readlink without -f silently returns wrong result
_compat_readlink_f() {
  local path="$1"
  if readlink -f "$path" 2>/dev/null; then
    return 0
  fi
  # macOS fallback: use perl Cwd::realpath (resolves symlinks, unlike abspath)
  if command -v perl &>/dev/null; then
    perl -MCwd=realpath -e 'print realpath($ARGV[0])' "$path" 2>/dev/null && return 0
  fi
  # Last resort: python3 os.path.realpath (resolves symlinks)
  if command -v python3 &>/dev/null; then
    COMPAT_PATH="$path" python3 -c "import os; print(os.path.realpath(os.environ['COMPAT_PATH']))" 2>/dev/null && return 0
  fi
  # Absolute fallback — return path as-is (caller should handle)
  echo "$path"
}

# --- Resolve path to canonical absolute form ---
# Usage: _compat_realpath "/some/path"
# Like realpath but handles missing targets via realpath -m equivalent
_compat_realpath() {
  local path="$1"
  if [[ -e "$path" ]]; then
    _compat_readlink_f "$path"
    return $?
  fi
  # Path doesn't exist — resolve parent + basename
  if realpath -m "$path" 2>/dev/null; then
    return 0
  fi
  # macOS fallback: resolve parent with readlink_f, append basename
  local parent
  parent=$(dirname "$path")
  local name
  name=$(basename "$path")
  if [[ -d "$parent" ]]; then
    local resolved_parent
    resolved_parent=$(_compat_readlink_f "$parent")
    echo "${resolved_parent}/${name}"
  else
    # python3 os.path.realpath handles non-existent paths correctly (resolves symlinks in existing prefix)
    if command -v python3 &>/dev/null; then
      COMPAT_PATH="$path" python3 -c "import os; print(os.path.realpath(os.environ['COMPAT_PATH']))" 2>/dev/null && return 0
    fi
    echo "$path"
  fi
}

# --- Get timeout command name ---
# Usage: TIMEOUT_CMD=$(_compat_timeout_cmd)
# Returns "timeout", "gtimeout", or empty string
_compat_timeout_cmd() {
  if command -v timeout &>/dev/null; then
    echo "timeout"
  elif command -v gtimeout &>/dev/null; then
    echo "gtimeout"
  else
    echo ""
  fi
}

# --- Get file size in bytes ---
# Usage: _compat_stat_size "/path/to/file"
_compat_stat_size() {
  local file="$1"
  if stat -f "%z" "$file" 2>/dev/null; then
    return 0
  fi
  if stat -c "%s" "$file" 2>/dev/null; then
    return 0
  fi
  wc -c < "$file" 2>/dev/null | tr -d ' '
}
