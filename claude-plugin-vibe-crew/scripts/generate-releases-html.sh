#!/usr/bin/env bash
# scripts/generate-releases-html.sh
# Parses CHANGELOG.md and generates docs/releases.html.
# CHANGELOG.md is the single source of truth — releases.html is always regenerated.
# Usage: generate-releases-html.sh
# Output: Overwrites docs/releases.html

set -euo pipefail

# --- Resolve paths ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$PLUGIN_ROOT/.." && pwd)"
CHANGELOG="$PLUGIN_ROOT/CHANGELOG.md"
OUTPUT="$REPO_ROOT/docs/releases.html"

if [[ ! -f "$CHANGELOG" ]]; then
  echo "Error: $CHANGELOG not found" >&2
  exit 1
fi

# --- HTML-escape a string ---
html_escape() {
  local s="$1"
  s="${s//&/&amp;}"
  s="${s//</&lt;}"
  s="${s//>/&gt;}"
  echo "$s"
}

# --- Convert inline markdown to HTML ---
# Handles: `code` -> <code>, -- -> &mdash;, -> -> &rarr;
inline_md() {
  local s="$1"
  # HTML-escape first (but preserve backticks for code processing)
  s="${s//&/&amp;}"
  s="${s//</&lt;}"
  s="${s//>/&gt;}"
  # Convert `code` to <code>code</code> (using sed for regex)
  s=$(echo "$s" | sed 's/`\([^`]*\)`/<code>\1<\/code>/g')
  # Convert -- to &mdash; (but not inside code tags, good enough for our use case)
  s=$(echo "$s" | sed 's/ -- / \&mdash; /g')
  # Convert -> to &rarr;
  s=$(echo "$s" | sed 's/ -&gt; / \&rarr; /g')
  echo "$s"
}

