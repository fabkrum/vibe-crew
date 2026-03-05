#!/usr/bin/env bash
# scripts/load-agent-with-overrides.sh
# Loads an agent prompt with user overrides merged in.
# Override files live in .vibecrew/agent-overrides/<agent>.md
# Sections in the override replace matching sections in the base prompt (by ## heading).
# New sections in the override are appended.
# Usage: load-agent-with-overrides.sh <agent_name>
# Outputs: merged prompt to stdout
# Exit 0 on success, Exit 1 on error.

set -euo pipefail

AGENT_NAME="${1:-}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

if [[ -z "$AGENT_NAME" ]]; then
  echo "Usage: load-agent-with-overrides.sh <agent_name>" >&2
  exit 1
fi

BASE_FILE="$PLUGIN_ROOT/agents/$AGENT_NAME.md"
OVERRIDE_FILE="$PROJECT_ROOT/.vibecrew/agent-overrides/$AGENT_NAME.md"

if [[ ! -f "$BASE_FILE" ]]; then
  echo "Error: Base agent file not found: $BASE_FILE" >&2
  exit 1
fi

# If no override exists, output base as-is
if [[ ! -f "$OVERRIDE_FILE" ]]; then
  cat "$BASE_FILE"
  exit 0
fi

# Validate override file is not empty
if [[ ! -s "$OVERRIDE_FILE" ]]; then
  cat "$BASE_FILE"
  exit 0
fi

# Create temp directory for section files
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# Extract sections from a markdown file into temp files
# Creates: $dir/section-NN.txt with content, $dir/headings.txt with heading names
extract_to_files() {
  local file="$1"
  local dir="$2"
  local line_num=0
  local section_idx=0
  local current_file=""
  local in_frontmatter=false
  local pre_section_file="$dir/pre-sections.txt"

  touch "$pre_section_file"
  > "$dir/headings.txt"

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_num=$((line_num + 1))

    # Handle YAML frontmatter (goes to pre-section)
    if [[ "$line_num" -eq 1 && "$line" == "---" ]]; then
      in_frontmatter=true
      echo "$line" >> "$pre_section_file"
      continue
    fi
    if [[ "$in_frontmatter" == true && "$line" == "---" ]]; then
      in_frontmatter=false
      echo "$line" >> "$pre_section_file"
      continue
    fi
    if [[ "$in_frontmatter" == true ]]; then
      echo "$line" >> "$pre_section_file"
      continue
    fi

    # Detect ## or ### headings
    if echo "$line" | grep -qE '^#{2,3} '; then
      heading="$(echo "$line" | sed 's/^#\+[[:space:]]*//')"
      section_idx=$((section_idx + 1))
      current_file="$dir/section-$(printf '%03d' "$section_idx").txt"
      echo "$heading" >> "$dir/headings.txt"
      echo "$line" > "$current_file"
      continue
    fi

    # Write to current section or pre-sections
    if [[ -n "$current_file" ]]; then
      echo "$line" >> "$current_file"
    else
      echo "$line" >> "$pre_section_file"
    fi
  done < "$file"
}

# Extract base and override sections
BASE_DIR="$WORK_DIR/base"
OVERRIDE_DIR="$WORK_DIR/override"
mkdir -p "$BASE_DIR" "$OVERRIDE_DIR"

extract_to_files "$BASE_FILE" "$BASE_DIR"
extract_to_files "$OVERRIDE_FILE" "$OVERRIDE_DIR"

# Output pre-section content from base (frontmatter + intro)
if [[ -s "$BASE_DIR/pre-sections.txt" ]]; then
  cat "$BASE_DIR/pre-sections.txt"
fi

# Read override headings into a list
OVERRIDE_HEADINGS=""
if [[ -f "$OVERRIDE_DIR/headings.txt" ]]; then
  OVERRIDE_HEADINGS="$(cat "$OVERRIDE_DIR/headings.txt")"
fi

# Track used override headings
USED_OVERRIDES=""

# For each base section, output it or its override replacement
if [[ -f "$BASE_DIR/headings.txt" ]]; then
  base_idx=0
  while IFS= read -r base_heading; do
    base_idx=$((base_idx + 1))
    base_section="$BASE_DIR/section-$(printf '%03d' "$base_idx").txt"

    # Check if override has a matching heading
    override_found=false
    if [[ -n "$OVERRIDE_HEADINGS" ]]; then
      override_idx=0
      while IFS= read -r override_heading; do
        override_idx=$((override_idx + 1))
        if [[ "$override_heading" == "$base_heading" ]]; then
          override_section="$OVERRIDE_DIR/section-$(printf '%03d' "$override_idx").txt"
          if [[ -f "$override_section" ]]; then
            cat "$override_section"
            echo ""
            override_found=true
            USED_OVERRIDES="$USED_OVERRIDES|$override_heading|"
            break
          fi
        fi
      done <<< "$OVERRIDE_HEADINGS"
    fi

    if [[ "$override_found" == false ]]; then
      cat "$base_section"
      echo ""
    fi
  done < "$BASE_DIR/headings.txt"
fi

# Append override-only sections (headings not in base)
if [[ -n "$OVERRIDE_HEADINGS" ]]; then
  override_idx=0
  while IFS= read -r override_heading; do
    override_idx=$((override_idx + 1))
    if [[ "$USED_OVERRIDES" != *"|$override_heading|"* ]]; then
      override_section="$OVERRIDE_DIR/section-$(printf '%03d' "$override_idx").txt"
      if [[ -f "$override_section" ]]; then
        echo ""
        cat "$override_section"
      fi
    fi
  done <<< "$OVERRIDE_HEADINGS"
fi

exit 0
