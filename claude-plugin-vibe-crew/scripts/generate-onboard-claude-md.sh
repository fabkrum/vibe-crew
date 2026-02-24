#!/usr/bin/env bash
# scripts/generate-onboard-claude-md.sh
# Takes onboard-findings.json output and generates a project-specific CLAUDE.md.
# Usage: generate-onboard-claude-md.sh [--findings <path>] [--output <path>]
# Exit 0 on success, Exit 1 on failure.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
FINDINGS_FILE="$PROJECT_ROOT/.vibecrew/onboard-findings.json"
OUTPUT_FILE="$PROJECT_ROOT/CLAUDE.md"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --findings) FINDINGS_FILE="$2"; shift 2 ;;
    --output) OUTPUT_FILE="$2"; shift 2 ;;
    *) shift ;;
  esac
done

if [[ ! -f "$FINDINGS_FILE" ]]; then
  echo "ERROR: Findings file not found: $FINDINGS_FILE" >&2
  exit 1
fi

# --- Extract findings ---
PROJECT_NAME=$(jq -r '.project_name // "Project"' "$FINDINGS_FILE")
FRAMEWORK=$(jq -r '.dependencies.framework // "unknown"' "$FINDINGS_FILE")
LANGUAGE=$(jq -r '.dependencies.language // "javascript"' "$FINDINGS_FILE")
PKG_MANAGER=$(jq -r '.dependencies.package_manager // "npm"' "$FINDINGS_FILE")
NODE_VERSION=$(jq -r '.dependencies.node_version // "18+"' "$FINDINGS_FILE")

# Conventions
SEMICOLONS=$(jq -r '.conventions.semicolons // true' "$FINDINGS_FILE")
QUOTES=$(jq -r '.conventions.quotes // "single"' "$FINDINGS_FILE")
INDENT=$(jq -r '.conventions.indent // "2-space"' "$FINDINGS_FILE")
FORMATTER=$(jq -r '.conventions.formatter // "none"' "$FINDINGS_FILE")
LINTER=$(jq -r '.conventions.linter // "none"' "$FINDINGS_FILE")
IMPORT_STYLE=$(jq -r '.conventions.import_style // "relative"' "$FINDINGS_FILE")
PATH_ALIAS=$(jq -r '.conventions.path_alias // ""' "$FINDINGS_FILE")
COMP_NAMING=$(jq -r '.conventions.component_naming // "PascalCase"' "$FINDINGS_FILE")
COMMIT_FORMAT=$(jq -r '.conventions.commit_format // "conventional"' "$FINDINGS_FILE")

# Architecture
API_STYLE=$(jq -r '.architecture.api_style // "unknown"' "$FINDINGS_FILE")
STATE_MGMT=$(jq -r '.architecture.state_management // "none"' "$FINDINGS_FILE")

# Testing
TEST_FW=$(jq -r '.test_gaps.test_framework // "unknown"' "$FINDINGS_FILE")
E2E_FW=$(jq -r '.test_gaps.e2e_framework // "none"' "$FINDINGS_FILE")

# Design
DESIGN_TYPE=$(jq -r '.design_system.type // "none"' "$FINDINGS_FILE")
COMP_LIB=$(jq -r '.design_system.component_library // "none"' "$FINDINGS_FILE")

# Key deps
KEY_DEPS=$(jq -r '.dependencies.key_dependencies // [] | join(", ")' "$FINDINGS_FILE")

# Source dirs
SOURCE_DIRS=$(jq -r '.structure.source_dirs // [] | join(", ")' "$FINDINGS_FILE")

# --- Generate CLAUDE.md ---
cat > "$OUTPUT_FILE.tmp" << CLAUDE_EOF
# CLAUDE.md

## Project Overview

$PROJECT_NAME — a $FRAMEWORK project using $LANGUAGE.

## Tech Stack

- **Framework**: $FRAMEWORK
- **Language**: $LANGUAGE
- **Package Manager**: $PKG_MANAGER
- **Node Version**: $NODE_VERSION
- **Key Dependencies**: $KEY_DEPS

