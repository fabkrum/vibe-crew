#!/usr/bin/env bash
# tests/run-tests.sh
# Entry point for running VibeCrew BATS tests
# Usage:
#   run-tests.sh              # Run all tests (unit + integration)
#   run-tests.sh all           # Run all tests (unit + integration)
#   run-tests.sh unit          # Run only unit tests (tests/*.bats)
#   run-tests.sh integration   # Run only integration tests (tests/integration/*.bats)
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
BATS="$TESTS_DIR/bats/bin/bats"

if [[ ! -x "$BATS" ]]; then
  echo "ERROR: BATS not found. Run: git submodule update --init --recursive" >&2
  exit 1
fi

MODE="${1:-all}"

# Shift the mode arg so remaining args pass through to BATS
if [[ "$MODE" == "unit" || "$MODE" == "integration" || "$MODE" == "all" ]]; then
  shift 2>/dev/null || true
fi

case "$MODE" in
  unit)
    echo "Running VibeCrew unit tests..."
    echo ""
    "$BATS" "$TESTS_DIR"/*.bats "$@"
    ;;
  integration)
    echo "Running VibeCrew integration tests..."
    echo ""
    if ls "$TESTS_DIR"/integration/*.bats 1>/dev/null 2>&1; then
      "$BATS" "$TESTS_DIR"/integration/*.bats "$@"
    else
      echo "No integration tests found in $TESTS_DIR/integration/"
      exit 0
    fi
    ;;
  all|*)
    echo "Running VibeCrew tests (unit + integration)..."
    echo ""
    BATS_FILES=("$TESTS_DIR"/*.bats)
    if ls "$TESTS_DIR"/integration/*.bats 1>/dev/null 2>&1; then
      BATS_FILES+=("$TESTS_DIR"/integration/*.bats)
    fi
    "$BATS" "${BATS_FILES[@]}" "$@"
    ;;
esac
