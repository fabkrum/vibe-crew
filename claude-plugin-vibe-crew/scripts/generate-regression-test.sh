#!/usr/bin/env bash
# scripts/generate-regression-test.sh
# Generates a regression test skeleton from a fix commit's context.
# Usage: generate-regression-test.sh <commit-hash> <framework>
#   framework: bats | vitest | jest | playwright
# Output: writes test skeleton file, prints file path
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

if [[ $# -lt 2 ]]; then
  echo "Usage: generate-regression-test.sh <commit-hash> <framework>" >&2
  exit 1
fi

COMMIT_HASH="$1"
FRAMEWORK="$2"

# Validate framework
case "$FRAMEWORK" in
  bats|vitest|jest|playwright) ;;
  *)
    echo "ERROR: Invalid framework '$FRAMEWORK'. Must be one of: bats, vitest, jest, playwright" >&2
    exit 1
    ;;
esac

# --- Extract commit info ---
COMMIT_MESSAGE=$(git -C "$PROJECT_ROOT" log --format='%s' -1 "$COMMIT_HASH" 2>/dev/null || echo "")
if [[ -z "$COMMIT_MESSAGE" ]]; then
  echo "ERROR: Could not find commit $COMMIT_HASH" >&2
  exit 1
fi

# Parse conventional commit components
SCOPE=""
DESCRIPTION=""
if echo "$COMMIT_MESSAGE" | grep -qE '^fix\(([^)]+)\):'; then
  SCOPE=$(echo "$COMMIT_MESSAGE" | sed -E 's/^fix\(([^)]+)\):.*/\1/')
  DESCRIPTION=$(echo "$COMMIT_MESSAGE" | sed -E 's/^fix\([^)]+\):[[:space:]]*//')
else
  DESCRIPTION=$(echo "$COMMIT_MESSAGE" | sed -E 's/^fix:[[:space:]]*//')
fi

# Get primary source file changed (largest diff, excluding config/docs)
# Use --root to handle root commits (no parent)
PRIMARY_FILE=$(git -C "$PROJECT_ROOT" diff-tree --root --no-commit-id --name-only -r "$COMMIT_HASH" 2>/dev/null | \
  grep -v -E '\.(md|json|yml|yaml|toml|lock)$' | \
  grep -v -E '^(docs/|\.github/|\.vibecrew/)' | \
  head -1 || echo "")

if [[ -z "$PRIMARY_FILE" ]]; then
  # Fall back to any changed file
  PRIMARY_FILE=$(git -C "$PROJECT_ROOT" diff-tree --root --no-commit-id --name-only -r "$COMMIT_HASH" 2>/dev/null | head -1 || echo "unknown")
fi

# Parse issue number
ISSUE_NUMBER=""
if echo "$COMMIT_MESSAGE" | grep -qEi '(fix(es)?|clos(es|ing)?|resolv(es|ing)?)\s+#[0-9]+'; then
  ISSUE_NUMBER=$(echo "$COMMIT_MESSAGE" | grep -oEi '#[0-9]+' | head -1 | tr -d '#')
fi

# --- Determine test file path ---
SHORT_HASH="${COMMIT_HASH:0:7}"
ISSUE_LINE=""
if [[ -n "$ISSUE_NUMBER" ]]; then
  ISSUE_LINE="# Issue: #$ISSUE_NUMBER"
fi

case "$FRAMEWORK" in
  bats)
    # For BATS tests (VibeCrew's own scripts)
    SCRIPT_NAME=$(basename "$PRIMARY_FILE" .sh)
    if [[ -z "$SCRIPT_NAME" ]]; then
      SCRIPT_NAME="unknown-script"
    fi
    TEST_FILE="$PROJECT_ROOT/tests/${SCRIPT_NAME}.regression.bats"
    mkdir -p "$PROJECT_ROOT/tests"

    # Check if the test file already exists for this script
    if [[ -f "$TEST_FILE" ]]; then
      # Append to existing regression file
      cat >> "$TEST_FILE" <<BATS_EOF

