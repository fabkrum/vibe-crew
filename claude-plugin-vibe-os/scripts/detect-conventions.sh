#!/usr/bin/env bash
# scripts/detect-conventions.sh
# Scans project files for coding conventions: naming, imports, formatting,
# commit format, git hooks, CI config.
# Outputs JSON with detected conventions.
# Exit 0 always.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# --- Detect primary language ---
LANGUAGE="unknown"
PACKAGE_MANAGER="unknown"
if [[ -f "$PROJECT_ROOT/package.json" ]]; then
  LANGUAGE="javascript"
  if [[ -f "$PROJECT_ROOT/package-lock.json" ]]; then PACKAGE_MANAGER="npm"
  elif [[ -f "$PROJECT_ROOT/yarn.lock" ]]; then PACKAGE_MANAGER="yarn"
  elif [[ -f "$PROJECT_ROOT/pnpm-lock.yaml" ]]; then PACKAGE_MANAGER="pnpm"
  else PACKAGE_MANAGER="npm"; fi
  # Refine to TypeScript if tsconfig exists
  [[ -f "$PROJECT_ROOT/tsconfig.json" ]] && LANGUAGE="typescript"
elif [[ -f "$PROJECT_ROOT/pyproject.toml" || -f "$PROJECT_ROOT/setup.py" || -f "$PROJECT_ROOT/requirements.txt" ]]; then
  LANGUAGE="python"
  if [[ -f "$PROJECT_ROOT/pyproject.toml" ]]; then PACKAGE_MANAGER="pip"
  elif [[ -f "$PROJECT_ROOT/Pipfile" ]]; then PACKAGE_MANAGER="pipenv"
  elif [[ -f "$PROJECT_ROOT/poetry.lock" ]]; then PACKAGE_MANAGER="poetry"
  else PACKAGE_MANAGER="pip"; fi
elif [[ -f "$PROJECT_ROOT/Gemfile" ]]; then
  LANGUAGE="ruby"; PACKAGE_MANAGER="bundler"
elif [[ -f "$PROJECT_ROOT/go.mod" ]]; then
  LANGUAGE="go"; PACKAGE_MANAGER="go-modules"
elif [[ -f "$PROJECT_ROOT/Cargo.toml" ]]; then
  LANGUAGE="rust"; PACKAGE_MANAGER="cargo"
elif [[ -f "$PROJECT_ROOT/composer.json" ]]; then
  LANGUAGE="php"; PACKAGE_MANAGER="composer"
elif [[ -f "$PROJECT_ROOT/pom.xml" ]]; then
  LANGUAGE="java"; PACKAGE_MANAGER="maven"
elif [[ -f "$PROJECT_ROOT/build.gradle" || -f "$PROJECT_ROOT/build.gradle.kts" ]]; then
  LANGUAGE="java"; PACKAGE_MANAGER="gradle"
fi

# --- Helper: detect from file sample ---
sample_files() {
  local pattern="$1"
  local count="${2:-10}"
  find "$PROJECT_ROOT" -maxdepth 4 -name "$pattern" \
    -not -path "*/node_modules/*" \
    -not -path "*/.next/*" \
    -not -path "*/dist/*" \
    -not -path "*/.vibeos/*" \
    2>/dev/null | head -"$count"
}

# --- Detect semicolons ---
SEMICOLONS="unknown"
JS_FILES=$(sample_files "*.ts" 5)
if [[ -z "$JS_FILES" ]]; then
  JS_FILES=$(sample_files "*.js" 5)
fi
if [[ -n "$JS_FILES" ]]; then
  SEMI_COUNT=0
  NO_SEMI_COUNT=0
  while IFS= read -r f; do
    [[ -z "$f" || ! -f "$f" ]] && continue
    # Check last non-empty, non-comment lines for semicolons
    HAS_SEMI=$(grep -c ';\s*$' "$f" 2>/dev/null || echo "0")
    NO_SEMI=$(grep -cE '[^;{}\s]\s*$' "$f" 2>/dev/null || echo "0")
    if [[ "$HAS_SEMI" -gt "$NO_SEMI" ]]; then
      ((SEMI_COUNT++))
    else
      ((NO_SEMI_COUNT++))
    fi
  done <<< "$JS_FILES"
  if [[ "$SEMI_COUNT" -gt "$NO_SEMI_COUNT" ]]; then
    SEMICOLONS="true"
  elif [[ "$NO_SEMI_COUNT" -gt "$SEMI_COUNT" ]]; then
    SEMICOLONS="false"
  fi
fi

# --- Detect quotes ---
QUOTES="unknown"
if [[ -n "$JS_FILES" ]]; then
  SINGLE_COUNT=0
  DOUBLE_COUNT=0
  while IFS= read -r f; do
    [[ -z "$f" || ! -f "$f" ]] && continue
    SINGLES=$(grep -c "'" "$f" 2>/dev/null || echo "0")
    DOUBLES=$(grep -c '"' "$f" 2>/dev/null || echo "0")
    if [[ "$SINGLES" -gt "$DOUBLES" ]]; then
      ((SINGLE_COUNT++))
    else
      ((DOUBLE_COUNT++))
    fi
  done <<< "$JS_FILES"
  if [[ "$SINGLE_COUNT" -gt "$DOUBLE_COUNT" ]]; then
    QUOTES="single"
  else
    QUOTES="double"
  fi
