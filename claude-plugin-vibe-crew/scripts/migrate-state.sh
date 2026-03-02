#!/usr/bin/env bash
# scripts/migrate-state.sh
# State file migration: reads schema_version from .vibecrew/ files
# and applies sequential migrations if the version is behind CURRENT_VERSION.
# Called by session-startup.sh on every session start.
# Exit 0 always (migration failures should not block the session)

set -euo pipefail

CURRENT_VERSION="1.6.0"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Source shared libraries
source "$(dirname "$0")/lib/lock.sh"
source "$(dirname "$0")/lib/atomic-write.sh"
source "$(dirname "$0")/lib/error-log.sh"

# --- Semver comparison ---
version_lt() {
  # Returns 0 (true) if $1 < $2
  [ "$(printf '%s\n%s' "$1" "$2" | sort -V | head -1)" != "$2" ]
}

# --- Migration: 1.0.0 -> 1.1.0 ---
migrate_1_0_to_1_1() {
  local file="$1"
  local basename
  basename=$(basename "$file")

  case "$basename" in
    state.json)
      # Add onboarded and onboarded_at fields (optional, default false/null)
      local updated
      updated=$(jq '. + {onboarded: (.onboarded // false), onboarded_at: (.onboarded_at // null)}' "$file")
      atomic_write "$file" "$updated" --no-backup
      ;;
    config.json)
      # Add performance_coach, doc_generator, and onboarding config sections
      local updated
      updated=$(jq '. + {
        performance_coach: (.performance_coach // {
          enabled: true,
          min_sessions_for_trends: 3,
          min_sessions_for_mutations: 5
        }),
        doc_generator: (.doc_generator // {
          auto_changelog: true,
          auto_feature_docs: true,
          auto_sidebar_rebuild: true
        }),
        onboarding: (.onboarding // {
          show_hints: true,
          dismissed_hints: []
        })
      }' "$file")
      atomic_write "$file" "$updated" --no-backup
      ;;
    backlog.json)
      # No structural changes needed for backlog in 1.1.0
      ;;
  esac
}

# --- Migrate score files: 1.0.0 -> 1.1.0 ---
migrate_score_1_0_to_1_1() {
  local file="$1"
  # Add user_feedback and trend fields (optional, default null/unknown)
  local updated
  updated=$(jq '. + {
    user_feedback: (.user_feedback // {rating: null, comment: null}),
    trend: (.trend // {direction: "unknown", window_size: 0, average_score: 0})
  }' "$file")
  atomic_write "$file" "$updated" --no-backup
}

# --- Migrate mutation log: 1.0.0 -> 1.1.0 ---
migrate_mutation_log_1_0_to_1_1() {
  local file="$1"
  # Add rejection_count, cooldown_until, confidence to each mutation entry
  local updated
  updated=$(jq '.mutations = [.mutations[] | . + {
    rejection_count: (.rejection_count // 0),
    cooldown_until: (.cooldown_until // null),
    confidence: (.confidence // "medium")
  }]' "$file")
  atomic_write "$file" "$updated" --no-backup
}

# --- Migration: 1.1.0 -> 1.2.0 ---
migrate_1_1_to_1_2() {
  local file="$1"
  local basename
  basename=$(basename "$file")

  case "$basename" in
    config.json)
      # Add audit config section
      local updated
      updated=$(jq '. + {
        audit: (.audit // {
          auto_github_issues: false,
          severity_threshold: "high"
        })
      }' "$file")
      atomic_write "$file" "$updated" --no-backup
      ;;
    state.json)
      # No structural changes needed for state in 1.2.0
      ;;
    backlog.json)
      # No structural changes needed for backlog in 1.2.0
      ;;
  esac
}

