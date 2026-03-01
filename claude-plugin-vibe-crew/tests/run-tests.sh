#!/usr/bin/env bash
# tests/run-tests.sh
# Entry point for running all VibeCrew BATS tests
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
BATS="$TESTS_DIR/bats/bin/bats"

if [[ ! -x "$BATS" ]]; then
  echo "ERROR: BATS not found. Run: git submodule update --init --recursive" >&2
  exit 1
fi

echo "Running VibeCrew tests..."
echo ""

"$BATS" "$TESTS_DIR"/*.bats "$@"