fi

# --- Detect indentation ---
INDENT="unknown"
if [[ -n "$JS_FILES" ]]; then
  FIRST_FILE=$(echo "$JS_FILES" | head -1)
  if [[ -f "$FIRST_FILE" ]]; then
    # Check leading whitespace
    if grep -qP '^\t' "$FIRST_FILE" 2>/dev/null; then
      INDENT="tabs"
    elif grep -qP '^    ' "$FIRST_FILE" 2>/dev/null; then
      INDENT="4-space"
    elif grep -qP '^  [^ ]' "$FIRST_FILE" 2>/dev/null; then
      INDENT="2-space"
    fi
  fi
fi

# --- Detect formatter ---
FORMATTER="none"
if [[ -f "$PROJECT_ROOT/.prettierrc" || -f "$PROJECT_ROOT/.prettierrc.json" || \
      -f "$PROJECT_ROOT/.prettierrc.js" || -f "$PROJECT_ROOT/prettier.config.js" || \
      -f "$PROJECT_ROOT/prettier.config.mjs" ]]; then
  FORMATTER="prettier"
fi

# --- Detect linter ---
LINTER="none"
if [[ -f "$PROJECT_ROOT/.eslintrc.json" || -f "$PROJECT_ROOT/.eslintrc.js" || \
      -f "$PROJECT_ROOT/.eslintrc.yml" || -f "$PROJECT_ROOT/eslint.config.js" || \
      -f "$PROJECT_ROOT/eslint.config.mjs" ]]; then
  LINTER="eslint"
fi

# --- Detect import style ---
IMPORT_STYLE="relative"
PATH_ALIAS=""
if [[ -f "$PROJECT_ROOT/tsconfig.json" ]]; then
  HAS_PATHS=$(jq -r '.compilerOptions.paths // empty' "$PROJECT_ROOT/tsconfig.json" 2>/dev/null || echo "")
  if [[ -n "$HAS_PATHS" ]]; then
    IMPORT_STYLE="absolute"
    PATH_ALIAS=$(jq -r '.compilerOptions.paths | keys[0] // ""' "$PROJECT_ROOT/tsconfig.json" 2>/dev/null | sed 's/\*.*//' || echo "")
  fi
fi

# --- Detect component naming ---
COMPONENT_NAMING="unknown"
COMPONENT_FILES=$(find "$PROJECT_ROOT" -maxdepth 4 \
  \( -name "*.tsx" -o -name "*.jsx" -o -name "*.vue" -o -name "*.svelte" \) \
  -not -path "*/node_modules/*" -not -path "*/.next/*" 2>/dev/null | head -10)
if [[ -n "$COMPONENT_FILES" ]]; then
  PASCAL_COUNT=0
  KEBAB_COUNT=0
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    BASENAME=$(basename "$f" | sed 's/\..*//')
    if echo "$BASENAME" | grep -qP '^[A-Z][a-zA-Z]+'; then
      ((PASCAL_COUNT++))
    elif echo "$BASENAME" | grep -qP '^[a-z]+-[a-z]+'; then
      ((KEBAB_COUNT++))
    fi
  done <<< "$COMPONENT_FILES"
  if [[ "$PASCAL_COUNT" -gt "$KEBAB_COUNT" ]]; then
    COMPONENT_NAMING="PascalCase"
  elif [[ "$KEBAB_COUNT" -gt "$PASCAL_COUNT" ]]; then
    COMPONENT_NAMING="kebab-case"
  fi
fi

# --- Detect commit format ---
COMMIT_FORMAT="freeform"
if command -v git &>/dev/null; then
  RECENT_COMMITS=$(git log --oneline -20 --format='%s' 2>/dev/null || echo "")
  if [[ -n "$RECENT_COMMITS" ]]; then
    CONVENTIONAL_COUNT=$(echo "$RECENT_COMMITS" | grep -cE '^(feat|fix|docs|style|refactor|test|chore|ci|build|perf|revert)\(' 2>/dev/null || echo "0")
    TOTAL_COMMITS=$(echo "$RECENT_COMMITS" | wc -l | tr -d ' ')
    if [[ "$TOTAL_COMMITS" -gt 0 ]]; then
      RATIO=$((CONVENTIONAL_COUNT * 100 / TOTAL_COMMITS))
      if [[ "$RATIO" -ge 60 ]]; then
        COMMIT_FORMAT="conventional"
      fi
    fi
  fi
fi

# --- Detect CI ---
CI="false"
if [[ -d "$PROJECT_ROOT/.github/workflows" || -f "$PROJECT_ROOT/.gitlab-ci.yml" || \
      -f "$PROJECT_ROOT/.circleci/config.yml" || -f "$PROJECT_ROOT/Jenkinsfile" ]]; then
  CI="true"