# --- Migration: 1.2.0 -> 1.3.0 ---
migrate_1_2_to_1_3() {
  local file="$1"
  local basename
  basename=$(basename "$file")

  case "$basename" in
    config.json)
      # Add opponent_processor, simplify, and ci_healing config sections
      local updated
      updated=$(jq '. + {
        opponent_processor: (.opponent_processor // {
          enabled: true,
          auto_invoke_after_tdr: true
        }),
        simplify: (.simplify // {
          enabled: true,
          min_files_for_analysis: 3,
          auto_revert_on_test_failure: true
        }),
        ci_healing: (.ci_healing // {
          enabled: true,
          max_attempts: 3,
          auto_checkpoint: true
        })
      }' "$file")
      atomic_write "$file" "$updated" --no-backup
      ;;
    state.json)
      # Add active_workflow field
      local updated
      updated=$(jq '. + {active_workflow: (.active_workflow // null)}' "$file")
      atomic_write "$file" "$updated" --no-backup
      ;;
    backlog.json)
      # No structural changes needed for backlog in 1.3.0
      ;;
  esac
}

# --- Migration: 1.3.0 -> 1.4.0 ---
migrate_1_3_to_1_4() {
  local file="$1"
  local basename
  basename=$(basename "$file")

  case "$basename" in
    config.json)
      # Add user_profile section with null defaults
      local updated
      updated=$(jq '. + {
        user_profile: (.user_profile // {
          interview_completed: false,
          role: null,
          code_literacy: null,
          autonomy: null,
          pr_review: null,
          verbosity: null,
          gamification_preference: null,
          learning: null,
          risk_tolerance: null,
          updated_at: null
        })
      }' "$file")
      atomic_write "$file" "$updated" --no-backup
      ;;
    state.json)
      # No structural changes needed for state in 1.4.0
      ;;
    backlog.json)
      # No structural changes needed for backlog in 1.4.0
      ;;
  esac
}

# --- Migration: 1.4.0 -> 1.5.0 ---
migrate_1_4_to_1_5() {
  local file="$1"
  local basename
  basename=$(basename "$file")

  case "$basename" in
    config.json)
      # Add quality_gate, pricing, and locks config sections
      local updated
      updated=$(jq '. + {
        quality_gate: (.quality_gate // {
          timeout_seconds: 120
        }),
        pricing: (.pricing // {
          opus: { input: 15.00, cache_create: 18.75, cache_read: 1.50, output: 75.00 },
          sonnet: { input: 3.00, cache_create: 3.75, cache_read: 0.30, output: 15.00 },
          haiku: { input: 0.25, cache_create: 0.30, cache_read: 0.03, output: 1.25 },
          last_updated: "2026-03-01"
        }),
        locks: (.locks // {
          stale_timeout_secs: 60,
          wait_timeout_secs: 30
        })
      }' "$file")
      atomic_write "$file" "$updated" --no-backup
      ;;
    state.json)
      # No structural changes needed for state in 1.5.0
      ;;
    backlog.json)
      # No structural changes needed for backlog in 1.5.0
      ;;
  esac
}

