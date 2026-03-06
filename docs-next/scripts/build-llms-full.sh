#!/usr/bin/env bash
# build-llms-full.sh — Flatten all docs pages into a single markdown file for AI ingestion.
# Run as part of the build process: generates public/llms-full.txt

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="${SCRIPT_DIR}/../src/pages"
OUT_FILE="${SCRIPT_DIR}/../public/llms-full.txt"

# Header
cat > "$OUT_FILE" << 'HEADER'
# VibeCrew — Full Documentation

> This file contains the complete VibeCrew documentation flattened into a single markdown file
> for AI model ingestion. Generated automatically at build time.
>
> Project: https://github.com/fabkrum/vibe-crew
> Docs: https://fabkrum.github.io/vibe-crew/

---

HEADER

# Page order — matches navigation structure
PAGES=(
  "index"
  "setup-detail"
  "project-planning"
  "warp"
  "faq"
  "workflow"
  "advanced-features"
  "architecture"
  "scripts"
  "gamification"
  "hooks"
  "mcp-servers"
  "companion-skills"
  "safety"
  "personalization"
  "plugin"
  "runtime"
  "self-improving"
  "skills"
  "command-flow"
  "status-line"
  "agents"
  "templates"
  "testing"
  "dashboard"
  "ui-patterns"
  "business-patterns"
  "animation-patterns"
  "form-patterns"
  "i18n-guide"
  "legal-compliance"
  "filter-search-patterns"
  "dataviz-patterns"
  "notification-patterns"
  "auth-patterns"
  "media-patterns"
  "collaboration-patterns"
  "settings-patterns"
  "onboarding-patterns"
  "social-patterns"
  "seo-patterns"
  "dark-patterns"
  "glossary"
  "releases"
)

for page in "${PAGES[@]}"; do
  file="${DOCS_DIR}/${page}.astro"
  if [[ ! -f "$file" ]]; then
    continue
  fi

  # Extract title from the page (look for title prop in DocsLayout)
  title=$(sed -n 's/.*title="\([^"]*\)".*/\1/p' "$file" | head -1)
  if [[ -z "$title" ]]; then
    title="$page"
  fi

  echo "## ${title}" >> "$OUT_FILE"
  echo "" >> "$OUT_FILE"

  # Extract text content: strip Astro frontmatter, HTML tags, style/script blocks, keep text
  sed -n '/^---$/,/^---$/!p' "$file" \
    | sed '/<style>/,/<\/style>/d' \
    | sed '/<script[^>]*>/,/<\/script>/d' \
    | sed 's/<[^>]*>//g' \
    | sed '/^[[:space:]]*$/d' \
    | sed 's/^[[:space:]]*//' \
    | sed 's/&mdash;/—/g; s/&rarr;/→/g; s/&middot;/·/g; s/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/&nbsp;/ /g; s/&quot;/"/g' \
    >> "$OUT_FILE"

  echo "" >> "$OUT_FILE"
  echo "---" >> "$OUT_FILE"
  echo "" >> "$OUT_FILE"
done

# Word count for info
wc_result=$(wc -w < "$OUT_FILE" | tr -d ' ')
echo "Generated llms-full.txt: ${wc_result} words"
