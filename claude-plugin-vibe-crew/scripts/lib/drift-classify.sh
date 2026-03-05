#!/usr/bin/env bash
# scripts/lib/drift-classify.sh
# Shared tool classification for drift detection.
# Source from drift-tracker.sh and drift-circuit-breaker.sh.
#
# Classification:
#   progress    — Write/Edit to source files, signal writes, git commit
#   exploration — Read, Glob, Grep, WebSearch, WebFetch, failed Bash
#   neutral     — Bash test/build/lint, config writes, unknown

# Classify a tool call as progress, exploration, or neutral.
# Usage: classify_tool_call <tool_name> <file_path_or_command> <exit_code>
# Returns: prints "progress", "exploration", or "neutral" to stdout
classify_tool_call() {
  local tool_name="${1:-}"
  local target="${2:-}"
  local exit_code="${3:-0}"

  case "$tool_name" in
    Write|Edit)
      # Source file writes are progress; config/data writes are neutral
      if _is_source_file "$target"; then
        echo "progress"
      elif _is_signal_file "$target"; then
        echo "progress"
      else
        echo "neutral"
      fi
      ;;
    Bash)
      # git commit is progress
      if [[ "$target" == *"git commit"* ]]; then
        echo "progress"
        return
      fi
      # Failed bash commands are exploration
      if [[ "$exit_code" != "0" ]]; then
        echo "exploration"
        return
      fi
      # Test/build/lint commands are neutral (success doesn't mean code progress)
      if _is_build_command "$target"; then
        echo "neutral"
        return
      fi
      # npm install, mkdir, etc. are neutral
      echo "neutral"
      ;;
    Read|Glob|Grep)
      echo "exploration"
      ;;
    WebSearch|WebFetch)
      echo "exploration"
      ;;
    *)
      echo "neutral"
      ;;
  esac
}

# Check if a file path is a source code file
_is_source_file() {
  local path="${1:-}"
  case "$path" in
    *.ts|*.tsx|*.js|*.jsx|*.vue|*.svelte|*.css|*.scss|*.html|*.py|*.rb|*.go|*.rs|*.java)
      # Exclude test files — writing tests is still progress
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Check if a file path is a signal file
_is_signal_file() {
  local path="${1:-}"
  [[ "$path" == *".vibecrew/signals/"* || "$path" == *".signal" ]]
}

# Check if a bash command is a build/test/lint command
_is_build_command() {
  local cmd="${1:-}"
  case "$cmd" in
    *"npm test"*|*"npm run test"*|*"npm run build"*|*"npm run lint"*|*"npx tsc"*|*"bats "*|*"jest "*|*"vitest "*|*"pytest "*|*"go test"*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}