# --- Collect version numbers for nav pills ---
VERSIONS=()
while IFS= read -r line; do
  if [[ "$line" =~ ^##\ \[([0-9]+\.[0-9]+\.[0-9]+)\] ]]; then
    VERSIONS+=("${BASH_REMATCH[1]}")
  fi
done < "$CHANGELOG"

# --- Count total files across all releases ---
TOTAL_FILES=$(grep -c '^ *- ' "$CHANGELOG" 2>/dev/null || echo "0")

# --- Begin HTML output ---
{
cat << 'HEADER_EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VibeCrew — Release Notes</title>
  <style>
    :root {
      --color-bg: #0a0a0b;
      --color-surface: #111113;
      --color-surface-2: #18181b;
      --color-surface-3: #1e1e22;
      --color-border: #27272a;
      --color-border-subtle: #1e1e22;
      --color-text: #fafafa;
      --color-text-secondary: #a1a1aa;
      --color-text-muted: #71717a;
      --color-accent: #a78bfa;
      --color-accent-dim: #7c3aed;
      --color-accent-bg: rgba(167, 139, 250, 0.08);
      --color-green: #4ade80;
      --color-green-dim: rgba(74, 222, 128, 0.1);
      --color-amber: #fbbf24;
      --color-amber-dim: rgba(251, 191, 36, 0.1);
      --color-red: #f87171;
      --color-red-dim: rgba(248, 113, 113, 0.1);
      --color-blue: #60a5fa;
      --color-blue-dim: rgba(96, 165, 250, 0.1);
      --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      --font-mono: 'JetBrains Mono', 'Fira Code', 'SF Mono', Consolas, monospace;
      --radius: 12px;
      --radius-sm: 8px;
      --radius-xs: 6px;
      --max-width: 860px;
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }

    html {
      scroll-behavior: smooth;
      scrollbar-width: thin;
      scrollbar-color: var(--color-border) transparent;
    }

    body {
      font-family: var(--font-sans);
      background: var(--color-bg);
      color: var(--color-text);
      line-height: 1.7;
      font-size: 16px;
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
    }

    /* ---- SIDEBAR ---- */
    .sidebar { position: fixed; top: 0; left: 0; bottom: 0; width: 260px; background: var(--color-surface); border-right: 1px solid var(--color-border-subtle); overflow-y: auto; z-index: 200; padding: 0; scrollbar-width: thin; scrollbar-color: var(--color-border) transparent; }
    .sidebar-header { padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--color-border-subtle); }
    .sidebar-header .nav-brand { display: flex; align-items: center; gap: 0.5rem; font-weight: 700; font-size: 1.1rem; color: var(--color-text); text-decoration: none; }
    .sidebar-header .nav-brand span { color: var(--color-accent); }
    .sidebar-nav { padding: 1rem 0; }
    .sidebar-group { padding: 0 0 0.5rem; }
    .sidebar-label { display: flex; align-items: center; justify-content: space-between; font-size: 0.65rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.1em; color: var(--color-text-muted); padding: 1rem 1.5rem 0.4rem; user-select: none; cursor: pointer; transition: color 0.15s; }
    .sidebar-label:hover { color: var(--color-text-secondary); }
    .sidebar-label::after { content: ''; width: 0; height: 0; border-left: 4px solid transparent; border-right: 4px solid transparent; border-top: 5px solid currentColor; transition: transform 0.2s; }
    .sidebar-group.collapsed .sidebar-label::after { transform: rotate(-90deg); }
    .sidebar-group.collapsed .sidebar-link { display: none; }
    .sidebar-link { display: block; font-size: 0.875rem; color: var(--color-text-secondary); text-decoration: none; padding: 0.35rem 1.5rem; transition: all 0.15s; border-left: 2px solid transparent; }
    .sidebar-link:hover { color: var(--color-text); background: var(--color-surface-2); text-decoration: none; }
    .sidebar-link.active { color: var(--color-accent); background: var(--color-accent-bg); border-left-color: var(--color-accent); }
    /* ---- MOBILE BAR ---- */
    .mobile-bar { display: none; position: fixed; top: 0; left: 0; right: 0; height: 52px; background: rgba(10, 10, 11, 0.92); backdrop-filter: blur(16px) saturate(1.4); -webkit-backdrop-filter: blur(16px) saturate(1.4); border-bottom: 1px solid var(--color-border-subtle); z-index: 300; padding: 0 1rem; align-items: center; gap: 0.75rem; }
    .mobile-bar .nav-brand { display: flex; align-items: center; gap: 0.5rem; font-weight: 700; font-size: 1rem; color: var(--color-text); text-decoration: none; }
    .mobile-bar .nav-brand span { color: var(--color-accent); }
    .hamburger { background: none; border: none; color: var(--color-text-secondary); cursor: pointer; padding: 0.4rem; border-radius: var(--radius-xs); display: flex; align-items: center; justify-content: center; transition: all 0.15s; }
    .hamburger:hover { color: var(--color-text); background: var(--color-surface-2); }
    .sidebar-overlay { display: none; position: fixed; inset: 0; background: rgba(0, 0, 0, 0.5); z-index: 150; }
    /* ---- LAYOUT ---- */
    .layout { margin-left: 260px; }

    /* ---- MAIN ---- */
    .main {
      max-width: var(--max-width);
      margin: 0 auto;
      padding: 3rem 2rem 6rem;
    }

    /* ---- SECTIONS ---- */
    .section {
      margin-bottom: 5rem;
    }

    .section-label {
      display: inline-block;
      font-size: 0.7rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.1em;
      color: var(--color-accent);
      margin-bottom: 0.75rem;
    }

    h2 {
      font-size: 1.9rem;
      font-weight: 750;
      letter-spacing: -0.025em;
      line-height: 1.2;
      margin-bottom: 1rem;
    }

    h3 {
      font-size: 1.3rem;
      font-weight: 700;
      letter-spacing: -0.01em;
      margin-bottom: 0.75rem;
      margin-top: 2.5rem;
    }

    h4 {
      font-size: 1.05rem;
      font-weight: 650;
      margin-bottom: 0.5rem;
      margin-top: 2rem;
    }

    .section > p,
    .section > ul,
    .section > ol {
      color: var(--color-text-secondary);
      margin-bottom: 1.25rem;
    }

    p {
      margin-bottom: 1rem;
      color: var(--color-text-secondary);
    }

    strong {
      color: var(--color-text);
      font-weight: 600;
    }

    a {
      color: var(--color-accent);
      text-decoration: none;
    }

    a:hover {
      text-decoration: underline;
    }

    ul, ol {
      padding-left: 1.5rem;
      margin-bottom: 1.25rem;
      color: var(--color-text-secondary);
    }

    li {
      margin-bottom: 0.4rem;
    }

    li::marker {
      color: var(--color-text-muted);
    }

    /* ---- CODE ---- */
    code {
      font-family: var(--font-mono);
      font-size: 0.85em;
      background: var(--color-surface-2);
      padding: 0.15em 0.45em;
      border-radius: 4px;
      color: var(--color-accent);
      border: 1px solid var(--color-border-subtle);
    }

    pre {
      background: var(--color-surface);
      border: 1px solid var(--color-border);
      border-radius: var(--radius-sm);
      padding: 1.25rem 1.5rem;
      overflow-x: auto;
      margin-bottom: 1.5rem;
      position: relative;
    }

    pre code {
      background: none;
      padding: 0;
      border: none;
      color: var(--color-text-secondary);
      font-size: 0.85rem;
      line-height: 1.7;
    }

    /* ---- FOOTER ---- */
    .footer {
      text-align: center;
      padding: 3rem 2rem;
      border-top: 1px solid var(--color-border-subtle);
      color: var(--color-text-muted);
      font-size: 0.85rem;
    }

    /* ---- RELEASE NOTES ---- */
    .release { margin-bottom: 4rem; }
    .release-header { display: flex; align-items: baseline; gap: 1rem; margin-bottom: 1.5rem; flex-wrap: wrap; }
    .release-header h2 { margin-bottom: 0; }
    .release-date { font-size: 0.9rem; color: var(--color-text-muted); font-family: var(--font-mono); }
    .release-tag { display: inline-flex; align-items: center; padding: 0.2rem 0.6rem; border-radius: 4px; font-size: 0.75rem; font-weight: 600; font-family: var(--font-mono); text-decoration: none; }
    .release-tag:hover { text-decoration: none; }
    .change-category { margin-top: 2rem; margin-bottom: 1rem; }
    .change-category h3 { display: inline-flex; align-items: center; gap: 0.5rem; }
    .change-badge { display: inline-flex; align-items: center; padding: 0.15rem 0.5rem; border-radius: 4px; font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; }
    .change-badge.added { background: var(--color-green-dim); color: var(--color-green); }
    .change-badge.changed { background: var(--color-amber-dim); color: var(--color-amber); }
    .change-badge.fixed { background: var(--color-blue-dim); color: var(--color-blue); }
    .feature-group { margin-top: 1.5rem; margin-bottom: 1rem; }
    .feature-group h4 { color: var(--color-text); margin-top: 0; }
    .file-list { list-style: none; padding-left: 0; }
    .file-list li { padding: 0.5rem 0; border-bottom: 1px solid var(--color-border-subtle); font-size: 0.9rem; color: var(--color-text-secondary); }
    .file-list li:last-child { border-bottom: none; }
    .file-list code { font-size: 0.8em; }
    .file-list .file-desc { color: var(--color-text-muted); }
    .version-nav { display: flex; gap: 0.75rem; margin-bottom: 2rem; flex-wrap: wrap; }
    .version-nav a { display: inline-flex; align-items: center; padding: 0.4rem 1rem; background: var(--color-surface); border: 1px solid var(--color-border); border-radius: var(--radius-xs); color: var(--color-text-secondary); text-decoration: none; font-size: 0.85rem; font-family: var(--font-mono); transition: all 0.15s; }
    .version-nav a:hover { border-color: var(--color-accent-dim); color: var(--color-accent); text-decoration: none; }

    /* ---- RESPONSIVE ---- */
    @media (max-width: 768px) {
      .sidebar { transform: translateX(-100%); transition: transform 0.25s ease; }
      body.sidebar-open .sidebar { transform: translateX(0); }
      body.sidebar-open .sidebar-overlay { display: block; }
      .mobile-bar { display: flex; }
      .layout { margin-left: 0; padding-top: 52px; }
      .main { padding: 2rem 1.25rem 4rem; }
      h2 { font-size: 1.5rem; }
      h3 { font-size: 1.15rem; }
      pre { padding: 1rem; }
    }
  </style>
</head>
<body>

<div class="mobile-bar">
  <button class="hamburger" onclick="document.body.classList.toggle('sidebar-open')" aria-label="Toggle navigation">
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.5"><line x1="3" y1="5" x2="17" y2="5"/><line x1="3" y1="10" x2="17" y2="10"/><line x1="3" y1="15" x2="17" y2="15"/></svg>
  </button>
  <a href="index.html" class="nav-brand"><span>&gt;_</span> VibeCrew</a>
</div>

<aside class="sidebar">
  <div class="sidebar-header">
    <a href="index.html" class="nav-brand"><span>&gt;_</span> VibeCrew</a>
  </div>
  <nav class="sidebar-nav">
    <div class="sidebar-group">
      <div class="sidebar-label" onclick="this.parentElement.classList.toggle('collapsed')">Workflows</div>
      <a href="workflow.html" class="sidebar-link">Core Workflow</a>
      <a href="advanced-features.html" class="sidebar-link">Advanced Features</a>
      <a href="personalization.html" class="sidebar-link">Personalization</a>
      <a href="gamification.html" class="sidebar-link">Gamification</a>
      <a href="warp.html" class="sidebar-link">Warp Tips &amp; Tricks</a>
      <a href="tips.html" class="sidebar-link">Tips &amp; Troubleshooting</a>
      <a href="example-session.html" class="sidebar-link">Example Session</a>
    </div>
    <div class="sidebar-group collapsed">
      <div class="sidebar-label" onclick="this.parentElement.classList.toggle('collapsed')">How It Works</div>
      <a href="architecture.html" class="sidebar-link">Overview</a>
      <a href="plugin.html" class="sidebar-link">Plugin Structure</a>
      <a href="agents.html" class="sidebar-link">Sub-Agents</a>
      <a href="hooks.html" class="sidebar-link">Hooks</a>
      <a href="mcp-servers.html" class="sidebar-link">MCP Servers</a>
      <a href="command-flow.html" class="sidebar-link">Slash Commands</a>
      <a href="skills.html" class="sidebar-link">Skills Reference</a>
      <a href="scripts.html" class="sidebar-link">Bash Scripts</a>
      <a href="templates.html" class="sidebar-link">Templates</a>
      <a href="runtime.html" class="sidebar-link">Runtime State</a>
      <a href="safety.html" class="sidebar-link">Permissions &amp; Safety</a>
      <a href="self-improving.html" class="sidebar-link">Self-Improving System</a>
      <a href="dashboard.html" class="sidebar-link">Vibe Dashboard</a>
    </div>
    <div class="sidebar-group collapsed">
      <div class="sidebar-label" onclick="this.parentElement.classList.toggle('collapsed')">Reference</div>
      <a href="commands.html" class="sidebar-link">Slash Commands</a>
      <a href="ui-patterns.html" class="sidebar-link">UI Pattern Guide</a>
      <a href="business-patterns.html" class="sidebar-link">Business Patterns</a>
      <a href="glossary.html" class="sidebar-link">Glossary</a>
      <a href="faq.html" class="sidebar-link">FAQ</a>
    </div>
    <a href="releases.html" class="sidebar-link active">Changelog</a>
  </nav>
</aside>

<div class="sidebar-overlay" onclick="document.body.classList.remove('sidebar-open')"></div>
<script>var a=document.querySelector(".sidebar-link.active");if(a){var g=a.closest(".sidebar-group");if(g)g.classList.remove("collapsed");}</script>

<div class="layout">
<div class="main">

  <section class="section">
    <span class="section-label">Changelog</span>
    <h2>Release Notes</h2>
    <p>All notable changes to VibeCrew, following <a href="https://keepachangelog.com/en/1.1.0/">Keep a Changelog</a> and <a href="https://semver.org/spec/v2.0.0.html">Semantic Versioning</a>.</p>
  </section>

HEADER_EOF

# --- Version nav pills ---
echo '  <div class="version-nav">'
for v in "${VERSIONS[@]}"; do
  echo "    <a href=\"#v${v}\">v${v}</a>"
done
echo '  </div>'
echo ''

# --- State machine: parse CHANGELOG.md ---
IN_RELEASE=false
IN_CATEGORY=false
IN_FEATURE_GROUP=false
IN_FILE_LIST=false
IN_LOOSE_LIST=false
CURRENT_VERSION=""
CURRENT_DATE=""
CURRENT_CATEGORY=""
ITEM_COUNT=0

close_file_list() {
  if $IN_FILE_LIST; then
    echo '      </ul>'
    echo '    </div>'
    IN_FILE_LIST=false
  fi
}

close_loose_list() {
  if $IN_LOOSE_LIST; then
    echo '      </ul>'
    IN_LOOSE_LIST=false
  fi
}

close_feature_group() {
  close_file_list
  IN_FEATURE_GROUP=false
}

close_category() {
  close_loose_list
  close_feature_group
  IN_CATEGORY=false
}

close_release() {
  close_category
  if $IN_RELEASE; then
    echo '  </div>'
    echo ''
    IN_RELEASE=false
  fi
}

while IFS= read -r line || [[ -n "$line" ]]; do

  # --- ## [X.Y.Z] - DATE → new release ---
  if [[ "$line" =~ ^##\ \[([0-9]+\.[0-9]+\.[0-9]+)\]\ -\ ([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
    close_release
    CURRENT_VERSION="${BASH_REMATCH[1]}"
    CURRENT_DATE="${BASH_REMATCH[2]}"
    IN_RELEASE=true
    IN_CATEGORY=false
    IN_FEATURE_GROUP=false
    IN_FILE_LIST=false
    IN_LOOSE_LIST=false

    cat << RELEASE_EOF
  <!-- ============================================================ -->
  <!-- v${CURRENT_VERSION}$(printf '%*s' $((55 - ${#CURRENT_VERSION})) '' | tr ' ' ' ') -->
  <!-- ============================================================ -->
  <div class="release" id="v${CURRENT_VERSION}">
    <div class="release-header">
      <h2>v${CURRENT_VERSION}</h2>
      <span class="release-date">${CURRENT_DATE}</span>
      <a href="https://github.com/fabkrum/vibe-crew/releases/tag/v${CURRENT_VERSION}" class="release-tag" style="background:var(--color-accent-bg);color:var(--color-accent);">GitHub Release</a>
    </div>
RELEASE_EOF
    continue
  fi

  # Skip non-release content
  if ! $IN_RELEASE; then
    continue
  fi

  # --- Horizontal rule (---) → separator between releases, ignore ---
  if [[ "$line" =~ ^---$ ]]; then
    continue
  fi

  # --- ### Added/Changed/Fixed → change category ---
  if [[ "$line" =~ ^###\ (Added|Changed|Fixed) ]]; then
    close_category
    CURRENT_CATEGORY="${BASH_REMATCH[1]}"
    IN_CATEGORY=true
    local_badge=$(echo "$CURRENT_CATEGORY" | tr '[:upper:]' '[:lower:]')

    cat << CATEGORY_EOF

    <div class="change-category">
      <h3><span class="change-badge ${local_badge}">${CURRENT_CATEGORY}</span></h3>
    </div>
CATEGORY_EOF
    continue
  fi

  # --- #### Feature Name → feature group ---
  if [[ "$line" =~ ^####\ (.+) ]]; then
    close_loose_list
    close_feature_group
    IN_FEATURE_GROUP=true
    IN_FILE_LIST=false
    local_title="${BASH_REMATCH[1]}"
    # Convert -- to &mdash; in title
    local_title_html=$(inline_md "$local_title")

    cat << FEATURE_EOF

    <div class="feature-group">
      <h4>${local_title_html}</h4>
FEATURE_EOF
    continue
  fi

  # --- Paragraph text (non-empty, non-list line after ####) ---
  if $IN_FEATURE_GROUP && ! $IN_FILE_LIST && [[ "$line" =~ ^[A-Za-z] ]]; then
    local_para=$(inline_md "$line")
    echo "      <p>${local_para}</p>"
    continue
  fi

  # --- List item: - `file.ext` -- description ---
  if [[ "$line" =~ ^-\ \`([^\`]+)\`\ --\ (.+) ]]; then
    local_file="${BASH_REMATCH[1]}"
    local_desc="${BASH_REMATCH[2]}"
    local_desc_html=$(inline_md "$local_desc")

    if $IN_FEATURE_GROUP; then
      if ! $IN_FILE_LIST; then
        echo '      <ul class="file-list">'
        IN_FILE_LIST=true
      fi
      echo "        <li><code>${local_file}</code> &mdash; <span class=\"file-desc\">${local_desc_html}</span></li>"
    else
      # Loose item under category, no feature group
      if ! $IN_LOOSE_LIST; then
        echo '      <ul class="file-list">'
        IN_LOOSE_LIST=true
      fi
      echo "        <li><code>${local_file}</code> &mdash; <span class=\"file-desc\">${local_desc_html}</span></li>"
    fi
    ITEM_COUNT=$((ITEM_COUNT + 1))
    continue
  fi

  # --- List item: - plain text (no file) ---
  if [[ "$line" =~ ^-\ (.+) ]]; then
    local_text="${BASH_REMATCH[1]}"
    local_text_html=$(inline_md "$local_text")

    if $IN_FEATURE_GROUP; then
      if ! $IN_FILE_LIST; then
        echo '      <ul class="file-list">'
        IN_FILE_LIST=true
      fi
      echo "        <li><span class=\"file-desc\">${local_text_html}</span></li>"
    else
      if ! $IN_LOOSE_LIST; then
        echo '      <ul class="file-list">'
        IN_LOOSE_LIST=true
      fi
      echo "        <li><span class=\"file-desc\">${local_text_html}</span></li>"
    fi
    ITEM_COUNT=$((ITEM_COUNT + 1))
    continue
  fi

done < "$CHANGELOG"

# Close any open elements
close_release

# --- Footer ---
cat << FOOTER_EOF
  <p style="text-align:center; color:var(--color-text-muted); margin-top:3rem;"><strong>Total: ~${ITEM_COUNT} items across ${#VERSIONS[@]} releases.</strong></p>
</div>

<footer class="footer">
  <p><strong>VibeCrew</strong> &mdash; The Autonomous Vibe-Coding Operating System</p>
  <p style="margin-top: 0.25rem;">A Claude Code plugin by Fabian Krumbholz &middot; February 2026</p>
</footer>
</div>

</body>
</html>
FOOTER_EOF

} > "$OUTPUT"

echo "Generated: $OUTPUT"
echo "  Versions: ${#VERSIONS[@]} (${VERSIONS[*]})"
echo "  Items: $ITEM_COUNT"
exit 0
