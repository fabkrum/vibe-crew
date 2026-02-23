# Research: Documentation Generation and Auto-Updating Docs Site

> **Phase 1 Research** | Document 06 | February 2026
>
> This document covers the design and tooling for VibeOS's self-updating documentation site. It addresses static site generator selection, automated release notes, file-based Kanban boards, session logging, token usage tracking, cost calculation, statistics dashboards, dual documentation sections (system vs. product), and the auto-rebuild mechanism triggered by PostToolUse hooks.

---

## Table of Contents

1. [Static Site Generators for Documentation](#1-static-site-generators-for-documentation)
2. [Auto-Generating Release Notes from Git History and PRs](#2-auto-generating-release-notes-from-git-history-and-prs)
3. [Kanban Board Implementation](#3-kanban-board-implementation)
4. [Session Logging and Statistics Tracking](#4-session-logging-and-statistics-tracking)
5. [Token Usage Tracking and Cost Calculation](#5-token-usage-tracking-and-cost-calculation)
6. [Statistics Dashboard Design](#6-statistics-dashboard-design)
7. [Two Documentation Sections: System Docs and Product Docs](#7-two-documentation-sections-system-docs-and-product-docs)
8. [Auto-Update Mechanism](#8-auto-update-mechanism)
9. [Recommendations for VibeOS](#9-recommendations-for-vibeos)
10. [Sources](#10-sources)

---

## 1. Static Site Generators for Documentation

### 1.1 Selection Criteria

VibeOS requires a documentation site that satisfies several unusual constraints:

- **Auto-rebuilds after every PR** -- the build must be fast (under 10 seconds for a typical docs site).
- **AI-generation friendly** -- the SSG must work well when an AI agent writes and modifies Markdown and configuration files directly. Complex templating systems or proprietary DSLs add friction.
- **Interactive dashboard support** -- the site must embed charts and a Kanban board as interactive components.
- **Lightweight output** -- users may preview the docs site on `localhost:3002` alongside their dev server (3000) and test server (3001). The docs site should consume minimal resources.
- **Low maintenance overhead** -- the Doc Generator agent must be able to scaffold, configure, and maintain the site without human intervention.

### 1.2 Astro

- **URL**: https://astro.build
- **Architecture**: Content-first, islands architecture. Ships zero JavaScript by default; interactive components ("islands") hydrate independently.
- **Build tool**: Vite under the hood.
- **Content format**: Markdown, MDX, or any framework component (React, Vue, Svelte, Solid).
- **Key strengths**:
  - Near-zero client JavaScript for static pages (under 50 KB typical).
  - Cold build for 200 pages: approximately 5-10 seconds.
  - HMR: under 100ms.
  - Can mix components from multiple frameworks in a single page.
  - Content Collections API provides type-safe frontmatter validation.
- **Key weaknesses**:
  - Newer ecosystem (2022+), smaller plugin library than Docusaurus.
  - No built-in docs navigation; requires Starlight or manual setup.
  - Islands model adds conceptual overhead for simple sites.

**Minimal Astro docs project:**

```bash
# Scaffold a new Astro project with the docs template
npm create astro@latest -- --template docs my-docs
cd my-docs
npm run dev    # Starts on http://localhost:4321
npm run build  # Outputs to dist/
```

**Configuration (`astro.config.mjs`):**

```javascript
import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';
import vue from '@astrojs/vue';

export default defineConfig({
  integrations: [
    mdx(),
    vue()  // Enables Vue islands for dashboard components
  ],
  output: 'static',
  server: { port: 3002 }
});
```

### 1.3 VitePress

- **URL**: https://vitepress.dev
- **Architecture**: Vue-based, Markdown-first. Each Markdown file becomes a Vue single-file component at build time.
- **Build tool**: Vite (native).
- **Content format**: Markdown with embedded Vue components.
- **Key strengths**:
  - Fastest cold build of all evaluated options: 3-8 seconds for 200 pages.
  - Fastest HMR: under 50ms.
  - Built-in sidebar auto-generation from file structure.
  - Built-in local search (MiniSearch).
  - Dark/light mode, syntax highlighting (Shiki), last-updated timestamps from git.
  - Data loaders (`.data.js` files) run at build time and support HMR watching.
  - Excellent developer experience for Vue-based interactive components.
- **Key weaknesses**:
  - Vue-only for interactive components (no React/Svelte islands).
  - No built-in doc versioning (community plugin required).
  - No built-in blog support.
  - Client bundle approximately 80-120 KB (heavier than Astro's zero-JS pages).

**Minimal VitePress docs project:**

```bash
# Scaffold a new VitePress site
mkdir docs && cd docs
npm init -y
npm install vitepress --save-dev
npx vitepress init
npm run docs:dev    # Starts on http://localhost:5173
npm run docs:build  # Outputs to .vitepress/dist/
```

**Configuration (`docs/.vitepress/config.js`):**

```javascript
import { defineConfig } from 'vitepress';

export default defineConfig({
  title: 'MyApp Docs',
  description: 'Auto-generated documentation',
  themeConfig: {
    nav: [
      { text: 'Guide', link: '/guide/' },
      { text: 'API', link: '/api/' },
      { text: 'Dashboard', link: '/dashboard' }
    ],
    sidebar: {
      '/guide/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Introduction', link: '/guide/' },
            { text: 'Installation', link: '/guide/installation' },
            { text: 'Commands', link: '/guide/commands' }
          ]
        }
      ],
      '/api/': [
        {
          text: 'API Reference',
          items: [
            { text: 'Authentication', link: '/api/auth' },
            { text: 'Users', link: '/api/users' }
          ]
        }
      ]
    },
    search: { provider: 'local' }
  },
  vite: {
    server: { port: 3002 }
  }
});
```

### 1.4 Nextra

- **URL**: https://nextra.site
- **Architecture**: Next.js-based, MDX-first. Inherits all Next.js rendering strategies (SSG, SSR, ISR).
- **Build tool**: Webpack or Turbopack (via Next.js).
- **Content format**: MDX with `_meta.json` sidebar configuration.
- **Key strengths**:
  - Tightest integration with the Next.js ecosystem.
  - Built-in full-text search (Flexsearch).
  - SSR/ISR support enables dynamic content without a separate API.
  - API routes can serve live data.
  - Best choice when the user's SaaS is also built with Next.js.
- **Key weaknesses**:
  - Tied to the Next.js ecosystem (heavy dependency).
  - Cold build: 20-40 seconds for 200 pages.
  - Client bundle: 150-250 KB per page (Next.js runtime + React).
  - HMR: 200ms-3s (Turbopack) or 1-3s (Webpack).
  - Overkill for a standalone docs site.

**Minimal Nextra docs project:**

```bash
npx create-next-app my-docs --example https://github.com/shuding/nextra-docs-template
cd my-docs
npm run dev    # Starts on http://localhost:3000
npm run build  # Outputs to .next/
```

### 1.5 Docusaurus

- **URL**: https://docusaurus.io
- **Architecture**: React-based (Meta project). Full-featured documentation platform with versioning, i18n, blog, and plugin system.
- **Build tool**: Webpack (v2), partially Rspack (v3).
- **Content format**: Markdown, MDX v3.
- **Key strengths**:
  - Most mature and battle-tested (2017+, used by React, Jest, Babel, Redux).
  - Built-in doc versioning (critical for library documentation).
  - Built-in blog engine.
  - Algolia DocSearch integration (free for open source).
  - Largest plugin ecosystem.
  - Theme customization via "swizzling" (component overrides).
- **Key weaknesses**:
  - Heaviest client bundle: 200-300 KB per page.
  - Slowest build: 30-60 seconds for 200 pages.
  - Slowest HMR: 1-3 seconds.
  - Doc versioning is irrelevant for VibeOS (single project at a time).
  - React dependency adds weight for a docs-only site.

### 1.6 Starlight (Astro-Based)

- **URL**: https://starlight.astro.build
- **Architecture**: Built on Astro specifically for documentation. Provides sidebar, navigation, search, i18n, and accessibility out of the box.
- **Build tool**: Vite (via Astro).
- **Content format**: Markdown, MDX.
- **Key strengths**:
  - Zero-JS pages by default, lightest possible output.
  - Pagefind search runs entirely client-side (no server, no external service).
  - Accessible by default (WCAG AA).
  - Component overrides for deep customization.
  - Automatic OpenGraph images.
  - Can embed React, Vue, or Svelte components as islands.
- **Key weaknesses**:
  - Newer (2023+), smaller community.
  - Interactive components require understanding the islands architecture.
  - Slightly slower build than VitePress (5-10 seconds vs. 3-8 seconds).

**Minimal Starlight project:**

```bash
npm create astro@latest -- --template starlight my-docs
cd my-docs
npm run dev    # Starts on http://localhost:4321
npm run build  # Outputs to dist/
```

**Configuration (`astro.config.mjs`):**

```javascript
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import vue from '@astrojs/vue';

export default defineConfig({
  integrations: [
    starlight({
      title: 'MyApp Docs',
      sidebar: [
        {
          label: 'System Guide',
          items: [
            { label: 'Installation', link: '/guide/installation/' },
            { label: 'Commands', link: '/guide/commands/' },
            { label: 'Agents', link: '/guide/agents/' }
          ]
        },
        {
          label: 'Product Docs',
          autogenerate: { directory: 'product' }
        },
        {
          label: 'Dashboard',
          items: [
            { label: 'Statistics', link: '/dashboard/' },
            { label: 'Kanban Board', link: '/dashboard/kanban/' }
          ]
        }
      ]
    }),
    vue()
  ],
  server: { port: 3002 }
});
```

### 1.7 Comparison Table

| Feature | Astro (plain) | Starlight | VitePress | Nextra | Docusaurus |
|---|---|---|---|---|---|
| **Client JS (typical page)** | ~0-50 KB | ~0-50 KB | ~80-120 KB | ~150-250 KB | ~200-300 KB |
| **Cold build (200 pages)** | ~5-10s | ~5-10s | ~3-8s | ~20-40s | ~30-60s |
| **HMR speed** | <100ms | <100ms | <50ms | 200ms-3s | 1-3s |
| **Underlying bundler** | Vite | Vite | Vite | Webpack/Turbopack | Webpack/Rspack |
| **Component framework** | Any (islands) | Any (islands) | Vue only | React (Next.js) | React |
| **Built-in search** | None (manual) | Pagefind | MiniSearch | Flexsearch | Algolia/community |
| **Built-in sidebar/nav** | No | Yes | Yes | Yes | Yes |
| **Doc versioning** | No | Plugin | Community | Community | Built-in |
| **i18n** | Manual | Built-in | Built-in | Built-in | Built-in |
| **MDX support** | Yes | Yes | No (Vue in MD) | Yes | Yes |
| **Blog support** | Manual | Plugin | No | Built-in | Built-in |
| **Accessibility (WCAG)** | Manual | AA by default | Partial | Partial | Partial |
| **GitHub stars (approx.)** | ~50k+ (Astro) | ~6k+ | ~14k+ | ~12k+ | ~58k+ |
| **AI-generation friendly** | High | High | Highest | Medium | Medium |
| **Dashboard embedding** | Islands | Islands | Vue components | React components | React components |

**AI-generation friendliness** refers to how easily an AI agent can scaffold, configure, modify, and rebuild the site. VitePress scores highest because:
- Configuration is a single JavaScript file with a clear structure.
- Pages are plain Markdown with optional Vue `<script setup>` blocks.
- No JSX, no complex templating, no framework-specific abstractions.
- Build output is deterministic and fast to verify.

### 1.8 Recommendation for VibeOS

**Primary choice: VitePress.**

VitePress offers the best combination of build speed (critical for auto-rebuilds on every PR), developer experience (Vue components integrate naturally with the dashboard), and AI-generation friendliness (simple configuration, plain Markdown). Its 80-120 KB client bundle is acceptable since the dashboard page is the only page that loads interactive charts (VitePress code-splits per page).

**Alternative: Starlight (Astro-based).**

If zero-JS pages become a higher priority (for example, if users frequently access docs on slow connections), Starlight is the next best option. Its islands architecture means interactive dashboard components only load on the dashboard page, while all other pages ship zero JavaScript. Migration from VitePress to Starlight is straightforward since both use Vite and Markdown.

---

## 2. Auto-Generating Release Notes from Git History and PRs

### 2.1 The Foundation: Conventional Commits

Automated release notes depend on a machine-parseable commit format. The Conventional Commits specification (v1.0.0) provides this foundation. (See Research Document 03 for full details on conventional commits.)

**Quick reference:**

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

| Type | SemVer Impact | Release Notes Section |
|---|---|---|
| `feat` | MINOR | "New Features" |
| `fix` | PATCH | "Bug Fixes" |
| `perf` | PATCH | "Performance Improvements" |
| `refactor` | None | "Refactoring" (or hidden) |
| `docs` | None | "Documentation" (or hidden) |
| `test` | None | Hidden |
| `chore` | None | Hidden |
| Any type with `!` or `BREAKING CHANGE` footer | MAJOR | "Breaking Changes" |

### 2.2 release-please (Google)

release-please is a fully automated release management tool that reads conventional commits on the main branch, maintains a "Release PR" that accumulates changelog entries, and creates a GitHub Release when the PR is merged.

**How it works:**

1. Developer merges feature PRs with conventional commit messages into `main`.
2. release-please detects the new commits and opens (or updates) a single "Release PR."
3. The Release PR contains an updated `CHANGELOG.md` and a version bump in `package.json`.
4. When a maintainer merges the Release PR, release-please creates a GitHub Release with an annotated tag and structured release notes.

**GitHub Action configuration:**

```yaml
# .github/workflows/release-please.yml
name: Release Please

on:
  push:
    branches:
      - main

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          release-type: node
```

**Custom configuration (`release-please-config.json`):**

```json
{
  "release-type": "node",
  "packages": {
    ".": {
      "changelog-path": "CHANGELOG.md",
      "bump-minor-pre-major": true,
      "bump-patch-for-minor-pre-major": true,
      "include-component-in-tag": false
    }
  },
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json"
}
```

**Output format (generated CHANGELOG.md):**

```markdown
## [1.3.0](https://github.com/user/repo/compare/v1.2.0...v1.3.0) (2026-02-23)

### Features

* **auth**: add OAuth2 login with Google provider ([#42](https://github.com/user/repo/pull/42))
* **dashboard**: add real-time metric charts ([abc1234](https://github.com/user/repo/commit/abc1234))

### Bug Fixes

* **payments**: correct decimal rounding in invoice totals ([#38](https://github.com/user/repo/pull/38))
```

**Strengths:**
- Fully automated, no manual version decisions.
- Works with conventional commits (which VibeOS enforces via hooks).
- Creates a Review PR as a safety checkpoint.
- Supports 18+ language ecosystems.
- Supports monorepos (manifest mode).

**Weaknesses:**
- Requires GitHub Actions (CI dependency).
- Release notes are derived from commit messages, not human-curated descriptions.

### 2.3 semantic-release

semantic-release automates the entire package release workflow: version determination, release notes generation, package publishing, and notification.

**How it works:**

1. Analyzes commits since the last release using conventional commit rules.
2. Determines the next version number.
3. Generates release notes.
4. Publishes the package (npm, GitHub Releases, etc.).
5. Notifies (Slack, email, etc.).

**Configuration (`.releaserc.json`):**

```json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/npm",
    "@semantic-release/github",
    ["@semantic-release/git", {
      "assets": ["CHANGELOG.md", "package.json"],
      "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
    }]
  ]
}
```

**Strengths:**
- Highly extensible plugin system.
- Supports custom release note templates.
- Can publish to npm, GitHub Releases, Docker registries, etc.
- Mature ecosystem (2014+).

**Weaknesses:**
- More complex configuration than release-please.
- Runs as a CI step (no Release PR review checkpoint).
- Plugin ordering matters and is error-prone.

### 2.4 Changesets

Changesets takes a different approach: developers explicitly create "changeset" files describing their changes. A bot aggregates these into version bumps and changelog entries.

**Changeset file format (`.changeset/add-auth.md`):**

```markdown
---
"@myapp/web": minor
"@myapp/api": patch
---

Added OAuth2 authentication with Google provider.
Fixed API rate limiting for auth endpoints.
```

**CLI workflow:**

```bash
npx changeset          # Interactive: select packages, bump type, write description
npx changeset version   # Apply changesets, update CHANGELOGs, bump versions
npx changeset publish   # Publish to npm
```

**Strengths:**
- Human-written descriptions (higher quality release notes).
- Excellent monorepo support (per-package changelogs).
- Pre-release and snapshot release support.

**Weaknesses:**
- Requires manual changeset creation (incompatible with autonomous AI workflows).
- Adds friction for every PR.

### 2.5 GitHub Releases API (`gh release create`)

For projects without CI, the `gh` CLI can create releases with auto-generated notes:

```bash
# Create a release with auto-generated notes from PR titles
gh release create v1.3.0 --generate-notes

# Create a release with custom notes
gh release create v1.3.0 --notes "$(cat RELEASE_NOTES.md)"

# Create a pre-release
gh release create v1.3.0-beta.1 --prerelease --generate-notes
```

**Custom release note categories (`.github/release.yml`):**

```yaml
changelog:
  categories:
    - title: "Breaking Changes"
      labels: ["breaking-change"]
    - title: "New Features"
      labels: ["enhancement", "feature"]
    - title: "Bug Fixes"
      labels: ["bug", "fix"]
    - title: "Performance"
      labels: ["performance"]
    - title: "Documentation"
      labels: ["documentation"]
    - title: "Other Changes"
      labels: ["*"]
  exclude:
    labels: ["skip-changelog", "dependencies"]
```

### 2.6 Generating Release Notes from PR Descriptions

An AI agent can parse PR descriptions to build richer release notes than commit messages alone:

```bash
#!/usr/bin/env bash
# generate-release-notes-from-prs.sh
# Generates release notes from merged PRs since the last tag.

set -euo pipefail

FROM_TAG="${1:?Usage: generate-release-notes-from-prs.sh <from-tag>}"

echo "# Release Notes"
echo ""
echo "## Changes since $FROM_TAG"
echo ""

# Get the date of the from-tag
TAG_DATE=$(git log -1 --format=%aI "$FROM_TAG" 2>/dev/null || echo "2000-01-01")

# Fetch merged PRs since the tag date
FEATURES=$(gh pr list --state merged --search "merged:>=$TAG_DATE label:feature" \
  --json number,title,body --jq '.[] | "- **#\(.number)**: \(.title)"')
FIXES=$(gh pr list --state merged --search "merged:>=$TAG_DATE label:bug" \
  --json number,title,body --jq '.[] | "- **#\(.number)**: \(.title)"')
BREAKING=$(gh pr list --state merged --search "merged:>=$TAG_DATE label:breaking-change" \
  --json number,title,body --jq '.[] | "- **#\(.number)**: \(.title)"')

if [ -n "$BREAKING" ]; then
  echo "### Breaking Changes"
  echo ""
  echo "$BREAKING"
  echo ""
fi

if [ -n "$FEATURES" ]; then
  echo "### New Features"
  echo ""
  echo "$FEATURES"
  echo ""
fi

if [ -n "$FIXES" ]; then
  echo "### Bug Fixes"
  echo ""
  echo "$FIXES"
  echo ""
fi

# Stats
COMMIT_COUNT=$(git rev-list --count "${FROM_TAG}..HEAD")
echo "### Stats"
echo ""
echo "- **Commits:** $COMMIT_COUNT"
echo "- **Tag date:** $(date -u +%Y-%m-%d)"
```

### 2.7 Release Notes Template for VibeOS

The Doc Generator agent should produce release notes following this template:

```markdown
# Release v{VERSION} -- {DATE}

## Breaking Changes
{List of breaking changes with migration instructions, or "None"}

## New Features
{List of features with brief descriptions and PR links}

## Bug Fixes
{List of fixes with brief descriptions and PR links}

## Performance Improvements
{List of performance changes, or omit section if none}

## Maintenance
{Dependency updates, refactoring, CI changes, or omit section if none}

## Statistics
- **Sessions:** {count} sessions during this release cycle
- **Average Vibe Score:** {score}/100
- **Total cost:** ${cost}
- **Features completed:** {count}
- **Test coverage:** {percent}%

---
*Generated by VibeOS Doc Generator | {timestamp}*
```

### 2.8 Tool Comparison

| Feature | release-please | semantic-release | Changesets | GitHub Native |
|---|---|---|---|---|
| **Automation level** | Fully automated | Fully automated | Semi-automated | Manual trigger |
| **Input source** | Conventional commits | Conventional commits | Changeset files | PR titles + labels |
| **Review checkpoint** | Release PR | None (direct release) | Version PR | None |
| **Monorepo support** | Yes (manifest) | Yes (plugins) | Yes (excellent) | No |
| **CI dependency** | Yes (GitHub Action) | Yes (CI step) | Yes (GitHub bot) | Yes (GitHub) |
| **Human-curated text** | No | No | Yes | Partial |
| **CHANGELOG.md** | Yes | Yes (plugin) | Yes | No |
| **Setup complexity** | Low | Medium | Medium | Very low |
| **VibeOS fit** | **Best** | Good | Poor (requires manual input) | Good (fallback) |

### 2.9 Integration with VibeOS

The Doc Generator agent should:

1. **On PR merge to main**: Parse git log since the last tag, group commits by type, and update a `releases/` directory with a new release notes file.
2. **On tag creation**: Trigger `gh release create` with the generated notes.
3. **Use release-please for CI-based projects**: Configure the GitHub Action during Tier 1 foundation setup.
4. **Fall back to manual generation**: For projects without CI, use the bash script approach (Section 2.6) to generate notes on demand via the `/wrap` command.

---

## 3. Kanban Board Implementation

### 3.1 Design Philosophy

VibeOS's Kanban board is file-based, not a SaaS dependency. The board reads from a single JSON file (`backlog.json`), renders in three contexts (docs site, terminal, Markdown), and updates automatically as agents move features through the development lifecycle.

**No external dependencies**: No Trello, Jira, Linear, or GitHub Projects integration. The board is self-contained within the project repository.

### 3.2 Data Model

The `backlog.json` file serves as the single source of truth:

```json
{
  "version": 1,
  "lastUpdated": "2026-02-23T10:30:00Z",
  "columns": [
    {
      "id": "idea",
      "title": "Ideas",
      "wipLimit": null
    },
    {
      "id": "planned",
      "title": "Planned",
      "wipLimit": 5
    },
    {
      "id": "ready",
      "title": "Ready",
      "wipLimit": 3
    },
    {
      "id": "in-progress",
      "title": "In Progress",
      "wipLimit": 2
    },
    {
      "id": "testing",
      "title": "Testing",
      "wipLimit": 2
    },
    {
      "id": "review",
      "title": "Review",
      "wipLimit": 3
    },
    {
      "id": "done",
      "title": "Done",
      "wipLimit": null
    }
  ],
  "cards": [
    {
      "id": "feat-001",
      "title": "User Authentication",
      "description": "OAuth2 + email/password login with session management",
      "column": "in-progress",
      "priority": "high",
      "labels": ["auth", "security"],
      "createdAt": "2026-02-20T08:00:00Z",
      "updatedAt": "2026-02-23T10:30:00Z",
      "assignedAgent": "feature-developer",
      "complexity": "medium",
      "branch": "feat/user-auth",
      "pr": null,
      "vibeScore": null,
      "sessionIds": ["session-2026-02-23-001"],
      "history": [
        { "from": "idea", "to": "planned", "at": "2026-02-20T09:00:00Z" },
        { "from": "planned", "to": "ready", "at": "2026-02-21T14:00:00Z" },
        { "from": "ready", "to": "in-progress", "at": "2026-02-23T10:00:00Z" }
      ]
    }
  ]
}
```

**Design decisions:**

- **Cards stored in a flat array** (not nested inside columns). This prevents data duplication and makes state transitions a simple field update.
- **History array** tracks every column transition for velocity calculations and audit trails.
- **WIP limits** are enforced by the Workflow Orchestrator before allowing a card to move into a column.

### 3.3 State Transitions

Cards move through columns based on agent actions and user approvals:

```
idea -> planned         Triggered by /plan-features or /new-feature
planned -> ready        Triggered by user approval of the feature spec
ready -> in-progress    Triggered by Feature Developer agent picking up the card
in-progress -> testing  Triggered by Feature Developer completing implementation
testing -> review       Triggered by all tests passing (Quality Check agent)
testing -> in-progress  Triggered by Test Writer finding failures (loop back)
review -> done          Triggered by user approving the PR merge
review -> in-progress   Triggered by user requesting changes (loop back)
```

### 3.4 State Transition Script

```bash
#!/usr/bin/env bash
# move-card.sh
# Moves a Kanban card to a new column with validation.

set -euo pipefail

BACKLOG_FILE=".vibeos/backlog.json"
CARD_ID="${1:?Usage: move-card.sh <card-id> <target-column>}"
TARGET_COL="${2:?Usage: move-card.sh <card-id> <target-column>}"
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Validate the target column exists
VALID_COL=$(jq -r --arg col "$TARGET_COL" '.columns[] | select(.id == $col) | .id' "$BACKLOG_FILE")
if [ -z "$VALID_COL" ]; then
  echo "ERROR: Column '$TARGET_COL' does not exist."
  exit 1
fi

# Check WIP limit
WIP_LIMIT=$(jq -r --arg col "$TARGET_COL" '.columns[] | select(.id == $col) | .wipLimit // "null"' "$BACKLOG_FILE")
if [ "$WIP_LIMIT" != "null" ]; then
  CURRENT_COUNT=$(jq --arg col "$TARGET_COL" '[.cards[] | select(.column == $col)] | length' "$BACKLOG_FILE")
  if [ "$CURRENT_COUNT" -ge "$WIP_LIMIT" ]; then
    echo "ERROR: Column '$TARGET_COL' has reached its WIP limit ($WIP_LIMIT)."
    exit 1
  fi
fi

# Get current column for history entry
CURRENT_COL=$(jq -r --arg id "$CARD_ID" '.cards[] | select(.id == $id) | .column' "$BACKLOG_FILE")

if [ -z "$CURRENT_COL" ]; then
  echo "ERROR: Card '$CARD_ID' not found."
  exit 1
fi

# Update the card
jq --arg id "$CARD_ID" \
   --arg col "$TARGET_COL" \
   --arg from "$CURRENT_COL" \
   --arg now "$NOW" '
  .cards |= map(
    if .id == $id then
      .column = $col |
      .updatedAt = $now |
      .history += [{"from": $from, "to": $col, "at": $now}]
    else . end
  ) |
  .lastUpdated = $now
' "$BACKLOG_FILE" > "${BACKLOG_FILE}.tmp" && mv "${BACKLOG_FILE}.tmp" "$BACKLOG_FILE"

echo "Card '$CARD_ID' moved from '$CURRENT_COL' to '$TARGET_COL'."
```

### 3.5 Rendering: Docs Site (Vue Component)

A Vue component renders the Kanban board in the VitePress docs site:

```vue
<!-- docs/.vitepress/theme/components/KanbanBoard.vue -->
<script setup>
import { computed } from 'vue'

const props = defineProps({
  data: { type: Object, required: true }
})

const boardColumns = computed(() => {
  return props.data.columns.map(col => ({
    ...col,
    cards: props.data.cards
      .filter(c => c.column === col.id)
      .sort((a, b) => {
        const priority = { high: 0, medium: 1, low: 2 }
        return (priority[a.priority] || 3) - (priority[b.priority] || 3)
      })
  }))
})
</script>

<template>
  <div class="kanban-board">
    <div v-for="column in boardColumns" :key="column.id" class="kanban-column">
      <div class="column-header">
        <h3>{{ column.title }}</h3>
        <span class="card-count">{{ column.cards.length }}</span>
        <span v-if="column.wipLimit" class="wip-limit">/ {{ column.wipLimit }}</span>
      </div>
      <div class="column-body">
        <div
          v-for="card in column.cards"
          :key="card.id"
          class="kanban-card"
          :class="'priority-' + card.priority"
        >
          <div class="card-title">{{ card.title }}</div>
          <p class="card-desc">{{ card.description }}</p>
          <div class="card-meta">
            <span v-for="label in card.labels" :key="label" class="label">
              {{ label }}
            </span>
          </div>
          <div class="card-footer">
            <span v-if="card.branch" class="branch">{{ card.branch }}</span>
            <span v-if="card.vibeScore !== null" class="vibe-score">
              {{ card.vibeScore }}
            </span>
          </div>
        </div>
        <div v-if="column.cards.length === 0" class="empty-column">
          No items
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.kanban-board {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 0.75rem;
  overflow-x: auto;
  padding: 1rem 0;
}

.kanban-column {
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  padding: 0.5rem;
  min-height: 150px;
}

.column-header {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  padding: 0.5rem;
  border-bottom: 1px solid var(--vp-c-divider);
  margin-bottom: 0.5rem;
}

.column-header h3 {
  margin: 0;
  font-size: 0.875rem;
  font-weight: 600;
}

.card-count {
  font-size: 0.75rem;
  background: var(--vp-c-brand);
  color: white;
  border-radius: 50%;
  width: 1.25rem;
  height: 1.25rem;
  display: flex;
  align-items: center;
  justify-content: center;
}

.kanban-card {
  background: var(--vp-c-bg);
  border-radius: 6px;
  padding: 0.75rem;
  margin-bottom: 0.5rem;
  border-left: 3px solid var(--vp-c-brand);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
}

.kanban-card.priority-high { border-left-color: #e53e3e; }
.kanban-card.priority-medium { border-left-color: #dd6b20; }
.kanban-card.priority-low { border-left-color: #38a169; }

.card-title { font-weight: 600; font-size: 0.875rem; }
.card-desc { font-size: 0.75rem; color: var(--vp-c-text-2); margin: 0.25rem 0; }

.label {
  font-size: 0.625rem;
  background: var(--vp-c-bg-soft);
  padding: 0.125rem 0.375rem;
  border-radius: 3px;
  margin-right: 0.25rem;
}

.empty-column {
  font-size: 0.75rem;
  color: var(--vp-c-text-3);
  text-align: center;
  padding: 1rem;
}
</style>
```

### 3.6 Rendering: Terminal (ASCII Board)

For the `/status` command, render a compact ASCII board:

```bash
#!/usr/bin/env bash
# render-kanban-terminal.sh
# Renders the Kanban board as an ASCII table for terminal display.

set -euo pipefail

BACKLOG_FILE=".vibeos/backlog.json"

# Column width
W=18

# Build the header
COLUMNS=$(jq -r '.columns[].id' "$BACKLOG_FILE")
HEADER=""
SEPARATOR=""
for col_id in $COLUMNS; do
  TITLE=$(jq -r --arg id "$col_id" '.columns[] | select(.id == $id) | .title' "$BACKLOG_FILE")
  COUNT=$(jq --arg id "$col_id" '[.cards[] | select(.column == $id)] | length' "$BACKLOG_FILE")
  CELL=$(printf "%-${W}s" "$TITLE ($COUNT)")
  HEADER="${HEADER}| ${CELL}"
  SEPARATOR="${SEPARATOR}+$(printf '%0.s-' $(seq 1 $((W + 2))))"
done
HEADER="${HEADER}|"
SEPARATOR="${SEPARATOR}+"

echo "$SEPARATOR"
echo "$HEADER"
echo "$SEPARATOR"

# Find the max card count across columns
MAX_CARDS=$(jq '[.columns[].id as $col | [.cards[] | select(.column == $col)] | length] | max' "$BACKLOG_FILE")

# Render rows
for ((i = 0; i < MAX_CARDS; i++)); do
  ROW=""
  for col_id in $COLUMNS; do
    CARD_TITLE=$(jq -r --arg id "$col_id" --argjson idx "$i" '
      [.cards[] | select(.column == $id)] | .[$idx].title // ""
    ' "$BACKLOG_FILE")
    # Truncate to column width
    CARD_TITLE=$(echo "$CARD_TITLE" | cut -c1-$W)
    CELL=$(printf "%-${W}s" "$CARD_TITLE")
    ROW="${ROW}| ${CELL}"
  done
  ROW="${ROW}|"
  echo "$ROW"
done

echo "$SEPARATOR"
```

**Example output:**

```
+--------------------+--------------------+--------------------+--------------------+
| Ideas (2)          | In Progress (1)    | Testing (1)        | Done (3)           |
+--------------------+--------------------+--------------------+--------------------+
| Search             | User Auth          | Payment Flow       | Landing Page       |
| Settings           |                    |                    | User Profile       |
|                    |                    |                    | Design System      |
+--------------------+--------------------+--------------------+--------------------+
```

### 3.7 Rendering: Markdown Table

Generate a Markdown representation for viewing in GitHub:

```bash
#!/usr/bin/env bash
# render-kanban-markdown.sh
# Generates a Markdown table of the Kanban board.

set -euo pipefail

BACKLOG_FILE=".vibeos/backlog.json"
OUTPUT_FILE="docs/kanban.md"

{
  echo "---"
  echo "title: Kanban Board"
  echo "---"
  echo ""
  echo "# Project Kanban Board"
  echo ""
  echo "_Last updated: $(jq -r '.lastUpdated' "$BACKLOG_FILE")_"
  echo ""

  # Build header row
  HEADERS=$(jq -r '.columns | map(.title) | join(" | ")' "$BACKLOG_FILE")
  echo "| $HEADERS |"

  # Build separator row
  COL_COUNT=$(jq '.columns | length' "$BACKLOG_FILE")
  SEP=""
  for ((i = 0; i < COL_COUNT; i++)); do
    SEP="${SEP}|---"
  done
  echo "${SEP}|"

  # Find max cards per column
  MAX=$(jq '[.columns[].id as $col | [.cards[] | select(.column == $col)] | length] | max' "$BACKLOG_FILE")

  # Build data rows
  for ((row = 0; row < MAX; row++)); do
    LINE=""
    for col_id in $(jq -r '.columns[].id' "$BACKLOG_FILE"); do
      CARD=$(jq -r --arg col "$col_id" --argjson idx "$row" '
        [.cards[] | select(.column == $col)] |
        if .[$idx] then
          "**\(.[$idx].title)** `\(.[$idx].priority)`"
        else "" end
      ' "$BACKLOG_FILE")
      LINE="${LINE}| ${CARD} "
    done
    echo "${LINE}|"
  done
} > "$OUTPUT_FILE"

echo "Kanban Markdown written to $OUTPUT_FILE"
```

### 3.8 Real-Time Updates

The Kanban board updates automatically through this flow:

1. An agent calls `move-card.sh` to update `backlog.json`.
2. The PostToolUse hook on Write detects the change to `backlog.json`.
3. The Doc Generator agent regenerates the Markdown table and commits it.
4. The VitePress dev server (if running) hot-reloads the Vue component via its data loader watching `backlog.json`.
5. On PR merge, the static site rebuilds with the latest board state.

---

## 4. Session Logging and Statistics Tracking

### 4.1 What Gets Logged

Every Claude Code session in VibeOS produces a structured log file. Claude Code generates `.jsonl` transcript files with token usage, tool invocations, and conversation turns. The Performance Coach agent parses these transcripts at session end and writes a structured summary.

### 4.2 Session Log Format

Each session produces one file at `.vibeos/sessions/<session-id>.json`:

```json
{
  "sessionId": "session-2026-02-23-001",
  "startedAt": "2026-02-23T10:00:00Z",
  "endedAt": "2026-02-23T11:45:00Z",
  "duration": {
    "totalSeconds": 6300,
    "activeSeconds": 5400,
    "idleSeconds": 900,
    "formatted": "1h 45m"
  },
  "agent": {
    "type": "feature-developer",
    "model": "claude-sonnet-4-20250514"
  },
  "feature": {
    "id": "feat-001",
    "name": "User Authentication",
    "phase": "code"
  },
  "tokens": {
    "inputTokens": 45200,
    "cacheCreationInputTokens": 8500,
    "cacheReadInputTokens": 32100,
    "outputTokens": 12800,
    "totalTokens": 98600,
    "cacheHitRate": 0.71,
    "costUSD": 0.42
  },
  "contextWindow": {
    "peakUsagePercent": 47,
    "averageUsagePercent": 32,
    "exceededThreshold": false
  },
  "files": {
    "modified": [
      {
        "path": "src/auth/login.ts",
        "linesAdded": 120,
        "linesRemoved": 15,
        "operation": "modified"
      },
      {
        "path": "src/auth/register.ts",
        "linesAdded": 85,
        "linesRemoved": 0,
        "operation": "created"
      }
    ],
    "totalModified": 8,
    "totalLinesAdded": 342,
    "totalLinesRemoved": 28
  },
  "tests": {
    "ran": true,
    "framework": "vitest",
    "total": 12,
    "passed": 10,
    "failed": 2,
    "skipped": 0,
    "coveragePercent": 78.5,
    "durationSeconds": 4.2
  },
  "git": {
    "branch": "feat/user-auth",
    "commits": [
      {
        "hash": "abc1234",
        "message": "feat(auth): add login form component",
        "filesChanged": 3
      },
      {
        "hash": "def5678",
        "message": "feat(auth): add registration flow",
        "filesChanged": 4
      },
      {
        "hash": "ghi9012",
        "message": "test(auth): add login form tests",
        "filesChanged": 1
      }
    ],
    "prCreated": false,
    "prNumber": null
  },
  "tools": {
    "totalInvocations": 87,
    "byTool": {
      "Write": 12,
      "Edit": 23,
      "Read": 18,
      "Bash": 15,
      "Glob": 8,
      "Grep": 11
    }
  },
  "errors": [
    {
      "timestamp": "2026-02-23T10:32:00Z",
      "type": "test_failure",
      "message": "Expected redirect to /dashboard, got /login",
      "resolved": true,
      "resolutionSeconds": 180
    }
  ],
  "vibeScore": {
    "total": 82,
    "breakdown": {
      "promptChurn": { "score": -5, "detail": "1 rework sequence detected" },
      "toolLoops": { "score": 0, "detail": "No tool loops" },
      "cacheUtilization": { "score": 5, "detail": "71% cache hit rate (good)" },
      "contextDiscipline": { "score": 0, "detail": "Peak 47%, within budget" },
      "testCoverage": { "score": -8, "detail": "78.5% coverage (target: 85%)" },
      "phaseArtifacts": { "score": 10, "detail": "All phase artifacts present" },
      "errorRecovery": { "score": -5, "detail": "1 error, resolved in 3 min" }
    },
    "suggestions": [
      "Write test stubs before implementation to reduce post-hoc failures",
      "Cache hit rate is good; continue using CLAUDE.md for context priming"
    ]
  },
  "metadata": {
    "claudeCodeVersion": "2.1.0",
    "vibeOSVersion": "0.5.0",
    "os": "darwin",
    "terminal": "warp"
  }
}
```

### 4.3 Metrics Categories

| Category | Metrics | Source | Purpose |
|---|---|---|---|
| **Duration** | Total, active, idle seconds | Session timestamps | Efficiency tracking |
| **Tokens** | Input, cached, output, total | Claude Code transcript `.jsonl` | Cost calculation |
| **Context** | Peak/average usage percent | Token counts vs. model window | Prevent context overflow |
| **Files** | Count modified, lines added/removed | `git diff --stat` | Productivity measurement |
| **Tests** | Total, passed, failed, coverage | Test runner output | Quality tracking |
| **Git** | Branch, commits, PR status | `git log`, `gh pr list` | Workflow tracking |
| **Tools** | Invocations by type | Transcript entries | Tool overuse/loop detection |
| **Errors** | Count, types, resolution time | Transcript error entries | Error pattern detection |
| **Vibe Score** | Composite score 0-100 | Calculated from all above | Overall session quality |

### 4.4 Storage: Individual JSON Files with Index

**Directory structure:**

```
.vibeos/sessions/
  index.json                      # Aggregated summary (rebuilt on each session end)
  session-2026-02-20-001.json     # Individual session log
  session-2026-02-21-001.json
  session-2026-02-21-002.json
  session-2026-02-23-001.json
```

**Index file format (`.vibeos/sessions/index.json`):**

```json
{
  "totalSessions": 42,
  "lastUpdated": "2026-02-23T11:45:00Z",
  "summary": {
    "totalTokens": 2450000,
    "totalCostUSD": 18.72,
    "averageVibeScore": 78.4,
    "totalLinesAdded": 8420,
    "totalLinesRemoved": 1230,
    "totalTestsPassed": 340,
    "totalTestsFailed": 12,
    "averageCacheHitRate": 0.65,
    "totalDurationSeconds": 145800,
    "featuresCompleted": 7
  },
  "sessions": [
    {
      "id": "session-2026-02-23-001",
      "date": "2026-02-23",
      "agent": "feature-developer",
      "feature": "User Authentication",
      "vibeScore": 82,
      "costUSD": 0.42,
      "totalTokens": 98600,
      "cacheHitRate": 0.71,
      "durationSeconds": 6300,
      "commits": 3,
      "linesAdded": 342
    }
  ]
}
```

**Index regeneration script:**

```bash
#!/usr/bin/env bash
# rebuild-session-index.sh
# Regenerates the session index from individual session files.

set -euo pipefail

SESSIONS_DIR=".vibeos/sessions"
INDEX_FILE="${SESSIONS_DIR}/index.json"
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Read all session files (exclude index.json)
SESSION_FILES=$(find "$SESSIONS_DIR" -name "session-*.json" -type f | sort)

if [ -z "$SESSION_FILES" ]; then
  echo '{"totalSessions":0,"lastUpdated":"'"$NOW"'","summary":{},"sessions":[]}' > "$INDEX_FILE"
  echo "No sessions found. Empty index created."
  exit 0
fi

# Build the index using jq
echo "$SESSION_FILES" | xargs jq -s '
  {
    totalSessions: length,
    lastUpdated: "'"$NOW"'",
    summary: {
      totalTokens: (map(.tokens.totalTokens // 0) | add),
      totalCostUSD: ((map(.tokens.costUSD // 0) | add) * 100 | round / 100),
      averageVibeScore: ((map(.vibeScore.total // 0) | add) / length | . * 10 | round / 10),
      totalLinesAdded: (map(.files.totalLinesAdded // 0) | add),
      totalLinesRemoved: (map(.files.totalLinesRemoved // 0) | add),
      totalTestsPassed: (map(.tests.passed // 0) | add),
      totalTestsFailed: (map(.tests.failed // 0) | add),
      averageCacheHitRate: ((map(.tokens.cacheHitRate // 0) | add) / length | . * 100 | round / 100),
      totalDurationSeconds: (map(.duration.totalSeconds // 0) | add),
      featuresCompleted: ([map(.feature.id // empty) | unique | length] | .[0] // 0)
    },
    sessions: map({
      id: .sessionId,
      date: (.startedAt | split("T")[0]),
      agent: .agent.type,
      feature: .feature.name,
      vibeScore: .vibeScore.total,
      costUSD: .tokens.costUSD,
      totalTokens: .tokens.totalTokens,
      cacheHitRate: .tokens.cacheHitRate,
      durationSeconds: .duration.totalSeconds,
      commits: (.git.commits | length),
      linesAdded: .files.totalLinesAdded
    }) | sort_by(.date) | reverse
  }
' > "$INDEX_FILE"

TOTAL=$(jq '.totalSessions' "$INDEX_FILE")
echo "Session index rebuilt: $TOTAL sessions."
```

### 4.5 Why Individual Files Over Alternatives

| Approach | Pros | Cons | VibeOS Fit |
|---|---|---|---|
| **Individual JSON files + index** | Git-friendly, human-readable, atomic writes, easy debugging | Requires index rebuild, multiple files | **Best** |
| **SQLite database** | Fast queries, aggregations, single file | Binary in git (no diffs), requires sqlite3 | Poor |
| **Append-only JSONL** | Fast writes, streamable | No random access, merge conflicts, growing file | Medium |
| **Single JSON array** | Simple, single file | Merge conflicts, entire file rewrite on each session | Poor |

---

## 5. Token Usage Tracking and Cost Calculation

### 5.1 Token Types in Claude Code Transcripts

Claude Code stores conversation transcripts as JSONL files. Each assistant message contains a `usage` object:

```json
{
  "type": "assistant",
  "message": {
    "id": "msg_01ABC...",
    "type": "message",
    "role": "assistant",
    "content": [],
    "model": "claude-sonnet-4-20250514",
    "usage": {
      "input_tokens": 4523,
      "cache_creation_input_tokens": 1200,
      "cache_read_input_tokens": 3100,
      "output_tokens": 856
    },
    "stop_reason": "end_turn"
  },
  "timestamp": "2026-02-23T10:15:32Z"
}
```

**Token field definitions:**

| Field | Description | Cost Relative to Base Input Price |
|---|---|---|
| `input_tokens` | Fresh (non-cached) tokens sent to the model | 1.0x (base input price) |
| `cache_creation_input_tokens` | Tokens written to the prompt cache | 1.25x input price |
| `cache_read_input_tokens` | Tokens read from cache (cache hit) | 0.1x input price |
| `output_tokens` | Tokens generated by the model | Output price (typically 5x input) |

**Total input tokens**: `input_tokens + cache_creation_input_tokens + cache_read_input_tokens`

**Cache hit rate**: `cache_read_input_tokens / total_input_tokens`

### 5.2 Pricing by Model

Pricing as of early 2026 (verify at https://www.anthropic.com/pricing):

| Model | Input (per 1M) | Cache Write (per 1M) | Cache Read (per 1M) | Output (per 1M) |
|---|---|---|---|---|
| **Haiku 3.5** | $0.80 | $1.00 | $0.08 | $4.00 |
| **Sonnet 4** | $3.00 | $3.75 | $0.30 | $15.00 |
| **Opus 4** | $15.00 | $18.75 | $1.50 | $75.00 |

**VibeOS model usage by agent:**

| Agent | Model | Typical Tokens Per Session | Typical Cost Per Session |
|---|---|---|---|
| Session Startup | Haiku | ~5,000 total | ~$0.01 |
| Workflow Orchestrator | Sonnet | ~15,000 total | ~$0.08 |
| Stack Scout | Sonnet | ~80,000 total | ~$0.45 |
| UI Designer | Sonnet | ~40,000 total | ~$0.22 |
| Feature Developer | Sonnet | ~100,000 total | ~$0.55 |
| Test Writer | Sonnet | ~60,000 total | ~$0.33 |
| Doc Generator | Sonnet | ~30,000 total | ~$0.17 |
| Performance Coach | Sonnet | ~20,000 total | ~$0.11 |
| Quality Check | Haiku | ~10,000 total | ~$0.02 |

### 5.3 Token Extraction Script (jq)

```bash
#!/usr/bin/env bash
# extract-tokens.sh
# Extracts token usage from a Claude Code transcript JSONL file.

set -euo pipefail

TRANSCRIPT_FILE="${1:?Usage: extract-tokens.sh <transcript.jsonl>}"

if [ ! -f "$TRANSCRIPT_FILE" ]; then
  echo "ERROR: File not found: $TRANSCRIPT_FILE"
  exit 1
fi

jq -s '
  map(select(.type == "assistant" and .message.usage != null)) |
  {
    message_count: length,
    models_used: (map(.message.model // "unknown") | unique),
    totals: {
      input_tokens: (map(.message.usage.input_tokens // 0) | add),
      cache_creation_tokens: (map(.message.usage.cache_creation_input_tokens // 0) | add),
      cache_read_tokens: (map(.message.usage.cache_read_input_tokens // 0) | add),
      output_tokens: (map(.message.usage.output_tokens // 0) | add)
    },
    by_model: (
      group_by(.message.model) | map({
        model: .[0].message.model,
        messages: length,
        input_tokens: (map(.message.usage.input_tokens // 0) | add),
        cache_creation_tokens: (map(.message.usage.cache_creation_input_tokens // 0) | add),
        cache_read_tokens: (map(.message.usage.cache_read_input_tokens // 0) | add),
        output_tokens: (map(.message.usage.output_tokens // 0) | add)
      })
    )
  } |
  .totals.total_input = (.totals.input_tokens + .totals.cache_creation_tokens + .totals.cache_read_tokens) |
  .totals.total_all = (.totals.total_input + .totals.output_tokens) |
  .totals.cache_hit_rate = (
    if .totals.total_input > 0
    then (.totals.cache_read_tokens / .totals.total_input * 100 | round / 100)
    else 0 end
  )
' "$TRANSCRIPT_FILE"
```

### 5.4 Token Extraction Script (Node.js)

```javascript
// extract-tokens.mjs
// Extracts token usage from a Claude Code transcript JSONL file.

import { createReadStream } from 'fs';
import { createInterface } from 'readline';

const PRICING = {
  'claude-3-5-haiku-20241022': {
    input: 0.80, cacheWrite: 1.00, cacheRead: 0.08, output: 4.00
  },
  'claude-sonnet-4-20250514': {
    input: 3.00, cacheWrite: 3.75, cacheRead: 0.30, output: 15.00
  },
  'claude-opus-4-20250514': {
    input: 15.00, cacheWrite: 18.75, cacheRead: 1.50, output: 75.00
  }
};

function findPricing(model) {
  if (PRICING[model]) return PRICING[model];
  // Prefix match: "claude-sonnet-4-*" -> sonnet pricing
  for (const [key, pricing] of Object.entries(PRICING)) {
    const prefix = key.replace(/-\d{8}$/, '');
    if (model && model.startsWith(prefix)) return pricing;
  }
  // Default to Sonnet
  console.warn(`Unknown model: ${model}, defaulting to Sonnet pricing`);
  return PRICING['claude-sonnet-4-20250514'];
}

function calculateCost(usage, model) {
  const pricing = findPricing(model);
  const perM = 1_000_000;
  return (
    (usage.inputTokens * pricing.input / perM) +
    (usage.cacheCreationTokens * pricing.cacheWrite / perM) +
    (usage.cacheReadTokens * pricing.cacheRead / perM) +
    (usage.outputTokens * pricing.output / perM)
  );
}

export async function extractTokenUsage(transcriptPath) {
  const rl = createInterface({
    input: createReadStream(transcriptPath),
    crlfDelay: Infinity
  });

  const totals = {
    inputTokens: 0,
    cacheCreationTokens: 0,
    cacheReadTokens: 0,
    outputTokens: 0,
    messageCount: 0,
    byModel: {}
  };

  for await (const line of rl) {
    if (!line.trim()) continue;
    try {
      const entry = JSON.parse(line);
      if (entry.type !== 'assistant' || !entry.message?.usage) continue;

      const usage = entry.message.usage;
      const model = entry.message.model || 'unknown';

      totals.inputTokens += usage.input_tokens || 0;
      totals.cacheCreationTokens += usage.cache_creation_input_tokens || 0;
      totals.cacheReadTokens += usage.cache_read_input_tokens || 0;
      totals.outputTokens += usage.output_tokens || 0;
      totals.messageCount++;

      if (!totals.byModel[model]) {
        totals.byModel[model] = {
          inputTokens: 0, cacheCreationTokens: 0,
          cacheReadTokens: 0, outputTokens: 0, messages: 0
        };
      }
      const m = totals.byModel[model];
      m.inputTokens += usage.input_tokens || 0;
      m.cacheCreationTokens += usage.cache_creation_input_tokens || 0;
      m.cacheReadTokens += usage.cache_read_input_tokens || 0;
      m.outputTokens += usage.output_tokens || 0;
      m.messages++;
    } catch (e) {
      // Skip malformed lines
    }
  }

  // Derived metrics
  const totalInput = totals.inputTokens + totals.cacheCreationTokens + totals.cacheReadTokens;
  totals.totalTokens = totalInput + totals.outputTokens;
  totals.cacheHitRate = totalInput > 0
    ? Math.round((totals.cacheReadTokens / totalInput) * 100) / 100
    : 0;

  // Calculate cost per model and total
  let totalCost = 0;
  for (const [model, usage] of Object.entries(totals.byModel)) {
    const cost = calculateCost(usage, model);
    totals.byModel[model].costUSD = Math.round(cost * 10000) / 10000;
    totalCost += cost;
  }
  totals.costUSD = Math.round(totalCost * 10000) / 10000;

  return totals;
}
```

### 5.5 Cost Calculation Formula

```
session_cost = SUM over each model:
  (input_tokens * model_input_price / 1,000,000)
  + (cache_creation_tokens * model_cache_write_price / 1,000,000)
  + (cache_read_tokens * model_cache_read_price / 1,000,000)
  + (output_tokens * model_output_price / 1,000,000)
```

**Example calculation for a Sonnet session:**

```
Input tokens:          4,523 * $3.00 / 1M = $0.01357
Cache creation tokens: 1,200 * $3.75 / 1M = $0.00450
Cache read tokens:     3,100 * $0.30 / 1M = $0.00093
Output tokens:           856 * $15.0 / 1M = $0.01284
                                    Total = $0.03184
```

### 5.6 Dashboard Metrics: Cost Tracking

The Doc Generator should display these cost-related metrics:

| Metric | Calculation | Display |
|---|---|---|
| **Cost per session** | Sum of per-model costs for the session | Dollar amount |
| **Cost per feature** | Sum of all session costs for a feature | Dollar amount |
| **Total project cost** | Sum of all session costs | Dollar amount |
| **Cost trend** | Cost per session over time | Line chart |
| **Cost by model** | Breakdown of cost by Haiku/Sonnet/Opus | Stacked bar or pie chart |
| **Cost efficiency** | Lines of code per dollar spent | Ratio |
| **Cache savings** | Cost difference if all cached tokens were fresh | Dollar amount saved |

### 5.7 Cache Optimization Insights

| Cache Hit Rate | Assessment | Action |
|---|---|---|
| < 30% | Poor | Review CLAUDE.md structure; move static context to the top |
| 30-60% | Average | Consolidate frequently-used context into CLAUDE.md |
| 60-80% | Good | System is well-optimized |
| > 80% | Excellent | Maximum cost efficiency achieved |

The Performance Coach should:
- Flag sessions with cache hit rate below 30% as a Vibe Score deduction (-15).
- Propose CLAUDE.md mutations to improve caching (e.g., move stable instructions above volatile content).
- Track cache hit rate trends to verify whether mutations improve efficiency.

---

## 6. Statistics Dashboard Design

### 6.1 Dashboard Panels

The VibeOS documentation site includes a statistics dashboard with the following panels:

#### Panel 1: Summary Cards

```
+-----------------+-----------------+-----------------+-----------------+
|  Sessions: 42   | Total Cost:     |  Avg Vibe Score |  Lines Written  |
|                 |  $18.72         |  78.4 / 100     |  8,420          |
|  +3 this week   |  +$2.10 today   |  +2.1 trend     |  +342 today     |
+-----------------+-----------------+-----------------+-----------------+
```

Metrics:
- Total sessions completed
- Total estimated cost (USD)
- Average Vibe Score across all sessions
- Total lines of code added
- Each card shows a trend indicator vs. the previous period

#### Panel 2: Vibe Score Trend (Line Chart)

```
Metrics:    Vibe Score per session
X-axis:     Session date/time
Y-axis:     Score (0-100)
Reference:  Target line at 80, Warning line at 60
Color:      Green above 80, yellow 60-80, red below 60
```

#### Panel 3: Token Usage by Type (Stacked Area Chart)

```
Metrics:    input_tokens, cache_read_tokens, cache_creation_tokens, output_tokens
X-axis:     Session date/time
Y-axis:     Token count
Stacking:   Each type stacked to show total
Color:      Input=blue, Cached=green, Creation=yellow, Output=orange
```

#### Panel 4: Cost per Feature (Horizontal Bar Chart)

```
Metrics:    Total cost for each feature (sum of session costs)
X-axis:     Cost (USD)
Y-axis:     Feature name
Sort:       Descending by cost
Color:      Gradient from green (cheap) to red (expensive)
```

#### Panel 5: Feature Velocity (Burndown / Throughput)

```
Metrics:    Features completed per week, features remaining
X-axis:     Week number
Y-axis:     Feature count
Chart type: Dual-axis: bar (completed) + line (remaining)
Insight:    Is the team shipping faster as the project matures?
```

#### Panel 6: Cache Hit Rate Trend (Line Chart with Zone Fill)

```
Metrics:    cache_read_tokens / total_input_tokens per session
X-axis:     Session date/time
Y-axis:     Percentage (0-100%)
Zones:      Red (<30%), Yellow (30-60%), Green (>60%)
Insight:    Is CLAUDE.md optimization working?
```

#### Panel 7: Session Activity Heatmap (GitHub-Style)

```
Metrics:    Number of sessions per day
Display:    52-week calendar heatmap (like GitHub contributions)
Color:      Intensity based on session count
Insight:    When are the most productive days?
```

#### Panel 8: Test Coverage Over Time (Line Chart)

```
Metrics:    Test coverage percentage per session (where tests ran)
X-axis:     Session date/time
Y-axis:     Coverage (0-100%)
Reference:  Target line at 85%
Insight:    Is test coverage improving or degrading?
```

### 6.2 Charting Library Selection

| Library | Size (min) | Type | Vue Wrapper | VibeOS Fit |
|---|---|---|---|---|
| **Chart.js** | ~70 KB | Canvas | vue-chartjs | **Best** |
| **Frappe Charts** | ~18 KB | SVG | None (direct) | Good |
| **uPlot** | ~35 KB | Canvas | None | Good (fastest) |
| **ECharts** | ~40 KB-1 MB | Canvas/SVG | vue-echarts | Overkill |
| **D3.js** | ~90 KB | SVG | None | Overkill |
| **Chart.css** | ~5 KB | Pure CSS | N/A | Too limited |

**Recommendation: Chart.js with vue-chartjs.**

- Mature, well-documented, widely used.
- Official Vue wrapper (`vue-chartjs`) integrates naturally with VitePress.
- Supports all chart types needed (line, bar, doughnut, area).
- ~70 KB is acceptable since only the dashboard page loads it (VitePress code-splits per page).
- Tree-shakeable: only import the chart types you use.

### 6.3 Dashboard Implementation

**Data loader (`docs/dashboard.data.js`):**

```javascript
// VitePress data loader -- runs at build time, supports HMR via watch
import { readFileSync, existsSync } from 'fs';
import { resolve } from 'path';

export default {
  watch: ['../../.vibeos/sessions/*.json'],
  load() {
    const indexPath = resolve(process.cwd(), '..', '.vibeos/sessions/index.json');

    if (!existsSync(indexPath)) {
      return {
        sessions: [],
        summary: {
          totalSessions: 0,
          totalCostUSD: 0,
          averageVibeScore: 0,
          totalLinesAdded: 0
        }
      };
    }

    return JSON.parse(readFileSync(indexPath, 'utf-8'));
  }
};
```

**Dashboard page (`docs/dashboard.md`):**

```markdown
---
layout: page
title: Project Dashboard
---

<script setup>
import { data } from './dashboard.data.js'
import Dashboard from './.vitepress/theme/components/Dashboard.vue'
</script>

# Project Dashboard

<Dashboard :data="data" />
```

**Dashboard component (`docs/.vitepress/theme/components/Dashboard.vue`):**

```vue
<script setup>
import { computed } from 'vue'
import { Line, Bar, Doughnut } from 'vue-chartjs'
import {
  Chart, CategoryScale, LinearScale, PointElement,
  LineElement, BarElement, ArcElement, Filler,
  Title, Tooltip, Legend
} from 'chart.js'

Chart.register(
  CategoryScale, LinearScale, PointElement,
  LineElement, BarElement, ArcElement, Filler,
  Title, Tooltip, Legend
)

const props = defineProps({
  data: { type: Object, required: true }
})

const vibeScoreData = computed(() => ({
  labels: props.data.sessions.map(s => s.date),
  datasets: [{
    label: 'Vibe Score',
    data: props.data.sessions.map(s => s.vibeScore),
    borderColor: '#7c3aed',
    backgroundColor: 'rgba(124, 58, 237, 0.1)',
    fill: true,
    tension: 0.3
  }]
}))

const costData = computed(() => ({
  labels: props.data.sessions.map(s => s.date),
  datasets: [{
    label: 'Cost (USD)',
    data: props.data.sessions.map(s => s.costUSD),
    backgroundColor: '#3b82f6'
  }]
}))

const cacheData = computed(() => ({
  labels: props.data.sessions.map(s => s.date),
  datasets: [{
    label: 'Cache Hit Rate',
    data: props.data.sessions.map(s => Math.round(s.cacheHitRate * 100)),
    borderColor: '#10b981',
    backgroundColor: 'rgba(16, 185, 129, 0.1)',
    fill: true,
    tension: 0.3
  }]
}))

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: { legend: { display: false } }
}
</script>

<template>
  <div class="dashboard">
    <!-- Summary Cards -->
    <div class="summary-cards">
      <div class="card">
        <div class="card-label">Sessions</div>
        <div class="card-value">{{ data.summary.totalSessions }}</div>
      </div>
      <div class="card">
        <div class="card-label">Total Cost</div>
        <div class="card-value">${{ data.summary.totalCostUSD?.toFixed(2) }}</div>
      </div>
      <div class="card">
        <div class="card-label">Avg Vibe Score</div>
        <div class="card-value">{{ data.summary.averageVibeScore?.toFixed(1) }}</div>
      </div>
      <div class="card">
        <div class="card-label">Lines Added</div>
        <div class="card-value">{{ data.summary.totalLinesAdded?.toLocaleString() }}</div>
      </div>
    </div>

    <!-- Charts -->
    <div class="chart-grid">
      <div class="chart-panel">
        <h3>Vibe Score Trend</h3>
        <div class="chart-container">
          <Line :data="vibeScoreData" :options="chartOptions" />
        </div>
      </div>
      <div class="chart-panel">
        <h3>Cost Per Session</h3>
        <div class="chart-container">
          <Bar :data="costData" :options="chartOptions" />
        </div>
      </div>
      <div class="chart-panel">
        <h3>Cache Hit Rate</h3>
        <div class="chart-container">
          <Line :data="cacheData" :options="chartOptions" />
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.dashboard { padding: 1rem 0; }

.summary-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.card {
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  padding: 1.25rem;
  text-align: center;
}

.card-label {
  font-size: 0.75rem;
  color: var(--vp-c-text-2);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.card-value {
  font-size: 1.75rem;
  font-weight: 700;
  margin-top: 0.25rem;
}

.chart-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 1.5rem;
}

.chart-panel {
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  padding: 1rem;
}

.chart-panel h3 {
  margin: 0 0 0.75rem 0;
  font-size: 0.875rem;
  font-weight: 600;
}

.chart-container {
  height: 200px;
  position: relative;
}
</style>
```

### 6.4 Terminal Dashboard Alternative

For the `/status` command, display a compact ASCII dashboard:

```javascript
// render-dashboard-terminal.mjs
// Renders a compact terminal dashboard from session data.

import { readFileSync } from 'fs';

function renderDashboard() {
  const index = JSON.parse(readFileSync('.vibeos/sessions/index.json', 'utf-8'));
  const s = index.summary;

  const lines = [
    '=========================================================',
    '                    VibeOS Dashboard                      ',
    '=========================================================',
    '',
    `  Sessions: ${s.totalSessions}     Cost: $${s.totalCostUSD?.toFixed(2)}     Score: ${s.averageVibeScore?.toFixed(1)}/100`,
    `  Lines: +${s.totalLinesAdded}     Tests: ${s.totalTestsPassed} passed, ${s.totalTestsFailed} failed`,
    `  Cache: ${(s.averageCacheHitRate * 100).toFixed(0)}% hit rate     Features: ${s.featuresCompleted} done`,
    '',
  ];

  // Vibe Score sparkline (last 10 sessions)
  const recent = index.sessions.slice(0, 10).reverse();
  if (recent.length > 0) {
    lines.push('  Vibe Score (last 10 sessions):');
    const scores = recent.map(s => s.vibeScore);
    const max = Math.max(...scores);
    const min = Math.min(...scores);
    const range = max - min || 1;
    const height = 5;

    for (let row = height; row >= 0; row--) {
      const threshold = min + (range * row / height);
      let line = row === height ? `  ${max.toString().padStart(3)} |` : `      |`;
      if (row === 0) line = `  ${min.toString().padStart(3)} |`;
      for (const score of scores) {
        line += score >= threshold ? ' ##' : '   ';
      }
      lines.push(line);
    }
    lines.push('      +' + '---'.repeat(scores.length));
  }

  lines.push('');
  lines.push('=========================================================');

  return lines.join('\n');
}

console.log(renderDashboard());
```

---

## 7. Two Documentation Sections: System Docs and Product Docs

### 7.1 The Dual-Section Architecture

The VibeOS docs site serves two distinct audiences and purposes:

1. **System Docs**: How to use VibeOS itself (commands, agents, configuration, troubleshooting).
2. **Product Docs**: Auto-generated documentation for the user's SaaS project (API reference, component catalog, architecture decisions).

These sections occupy separate navigation areas in the docs site but share the same build infrastructure.

### 7.2 System Documentation

System docs are maintained by the VibeOS plugin and rarely change after initial scaffolding. They document:

| Page | Content | Auto-Generated? |
|---|---|---|
| Installation | How to install and configure VibeOS | No (static) |
| Commands Reference | All 9 slash commands with examples | No (static) |
| Agent Reference | The 9 agents, their roles, models, and responsibilities | No (static) |
| Workflows | Tier 1 and Tier 2 workflow explanations | No (static) |
| Configuration | `.vibeos/config.json` options | No (static) |
| Troubleshooting | Common errors and solutions | Partially (updated by Performance Coach) |

**Directory structure:**

```
docs/
  guide/
    index.md              # Introduction to VibeOS
    installation.md       # Installation guide
    commands.md           # Slash command reference
    agents.md             # Agent reference
    workflows.md          # Tier 1 + Tier 2 workflows
    configuration.md      # Configuration options
    troubleshooting.md    # Common issues
```

### 7.3 Product Documentation

Product docs are auto-generated by the Doc Generator agent from the user's project source code. They document the SaaS application being built:

| Page | Content | Generation Source |
|---|---|---|
| API Reference | REST/GraphQL endpoints, request/response schemas | Route files, OpenAPI spec, or TypeScript types |
| Component Catalog | UI components with props, usage examples | Component files (React/Vue/Svelte) |
| Architecture Decisions | TDRs (Technology Decision Records) | `.vibeos/` TDR files from Tier 1 |
| Database Schema | Entity relationships, table definitions | Prisma schema, Drizzle schema, or migration files |
| Environment Variables | Required and optional env vars | `.env.example` file |

**Directory structure:**

```
docs/
  product/
    index.md              # Product overview (from VISION.md)
    api/
      index.md            # API overview
      auth.md             # Auth endpoints
      users.md            # User endpoints
    components/
      index.md            # Component overview
      button.md           # Button component
      form.md             # Form component
    architecture/
      tdr-001-stack.md    # Stack selection TDR
      tdr-002-auth.md     # Auth approach TDR
    schema.md             # Database schema
    env-vars.md           # Environment variables
```

### 7.4 Auto-Generating API Documentation

The Doc Generator agent can generate API docs from several sources:

**From TypeScript route files (Next.js App Router example):**

```bash
#!/usr/bin/env bash
# generate-api-docs.sh
# Generates API documentation from Next.js route files.

set -euo pipefail

ROUTES_DIR="src/app/api"
OUTPUT_DIR="docs/product/api"

mkdir -p "$OUTPUT_DIR"

# Find all route.ts files
find "$ROUTES_DIR" -name "route.ts" -o -name "route.js" | while read -r route_file; do
  # Extract the API path from the file path
  # src/app/api/users/[id]/route.ts -> /api/users/[id]
  API_PATH=$(echo "$route_file" | sed "s|$ROUTES_DIR|/api|" | sed 's|/route\.\(ts\|js\)$||')

  # Extract HTTP methods (GET, POST, PUT, DELETE, PATCH)
  METHODS=$(grep -oE 'export (async )?function (GET|POST|PUT|DELETE|PATCH)' "$route_file" \
    | grep -oE '(GET|POST|PUT|DELETE|PATCH)' || true)

  if [ -z "$METHODS" ]; then
    continue
  fi

  # Generate a slug for the filename
  SLUG=$(echo "$API_PATH" | sed 's|^/api/||' | tr '/' '-' | tr '[]' '_')
  OUTPUT_FILE="${OUTPUT_DIR}/${SLUG}.md"

  {
    echo "---"
    echo "title: ${API_PATH}"
    echo "---"
    echo ""
    echo "# \`${API_PATH}\`"
    echo ""
    echo "## Methods"
    echo ""
    for method in $METHODS; do
      echo "### \`${method}\`"
      echo ""
      echo "_Auto-generated from \`${route_file}\`_"
      echo ""
    done
  } > "$OUTPUT_FILE"

  echo "Generated: $OUTPUT_FILE"
done
```

**From an OpenAPI/Swagger specification:**

```bash
# If the project has an OpenAPI spec, use it directly
if [ -f "openapi.json" ] || [ -f "openapi.yaml" ]; then
  # Use redocly to generate static HTML, then convert to Markdown
  npx @redocly/cli build-docs openapi.json --output docs/product/api/openapi.html

  # Or use swagger-markdown for Markdown output
  npx swagger-markdown -i openapi.json -o docs/product/api/index.md
fi
```

### 7.5 Auto-Generating Component Documentation

For React/Vue/Svelte components, the Doc Generator extracts props, types, and default values:

```bash
#!/usr/bin/env bash
# generate-component-docs.sh
# Generates component documentation from source files.

set -euo pipefail

COMPONENTS_DIR="src/components"
OUTPUT_DIR="docs/product/components"

mkdir -p "$OUTPUT_DIR"

# Find component files
find "$COMPONENTS_DIR" -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" | while read -r comp_file; do
  FILENAME=$(basename "$comp_file" | sed 's/\.\(tsx\|vue\|svelte\)$//')
  SLUG=$(echo "$FILENAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
  OUTPUT_FILE="${OUTPUT_DIR}/${SLUG}.md"

  {
    echo "---"
    echo "title: ${FILENAME}"
    echo "---"
    echo ""
    echo "# ${FILENAME}"
    echo ""
    echo "**Source:** \`${comp_file}\`"
    echo ""
    echo "## Props"
    echo ""
    echo "_Auto-generated from source. See source file for full type definitions._"
    echo ""
    echo "\`\`\`typescript"
    # Extract interface/type definitions (basic extraction)
    grep -A 20 'interface.*Props' "$comp_file" 2>/dev/null || \
    grep -A 20 'type.*Props' "$comp_file" 2>/dev/null || \
    echo "// No Props interface found"
    echo "\`\`\`"
    echo ""
    echo "## Usage"
    echo ""
    echo "\`\`\`tsx"
    echo "import { ${FILENAME} } from '@/components/${FILENAME}'"
    echo ""
    echo "<${FILENAME} />"
    echo "\`\`\`"
  } > "$OUTPUT_FILE"

  echo "Generated: $OUTPUT_FILE"
done
```

### 7.6 Navigation Configuration

The VitePress sidebar should clearly separate system and product docs:

```javascript
// docs/.vitepress/config.js (sidebar section)
sidebar: {
  // System docs navigation
  '/guide/': [
    {
      text: 'VibeOS Guide',
      items: [
        { text: 'Introduction', link: '/guide/' },
        { text: 'Installation', link: '/guide/installation' },
        { text: 'Commands', link: '/guide/commands' },
        { text: 'Agents', link: '/guide/agents' },
        { text: 'Workflows', link: '/guide/workflows' },
        { text: 'Configuration', link: '/guide/configuration' },
        { text: 'Troubleshooting', link: '/guide/troubleshooting' }
      ]
    }
  ],
  // Product docs navigation (auto-generated sections)
  '/product/': [
    {
      text: 'API Reference',
      collapsed: false,
      items: [] // Auto-populated by build script
    },
    {
      text: 'Components',
      collapsed: false,
      items: [] // Auto-populated by build script
    },
    {
      text: 'Architecture',
      collapsed: false,
      items: [] // Auto-populated by build script
    }
  ],
  // Dashboard navigation
  '/dashboard/': [
    {
      text: 'Dashboard',
      items: [
        { text: 'Statistics', link: '/dashboard/' },
        { text: 'Kanban Board', link: '/dashboard/kanban' }
      ]
    }
  ]
}
```

### 7.7 Auto-Populating the Sidebar

A build-time script reads the generated product docs and populates the sidebar configuration:

```javascript
// docs/.vitepress/sidebar-generator.js
// Auto-generates sidebar items from the product docs directory.

import { readdirSync, statSync } from 'fs';
import { join, basename, relative } from 'path';

export function generateProductSidebar(docsDir) {
  const productDir = join(docsDir, 'product');
  const sections = [];

  for (const dir of readdirSync(productDir)) {
    const dirPath = join(productDir, dir);
    if (!statSync(dirPath).isDirectory()) continue;

    const items = readdirSync(dirPath)
      .filter(f => f.endsWith('.md') && f !== 'index.md')
      .map(f => ({
        text: basename(f, '.md').replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase()),
        link: `/product/${dir}/${basename(f, '.md')}`
      }));

    if (items.length > 0 || readdirSync(dirPath).includes('index.md')) {
      sections.push({
        text: dir.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase()),
        collapsed: false,
        items: [
          { text: 'Overview', link: `/product/${dir}/` },
          ...items
        ]
      });
    }
  }

  return sections;
}
```

---

## 8. Auto-Update Mechanism

### 8.1 Trigger: PostToolUse Hook on PR Merge

The docs site rebuilds automatically when a PR is merged into main. In VibeOS, this is implemented through the PostToolUse hook system:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": {
          "tool": "Bash",
          "command_pattern": "gh pr merge|git merge"
        },
        "script": "scripts/rebuild-docs.sh"
      }
    ]
  }
}
```

### 8.2 Rebuild Process

The rebuild follows a deterministic sequence:

```
PR merged into main
    |
    v
PostToolUse hook fires
    |
    v
rebuild-docs.sh runs
    |
    +-- 1. Regenerate product docs (API, components, schema)
    +-- 2. Regenerate Kanban Markdown table
    +-- 3. Rebuild session index (if new sessions exist)
    +-- 4. Generate release notes (if new tag exists)
    +-- 5. Run VitePress build
    +-- 6. Commit updated docs to the docs branch (or main)
    +-- 7. Restart docs server (if running)
```

### 8.3 Rebuild Script

```bash
#!/usr/bin/env bash
# rebuild-docs.sh
# Hook: PostToolUse (on PR merge / git merge)
# Regenerates the documentation site after a merge.

set -euo pipefail

PROJECT_ROOT=$(git rev-parse --show-toplevel)
DOCS_DIR="${PROJECT_ROOT}/docs"

echo "[docs] Starting documentation rebuild..."

# Step 1: Regenerate product docs
if [ -f "${PROJECT_ROOT}/scripts/generate-api-docs.sh" ]; then
  echo "[docs] Regenerating API documentation..."
  bash "${PROJECT_ROOT}/scripts/generate-api-docs.sh"
fi

if [ -f "${PROJECT_ROOT}/scripts/generate-component-docs.sh" ]; then
  echo "[docs] Regenerating component documentation..."
  bash "${PROJECT_ROOT}/scripts/generate-component-docs.sh"
fi

# Step 2: Regenerate Kanban Markdown
if [ -f "${PROJECT_ROOT}/scripts/render-kanban-markdown.sh" ]; then
  echo "[docs] Regenerating Kanban board..."
  bash "${PROJECT_ROOT}/scripts/render-kanban-markdown.sh"
fi

# Step 3: Rebuild session index
if [ -f "${PROJECT_ROOT}/scripts/rebuild-session-index.sh" ]; then
  echo "[docs] Rebuilding session index..."
  bash "${PROJECT_ROOT}/scripts/rebuild-session-index.sh"
fi

# Step 4: Check for new tags and generate release notes
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -n "$LATEST_TAG" ]; then
  PREVIOUS_TAG=$(git describe --tags --abbrev=0 "${LATEST_TAG}^" 2>/dev/null || echo "")
  if [ -n "$PREVIOUS_TAG" ]; then
    NOTES_FILE="${DOCS_DIR}/releases/${LATEST_TAG}.md"
    if [ ! -f "$NOTES_FILE" ]; then
      echo "[docs] Generating release notes for $LATEST_TAG..."
      mkdir -p "${DOCS_DIR}/releases"
      bash "${PROJECT_ROOT}/scripts/generate-release-notes-from-prs.sh" "$PREVIOUS_TAG" > "$NOTES_FILE"
    fi
  fi
fi

# Step 5: Build the VitePress site
echo "[docs] Building VitePress site..."
cd "$DOCS_DIR"
npx vitepress build

echo "[docs] Build complete. Output in ${DOCS_DIR}/.vitepress/dist/"

# Step 6: Commit updated docs (if there are changes)
cd "$PROJECT_ROOT"
if ! git diff --quiet -- docs/ .vibeos/; then
  git add docs/ .vibeos/sessions/index.json
  git commit -m "docs: auto-regenerate documentation after merge

Co-Authored-By: VibeOS Doc Generator <noreply@vibeos.dev>"
  echo "[docs] Documentation changes committed."
else
  echo "[docs] No documentation changes to commit."
fi

# Step 7: Restart docs server if running
DOCS_PID=$(lsof -ti:3002 2>/dev/null || true)
if [ -n "$DOCS_PID" ]; then
  echo "[docs] Restarting docs server on port 3002..."
  kill "$DOCS_PID" 2>/dev/null || true
  sleep 1
fi

echo "[docs] Documentation rebuild complete."
```

### 8.4 Port Allocation

VibeOS allocates three ports to avoid conflicts:

| Server | Port | Purpose |
|---|---|---|
| Dev server | 3000 | Application development (Next.js, Vite, etc.) |
| Test server | 3001 | Test runner (Vitest UI, Playwright report) |
| Docs server | 3002 | VitePress documentation site |

**Starting the docs server in the background:**

```bash
# Start VitePress dev server on port 3002
cd docs && npx vitepress dev --port 3002 &
DOCS_PID=$!
echo "$DOCS_PID" > .vibeos/docs-server.pid
echo "Docs server started on http://localhost:3002 (PID: $DOCS_PID)"
```

**Stopping the docs server:**

```bash
if [ -f .vibeos/docs-server.pid ]; then
  kill "$(cat .vibeos/docs-server.pid)" 2>/dev/null || true
  rm .vibeos/docs-server.pid
  echo "Docs server stopped."
fi
```

### 8.5 Build Performance Considerations

The auto-rebuild must complete quickly to avoid blocking the development workflow:

| Optimization | Implementation | Impact |
|---|---|---|
| **Incremental builds** | VitePress only rebuilds changed pages | Rebuild in 1-3s for single-page changes |
| **Selective regeneration** | Only regenerate product docs that changed (check git diff) | Skip unnecessary script runs |
| **Background builds** | Run `vitepress build` in a background process | Non-blocking for the developer |
| **Conditional commits** | Only commit if files actually changed (git diff check) | Avoid empty "docs: auto-regenerate" commits |
| **Cache VitePress output** | VitePress caches Vite build artifacts in `node_modules/.vite` | Faster subsequent builds |

**Selective regeneration optimization:**

```bash
# Only regenerate API docs if route files changed
ROUTE_CHANGES=$(git diff --name-only HEAD~1 -- 'src/app/api/**' 2>/dev/null || true)
if [ -n "$ROUTE_CHANGES" ]; then
  echo "[docs] API routes changed, regenerating API docs..."
  bash scripts/generate-api-docs.sh
fi

# Only regenerate component docs if component files changed
COMP_CHANGES=$(git diff --name-only HEAD~1 -- 'src/components/**' 2>/dev/null || true)
if [ -n "$COMP_CHANGES" ]; then
  echo "[docs] Components changed, regenerating component docs..."
  bash scripts/generate-component-docs.sh
fi
```

---

## 9. Recommendations for VibeOS

### 9.1 Summary of Choices

| Component | Recommendation | Rationale |
|---|---|---|
| **Docs SSG** | VitePress | Fastest rebuild, Vue-native dashboard components, simplest AI-generation |
| **Release Notes** | release-please | Fully automated, works with conventional commits, creates Release PRs |
| **Kanban Storage** | Custom JSON (`backlog.json`) | Single file, atomic ops via `jq`, three render targets |
| **Kanban Rendering** | Vue component (web) + ASCII (terminal) + Markdown (GitHub) | Three contexts, one data source |
| **Session Logs** | Individual JSON files + `index.json` | Git-friendly, human-readable, aggregatable |
| **Token Extraction** | Custom JSONL parser (`jq` + Node.js) | Direct Claude Code transcript access |
| **Cost Calculation** | Per-model pricing lookup table | Accurate, updatable when pricing changes |
| **Dashboard Charts** | Chart.js via `vue-chartjs` | Mature, flexible, Vue-native integration |
| **Terminal Dashboard** | `asciichart` + formatted strings | Lightweight, no TUI framework dependency |
| **System Docs** | Static Markdown pages in `docs/guide/` | Rarely change, human-authored |
| **Product Docs** | Auto-generated from source in `docs/product/` | Rebuilt on every PR merge |
| **Auto-Update** | PostToolUse hook triggers `rebuild-docs.sh` | Deterministic, selective, non-blocking |
| **Port** | 3002 (dev=3000, test=3001, docs=3002) | No conflicts between servers |

### 9.2 Implementation Priority

The documentation system should be built in this order during Phase 3:

1. **Session logging infrastructure** -- Define the JSON schema, implement the Performance Coach's write-on-session-end logic. This is the foundation that feeds every other component.

2. **Token extraction and cost calculation** -- Parse JSONL transcripts, populate session logs with token and cost data. Required before the dashboard can display anything meaningful.

3. **VitePress docs site scaffold** -- Basic site structure with navigation, separate system and product sections, dark/light mode. Deploy as a static site on port 3002.

4. **Kanban board** -- JSON state management (`move-card.sh`), Vue component for the docs site, ASCII renderer for the `/status` command. Connect to the Workflow Orchestrator for automatic state transitions.

5. **Statistics dashboard** -- Chart components reading from `index.json`. Start with the Vibe Score trend and cost tracker (highest value), then add remaining panels.

6. **Product docs generation** -- Scripts to auto-generate API reference and component catalog from source files. Connect to the PostToolUse rebuild hook.

7. **Release notes automation** -- Configure release-please (if CI is available) or the bash script fallback. Integrate with the `/wrap` command.

8. **Auto-rebuild hook** -- PostToolUse hook on merge triggers `rebuild-docs.sh` with selective regeneration. This ties everything together.

### 9.3 Architecture Diagram

```
                              +-------------------+
                              |  Claude Code      |
                              |  Transcript       |
                              |  (.jsonl)         |
                              +--------+----------+
                                       | parse
                                       v
+------------------+         +---------------------+
|  Git History     |-------->|  Performance Coach  |
|  (commits,       |         |  (session end)      |
|   PRs, tags)     |         +--------+------------+
+--------+---------+                  | write
         |                            v
         |              +----------------------------+
         |              |  .vibeos/                   |
         |              |    sessions/                |
         |              |      session-*.json         |
         |              |      index.json             |
         |              |    backlog.json             |
         |              |    scores/                  |
         |              +-------------+--------------+
         |                            | read at build
         v                            v
+------------------+    +----------------------------+
|  release-please  |    |  VitePress Docs Site       |
|  (Release PR)    |--->|  (port 3002)               |
+------------------+    |                            |
                        |  /guide/     System docs   |
+------------------+    |  /product/   Product docs  |
|  Source Code     |    |  /dashboard/ Statistics    |
|  (routes, types, |--->|  /dashboard/kanban Board   |
|   components)    |    |  /releases/  Release notes |
+------------------+    +----------------------------+
   generate-*-docs.sh              |
                           +-------+--------+
                           |  Static HTML   |
                           |  (dist/)       |
                           +----------------+

Trigger: PostToolUse hook on merge -> rebuild-docs.sh
```

### 9.4 Key Design Decisions

1. **VitePress over Starlight**: VitePress wins on rebuild speed and simplicity. Since VibeOS uses Vue components for the dashboard, the Vue ecosystem alignment is natural. If zero-JS pages become a priority later, migration to Starlight is straightforward because both use Vite and Markdown.

2. **release-please over Changesets**: VibeOS is autonomous. Human-curated changelog entries (Changesets' strength) are unnecessary when the Doc Generator agent can parse conventional commits. release-please's fully automated approach aligns with the "autonomy with safety" design principle.

3. **JSON files over SQLite for session logs**: Git-friendliness outweighs query performance for a single-project tool. Session logs are append-only and rarely exceed hundreds of entries. JSON keeps everything transparent, debuggable, and diff-friendly in version control.

4. **Chart.js over lighter alternatives**: While uPlot (35 KB) and Frappe Charts (18 KB) are smaller, Chart.js's `vue-chartjs` wrapper provides the best developer experience for VitePress integration. The 70 KB cost is acceptable because the dashboard page is the only page that loads it (VitePress code-splits per page).

5. **Dual rendering (web + terminal)**: The `/status` command needs terminal output for quick glances. The web dashboard provides deep analysis. Both read the same data source (`index.json`), ensuring consistency with zero data duplication.

6. **Flat card array in backlog.json**: Cards are stored in a flat array with a `column` field rather than nested inside column objects. This avoids data duplication, simplifies state transitions (update one field instead of moving between arrays), and makes `jq` queries more straightforward.

7. **Selective regeneration over full rebuild**: The rebuild script checks `git diff` to determine which product docs actually need regeneration. This keeps rebuild times under 5 seconds even as the project grows.

8. **Three Kanban render targets**: The Vue component (web), ASCII table (terminal), and Markdown table (GitHub) all read from the same `backlog.json`. This ensures all views are consistent without requiring synchronization logic.

---

## 10. Sources

The following sources informed this research:

- **VitePress documentation**: https://vitepress.dev/guide/what-is-vitepress
- **VitePress data loading**: https://vitepress.dev/guide/data-loading
- **Astro documentation**: https://docs.astro.build/en/getting-started/
- **Astro Starlight documentation**: https://starlight.astro.build/getting-started/
- **Docusaurus documentation**: https://docusaurus.io/docs
- **Nextra documentation**: https://nextra.site/docs
- **Conventional Commits specification v1.0.0**: https://www.conventionalcommits.org/en/v1.0.0/
- **release-please by Google**: https://github.com/googleapis/release-please
- **release-please GitHub Action**: https://github.com/googleapis/release-please-action
- **semantic-release**: https://github.com/semantic-release/semantic-release
- **Changesets by Atlassian**: https://github.com/changesets/changesets
- **GitHub auto-generated release notes**: https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes
- **GitHub CLI (`gh`) documentation**: https://cli.github.com/manual/
- **Chart.js documentation**: https://www.chartjs.org/docs/latest/
- **vue-chartjs**: https://vue-chartjs.org/
- **Frappe Charts**: https://frappe.io/charts
- **uPlot**: https://github.com/leeoniya/uPlot
- **asciichart (terminal charting)**: https://github.com/kroitor/asciichart
- **Anthropic API pricing**: https://www.anthropic.com/pricing
- **Anthropic prompt caching**: https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching
- **Anthropic token counting**: https://docs.anthropic.com/en/docs/build-with-claude/token-counting
- **Claude Code documentation**: https://docs.anthropic.com/en/docs/claude-code

> **Note**: Token pricing and model identifiers are subject to change. The pricing table in Section 5.2 reflects approximate values as of early 2026. Always verify current pricing at https://www.anthropic.com/pricing before using cost calculations for budgeting decisions.
