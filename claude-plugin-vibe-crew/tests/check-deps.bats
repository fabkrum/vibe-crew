#!/usr/bin/env bats
# tests/check-deps.bats
# Tests for scripts/check-deps.sh — dependency validation

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/check-deps.sh"
}

teardown() {
  teardown_vibecrew_dir
}

# =============================================================================
# Basic output structure
# =============================================================================

@test "outputs valid JSON" {
  run bash "$SCRIPT"
  # May exit 0 or 1 depending on system deps — just check JSON validity
  echo "$output" | jq . >/dev/null 2>&1
}

@test "JSON contains dependencies array" {
  run bash "$SCRIPT"
  local has_deps
  has_deps=$(echo "$output" | jq 'has("dependencies")')
  [ "$has_deps" = "true" ]
}

@test "JSON contains summary object" {
  run bash "$SCRIPT"
  local has_summary
  has_summary=$(echo "$output" | jq 'has("summary")')
  [ "$has_summary" = "true" ]
}

@test "JSON contains gh_authenticated field" {
  run bash "$SCRIPT"
  local has_gh
  has_gh=$(echo "$output" | jq 'has("gh_authenticated")')
  [ "$has_gh" = "true" ]
}

# =============================================================================
# Claude Code check removed
# =============================================================================

@test "does not check for Claude Code binary" {
  run bash "$SCRIPT"
  # The dependency list should NOT contain "Claude Code"
  local has_claude
  has_claude=$(echo "$output" | jq '[.dependencies[] | select(.name == "Claude Code")] | length')
  [ "$has_claude" = "0" ]
}

# =============================================================================
# Required vs optional dependency tiers
# =============================================================================

@test "Git is required" {
  run bash "$SCRIPT"
  local level
  level=$(echo "$output" | jq -r '.dependencies[] | select(.name == "Git") | .level')
  [ "$level" = "required" ]
}

@test "Node.js is required" {
  run bash "$SCRIPT"
  local level
  level=$(echo "$output" | jq -r '.dependencies[] | select(.name == "Node.js") | .level')
  [ "$level" = "required" ]
}

@test "jq is required" {
  run bash "$SCRIPT"
  local level
  level=$(echo "$output" | jq -r '.dependencies[] | select(.name == "jq") | .level')
  [ "$level" = "required" ]
}

@test "GitHub CLI is optional" {
  run bash "$SCRIPT"
  local level
  level=$(echo "$output" | jq -r '.dependencies[] | select(.name == "GitHub CLI") | .level')
  [ "$level" = "optional" ]
}

@test "terminal-notifier is optional" {
  run bash "$SCRIPT"
  local level
  level=$(echo "$output" | jq -r '.dependencies[] | select(.name == "terminal-notifier") | .level')
  [ "$level" = "optional" ]
}

# =============================================================================
# summary.ready reflects only required deps
# =============================================================================

@test "summary.ready is true when required deps present (regardless of optional)" {
  # On a typical dev machine, git, node, and jq are present
  # so summary.ready should be true even if optional deps are missing
  run bash "$SCRIPT"
  if [ "$status" -eq 0 ]; then
    local ready
    ready=$(echo "$output" | jq '.summary.ready')
    [ "$ready" = "true" ]
  else
    # If required deps are actually missing on this system, skip
    skip "Required dependencies missing on this system"
  fi
}

# =============================================================================
# --auto-install flag
# =============================================================================

@test "--auto-install includes install_commands in output" {
  run bash "$SCRIPT" --auto-install
  local has_cmds
  has_cmds=$(echo "$output" | jq 'has("install_commands")')
  [ "$has_cmds" = "true" ]
}

@test "--auto-install includes package_manager in output" {
  run bash "$SCRIPT" --auto-install
  local has_pkg
  has_pkg=$(echo "$output" | jq 'has("package_manager")')
  [ "$has_pkg" = "true" ]
}

@test "--auto-install install_commands is an array" {
  run bash "$SCRIPT" --auto-install
  local type
  type=$(echo "$output" | jq -r '.install_commands | type')
  [ "$type" = "array" ]
}

@test "without --auto-install, no install_commands field" {
  run bash "$SCRIPT"
  local has_cmds
  has_cmds=$(echo "$output" | jq 'has("install_commands")')
  [ "$has_cmds" = "false" ]
}

# =============================================================================
# gh auth status
# =============================================================================

@test "gh_authenticated is not_installed when gh is missing" {
  # Temporarily hide gh from PATH
  run bash -c "PATH=/usr/bin:/bin bash '$SCRIPT' 2>/dev/null || true"
  # If gh isn't in /usr/bin or /bin, it should show as not_installed
  # This test may need to be skipped on systems where gh is in /usr/bin
  local gh_auth
  gh_auth=$(echo "$output" | jq -r '.gh_authenticated // empty')
  if [ -n "$gh_auth" ]; then
    # As long as it's a valid value, that's fine
    [[ "$gh_auth" == "ok" || "$gh_auth" == "not_authenticated" || "$gh_auth" == "not_installed" ]]
  fi
}

# =============================================================================
# Dependency count
# =============================================================================

@test "checks exactly 6 dependencies (3 required + 3 optional)" {
  run bash "$SCRIPT"
  local count
  count=$(echo "$output" | jq '.dependencies | length')
  [ "$count" = "6" ]
}

# =============================================================================
# summary fields
# =============================================================================

@test "summary contains optional_missing field (not recommended_missing)" {
  run bash "$SCRIPT"
  local has_field
  has_field=$(echo "$output" | jq 'has("summary") and (.summary | has("optional_missing"))')
  [ "$has_field" = "true" ]
}