# --- Migration: 1.5.0 -> 1.6.0 ---
migrate_1_5_to_1_6() {
  local file="$1"
  local basename
  basename=$(basename "$file")

  case "$basename" in
    config.json)
      # Add git_provider, rename github_issues → issues, rename audit.auto_github_issues → audit.auto_issues
      local updated
      updated=$(jq '. + {
        git_provider: (.git_provider // null),
        issues: (.issues // .github_issues // {
          enabled: false,
          autofix_label: "autofix",
          default_mode: "hotfix",
          auto_pr: true,
          sync_limit: 10
        })
      }
      | .audit = ((.audit // {}) | . + {auto_issues: (.auto_issues // .auto_github_issues // false)} | del(.auto_github_issues))
      | del(.github_issues)' "$file")
      atomic_write "$file" "$updated" --no-backup
      ;;
    state.json)
      # No structural changes needed for state in 1.6.0
      ;;
    backlog.json)
      # Rename github_issue_number → issue_number, github_issue_url → issue_url,
      # add provider field, change source/labels
      local updated
      updated=$(jq '.features = [.features[] |
        if .github_issue_number then
          . + {
            issue_number: .github_issue_number,
            issue_url: .github_issue_url,
            provider: "github",
            source: (if .source == "github-issue" then "issue" else .source end),
            labels: [.labels[] | if . == "github-issue" then "issue" else . end]
          } | del(.github_issue_number, .github_issue_url)
        else . end
      ]' "$file")
      atomic_write "$file" "$updated" --no-backup
      ;;
  esac
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

  # Apply sequential migrations
  if version_lt "$version" "1.1.0"; then
    migrate_1_0_to_1_1 "$file"
  fi
  if version_lt "$version" "1.2.0"; then
    migrate_1_1_to_1_2 "$file"
  fi
  if version_lt "$version" "1.3.0"; then
    migrate_1_2_to_1_3 "$file"
  fi
  if version_lt "$version" "1.4.0"; then
    migrate_1_3_to_1_4 "$file"
  fi
  if version_lt "$version" "1.5.0"; then
    migrate_1_4_to_1_5 "$file"
  fi
  if version_lt "$version" "1.6.0"; then
    migrate_1_5_to_1_6 "$file"
  fi

  # Update schema_version to current
  local ver_updated
  ver_updated=$(jq --arg v "$CURRENT_VERSION" '.schema_version = $v' "$file")
  atomic_write "$file" "$ver_updated" --no-backup

  echo "Migrated $(basename "$file") from $version to $CURRENT_VERSION"
}

# --- Acquire lock and run on all state files ---
LOCK_FAIL_OPEN=true

VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
STATE_FILE="$VIBECREW_DIR/state.json"
BACKLOG_FILE="$VIBECREW_DIR/backlog.json"
CONFIG_FILE="$VIBECREW_DIR/config.json"

if acquire_state_lock "migrate-state"; then
  # Backup all files before migration
  BACKUP_DIR="$VIBECREW_DIR/.backup"
  mkdir -p "$BACKUP_DIR"
  for f in "$STATE_FILE" "$BACKLOG_FILE" "$CONFIG_FILE"; do
    [[ -f "$f" ]] && cp "$f" "$BACKUP_DIR/$(basename "$f").pre-migration" 2>/dev/null || log_error "migrate-state" "Failed to backup $(basename "$f") before migration"
  done

  for f in "$CONFIG_FILE" "$STATE_FILE" "$BACKLOG_FILE"; do
    migrate_file "$f"
  done

  # --- Migrate score files (inside lock scope) ---
  if [[ -d "$PROJECT_ROOT/.vibecrew/scores" ]]; then
    for f in "$PROJECT_ROOT/.vibecrew/scores"/score-*.json; do
      [[ -f "$f" ]] || continue
      local_version=$(jq -r '.schema_version // "1.0.0"' "$f" 2>/dev/null || echo "1.0.0")
      if version_lt "$local_version" "1.1.0"; then
        migrate_score_1_0_to_1_1 "$f"
        score_ver=$(jq --arg v "$CURRENT_VERSION" '.schema_version = $v' "$f")
        atomic_write "$f" "$score_ver" --no-backup
      fi
    done
  fi

  # --- Migrate mutation log (inside lock scope) ---
  MUTATION_LOG="$PROJECT_ROOT/.vibecrew/mutation-log.json"
  if [[ -f "$MUTATION_LOG" ]]; then
    local_version=$(jq -r '.schema_version // "1.0.0"' "$MUTATION_LOG" 2>/dev/null || echo "1.0.0")
    if version_lt "$local_version" "1.1.0"; then
      migrate_mutation_log_1_0_to_1_1 "$MUTATION_LOG"
      mut_ver=$(jq --arg v "$CURRENT_VERSION" '.schema_version = $v' "$MUTATION_LOG")
      atomic_write "$MUTATION_LOG" "$mut_ver" --no-backup
      echo "Migrated mutation-log.json from $local_version to $CURRENT_VERSION"
    fi
  fi
else
  echo "WARNING: Could not acquire lock, skipping migration" >&2
fi

[[ "$_LOCK_ACQUIRED" == "true" ]] && release_state_lock
exit 0
