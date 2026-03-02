#!/usr/bin/env bats
# tests/docs-build.bats
# Tests for docs/ build output — prevents GitHub Pages regressions

setup() {
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  DOCS_DIR="$REPO_ROOT/docs"
  DOCS_NEXT_DIR="$REPO_ROOT/docs-next"
}

# =============================================================================
# .nojekyll — prevents GitHub Pages Jekyll from ignoring _astro/ directory
# =============================================================================

@test "docs/.nojekyll exists (GitHub Pages serves _astro/ directory)" {
  [ -f "$DOCS_DIR/.nojekyll" ]
}

@test "docs-next/public/.nojekyll exists (survives Astro rebuilds)" {
  [ -f "$DOCS_NEXT_DIR/public/.nojekyll" ]
}

# =============================================================================
# _astro/ directory — CSS bundle must exist
# =============================================================================

@test "docs/_astro/ directory exists" {
  [ -d "$DOCS_DIR/_astro" ]
}

@test "docs/_astro/ contains at least one CSS file" {
  local css_count
  css_count=$(find "$DOCS_DIR/_astro" -name "*.css" 2>/dev/null | wc -l | tr -d ' ')
  [ "$css_count" -gt 0 ]
}

# =============================================================================
# HTML references — CSS links must resolve to existing files
# =============================================================================

@test "index.html references a CSS file that exists in _astro/" {
  [ -f "$DOCS_DIR/index.html" ] || skip "index.html not found"

  # Extract CSS hrefs from the HTML (pattern: /_astro/*.css or /vibe-crew/_astro/*.css)
  local css_refs
  css_refs=$(grep -oE '(/_astro/[^"]+\.css|/vibe-crew/_astro/[^"]+\.css)' "$DOCS_DIR/index.html" || true)
  [ -n "$css_refs" ] || skip "No CSS references found in index.html"

  # Check each referenced CSS file exists
  local all_found=true
  while IFS= read -r ref; do
    # Strip /vibe-crew prefix if present (the base path)
    local local_path="${ref#/vibe-crew}"
    if [ ! -f "$DOCS_DIR$local_path" ]; then
      echo "Missing CSS file: $DOCS_DIR$local_path (referenced as $ref)"
      all_found=false
    fi
  done <<< "$css_refs"

  [ "$all_found" = "true" ]
}

# =============================================================================
# Font files — self-hosted fonts must be present
# =============================================================================

@test "docs/fonts/ directory exists with font files" {
  [ -d "$DOCS_DIR/fonts" ]
  local font_count
  font_count=$(find "$DOCS_DIR/fonts" -name "*.woff2" 2>/dev/null | wc -l | tr -d ' ')
  [ "$font_count" -gt 0 ]
}

# =============================================================================
# Astro config — base path must be set for GitHub Pages subpath
# =============================================================================

@test "astro.config.mjs has base path set to /vibe-crew" {
  [ -f "$DOCS_NEXT_DIR/astro.config.mjs" ] || skip "astro.config.mjs not found"
  grep -q "base:.*['\"]\/vibe-crew['\"]" "$DOCS_NEXT_DIR/astro.config.mjs"
}

@test "astro.config.mjs outputs to ../docs" {
  [ -f "$DOCS_NEXT_DIR/astro.config.mjs" ] || skip "astro.config.mjs not found"
  grep -q "outDir:.*['\"]\.\.\/docs['\"]" "$DOCS_NEXT_DIR/astro.config.mjs"
}
