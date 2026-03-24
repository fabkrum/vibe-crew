---
title: Getting Started
---

# Getting Started with VibeCrew

VibeCrew is a Claude Code plugin that transforms Claude Code into an autonomous vibe-coding operating system.

## Prerequisites

- **Claude Code** 2.0 or later
- **Git** 2.30+
- **GitHub CLI** (`gh`) 2.0+
- **Node.js** 18+
- **jq** (JSON processing)
- **terminal-notifier** (macOS notifications, optional)

## Installation

Start Claude Code with the VibeCrew plugin:

```bash
claude --plugin-dir /path/to/claude-plugin-vibe-crew
```

## Initial Setup

Run the setup wizard to configure your environment:

```
/setup
```

The wizard will:

1. Check prerequisites (Git, Node.js, jq required; gh, terminal-notifier optional)
2. Detect your terminal emulator (Warp, iTerm2, VS Code, Terminal.app)
3. Test notification delivery
4. Verify MCP server connections (Context7, Chrome DevTools, Playwright)
5. Configure your Claude Code command (`claude`, `claude-p`, `claude-w`, or custom)
6. Initialize the `.vibecrew/` state directory
7. Set up git repository (GitHub, GitLab, or local)

**Warp Terminal users:** The wizard auto-generates a launch configuration at `~/.warp/launch_configurations/<project>.yaml` with multi-pane layout. If VibeCrew is loaded via `--plugin-dir`, the flag is automatically included in the launch config so all Warp panes have access to VibeCrew commands.

## Creating a New Project

Start your first project with the guided foundation workflow:

```
/new-project
```

This creates 6 foundation artifacts before any source code is written:

1. **VISION.md** — Project vision, personas, value proposition
2. **design-system.css** — Color tokens, typography, spacing
3. **Technology Decision Record** — Stack choices with rationale
4. **roadmap.md** — Prioritized feature roadmap
5. **Architecture Diagrams** — 5 Mermaid diagrams (system, schema, state flows, API sequences, component tree)
6. **CLAUDE.md** — Code conventions and session learnings

## Building Features

Once the foundation is complete, start building:

```
/plan-features          # Plan and prioritize features
/new-feature "name"     # Start a new feature
/run-backlog            # Autonomous feature loop
```

## Viewing the Vibe Dashboard

Your project includes a browser-based dashboard with real-time development metrics:

```bash
cd docs
npm install
npm run docs:dev
```

Visit `http://localhost:5173` to see:

- **About** — Project overview sourced from VISION.md, tech stack, feature showcase
- **Kanban** — Feature backlog across 7 workflow stages
- **Stats** — Total sessions, average Vibe Score, token usage, estimated cost
- **Trends** — Vibe Score history, token breakdown, agent activity over time
- **Logbook** — Per-session drill-down with score breakdowns, token usage, agents, test results, and coaching
- **Coverage** — Test coverage gauge and feature delivery progress
- **Achievements** — Level, badges, skill trees, streaks, and challenges
- **Releases** — Version timeline with changelogs, commit stats, and diff summaries
- **Settings** — Edit your VibeCrew configuration (profile, notifications, cost limits, MCP servers)

Data updates automatically in dev mode via the file watcher. Each time you run `/wrap`, sessions, scores, and releases refresh in real time.

For a static preview without hot-reload:

```bash
npm run docs:build && npm run docs:preview
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `/setup` | Configure environment |
| `/new-project` | Create project foundation |
| `/plan-features` | Plan feature backlog |
| `/new-feature` | Start a feature |
| `/run-backlog` | Autonomous feature loop |
| `/idea` | Quick backlog capture |
| `/status` | Project dashboard |
| `/check` | Run quality checks |
| `/wrap` | Close session with score |

See the [Command Reference](/system/commands) for full details.
