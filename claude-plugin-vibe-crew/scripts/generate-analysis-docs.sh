#!/usr/bin/env bash
# scripts/generate-analysis-docs.sh
# Transforms onboard-findings.json into 4 persistent markdown analysis docs
# in .vibecrew/analysis/ (~30-50 lines each).
# Usage: generate-analysis-docs.sh [--findings <path>]
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
FINDINGS_FILE="${PROJECT_ROOT}/.vibecrew/onboard-findings.json"
ANALYSIS_DIR="${PROJECT_ROOT}/.vibecrew/analysis"

# Parse optional --findings flag
while [[ $# -gt 0 ]]; do
  case "$1" in
    --findings)
      FINDINGS_FILE="${2:-$FINDINGS_FILE}"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [[ ! -f "$FINDINGS_FILE" ]]; then
  echo "Error: Findings file not found at $FINDINGS_FILE"
  echo "Run /onboard first to generate findings."
  exit 1
fi

mkdir -p "$ANALYSIS_DIR"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# --- stack.md ---
cat > "$ANALYSIS_DIR/stack.md.tmp" <<'HEREDOC_END'
# Stack Analysis
HEREDOC_END

jq -r '
"Generated: \(now | todate)\n" +
"## Runtime\n" +
"- **Language**: \(.dependencies.language // "unknown")\n" +
"- **Framework**: \(.dependencies.framework // "unknown")\n" +
"- **Runtime**: \(.dependencies.runtime // "Node.js")\n" +
"- **Package Manager**: \(.dependencies.package_manager // "npm")\n\n" +
"## Key Dependencies\n" +
(if .dependencies.key_deps then (.dependencies.key_deps | to_entries | map("- \(.key): \(.value)") | join("\n")) else "- (none detected)" end) +
"\n\n## UI & Components\n" +
"- **Component Library**: \(.design_system.component_library // "none")\n" +
"- **Styling**: \(.design_system.type // "unknown")\n\n" +
"## Data & Deploy\n" +
"- **Database**: \(.architecture.database // "unknown")\n" +
"- **Deployment**: \(.architecture.deployment // "unknown")\n"
' "$FINDINGS_FILE" >> "$ANALYSIS_DIR/stack.md.tmp" 2>/dev/null || echo "- (parsing error)" >> "$ANALYSIS_DIR/stack.md.tmp"
mv "$ANALYSIS_DIR/stack.md.tmp" "$ANALYSIS_DIR/stack.md"

# --- architecture.md ---
cat > "$ANALYSIS_DIR/architecture.md.tmp" <<'HEREDOC_END'
# Architecture Analysis
HEREDOC_END

jq -r '
"Generated: \(now | todate)\n" +
"## Directory Structure\n" +
(if .structure.source_dirs then (.structure.source_dirs | map("- `\(.)`") | join("\n")) else "- (not detected)" end) +
"\n\n## Component Organization\n" +
(if .structure.component_dirs then (.structure.component_dirs | map("- `\(.)`") | join("\n")) else "- (not detected)" end) +
"\n\n## API & Routes\n" +
"- **API Style**: \(.architecture.api_style // "unknown")\n" +
"- **API Routes**: \(.structure.api_routes // "unknown")\n" +
"- **Database Schema**: \(.structure.schema_location // "unknown")\n\n" +
"## Patterns\n" +
"- **State Management**: \(.architecture.state_management // "unknown")\n" +
"- **Error Handling**: \(.architecture.error_handling // "unknown")\n" +
"- **Auth Approach**: \(.architecture.auth // "unknown")\n"
' "$FINDINGS_FILE" >> "$ANALYSIS_DIR/architecture.md.tmp" 2>/dev/null || echo "- (parsing error)" >> "$ANALYSIS_DIR/architecture.md.tmp"
mv "$ANALYSIS_DIR/architecture.md.tmp" "$ANALYSIS_DIR/architecture.md"

# --- conventions.md ---
cat > "$ANALYSIS_DIR/conventions.md.tmp" <<'HEREDOC_END'
# Conventions Analysis
HEREDOC_END

jq -r '
"Generated: \(now | todate)\n" +
"## Code Style\n" +
"- **Quotes**: \(.conventions.quotes // "unknown")\n" +
"- **Semicolons**: \(.conventions.semicolons // "unknown")\n" +
"- **Indent**: \(.conventions.indent // "unknown")\n" +
"- **Formatter**: \(.conventions.formatter // "none")\n" +
"- **Linter**: \(.conventions.linter // "none")\n\n" +
"## Naming\n" +
"- **Components**: \(.conventions.component_naming // "unknown")\n" +
"- **Files**: \(.conventions.file_naming // "unknown")\n" +
"- **Imports**: \(.conventions.import_style // "unknown") \(.conventions.path_alias // "")\n\n" +
"## Git\n" +
"- **Commit Format**: \(.conventions.commit_format // "unknown")\n\n" +
"## Testing\n" +
"- **Test Framework**: \(.conventions.test_framework // "unknown")\n" +
"- **Test Co-location**: \(.conventions.test_colocation // "unknown")\n"
' "$FINDINGS_FILE" >> "$ANALYSIS_DIR/conventions.md.tmp" 2>/dev/null || echo "- (parsing error)" >> "$ANALYSIS_DIR/conventions.md.tmp"
mv "$ANALYSIS_DIR/conventions.md.tmp" "$ANALYSIS_DIR/conventions.md"

# --- gaps.md ---
cat > "$ANALYSIS_DIR/gaps.md.tmp" <<'HEREDOC_END'
# Gaps Analysis
HEREDOC_END

jq -r '
"Generated: \(now | todate)\n" +
"## Test Coverage\n" +
"- **Source Files**: \(.test_gaps.source_count // 0)\n" +
"- **Test Files**: \(.test_gaps.test_count // 0)\n" +
"- **Estimated Coverage**: \(.test_gaps.coverage_estimate // "unknown")%\n\n" +
"## Untested Modules (Top 10)\n" +
(if .test_gaps.untested_modules then
  (.test_gaps.untested_modules | .[0:10] | map("- `\(.)`") | join("\n"))
else "- (none detected)" end) +
"\n\n## Documentation Gaps\n" +
"- **README**: \(if .structure.has_readme then "present" else "missing" end)\n" +
"- **API Docs**: \(.structure.api_docs // "unknown")\n\n" +
"## Maintenance\n" +
"- **Deprecated Deps**: \(.dependencies.deprecated_count // 0)\n" +
"- **TODO Count**: \(.structure.todo_count // 0)\n"
' "$FINDINGS_FILE" >> "$ANALYSIS_DIR/gaps.md.tmp" 2>/dev/null || echo "- (parsing error)" >> "$ANALYSIS_DIR/gaps.md.tmp"
mv "$ANALYSIS_DIR/gaps.md.tmp" "$ANALYSIS_DIR/gaps.md"

echo "Analysis docs generated in $ANALYSIS_DIR"
echo "  stack.md | architecture.md | conventions.md | gaps.md"
echo "  Timestamp: $TIMESTAMP"

exit 0
