#!/usr/bin/env bash
# scripts/collect-erosion-metrics.sh
# Core metric collection for code erosion tracking.
# Collects LOC, complexity, function length, imports, and dependencies.
# Usage: collect-erosion-metrics.sh [project_root]
# Output: JSON metrics to stdout
# Exit 0 on success

set -euo pipefail

PROJECT_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

# --- Source file extensions to analyze ---
SOURCE_EXTENSIONS=("ts" "tsx" "js" "jsx" "vue" "svelte" "py" "rb" "go" "rs" "java")

# Build find pattern
FIND_PATTERN=""
for ext in "${SOURCE_EXTENSIONS[@]}"; do
  if [[ -n "$FIND_PATTERN" ]]; then
    FIND_PATTERN="$FIND_PATTERN -o"
  fi
  FIND_PATTERN="$FIND_PATTERN -name '*.${ext}'"
done

# --- Collect modified files (git diff against default branch) ---
DEFAULT_BRANCH=$(git -C "$PROJECT_ROOT" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
MODIFIED_FILES=$(git -C "$PROJECT_ROOT" diff --name-only "${DEFAULT_BRANCH}...HEAD" 2>/dev/null || git -C "$PROJECT_ROOT" diff --name-only HEAD~5 2>/dev/null || echo "")

# Filter to source files only
SOURCE_MODIFIED=()
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  for ext in "${SOURCE_EXTENSIONS[@]}"; do
    if [[ "$file" == *".${ext}" ]]; then
      [[ -f "$PROJECT_ROOT/$file" ]] && SOURCE_MODIFIED+=("$file")
      break
    fi
  done
done <<< "$MODIFIED_FILES"

# --- 1. LOC per modified file ---
FILE_METRICS="[]"
for file in "${SOURCE_MODIFIED[@]+${SOURCE_MODIFIED[@]}}"; do
  [[ -z "$file" ]] && continue
  FULL_PATH="$PROJECT_ROOT/$file"
  [[ -f "$FULL_PATH" ]] || continue

  LOC=$(wc -l < "$FULL_PATH" | tr -d ' ')

  # Cyclomatic complexity: count branching keywords
  COMPLEXITY=$(grep -cE '\b(if|else if|elif|else|for|while|switch|case|catch|&&|\|\||\?)\b' "$FULL_PATH" 2>/dev/null || echo "0")

  # Function count and max function length (brace-balanced)
  FUNC_COUNT=0
  MAX_FUNC_LEN=0
  if [[ "$file" == *.py ]]; then
    # Python: count def statements, estimate length by next def/class/end-of-file
    FUNC_COUNT=$(grep -cE '^\s*def\s+' "$FULL_PATH" 2>/dev/null || echo "0")
    # Approximate max function length
    MAX_FUNC_LEN=$(awk '/^[[:space:]]*def /{if(start)len=NR-start; if(len>max)max=len; start=NR} END{len=NR-start; if(len>max)max=len; print max+0}' "$FULL_PATH" 2>/dev/null || echo "0")
  else
    # JS/TS/Go/Rust/Java: count function/method declarations
    FUNC_COUNT=$(grep -cE '(function\s+\w+|=>\s*\{|const\s+\w+\s*=\s*(async\s*)?\(|^\s*(async\s+)?fn\s+|^\s*(public|private|protected)?\s*(static\s+)?\w+\s*\()' "$FULL_PATH" 2>/dev/null || echo "0")
    # Max function length via awk brace counting
    MAX_FUNC_LEN=$(awk '
      /function |=> *\{|const [a-zA-Z]+ *= *(async *)?\(/ { if(!in_func){in_func=1; start=NR; depth=0} }
      in_func { depth+=gsub(/{/,"&"); depth-=gsub(/}/,"&"); if(depth<=0 && NR>start){len=NR-start+1; if(len>max)max=len; in_func=0} }
      END { print max+0 }
    ' "$FULL_PATH" 2>/dev/null || echo "0")
  fi

  # Import count
  IMPORTS=$(grep -cE '(^\s*(import |from )|require\()' "$FULL_PATH" 2>/dev/null || echo "0")

  # Ensure numeric values are valid
  [[ -z "$LOC" || ! "$LOC" =~ ^[0-9]+$ ]] && LOC=0
  [[ -z "$COMPLEXITY" || ! "$COMPLEXITY" =~ ^[0-9]+$ ]] && COMPLEXITY=0
  [[ -z "$FUNC_COUNT" || ! "$FUNC_COUNT" =~ ^[0-9]+$ ]] && FUNC_COUNT=0
  [[ -z "$MAX_FUNC_LEN" || ! "$MAX_FUNC_LEN" =~ ^[0-9]+$ ]] && MAX_FUNC_LEN=0
  [[ -z "$IMPORTS" || ! "$IMPORTS" =~ ^[0-9]+$ ]] && IMPORTS=0

  FILE_METRICS=$(echo "$FILE_METRICS" | jq \
    --arg file "$file" \
    --argjson loc "$LOC" \
    --argjson complexity "$COMPLEXITY" \
    --argjson func_count "$FUNC_COUNT" \
    --argjson max_func_len "$MAX_FUNC_LEN" \
    --argjson imports "$IMPORTS" \
    '. + [{file: $file, loc: $loc, complexity: $complexity, func_count: $func_count, max_func_len: $max_func_len, imports: $imports}]')
done

# --- 2. Total project LOC ---
TOTAL_LOC=0
LOC_OUTPUT=$(eval "find '$PROJECT_ROOT' -type f \\( $FIND_PATTERN \\) -not -path '*/node_modules/*' -not -path '*/.vibecrew/*' -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/.next/*' -print0 2>/dev/null | xargs -0 wc -l 2>/dev/null" || echo "")
if [[ -n "$LOC_OUTPUT" ]]; then
  # When multiple files, last line has "total". When single file, no total line.
  LAST_LINE=$(echo "$LOC_OUTPUT" | tail -1)
  if echo "$LAST_LINE" | grep -q 'total$'; then
    TOTAL_LOC=$(echo "$LAST_LINE" | awk '{print $1}')
  else
    # Sum all lines (single file or no total)
    TOTAL_LOC=$(echo "$LOC_OUTPUT" | awk '{s+=$1} END{print s+0}')
  fi
fi
[[ -z "$TOTAL_LOC" ]] && TOTAL_LOC=0

# --- 3. Total dependencies ---
TOTAL_DEPS=0
TOTAL_DEV_DEPS=0
if [[ -f "$PROJECT_ROOT/package.json" ]]; then
  TOTAL_DEPS=$(jq '[.dependencies // {} | keys | length] | add // 0' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "0")
  TOTAL_DEV_DEPS=$(jq '[.devDependencies // {} | keys | length] | add // 0' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "0")
fi

# --- 4. Summary stats ---
TOTAL_FILES=${#SOURCE_MODIFIED[@]}
FILES_OVER_LOC_LIMIT=$(echo "$FILE_METRICS" | jq '[.[] | select(.loc > 300)] | length' 2>/dev/null || echo "0")
FUNCS_OVER_LEN_LIMIT=$(echo "$FILE_METRICS" | jq '[.[] | select(.max_func_len > 50)] | length' 2>/dev/null || echo "0")
FUNCS_OVER_COMPLEXITY=$(echo "$FILE_METRICS" | jq '[.[] | select(.complexity > 10)] | length' 2>/dev/null || echo "0")

# --- Output JSON ---
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

jq -n \
  --arg ts "$TIMESTAMP" \
  --argjson total_loc "$TOTAL_LOC" \
  --argjson total_deps "$TOTAL_DEPS" \
  --argjson total_dev_deps "$TOTAL_DEV_DEPS" \
  --argjson files_analyzed "$TOTAL_FILES" \
  --argjson files_over_loc "$FILES_OVER_LOC_LIMIT" \
  --argjson funcs_over_len "$FUNCS_OVER_LEN_LIMIT" \
  --argjson funcs_over_complexity "$FUNCS_OVER_COMPLEXITY" \
  --argjson file_metrics "$FILE_METRICS" \
  '{
    timestamp: $ts,
    total_project_loc: $total_loc,
    total_dependencies: $total_deps,
    total_dev_dependencies: $total_dev_deps,
    files_analyzed: $files_analyzed,
    files_over_loc_limit: $files_over_loc,
    functions_over_length_limit: $funcs_over_len,
    functions_over_complexity_limit: $funcs_over_complexity,
    file_metrics: $file_metrics
  }'
