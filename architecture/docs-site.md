# Architecture: Documentation Site Design

> **Phase 2 Architecture** | Document 2.5 | February 2026
>
> This document defines the architecture of VibeCrew's documentation website for v1.0. The scope is intentionally minimal: a Kanban board visualization and a basic stats page, both powered by VitePress data loaders reading `.vibecrew/` JSON files.

---

## Table of Contents

1. [Tech Stack: VitePress](#1-tech-stack-vitepress)
2. [Directory Structure](#2-directory-structure)
3. [VitePress Configuration](#3-vitepress-configuration)
4. [Kanban Board](#4-kanban-board)
5. [Basic Stats Page](#5-basic-stats-page)
6. [Data Loader Reference](#6-data-loader-reference)
7. [v1.1 Roadmap](#7-v11-roadmap)

---

## 1. Tech Stack: VitePress

### 1.1 Why VitePress

VitePress is the documentation framework for the VibeCrew docs site. The decision is based on Phase 1 research (Research Document 06) and three requirements:

| Requirement | VitePress Capability |
|---|---|
| **Fast rebuilds** | 3-8 second cold build for 200 pages; 1-3 second incremental rebuilds |
| **Vue components** | Interactive components embed directly in Markdown via `<script setup>` blocks |
| **Data loaders** | `.data.js` files execute at build time, support HMR file watching, and inject `.vibecrew/` JSON into pages |

### 1.2 Dependencies

```json
{
  "devDependencies": {
    "vitepress": "^1.6.0",
    "vue": "^3.5.0"
  }
}
```

No charting libraries are included in v1.0. Vue is a required peer dependency for VitePress.

### 1.3 Fallback Option

If zero-JS static pages become a higher priority, Starlight (Astro-based) is the alternative. Migration is straightforward because both frameworks use Vite and Markdown.

---

## 2. Directory Structure

The docs site lives inside the project's `docs/` directory. VitePress configuration and custom theme components live under `docs/.vitepress/`.

```
docs/
  .vitepress/
    config.js                          # VitePress configuration
    theme/
      index.js                         # Custom theme registration
      components/
        KanbanBoard.vue                # Kanban board visualization
        StatsPage.vue                  # Basic session statistics
      styles/
        kanban.css                     # Kanban board styles
        stats.css                      # Stats page styles
    dist/                              # Build output (gitignored)

  # Data loaders (run at build time, support HMR watching)
  kanban.data.js                       # Reads .vibecrew/backlog.json
  stats.data.js                        # Reads .vibecrew/sessions/*.json

  # Pages
  index.md                             # Docs site landing page
  kanban.md                            # Kanban board page
  stats.md                             # Basic statistics page
  settings.md                          # Settings panel (config.json editor)

  # System documentation (how VibeCrew works)
  guide/
    index.md                           # Introduction to VibeCrew
    installation.md                    # Installation guide
    commands.md                        # Slash command reference
    agents.md                          # Agent reference (9 agents)
    workflows.md                       # Tier 1 + Tier 2 workflow explanations
    hooks.md                           # Hook system reference
    configuration.md                   # .vibecrew/config.json options
    troubleshooting.md                 # Common issues and solutions
```

---

## 3. VitePress Configuration

### 3.1 Main Configuration File

```javascript
// docs/.vitepress/config.js
import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Project Docs',
  description: 'Auto-generated documentation powered by VibeCrew',
  lastUpdated: true,

  themeConfig: {
    nav: [
      { text: 'Guide', link: '/guide/' },
      { text: 'Kanban', link: '/kanban' },
      { text: 'Stats', link: '/stats' },
      { text: 'Settings', link: '/settings' }
    ],

    sidebar: {
      '/guide/': [
        {
          text: 'VibeCrew Guide',
          items: [
            { text: 'Introduction', link: '/guide/' },
            { text: 'Installation', link: '/guide/installation' },
            { text: 'Commands', link: '/guide/commands' },
            { text: 'Agents', link: '/guide/agents' },
            { text: 'Workflows', link: '/guide/workflows' },
            { text: 'Hooks', link: '/guide/hooks' },
            { text: 'Configuration', link: '/guide/configuration' },
            { text: 'Troubleshooting', link: '/guide/troubleshooting' }
          ]
        }
      ]
    },

    search: { provider: 'local' },

    footer: {
      message: 'Built with VibeCrew',
      copyright: 'Auto-generated documentation'
    }
  },

  markdown: {
    lineNumbers: true
  }
})
```

### 3.2 Custom Theme Registration

```javascript
// docs/.vitepress/theme/index.js
import DefaultTheme from 'vitepress/theme'
import KanbanBoard from './components/KanbanBoard.vue'
import StatsPage from './components/StatsPage.vue'
import './styles/kanban.css'
import './styles/stats.css'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component('KanbanBoard', KanbanBoard)
    app.component('StatsPage', StatsPage)
  }
}
```

---

## 4. Kanban Board

The Kanban board is a read-only visualization of the project backlog. It renders data from `.vibecrew/backlog.json` and does not provide drag-and-drop or editing capabilities. All mutations to feature state happen through VibeCrew slash commands (`/new-feature`, `/run-backlog`, `/plan-features`).

### 4.1 Columns

The board renders 7 columns matching the feature column flow defined in `architecture/schemas.md` Section 4:

| Column | ID | WIP Limit |
|---|---|---|
| Ideas | `idea` | None |
| Planned | `planned` | 5 |
| Ready | `ready` | 3 |
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

The board reads from `.vibecrew/backlog.json` via `kanban.data.js`. The `backlog.json` schema is defined in `architecture/schemas.md` Section 4. Key fields used:

- `columns[]` -- Column definitions with `id`, `title`, `wip_limit`
- `features[]` -- Feature objects with `name`, `column`, `priority`, `labels`

### 4.4 Vue Component

```vue
<!-- docs/.vitepress/theme/components/KanbanBoard.vue -->
<script setup>
import { computed } from 'vue'

const props = defineProps({
  data: { type: Object, required: true }
})

const boardColumns = computed(() => {
  if (!props.data?.columns) return []
  return props.data.columns.map(col => ({
    ...col,
    features: (props.data.features || [])
      .filter(f => f.column === col.id)
      .sort((a, b) => (a.priority || 99) - (b.priority || 99))
  }))
})

function priorityClass(priority) {
  if (priority === 1) return 'priority-high'
  if (priority === 2) return 'priority-medium'
  return 'priority-low'
}
</script>

<template>
  <div class="kanban-board">
    <div v-for="column in boardColumns" :key="column.id" class="kanban-column">
      <div class="column-header">
        <h3>{{ column.title }}</h3>
        <span class="card-count">
          {{ column.features.length }}
          <span v-if="column.wip_limit" class="wip-limit">/ {{ column.wip_limit }}</span>
        </span>
      </div>
      <div class="column-body">
        <div
          v-for="feature in column.features"
          :key="feature.id"
          class="kanban-card"
          :class="priorityClass(feature.priority)"
        >
          <div class="card-title">{{ feature.name }}</div>
          <div v-if="feature.labels?.length" class="card-labels">
            <span v-for="label in feature.labels" :key="label" class="label">
              {{ label }}
            </span>
          </div>
        </div>
        <div v-if="column.features.length === 0" class="empty-column">
          No items
        </div>
      </div>
    </div>
  </div>
</template>
```

### 4.5 Kanban Styles

```css
/* docs/.vitepress/theme/styles/kanban.css */

.kanban-board {
  display: flex;
  gap: 0.75rem;
  overflow-x: auto;
  padding: 1rem 0;
}

.kanban-column {
  min-width: 180px;
  flex: 1;
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  padding: 0.75rem;
}

.column-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid var(--vp-c-divider);
}

.column-header h3 {
  margin: 0;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.card-count {
  font-size: 0.75rem;
  color: var(--vp-c-text-2);
}

.wip-limit {
  color: var(--vp-c-text-3);
}

.kanban-card {
  background: var(--vp-c-bg);
  border-radius: 6px;
  padding: 0.75rem;
  margin-bottom: 0.5rem;
  border-left: 3px solid var(--vp-c-divider);
}

.kanban-card.priority-high { border-left-color: #ef4444; }
.kanban-card.priority-medium { border-left-color: #f97316; }
.kanban-card.priority-low { border-left-color: #10b981; }

.card-title {
  font-weight: 600;
  font-size: 0.875rem;
  margin-bottom: 0.35rem;
}

.card-labels {
  display: flex;
  flex-wrap: wrap;
  gap: 0.25rem;
}

.card-labels .label {
  font-size: 0.65rem;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-2);
  padding: 0.1rem 0.4rem;
  border-radius: 4px;
}

.empty-column {
  color: var(--vp-c-text-3);
  font-size: 0.8rem;
  text-align: center;
  padding: 1rem 0;
}

/* Responsive: stack columns vertically on narrow screens */
@media (max-width: 768px) {
  .kanban-board {
    flex-direction: column;
  }
  .kanban-column {
    min-width: auto;
  }
}
```

### 4.6 Kanban Page

```markdown
---
layout: page
title: Kanban Board
---

<script setup>
import { data } from './kanban.data.js'
import KanbanBoard from './.vitepress/theme/components/KanbanBoard.vue'
</script>

# Project Kanban Board

<KanbanBoard :data="data" />
```

---

## 5. Basic Stats Page

The stats page shows four summary metrics derived from session log files. No charts are included in v1.0 -- the values are displayed in a simple card layout.

### 5.1 Metrics Displayed

| Metric | Source Field | Calculation |
|---|---|---|
| **Total Sessions** | Count of session files | `files.length` |
| **Average Vibe Score** | `vibe_score` per session | `sum(scores) / count(non-null scores)` |
| **Total Tokens Used** | `tokens.input + tokens.cache_creation + tokens.cache_read + tokens.output` | Sum across all sessions |
| **Estimated Total Cost** | `tokens.estimated_cost_usd` | Sum across all sessions |

### 5.2 Data Source

The stats page reads all session log files from `.vibecrew/sessions/*.json` via `stats.data.js`. The session log schema is defined in `architecture/schemas.md` Section 5. Key fields used:

- `session_id` -- Session identifier
- `vibe_score` -- Integer 0-100 or null
- `tokens.input`, `tokens.cache_creation`, `tokens.cache_read`, `tokens.output` -- Token counts
- `tokens.estimated_cost_usd` -- Per-session cost estimate

### 5.3 Vue Component

```vue
<!-- docs/.vitepress/theme/components/StatsPage.vue -->
<script setup>
import { computed } from 'vue'

const props = defineProps({
  sessions: { type: Array, required: true }
})

const stats = computed(() => {
  const sessions = props.sessions || []
  const totalSessions = sessions.length

  const scores = sessions
    .map(s => s.vibe_score)
    .filter(v => v != null)
  const averageVibeScore = scores.length > 0
    ? Math.round(scores.reduce((a, b) => a + b, 0) / scores.length)
    : 0

  let totalTokens = 0
  let totalCost = 0
  for (const s of sessions) {
    if (s.tokens) {
      totalTokens += (s.tokens.input || 0)
        + (s.tokens.cache_creation || 0)
        + (s.tokens.cache_read || 0)
        + (s.tokens.output || 0)
      totalCost += (s.tokens.estimated_cost_usd || 0)
    }
  }

  return { totalSessions, averageVibeScore, totalTokens, totalCost }
})

function formatTokens(n) {
  if (n >= 1_000_000) return (n / 1_000_000).toFixed(1) + 'M'
  if (n >= 1_000) return (n / 1_000).toFixed(1) + 'K'
  return String(n)
}

function formatCost(n) {
  return '$' + n.toFixed(2)
}
</script>

<template>
  <div class="stats-page">
    <div class="stats-cards">
      <div class="stat-card">
        <div class="stat-label">Total Sessions</div>
        <div class="stat-value">{{ stats.totalSessions }}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Average Vibe Score</div>
        <div class="stat-value">{{ stats.averageVibeScore }}<span class="stat-unit">/100</span></div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Total Tokens Used</div>
        <div class="stat-value">{{ formatTokens(stats.totalTokens) }}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Estimated Total Cost</div>
        <div class="stat-value">{{ formatCost(stats.totalCost) }}</div>
      </div>
    </div>
    <p v-if="stats.totalSessions === 0" class="stats-empty">
      No sessions recorded yet. Run <code>/wrap</code> to save session data.
    </p>
  </div>
</template>
```

### 5.4 Stats Styles

```css
/* docs/.vitepress/theme/styles/stats.css */

.stats-page {
  padding: 1rem 0;
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 1rem;
}

.stat-card {
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  padding: 1.5rem;
  text-align: center;
}

.stat-label {
  font-size: 0.75rem;
  color: var(--vp-c-text-2);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 0.5rem;
}

.stat-value {
  font-size: 2rem;
  font-weight: 700;
}

.stat-unit {
  font-size: 0.875rem;
  font-weight: 400;
  color: var(--vp-c-text-2);
}

.stats-empty {
  color: var(--vp-c-text-3);
  text-align: center;
  margin-top: 2rem;
}
```

### 5.5 Stats Page

```markdown
---
layout: page
title: Session Statistics
---

<script setup>
import { data } from './stats.data.js'
import StatsPage from './.vitepress/theme/components/StatsPage.vue'
</script>

# Session Statistics

<StatsPage :sessions="data" />
```

---

## 6. Data Loader Reference

VitePress data loaders are `.data.js` files that execute at build time (or on watched file changes during dev). They bridge `.vibecrew/` JSON state and Vue components.

### 6.1 Kanban Data Loader

```javascript
// docs/kanban.data.js
// Reads backlog.json for the Kanban board component.
// Schema: architecture/schemas.md Section 4

import { readFileSync, existsSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'

const __dir = dirname(fileURLToPath(import.meta.url))

export default {
  watch: ['../.vibecrew/backlog.json'],
  load() {
    const backlogPath = resolve(__dir, '..', '.vibecrew', 'backlog.json')

    if (!existsSync(backlogPath)) {
      return {
        schema_version: '1.0.0',
        columns: [
          { id: 'idea', title: 'Ideas', wip_limit: null },
          { id: 'planned', title: 'Planned', wip_limit: 5 },
          { id: 'ready', title: 'Ready', wip_limit: 3 },
          { id: 'in-progress', title: 'In Development', wip_limit: 1 },
          { id: 'testing', title: 'Testing', wip_limit: 1 },
          { id: 'review', title: 'Review', wip_limit: 2 },
          { id: 'done', title: 'Done', wip_limit: null }
        ],
        features: []
      }
    }

    return JSON.parse(readFileSync(backlogPath, 'utf-8'))
  }
}
```

### 6.2 Stats Data Loader

```javascript
// docs/stats.data.js
// Reads session log files for the stats page.
// Schema: architecture/schemas.md Section 5

import { readFileSync, readdirSync, existsSync } from 'fs'
import { resolve, join, dirname } from 'path'
import { fileURLToPath } from 'url'

const __dir = dirname(fileURLToPath(import.meta.url))

export default {
  watch: ['../.vibecrew/sessions/*.json'],
  load() {
    const sessionsDir = resolve(__dir, '..', '.vibecrew', 'sessions')

    if (!existsSync(sessionsDir)) {
      return []
    }

    const files = readdirSync(sessionsDir)
      .filter(f => f.startsWith('session-') && f.endsWith('.json'))
      .sort()

    return files.map(f => {
      try {
        return JSON.parse(readFileSync(join(sessionsDir, f), 'utf-8'))
      } catch {
        return null
      }
    }).filter(Boolean)
  }
}
```

### 6.3 Config Data Loader

```javascript
// docs/data/config.data.ts
// Reads config.json for the Settings panel component.
// Schema: templates/config.json.template

import { readFileSync, existsSync } from 'node:fs'
import { resolve, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dir = dirname(fileURLToPath(import.meta.url))

export default {
  watch: ['../../.vibecrew/config.json'],
  load() {
    const projectRoot = resolve(__dir, '../..')
    const configPath = resolve(projectRoot, '.vibecrew/config.json')

    if (!existsSync(configPath)) {
      return defaultConfig // Full default from config.json.template
    }

    const raw = readFileSync(configPath, 'utf-8')
    return deepMerge(defaultConfig, JSON.parse(raw))
  }
}
```

The config loader deep-merges parsed JSON with template defaults so that missing keys (from older schema versions) always have fallback values. The `watch` path triggers HMR when the config is changed externally (e.g., via `/profile` in the CLI). The component writes back through a Vite dev server middleware endpoint (`/api/save-config`), which performs atomic writes (temp file + rename) to prevent partial reads.

### 6.4 Notes on Data Loaders

- Both loaders use `import.meta.url` to resolve paths, which is the correct approach for ES modules. The `__dirname` global is not available in ES module scope.
- Each loader declares a single `watch` array for HMR. During `vitepress dev`, changes to the watched files trigger the loader to re-execute and push updated data to the browser.
- Both loaders return safe defaults (empty arrays or stub objects) when the `.vibecrew/` files do not yet exist. This prevents build failures on first run.

---

## 7. v1.1 Roadmap

The following features are planned for v1.1 but are explicitly **out of scope** for v1.0:

- **Statistics dashboard with charts** -- Token usage, cost trends, Vibe Score history, test coverage, and feature velocity visualizations using a charting library.
- **Release notes auto-generation** -- Generating Markdown release notes from conventional commit history and linking them in the docs site navigation.
- **Product documentation section** -- Auto-generated docs for the user's SaaS application (API endpoints, component catalog, database schema, deployment guide).
- **Advanced Vue components** -- Dedicated chart components, active agent session panels, and summary cards with trend indicators.
- **Auto-rebuild on PR merge** -- PostToolUse hook triggering selective documentation regeneration via `rebuild-docs.sh`.
- **Sidebar auto-generation** -- File-system-based sidebar generator for product documentation pages.

---

## Key Design Decisions

1. **Minimal v1.0 scope**: The original design specified 7 Vue dashboard components, Chart.js charts, release notes auto-generation, and a dedicated dev server on port 3002. This was cut to 2 components (Kanban board + stats page) following a best-practices review. Ship the core value first; add charts and automation in v1.1.

2. **VitePress over Starlight**: VitePress wins on rebuild speed (3-8s vs. 5-10s) and simplicity. Since VibeCrew uses Vue components for interactive pages, the Vue ecosystem alignment is natural.

3. **Data loaders over API endpoints**: VitePress data loaders execute at build time and inject data directly into Vue components. This eliminates the need for a runtime API server, keeps the docs site fully static, and supports HMR during development via file watching.

4. **`import.meta.url` over `__dirname`**: VitePress config and data loaders use ES modules. The `__dirname` global does not exist in ES module scope. All path resolution uses `dirname(fileURLToPath(import.meta.url))`.

5. **Read-only Kanban board**: The web Kanban board is a visualization, not an editor. All state mutations happen through slash commands. This prevents the docs site from becoming a mutation surface that could conflict with agent operations.

6. **No dedicated port allocation**: The v1.0 docs site uses VitePress defaults. Users run `npx vitepress dev docs` when they want to preview. A dedicated port (3002) with `strictPort` and background process management is deferred to v1.1.

7. **Schema references over inline definitions**: All JSON schemas are defined in `architecture/schemas.md` and referenced from this document. This eliminates duplicate schema definitions that can drift out of sync.
