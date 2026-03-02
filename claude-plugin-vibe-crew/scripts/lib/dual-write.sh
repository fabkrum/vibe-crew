#!/usr/bin/env bash
# scripts/lib/dual-write.sh
# Write-ahead journal for atomic dual-file updates (state.json + backlog.json).
# Ensures that interrupted dual writes can be recovered by sync-state.sh.
#
# Usage:
#   source "$(dirname "$0")/lib/dual-write.sh"
#   prepare_dual_write "$VIBECREW_DIR" "$FILE1" "$CONTENT1" "$FILE2" "$CONTENT2"
#   atomic_write "$FILE1" "$CONTENT1"
#   atomic_write "$FILE2" "$CONTENT2"
#   finalize_dual_write "$VIBECREW_DIR"
#
# Recovery (in sync-state.sh):
#   source "$(dirname "$0")/lib/dual-write.sh"
#   source "$(dirname "$0")/lib/atomic-write.sh"
#   if recover_dual_write "$VIBECREW_DIR"; then
#     echo "Recovered interrupted dual write"
#   fi

prepare_dual_write() {
  local vibecrew_dir="$1"
  local file1="$2" content1="$3"
  local file2="$4" content2="$5"

  local journal_dir="$vibecrew_dir/locks"
  mkdir -p "$journal_dir"

  # Write staged content to journal files (PID-suffixed for safety)
  echo "$content1" > "$journal_dir/journal-file1.staged.tmp.$$"
  echo "$content2" > "$journal_dir/journal-file2.staged.tmp.$$"
  mv "$journal_dir/journal-file1.staged.tmp.$$" "$journal_dir/journal-file1.staged"
  mv "$journal_dir/journal-file2.staged.tmp.$$" "$journal_dir/journal-file2.staged"

  # Write the control journal (atomic mv) — this activates the journal
  jq -n \
    --arg f1 "$file1" \
    --arg f2 "$file2" \
    --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg pid "$$" \
    '{timestamp: $ts, pid: $pid, file1: $f1, file2: $f2}' \
    > "$journal_dir/dual-write.journal.tmp.$$"
  mv "$journal_dir/dual-write.journal.tmp.$$" "$journal_dir/dual-write.journal"
}

finalize_dual_write() {
  local vibecrew_dir="$1"
  local journal_dir="$vibecrew_dir/locks"

  rm -f "$journal_dir/dual-write.journal" \
       "$journal_dir/journal-file1.staged" \
       "$journal_dir/journal-file2.staged"
}

recover_dual_write() {
  local vibecrew_dir="$1"
  local journal_dir="$vibecrew_dir/locks"
  local journal="$journal_dir/dual-write.journal"

  if [[ ! -f "$journal" ]]; then
    return 1  # No journal to recover
  fi

  # Read target file paths from journal
  local file1 file2
  file1=$(jq -r '.file1 // empty' "$journal" 2>/dev/null)
  file2=$(jq -r '.file2 // empty' "$journal" 2>/dev/null)

  if [[ -z "$file1" || -z "$file2" ]]; then
    # Corrupt journal — clean up
    rm -f "$journal" "$journal_dir/journal-file1.staged" "$journal_dir/journal-file2.staged"
    return 1
  fi

  # Check that staged content files exist
  if [[ ! -f "$journal_dir/journal-file1.staged" || ! -f "$journal_dir/journal-file2.staged" ]]; then
    # Incomplete journal — clean up
    rm -f "$journal" "$journal_dir/journal-file1.staged" "$journal_dir/journal-file2.staged"
    return 1
  fi

  # Validate staged content is valid JSON
  if ! jq empty "$journal_dir/journal-file1.staged" 2>/dev/null || \
     ! jq empty "$journal_dir/journal-file2.staged" 2>/dev/null; then
    rm -f "$journal" "$journal_dir/journal-file1.staged" "$journal_dir/journal-file2.staged"
    return 1
  fi

  # Replay both writes (atomic_write must be sourced by caller)
  local content1 content2
  content1=$(cat "$journal_dir/journal-file1.staged")
  content2=$(cat "$journal_dir/journal-file2.staged")

  local rc=0
  atomic_write "$file1" "$content1" --no-backup || rc=1
  atomic_write "$file2" "$content2" --no-backup || rc=1

  # Clean up journal
  rm -f "$journal" "$journal_dir/journal-file1.staged" "$journal_dir/journal-file2.staged"

  if [[ "$rc" -ne 0 ]]; then
    echo "WARNING: Dual-write recovery completed with errors" >&2
  fi
  return "$rc"
}