fi

# --- Detect trailing commas ---
TRAILING_COMMAS="unknown"
if [[ "$FORMATTER" == "prettier" ]]; then
  # Check prettier config for trailing comma setting
  for cfg in "$PROJECT_ROOT/.prettierrc" "$PROJECT_ROOT/.prettierrc.json"; do
    if [[ -f "$cfg" ]]; then
      TC=$(jq -r '.trailingComma // "all"' "$cfg" 2>/dev/null || echo "all")
      if [[ "$TC" == "all" || "$TC" == "es5" ]]; then
        TRAILING_COMMAS="true"
      else
        TRAILING_COMMAS="false"
      fi
      break
    fi
  done
fi

# --- Per-language formatter/linter detection ---
if [[ "$LANGUAGE" != "javascript" && "$LANGUAGE" != "typescript" && "$LANGUAGE" != "unknown" ]]; then
  case "$LANGUAGE" in
    python)
      # Formatter: Black or Ruff
      if [[ -f "$PROJECT_ROOT/pyproject.toml" ]]; then
        if grep -q '\[tool\.black\]' "$PROJECT_ROOT/pyproject.toml" 2>/dev/null; then FORMATTER="black"
        elif grep -q '\[tool\.ruff\]' "$PROJECT_ROOT/pyproject.toml" 2>/dev/null; then FORMATTER="ruff"; fi
      fi
      if [[ "$FORMATTER" == "none" ]] && command -v black &>/dev/null; then FORMATTER="black"; fi
      # Linter: Ruff, Flake8, Pylint
      if [[ -f "$PROJECT_ROOT/.flake8" || -f "$PROJECT_ROOT/setup.cfg" ]]; then
        grep -q 'flake8' "$PROJECT_ROOT/setup.cfg" 2>/dev/null && LINTER="flake8"
      fi
      if [[ -f "$PROJECT_ROOT/pyproject.toml" ]] && grep -q '\[tool\.ruff\]' "$PROJECT_ROOT/pyproject.toml" 2>/dev/null; then
        LINTER="ruff"
      fi
      [[ "$LINTER" == "none" ]] && [[ -f "$PROJECT_ROOT/.pylintrc" ]] && LINTER="pylint"
      # Naming: PEP8 snake_case
      INDENT="4-space"
      ;;
    ruby)
      [[ -f "$PROJECT_ROOT/.rubocop.yml" ]] && FORMATTER="rubocop" && LINTER="rubocop"
      INDENT="2-space"
      ;;
    go)
      FORMATTER="gofmt"
      if [[ -f "$PROJECT_ROOT/.golangci.yml" || -f "$PROJECT_ROOT/.golangci.yaml" ]]; then
        LINTER="golangci-lint"
      fi
      INDENT="tabs"
      ;;
    rust)
      FORMATTER="rustfmt"
      LINTER="clippy"
      INDENT="4-space"
      ;;
    php)
      [[ -f "$PROJECT_ROOT/.php-cs-fixer.php" || -f "$PROJECT_ROOT/.php-cs-fixer.dist.php" ]] && FORMATTER="php-cs-fixer"
      [[ -f "$PROJECT_ROOT/phpstan.neon" || -f "$PROJECT_ROOT/phpstan.neon.dist" ]] && LINTER="phpstan"
      INDENT="4-space"
      ;;
    java)
      [[ -f "$PROJECT_ROOT/checkstyle.xml" ]] && LINTER="checkstyle"
      [[ -f "$PROJECT_ROOT/.editorconfig" ]] && FORMATTER="editorconfig"
      INDENT="4-space"
      ;;
  esac
fi

# --- Output JSON ---
jq -n \
  --arg lang "$LANGUAGE" \
  --arg pkg_mgr "$PACKAGE_MANAGER" \
  --arg semi "$SEMICOLONS" \
  --arg quotes "$QUOTES" \
  --arg indent "$INDENT" \
  --arg formatter "$FORMATTER" \
  --arg linter "$LINTER" \
  --arg import_style "$IMPORT_STYLE" \
  --arg path_alias "$PATH_ALIAS" \
  --arg comp_naming "$COMPONENT_NAMING" \
  --arg commit_fmt "$COMMIT_FORMAT" \
  --arg ci "$CI" \
  --arg trailing "$TRAILING_COMMAS" \
  '{
    language: $lang,
    package_manager: $pkg_mgr,
    semicolons: (if $semi == "true" then true elif $semi == "false" then false else null end),
    quotes: $quotes,
    indent: $indent,
    formatter: $formatter,
    linter: $linter,
    import_style: $import_style,
    path_alias: $path_alias,
    component_naming: $comp_naming,
    commit_format: $commit_fmt,
    ci: (if $ci == "true" then true else false end),
    trailing_commas: (if $trailing == "true" then true elif $trailing == "false" then false else null end)
  }'

exit 0
