#!/usr/bin/env bats

# Tests for R7: Quality Gate Configurable Timeout

setup() {
  TEST_DIR="$(mktemp -d)"
  mkdir -p "$TEST_DIR/.vibecrew"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "default timeout is 120 when no config exists" {
  # Simulate reading timeout from config
  CONFIG_FILE="$TEST_DIR/.vibecrew/config.json"
  QG_TIMEOUT=120
  if [[ -f "$CONFIG_FILE" ]]; then
    CONFIGURED_TIMEOUT="$(jq -r '.quality_gate.timeout_seconds // 120' "$CONFIG_FILE" 2>/dev/null || echo "120")"
    if [[ "$CONFIGURED_TIMEOUT" =~ ^[0-9]+$ ]] && [[ "$CONFIGURED_TIMEOUT" -gt 0 ]]; then
      QG_TIMEOUT="$CONFIGURED_TIMEOUT"
    fi
  fi
  [ "$QG_TIMEOUT" -eq 120 ]
}

@test "timeout reads from config when present" {
  cat > "$TEST_DIR/.vibecrew/config.json" << 'EOF'
{
  "quality_gate": {
    "timeout_seconds": 300
  }
}
EOF
  CONFIG_FILE="$TEST_DIR/.vibecrew/config.json"
  QG_TIMEOUT=120
  CONFIGURED_TIMEOUT="$(jq -r '.quality_gate.timeout_seconds // 120' "$CONFIG_FILE" 2>/dev/null || echo "120")"
  if [[ "$CONFIGURED_TIMEOUT" =~ ^[0-9]+$ ]] && [[ "$CONFIGURED_TIMEOUT" -gt 0 ]]; then
    QG_TIMEOUT="$CONFIGURED_TIMEOUT"
  fi
  [ "$QG_TIMEOUT" -eq 300 ]
}

@test "invalid timeout falls back to default" {
  cat > "$TEST_DIR/.vibecrew/config.json" << 'EOF'
{
  "quality_gate": {
    "timeout_seconds": "invalid"
  }
}
EOF
  CONFIG_FILE="$TEST_DIR/.vibecrew/config.json"
  QG_TIMEOUT=120
  CONFIGURED_TIMEOUT="$(jq -r '.quality_gate.timeout_seconds // 120' "$CONFIG_FILE" 2>/dev/null || echo "120")"
  if [[ "$CONFIGURED_TIMEOUT" =~ ^[0-9]+$ ]] && [[ "$CONFIGURED_TIMEOUT" -gt 0 ]]; then
    QG_TIMEOUT="$CONFIGURED_TIMEOUT"
  fi
  [ "$QG_TIMEOUT" -eq 120 ]
}
