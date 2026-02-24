#!/usr/bin/env bash
# scripts/migrate-state.sh
# State file migration: reads schema_version from .vibecrew/ files
# and applies sequential migrations if the version is behind CURRENT_VERSION.
# Called by session-startup.sh on every session start.
# Exit 0 always (migration failures should not block the session)

set -euo pipefail

CURRENT_VERSION="1.4.0"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

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
      jq '. + {onboarded: (.onboarded // false), onboarded_at: (.onboarded_at // null)}' \
        "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
      ;;
    config.json)
      # Add performance_coach, doc_generator, and onboarding config sections
      jq '. + {
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
      }' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
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
  jq '. + {
    user_feedback: (.user_feedback // {rating: null, comment: null}),
    trend: (.trend // {direction: "unknown", window_size: 0, average_score: 0})
  }' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}

# --- Migrate mutation log: 1.0.0 -> 1.1.0 ---
migrate_mutation_log_1_0_to_1_1() {
  local file="$1"
  # Add rejection_count, cooldown_until, confidence to each mutation entry
  jq '.mutations = [.mutations[] | . + {
    rejection_count: (.rejection_count // 0),
    cooldown_until: (.cooldown_until // null),
    confidence: (.confidence // "medium")
  }]' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}

# --- Migration: 1.1.0 -> 1.2.0 ---
migrate_1_1_to_1_2() {
  local file="$1"
  local basename
  basename=$(basename "$file")

  case "$basename" in
    config.json)
      # Add audit config section
      jq '. + {
        audit: (.audit // {
          auto_github_issues: false,
          severity_threshold: "high"
        })
      }' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
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
      jq '. + {
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
      }' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
      ;;
    state.json)
      # Add active_workflow field
      jq '. + {active_workflow: (.active_workflow // null)}' \
        "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
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
      jq '. + {
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
      }' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
      ;;
    state.json)
      # No structural changes needed for state in 1.4.0
      ;;
    backlog.json)
      # No structural changes needed for backlog in 1.4.0
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

  # Update schema_version to current
  local tmp="${file}.tmp"
  jq --arg v "$CURRENT_VERSION" '.schema_version = $v' "$file" > "$tmp" && mv "$tmp" "$file"

  echo "Migrated $(basename "$file") from $version to $CURRENT_VERSION"
}

# --- Run on all state files ---
for f in "$PROJECT_ROOT/.vibecrew/config.json" "$PROJECT_ROOT/.vibecrew/state.json" "$PROJECT_ROOT/.vibecrew/backlog.json"; do
  migrate_file "$f"
done

# --- Migrate score files ---
if [[ -d "$PROJECT_ROOT/.vibecrew/scores" ]]; then
  for f in "$PROJECT_ROOT/.vibecrew/scores"/score-*.json; do
    [[ -f "$f" ]] || continue
    local_version=$(jq -r '.schema_version // "1.0.0"' "$f" 2>/dev/null || echo "1.0.0")
    if version_lt "$local_version" "1.1.0"; then
      migrate_score_1_0_to_1_1 "$f"
      jq --arg v "$CURRENT_VERSION" '.schema_version = $v' "$f" > "${f}.tmp" && mv "${f}.tmp" "$f"
    fi
  done
fi

# --- Migrate mutation log ---
MUTATION_LOG="$PROJECT_ROOT/.vibecrew/mutation-log.json"
if [[ -f "$MUTATION_LOG" ]]; then
  local_version=$(jq -r '.schema_version // "1.0.0"' "$MUTATION_LOG" 2>/dev/null || echo "1.0.0")
  if version_lt "$local_version" "1.1.0"; then
    migrate_mutation_log_1_0_to_1_1 "$MUTATION_LOG"
    jq --arg v "$CURRENT_VERSION" '.schema_version = $v' "$MUTATION_LOG" > "${MUTATION_LOG}.tmp" && mv "${MUTATION_LOG}.tmp" "$MUTATION_LOG"
    echo "Migrated mutation-log.json from $local_version to $CURRENT_VERSION"
  fi
fi

exit 0
