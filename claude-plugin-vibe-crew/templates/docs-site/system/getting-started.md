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

Install the VibeCrew plugin:

```bash
claude plugin install /path/to/claude-plugin-vibe-crew
```

## Initial Setup

Run the setup wizard to configure your environment:

```
/setup
```

The wizard will:

1. Detect your terminal emulator (Warp, iTerm2, VS Code, Terminal.app)
2. Test notification delivery
3. Verify MCP server connections (Context7, Puppeteer)
4. Initialize the `.vibecrew/` state directory

## Creating a New Project

Start your first project with the guided foundation workflow:

```
/new-project
```

This creates 5 foundation artifacts before any source code is written:

1. **VISION.md** — Project vision, personas, value proposition
2. **design-system.css** — Color tokens, typography, spacing
3. **Technology Decision Record** — Stack choices with rationale
4. **roadmap.md** — Prioritized feature roadmap
5. **CLAUDE.md** — Code conventions and session learnings

## Building Features

Once the foundation is complete, start building:

```
/plan-features          # Plan and prioritize features
/new-feature "name"     # Start a new feature
/run-backlog            # Autonomous feature loop
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