## Architecture Rules

CLAUDE_EOF

# Add architecture-specific rules
if [[ "$API_STYLE" != "unknown" && "$API_STYLE" != "none" ]]; then
  echo "- API style: $API_STYLE. Follow existing API patterns when adding new endpoints." >> "$OUTPUT_FILE.tmp"
fi

if [[ "$STATE_MGMT" != "none" ]]; then
  echo "- State management: $STATE_MGMT. Use this for all client-side state. Do not introduce alternative state solutions." >> "$OUTPUT_FILE.tmp"
fi

if [[ "$IMPORT_STYLE" == "absolute" && -n "$PATH_ALIAS" ]]; then
  echo "- Use absolute imports with the \`$PATH_ALIAS\` path alias. Do not use relative imports for cross-directory references." >> "$OUTPUT_FILE.tmp"
fi

cat >> "$OUTPUT_FILE.tmp" << CLAUDE_EOF

## Code Conventions

- **Component naming**: $COMP_NAMING
- **Semicolons**: $SEMICOLONS
- **Quotes**: $QUOTES
- **Indentation**: $INDENT
- **Trailing commas**: $(jq -r '.conventions.trailing_commas // "true"' "$FINDINGS_FILE")
CLAUDE_EOF

if [[ "$FORMATTER" != "none" ]]; then
  echo "- **Formatter**: $FORMATTER (auto-applied on save)" >> "$OUTPUT_FILE.tmp"
fi

if [[ "$LINTER" != "none" ]]; then
  echo "- **Linter**: $LINTER" >> "$OUTPUT_FILE.tmp"
fi

if [[ "$COMMIT_FORMAT" == "conventional" ]]; then
  echo "- **Commit format**: Conventional Commits (feat, fix, docs, style, refactor, test, chore)" >> "$OUTPUT_FILE.tmp"
fi

# Design system section
cat >> "$OUTPUT_FILE.tmp" << CLAUDE_EOF

## Design System

CLAUDE_EOF

if [[ "$DESIGN_TYPE" != "none" ]]; then
  echo "- **Type**: $DESIGN_TYPE" >> "$OUTPUT_FILE.tmp"
fi

if [[ "$COMP_LIB" != "none" ]]; then
  echo "- **Component Library**: $COMP_LIB. Use existing components before creating custom ones." >> "$OUTPUT_FILE.tmp"
fi

if [[ "$DESIGN_TYPE" == "tailwind" ]]; then
  echo "- Use Tailwind utility classes. Follow the project's tailwind.config for custom values." >> "$OUTPUT_FILE.tmp"
elif [[ "$DESIGN_TYPE" == "css-vars" ]]; then
  echo "- Use CSS custom properties from the design system. Do not hardcode colors or spacing values." >> "$OUTPUT_FILE.tmp"
fi

# Testing section
cat >> "$OUTPUT_FILE.tmp" << CLAUDE_EOF

## Testing Requirements

- **Unit/Integration**: $TEST_FW
CLAUDE_EOF

if [[ "$E2E_FW" != "none" ]]; then
  echo "- **E2E**: $E2E_FW" >> "$OUTPUT_FILE.tmp"
fi

cat >> "$OUTPUT_FILE.tmp" << CLAUDE_EOF
- Write tests for all new features and bug fixes.
- Place test files adjacent to source files using \`*.test.*\` naming.

## Common Commands

\`\`\`bash
$PKG_MANAGER install        # Install dependencies
$PKG_MANAGER run dev         # Start dev server
$PKG_MANAGER test            # Run tests
$PKG_MANAGER run build       # Build for production
$PKG_MANAGER run lint        # Run linter
\`\`\`

## Directory Structure

- Source code: $SOURCE_DIRS

## Session Learnings

CLAUDE_EOF

mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
echo "Generated CLAUDE.md at $OUTPUT_FILE"

exit 0