@test "regression: $DESCRIPTION" {
  # Bug: $DESCRIPTION
  # Commit: $SHORT_HASH
  ${ISSUE_LINE}
  # TODO: Set up the conditions that triggered the bug
  # TODO: Run the script and verify it no longer fails
  skip "Regression test skeleton — fill in reproduction steps"
}
BATS_EOF
    else
      cat > "$TEST_FILE" <<BATS_EOF
#!/usr/bin/env bats
# Regression tests for: $PRIMARY_FILE
# Auto-generated from fix: commits during /wrap

load 'test_helper/common-setup'

setup() {
  setup_vibecrew_dir
  SCRIPT="\$SCRIPTS_DIR/$SCRIPT_NAME.sh"
}

teardown() {
  teardown_vibecrew_dir
}

@test "regression: $DESCRIPTION" {
  # Bug: $DESCRIPTION
  # Commit: $SHORT_HASH
  ${ISSUE_LINE}
  # TODO: Set up the conditions that triggered the bug
  # TODO: Run the script and verify it no longer fails
  skip "Regression test skeleton — fill in reproduction steps"
}
BATS_EOF
    fi
    ;;

  vitest|jest)
    # For TypeScript/JavaScript projects
    local_dir=$(dirname "$PRIMARY_FILE")
    local_base=$(basename "$PRIMARY_FILE" | sed -E 's/\.(ts|tsx|js|jsx)$//')
    local_ext=$(basename "$PRIMARY_FILE" | grep -oE '\.(ts|tsx|js|jsx)$' || echo ".ts")

    # Determine test directory pattern
    if [[ -d "$PROJECT_ROOT/$local_dir/__tests__" ]]; then
      TEST_FILE="$PROJECT_ROOT/$local_dir/__tests__/$local_base.regression.test${local_ext}"
    elif [[ -d "$PROJECT_ROOT/$local_dir/tests" ]]; then
      TEST_FILE="$PROJECT_ROOT/$local_dir/tests/$local_base.regression.test${local_ext}"
    else
      # Co-located test
      TEST_FILE="$PROJECT_ROOT/$local_dir/$local_base.regression.test${local_ext}"
    fi

    mkdir -p "$(dirname "$TEST_FILE")"

    # Determine import path
    IMPORT_PATH="./$local_base"
    if [[ -d "$(dirname "$TEST_FILE")/__tests__" ]] || [[ "$(dirname "$TEST_FILE")" == *"__tests__"* ]]; then
      IMPORT_PATH="../$local_base"
    fi

    if [[ "$FRAMEWORK" == "vitest" ]]; then
      IMPORT_STMT="import { describe, it, expect } from 'vitest';"
    else
      IMPORT_STMT="// Jest — no explicit imports needed"
    fi

    cat > "$TEST_FILE" <<TS_EOF
// Regression test for: $COMMIT_MESSAGE
// Commit: $SHORT_HASH
${ISSUE_LINE:+// Issue: #$ISSUE_NUMBER}

$IMPORT_STMT

describe('regression: ${SCOPE:-$(basename "$PRIMARY_FILE" | sed -E 's/\.[^.]+$//')}', () => {
  it('should $DESCRIPTION', () => {
    // Bug: $DESCRIPTION
    // TODO: Set up the conditions that triggered the bug
    // TODO: Assert the fix works correctly
    expect(true).toBe(false); // Placeholder — replace with actual assertion
  });
});
TS_EOF
    ;;

  playwright)
    # For E2E regression tests
    TEST_FILE="$PROJECT_ROOT/e2e/regression-${SHORT_HASH}.spec.ts"
    mkdir -p "$(dirname "$TEST_FILE")"

    cat > "$TEST_FILE" <<PW_EOF
// Regression test for: $COMMIT_MESSAGE
// Commit: $SHORT_HASH
${ISSUE_LINE:+// Issue: #$ISSUE_NUMBER}

import { test, expect } from '@playwright/test';

test.describe('regression: ${SCOPE:-fix}', () => {
  test('$DESCRIPTION', async ({ page }) => {
    // Bug: $DESCRIPTION
    // TODO: Navigate to the affected page
    // TODO: Set up the conditions that triggered the bug
    // TODO: Assert the fix works correctly
    test.skip(true, 'Regression test skeleton — fill in reproduction steps');
  });
});
PW_EOF
    ;;
esac

echo "$TEST_FILE"
exit 0
