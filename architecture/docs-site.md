# Architecture: Documentation Site Design

> **Phase 2 Architecture** | Document 2.5 | March 2026
>
> This document defines the architecture of VibeCrew's documentation website. The dashboard includes 12 pages: a project overview (About), getting-started guide, product features, Kanban board, session statistics, trend charts, session logbook, test coverage, achievements, release timeline, architecture diagrams, and a settings editor — all powered by VitePress data loaders reading `.vibecrew/` JSON files and project root artifacts.

---

## Table of Contents

1. [Tech Stack: VitePress](#1-tech-stack-vitepress)
2. [Directory Structure](#2-directory-structure)
3. [VitePress Configuration](#3-vitepress-configuration)
4. [Kanban Board](#4-kanban-board)
5. [Basic Stats Page](#5-basic-stats-page)
6. [About Page](#6-about-page)
7. [Releases Timeline](#7-releases-timeline)
8. [Session Logbook](#8-session-logbook)
9. [Data Loader Reference](#9-data-loader-reference)
10. [Key Design Decisions](#10-key-design-decisions)

---

## 1. Tech Stack: VitePress

### 1.1 Why VitePress

VitePress is the documentation framework for the VibeCrew docs site. The decision is based on Phase 1 research (Research Document 06) and three requirements:

| Requirement | VitePress Capability |
|---|---|
| **Fast rebuilds** | 3-8 second cold build for 200 pages; 1-3 second incremental rebuilds |
| **Vue components** | Interactive components embed directly in Markdown via `<script setup>` blocks |
| **Data loaders** | `.data.ts` files execute at build time, support HMR file watching, and inject `.vibecrew/` JSON into pages |

### 1.2 Dependencies

```json
{
  "devDependencies": {
    "vitepress": "^1.6.0",
    "vue": "^3.5.0",
    "@vue/test-utils": "^2.4.0",
    "vitest": "^3.0.0",
    "jsdom": "^26.0.0"
  }
}
```

### 1.3 Fallback Option

If zero-JS static pages become a higher priority, Starlight (Astro-based) is the alternative. Migration is straightforward because both frameworks use Vite and Markdown.

---

## 2. Directory Structure

The docs site lives inside the project's `docs/` directory. VitePress configuration and custom theme components live under `docs/.vitepress/`.

```
docs/
  .vitepress/
    config.ts                            # VitePress configuration (nav, sidebar, API plugins, file watcher)
    theme/
      index.js                           # Custom theme registration (16 components)
    dist/                                # Build output (gitignored)

  # Data loaders (run at build time, support HMR watching)
  data/
    backlog.data.ts                      # Reads .vibecrew/backlog.json
    sessions.data.ts                     # Reads .vibecrew/sessions/*.json
    scores.data.ts                       # Reads .vibecrew/scores/*.json
    config.data.ts                       # Reads .vibecrew/config.json
    feature-docs.data.ts                 # Reads docs/features/*.md
    gamification.data.ts                 # Reads .vibecrew/gamification.json
    architecture.data.ts                 # Reads .vibecrew/architecture/*.mmd
    releases.data.ts                     # Reads .vibecrew/releases/*.json
    about.data.ts                        # Reads VISION.md, TDR.md, package.json

  # Vue components
  components/
    KanbanBoard.vue                      # Interactive 7-column Kanban board
    FeatureProgress.vue                  # Feature delivery progress bars
    CoverageGauge.vue                    # Test coverage gauge
    ScoreTrend.vue                       # Vibe Score line chart (SVG)
    AgentActivityPanel.vue               # Agent invocation bars + timeline
    StatsPage.vue                        # Four summary metric cards
    TokenBreakdown.vue                   # Stacked token bars per session
    AchievementsBoard.vue                # Level, badges, skill radar, streaks
    SettingsPanel.vue                    # Config.json browser editor
    LiveSessionPanel.vue                 # Real-time session status bar
    ArchitectureOverview.vue             # Mermaid diagram tabs
    ProductFeatures.vue                  # Completed features grid by label
    AboutPage.vue                        # Project overview (vision, tech stack, features, dev server)
    ReleasesTimeline.vue                 # Vertical release timeline with changelog sections
    SessionLogbook.vue                   # Session list with expandable accordion
    SessionLogbookEntry.vue              # Single session expanded detail panel

  # Pages
  index.md                               # Home page with feature cards
  about.md                               # About page (VISION.md / TDR.md overview)
  features.md                            # Product features page
  kanban.md                              # Kanban board page
  stats.md                               # Session statistics page
  trends.md                              # Trends page (score, tokens, agents)
  logbook.md                             # Session logbook page
  coverage.md                            # Coverage page
  achievements.md                        # Achievements page
  releases.md                            # Releases timeline page
  architecture.md                        # Architecture diagrams page
  settings.md                            # Settings editor page

  # System documentation
  system/
    getting-started.md                   # Getting started guide
    commands.md                          # Slash command reference

  # Feature documentation (auto-generated by Doc Generator)
  features/
    *.md                                 # Per-feature documentation

  # Tests
  __tests__/
    SessionLogbook.test.ts               # Logbook component tests
    StatsPage.test.ts                    # Stats component tests
    ProductFeatures.test.ts              # Features component tests
    AchievementsBoard.test.ts            # Achievements component tests
    SettingsPanel.test.ts                # Settings component tests
    CoverageGauge.test.ts                # Coverage component tests
    TokenBreakdown.test.ts               # Token breakdown component tests
    AddIdeaModal.test.ts                 # Add idea modal tests
    FeatureProgress.test.ts              # Feature progress tests
    useBacklogApi.test.ts                # Backlog API composable tests
    backlog.data.test.ts                 # Backlog data loader tests
    feature-docs.data.test.ts            # Feature docs data loader tests
```

---

## 3. VitePress Configuration

### 3.1 Navigation

The config defines 12 nav entries:

```typescript
nav: [
  { text: "About", link: "/about" },
  { text: "Guide", link: "/system/getting-started" },
  { text: "Features", link: "/features" },
  { text: "Kanban", link: "/kanban" },
  { text: "Stats", link: "/stats" },
  { text: "Trends", link: "/trends" },
  { text: "Logbook", link: "/logbook" },
  { text: "Coverage", link: "/coverage" },
  { text: "Achievements", link: "/achievements" },
  { text: "Releases", link: "/releases" },
  { text: "Architecture", link: "/architecture" },
  { text: "Settings", link: "/settings" },
],
```

### 3.2 Theme Registration

The theme registers 16 Vue components globally:

```javascript
// KanbanBoard, FeatureProgress, CoverageGauge, ScoreTrend,
// AgentActivityPanel, StatsPage, TokenBreakdown, AchievementsBoard,
// SettingsPanel, LiveSessionPanel, ArchitectureOverview, ProductFeatures,
// AboutPage, ReleasesTimeline, SessionLogbook, SessionLogbookEntry
```

### 3.3 API Plugins

The config includes 5 Vite plugins:
- **Settings API** — `POST /api/save-config` for writing config.json
- **Backlog API** — `GET /api/backlog`, `POST /api/backlog/add-idea`, `POST /api/backlog/move`, `POST /api/backlog/update`
- **Launch API** — `POST /api/launch-warp` for Warp terminal integration
- **Live Session API** — `GET /api/live-session` for real-time session status
- **File Watcher** — Watches `.vibecrew/` directory and broadcasts WebSocket events for real-time updates

### 3.4 File Watcher Events

| File Pattern | Event Type |
|---|---|
| `backlog.json` | `backlog_changed` |
| `live-session.json` | `live_session_changed` |
| `config.json` | `config_changed` |
| `session-*` | `session_changed` |
| `score-*` | `score_changed` |
| `release-*` | `release_changed` |
| Other files | `state_changed` |

---

## 4. Kanban Board

The Kanban board is an interactive visualization of the project backlog. It renders data from `.vibecrew/backlog.json` and supports drag-and-drop reordering, an add-idea form, card editing, and Warp terminal launch actions in dev mode. In static builds it falls back to a read-only display. State mutations are persisted through the Vite dev server middleware endpoint (`/api/save-backlog`).

### 4.1 Columns

The board renders 7 columns matching the feature column flow defined in `architecture/schemas.md` Section 4:

| Column | ID | WIP Limit |
|---|---|---|
| Ideas | `idea` | None |
| Planned | `planned` | 5 |
| Planning | `planning` | 2 |
| In Development | `in-progress` | 1 |
| Testing | `testing` | 1 |
| Review | `review` | 2 |
| Done | `done` | None |

### 4.2 Card Display

Each card shows:
- **Feature name** (bolded)
- **Priority** (numeric, lower = higher priority; styled with colored left border: priority 1 = red, 2 = orange, 3+ = green)
- **Labels** (tag badges)

### 4.3 Data Source

Reads from `.vibecrew/backlog.json` via `backlog.data.ts`.

---

## 5. Basic Stats Page

The stats page shows four summary metrics derived from session log files displayed in a card layout.

### 5.1 Metrics Displayed

| Metric | Source Field | Calculation |
|---|---|---|
| **Total Sessions** | Count of session files | `files.length` |
| **Average Vibe Score** | `vibe_score` per session | `sum(scores) / count(non-null scores)` |
| **Total Tokens Used** | `tokens.input + tokens.cache_creation + tokens.cache_read + tokens.output` | Sum across all sessions |
| **Estimated Total Cost** | `tokens.estimated_cost_usd` | Sum across all sessions |

### 5.2 Data Source

Reads `.vibecrew/sessions/*.json` via `sessions.data.ts`.

---

## 6. About Page

The About page provides a user-facing project overview by aggregating data from multiple sources created during the Tier 1 foundation.

### 6.1 Data Sources

| Source | Content |
|---|---|
| `VISION.md` | Project name, tagline, description, target audience, problems solved |
| `TDR.md` | Technology stack summary |
| `package.json` | npm scripts for the dev server section |
| `backlog.json` | Completed features for the feature showcase |
| `docs/features/*.md` | Feature doc slugs for linking |

### 6.2 Component Structure (`AboutPage.vue`)

6 card sections:
1. **Hero** — Project name, tagline, description (from VISION.md H1 + first paragraph)
2. **Target Audience** — Extracted from `## Target Audience` section
3. **Problems Solved** — Extracted from `## Problems Solved` section
4. **Feature Showcase** — Grid of done features (name + description), linking to feature docs when available
5. **Tech Stack** — Rendered from TDR's technology stack section
6. **Dev Server** — Table of `package.json` scripts with dashboard scripts highlighted, plus auto-update explanation

### 6.3 Data Loader (`about.data.ts`)

Parses markdown by extracting `## Heading` boundaries. Watches `VISION.md`, `TDR.md`, and `package.json`. Returns graceful fallbacks when files don't exist (foundation not complete).

---

## 7. Releases Timeline

The Releases page displays a vertical timeline of all project releases generated by `/wrap` and `/release`.

### 7.1 Data Source

Reads `.vibecrew/releases/release-*.json` via `releases.data.ts`. Files are sorted newest-first.

### 7.2 Release JSON Schema

```typescript
interface ReleaseEntry {
  version: string;          // e.g., "1.2.0"
  date: string;             // ISO 8601
  sections: {
    features: string[];     // Feature descriptions
    fixes: string[];        // Bug fix descriptions
    refactors: string[];    // Refactoring descriptions
    docs: string[];         // Documentation changes
    other: string[];        // Uncategorized changes
  };
  stats: {
    total_commits: number;
    files_changed: number;
    insertions: number;
    deletions: number;
  };
}
```

### 7.3 Component Structure (`ReleasesTimeline.vue`)

- Summary bar with total releases and latest version badge
- Vertical CSS timeline (line + dots, no external library)
- Each release: version pill, date, change sections (only non-empty sections shown), stats row

---

## 8. Session Logbook

The Session Logbook provides per-session drill-down as a complement to the Stats and Trends aggregate views.

### 8.1 Data Sources

- **Sessions**: `.vibecrew/sessions/*.json` via `sessions.data.ts`
- **Scores**: `.vibecrew/scores/*.json` via `scores.data.ts`

Sessions and scores are joined by `session_id` using a `Map<string, ScoreEntry>` lookup.

### 8.2 Component Structure

**`SessionLogbook.vue`** — Parent component:
- Summary bar (total sessions, date range)
- Filter/sort controls (newest/oldest toggle, feature filter dropdown)
- Expandable accordion list (50 visible, "Load more" button)
- Collapsed row: date/time, feature ID, duration, vibe score badge (color-coded)

**`SessionLogbookEntry.vue`** — Expanded detail (child):
- Task Summary — session description
- Vibe Score Breakdown — score + rating, deductions (red pills) and bonuses (green pills)
- Token Usage — input, cache_creation, cache_read, output, cost, cache hit rate
- Context Window — peak %, compactions
- Agents Used — colored chips matching `AgentActivityPanel` color scheme
- Test Results — total/passed/failed, coverage %
- Files Modified — collapsible list with +/- line counts
- Commits — hash (7-char monospace) + message
- Coaching — suggestions from score data

### 8.3 Score Color Coding

| Score Range | Color | Hex |
|---|---|---|
| >= 90 | Green | `#22c55e` |
| 70-89 | Blue | `#3b82f6` |
| 50-69 | Yellow | `#eab308` |
| < 50 | Red | `#ef4444` |

---

## 9. Data Loader Reference

VitePress data loaders are `.data.ts` files that execute at build time (or on watched file changes during dev). They bridge `.vibecrew/` JSON state and Vue components.

| Loader | Watch Path | Returns | Key Behavior |
|---|---|---|---|
| `backlog.data.ts` | `../../.vibecrew/backlog.json` | Backlog object | Falls back to default columns if missing |
| `sessions.data.ts` | `../../.vibecrew/sessions/*.json` | `SessionData[]` | Filters `session-*.json`, sorts chronologically |
| `scores.data.ts` | `../../.vibecrew/scores/*.json` | `ScoresData` | Last 20 scores, trend calculation, deduction aggregation |
| `config.data.ts` | `../../.vibecrew/config.json` | Config object | Deep-merges with template defaults |
| `feature-docs.data.ts` | `../../docs/features/*.md` | `string[]` | Returns basenames of feature doc files |
| `gamification.data.ts` | `../../.vibecrew/gamification.json` | Gamification object | Level, XP, badges, streaks |
| `architecture.data.ts` | `../../.vibecrew/architecture/*.mmd` | Mermaid diagram strings | Reads 5 architecture diagram files |
| `releases.data.ts` | `../../.vibecrew/releases/*.json` | `ReleaseEntry[]` | Filters `release-*.json`, sorted newest-first |
| `about.data.ts` | `../../VISION.md`, `../../TDR.md`, `../../package.json` | `AboutData` | Markdown section extraction, graceful fallbacks |

### 9.1 Notes on Data Loaders

- All loaders use `import.meta.url` or `process.cwd()` to resolve paths (ES module scope — no `__dirname`).
- Each loader declares a `watch` array for HMR. During `vitepress dev`, changes to watched files trigger re-execution and push updated data to the browser.
- All loaders return safe defaults (empty arrays or stub objects) when `.vibecrew/` files do not yet exist.

---

## 10. Key Design Decisions

1. **VitePress over Starlight**: VitePress wins on rebuild speed (3-8s vs. 5-10s) and simplicity. Since VibeCrew uses Vue components for interactive pages, the Vue ecosystem alignment is natural.

2. **Data loaders over API endpoints**: VitePress data loaders execute at build time and inject data directly into Vue components. This eliminates the need for a runtime API server, keeps the docs site fully static, and supports HMR during development via file watching.

3. **`import.meta.url` over `__dirname`**: VitePress config and data loaders use ES modules. The `__dirname` global does not exist in ES module scope. All path resolution uses `dirname(fileURLToPath(import.meta.url))`.

4. **Interactive Kanban board**: The web Kanban board supports drag-and-drop column transitions, an add-idea form, inline card editing, and Warp terminal launch actions when running in dev mode. In static builds (no dev server), the board falls back to a read-only display. All mutations go through the Vite dev server middleware, which performs atomic writes to `backlog.json`.

5. **One-command dashboard launch**: The `scripts/start-dashboard.sh` script provides one-command launch with smart port detection.

6. **Schema references over inline definitions**: All JSON schemas are defined in `architecture/schemas.md` and referenced from this document.

7. **Session-score join via Map**: The Logbook joins sessions with scores by `session_id` using a `Map` for O(1) lookups, avoiding N*M traversal.

8. **Logbook complements, not replaces, Stats/Trends**: Stats shows aggregates, Trends shows time-series charts, Logbook shows per-session drill-down. Different granularity for different questions.

9. **About page vs ProductFeatures**: About is external-facing (what is this app?), ProductFeatures is internal-tracking (labels, dates, developer metadata). Different audience.
