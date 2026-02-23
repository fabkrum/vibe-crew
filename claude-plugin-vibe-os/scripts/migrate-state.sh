#!/usr/bin/env bash
# scripts/migrate-state.sh
# State file migration: reads schema_version from .vibeos/ files
# and applies sequential migrations if the version is behind CURRENT_VERSION.
# Called by session-startup.sh on every session start.
# Exit 0 always (migration failures should not block the session)

set -euo pipefail

CURRENT_VERSION="1.0.0"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# --- Semver comparison ---
version_lt() {
  # Returns 0 (true) if $1 < $2
  [ "$(printf '%s\n%s' "$1" "$2" | sort -V | head -1)" != "$2" ]
}

# --- Migrate a single file ---
migrate_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    return 0  # File does not exist, skip
  fi

  local version
  version=$(jq -r '.schema_version // "0.0.0"' "$file" 2>/dev/null)

  # Forward-compatibility guard: refuse to modify newer schemas
  if version_lt "$CURRENT_VERSION" "$version"; then
    echo "WARNING: $file has schema_version $version (newer than $CURRENT_VERSION). Skipping." >&2
    return 0
  fi

  # Already up to date
  if [[ "$version" == "$CURRENT_VERSION" ]]; then
    return 0
  fi

  # --- Future migrations go here ---
  # Example:
  # if version_lt "$version" "1.1.0"; then
  #   migrate_1_0_to_1_1 "$file"
  # fi
  # if version_lt "$version" "1.2.0"; then
  #   migrate_1_1_to_1_2 "$file"
  # fi

  # Update schema_version to current
  local tmp="${file}.tmp"
  jq --arg v "$CURRENT_VERSION" '.schema_version = $v' "$file" > "$tmp" && mv "$tmp" "$file"

  echo "Migrated $(basename "$file") from $version to $CURRENT_VERSION"
}

# --- Run on all state files ---
for f in "$PROJECT_ROOT/.vibeos/config.json" "$PROJECT_ROOT/.vibeos/state.json" "$PROJECT_ROOT/.vibeos/backlog.json"; do
  migrate_file "$f"
done

exit 0
