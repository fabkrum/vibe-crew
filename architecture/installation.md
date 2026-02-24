# Architecture: Plugin Installation Design

> **Phase 2 Architecture** | Document 2.7 (Revised) | February 2026
>
> This document defines how VibeCrew installs, configures, and bootstraps itself as a Claude Code plugin. It covers the plugin manifest, dependency management, MCP server configuration, hook wiring, skill registration, agent definitions, first-run setup wizard, configuration format, state file initialization, CLAUDE.md template generation, and state file migration. The target environment is macOS with Warp terminal, serving solo non-technical developers.
>
> **Revision notes:** This revision fixes jq field path inconsistencies (all paths now match [schemas.md](schemas.md)), corrects dependency classification (required vs recommended), updates to the 5-agent topology, adds the `compact-reinject.sh` hook, removes the deferred `coach-retro.sh` hook, adds state file versioning with `schema_version`, and replaces all inline JSON schemas with references to [schemas.md](schemas.md).

---

## Table of Contents

1. [Plugin Manifest](#1-plugin-manifest)
2. [Dependencies](#2-dependencies)
3. [MCP Server Configuration](#3-mcp-server-configuration)
4. [Hook Configuration](#4-hook-configuration)
5. [Skills / Commands](#5-skills--commands)
6. [Agent Definitions](#6-agent-definitions)
7. [Setup Wizard](#7-setup-wizard)
8. [Configuration Format](#8-configuration-format)
9. [State File Initialization](#9-state-file-initialization)
10. [CLAUDE.md Template](#10-claudemd-template)
11. [State File Migration Strategy](#11-state-file-migration-strategy)

---

## 1. Plugin Manifest

### 1.1 Plugin Layout

VibeCrew follows the standard Claude Code plugin convention. The `.claude-plugin/` directory contains only the manifest. All component directories sit at the plugin root.

```
claude-plugin-vibe-crew/
  .claude-plugin/
    plugin.json                  # Plugin manifest (only file in this directory)
  agents/                        # 5 specialized sub-agent definitions
    session-startup.md
    workflow-orchestrator.md
    stack-scout.md
    builder.md
    verifier.md
  skills/                        # 9 slash command definitions
    setup/
      SKILL.md
    new-project/
      SKILL.md
    plan-features/
      SKILL.md
    new-feature/
      SKILL.md
    run-backlog/
      SKILL.md
    idea/
      SKILL.md
    status/
      SKILL.md
    check/
      SKILL.md
    wrap/
      SKILL.md
  hooks/
    hooks.json                   # Event-to-script routing table
  scripts/                       # 7 bash automation scripts
    session-startup.sh
    compact-reinject.sh
    phase-gate.sh
    protect-data.sh
    restrict-paths.sh
    format-code.sh
    notify.sh
    check-context.sh
    check-deps.sh
    migrate-state.sh
  templates/
    CLAUDE.md.template           # CLAUDE.md template for new projects
    config.json.template         # Default .vibecrew/config.json
    state.json.template          # Default .vibecrew/state.json
  .mcp.json                      # MCP server definitions (Context7, Chrome DevTools)
  settings.json                  # Default permission rules (deny list)
  LICENSE
  CHANGELOG.md
```

### 1.2 plugin.json

```json
{
  "name": "vibe-crew",
  "version": "1.0.0",
  "description": "Autonomous vibe-coding operating system for Claude Code",
  "author": {
    "name": "Fabian Krumbholz",
    "url": "https://github.com/fabkrum"
  },
  "homepage": "https://docs.vibecrew.dev",
  "repository": "https://github.com/fabkrum/vibe-crew",
  "license": "MIT",
  "keywords": ["vibe-coding", "automation", "multi-agent", "sdlc"],
  "agents": "./agents/",
  "skills": "./skills/",
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

### 1.3 Installation Methods

VibeCrew supports three installation methods at four scope levels.

**Method 1: Marketplace install (recommended)**

```bash
claude plugin install vibe-crew@marketplace --scope project
```

**Method 2: Direct placement (symlink for development)**

```bash
ln -s /path/to/claude-plugin-vibe-crew /path/to/project/claude-plugin-vibe-crew
```

**Method 3: CLI install with explicit scope**

```bash
claude plugin install vibe-crew@marketplace --scope user    # all projects
claude plugin install vibe-crew@marketplace --scope project # team-shared
claude plugin install vibe-crew@marketplace --scope local   # gitignored
```

| Scope | Settings File | Use Case |
|-------|--------------|----------|
| `user` | `~/.claude/settings.json` | Personal -- active across all projects |
| `project` | `.claude/settings.json` | Team -- committed to version control |
| `local` | `.claude/settings.local.json` | Personal per-project -- gitignored |
| `managed` | `managed-settings.json` | Enterprise -- read-only, admin-controlled |

After installation, the user runs `/setup` to initialize the `.vibecrew/` runtime directory.

### 1.4 Path References

All internal paths use the `${CLAUDE_PLUGIN_ROOT}` environment variable. This resolves to the absolute path of the plugin directory regardless of installation method or cache location.

```bash
# Correct: works after caching
"${CLAUDE_PLUGIN_ROOT}/scripts/phase-gate.sh"

# Incorrect: breaks after caching
"./scripts/phase-gate.sh"
"/Users/dev/claude-plugin-vibe-crew/scripts/phase-gate.sh"
```

### 1.5 Plugin Caching

When installed via the marketplace, Claude Code copies the plugin to `~/.claude/plugins/cache/vibe-crew/`. All assets must be self-contained (no external references). Version changes in `plugin.json` trigger cache refresh via `claude plugin update vibe-crew`. File permissions are preserved during copy.

---

## 2. Dependencies

### 2.1 Required Dependencies

These must be present for VibeCrew to function. The setup wizard blocks until all are satisfied.

| Dependency | Minimum Version | Purpose | Installation |
|------------|----------------|---------|--------------|
| Claude Code | 2.0+ | Plugin host runtime | `npm install -g @anthropic-ai/claude-code` |
| Git | 2.30+ | Version control, worktrees, PRs | Pre-installed on macOS (Xcode CLT) |
| GitHub CLI (`gh`) | 2.0+ | Automated PR creation, issue management | `brew install gh` |
| Node.js | 18+ | MCP server execution (npx), build tools | `brew install node` |
| `jq` | 1.6+ | JSON parsing in all hook scripts | `brew install jq` |

### 2.2 Recommended Dependencies

These enhance the experience but degrade gracefully when missing. The setup wizard warns but does not block.

| Dependency | Minimum Version | Purpose | Degradation Without It | Installation |
|------------|----------------|---------|----------------------|--------------|
| `terminal-notifier` | 2.0+ | Native macOS notifications for the Interrupt Protocol | Falls back to OSC 9 escape sequences; user may miss permission prompts and task completions | `brew install terminal-notifier` |
| Context7 MCP | latest | Library documentation lookup on demand | Agents fall back to `WebSearch`/`WebFetch`; higher token cost but functional | Auto-installed via `npx -y` |
| Chrome DevTools MCP | latest | Browser debugging and automation for research and visual testing | Stack Scout skips browser-based research; Verifier skips visual regression tests | Auto-installed via `npx -y` |

### 2.3 Dependency Check Script

The `scripts/check-deps.sh` script validates all dependencies. It is called by the `/setup` wizard and can be run standalone.

```bash
#!/usr/bin/env bash
# check-deps.sh -- Validate all VibeCrew dependencies
# Returns JSON with status of each dependency
# Exit 0: all required dependencies met; Exit 1: required dependency missing

set -euo pipefail

PASS=0; FAIL=0; WARN=0; RESULTS=()

check_dep() {
  local name="$1" command="$2" min_version="$3" install_hint="$4" required="$5"
  local version_flag="${6:---version}"

  if ! command -v "$command" &> /dev/null; then
    RESULTS+=("{\"name\":\"$name\",\"status\":\"missing\",\"required\":\"$min_version\",\"install\":\"$install_hint\",\"level\":\"$required\"}")
    [ "$required" = "required" ] && ((FAIL++)) || ((WARN++))
    return
  fi

  local version
  version=$("$command" $version_flag 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
  RESULTS+=("{\"name\":\"$name\",\"status\":\"ok\",\"found\":\"$version\",\"required\":\"$min_version\",\"level\":\"$required\"}")
  ((PASS++))
}

# Required
check_dep "Claude Code" "claude" "2.0.0" "npm install -g @anthropic-ai/claude-code" "required"
check_dep "Git" "git" "2.30.0" "xcode-select --install" "required"
check_dep "GitHub CLI" "gh" "2.0.0" "brew install gh" "required"
check_dep "Node.js" "node" "18.0.0" "brew install node" "required" "--version"
check_dep "jq" "jq" "1.6" "brew install jq" "required"

# Recommended
check_dep "terminal-notifier" "terminal-notifier" "2.0.0" "brew install terminal-notifier" "recommended"

# Check gh auth
GH_AUTH="ok"
command -v gh &>/dev/null && ! gh auth status &>/dev/null && GH_AUTH="not_authenticated" && ((FAIL++))

DEPS_JSON=$(printf '%s,' "${RESULTS[@]}" | sed 's/,$//')
jq -n --argjson deps "[$DEPS_JSON]" --arg gh_auth "$GH_AUTH" \
  --argjson pass "$PASS" --argjson fail "$FAIL" --argjson warn "$WARN" \
  '{dependencies:$deps, gh_authenticated:$gh_auth, summary:{passed:$pass, required_failed:$fail, recommended_missing:$warn, ready:($fail==0)}}'

[ "$FAIL" -gt 0 ] && exit 1 || exit 0
```

---

## 3. MCP Server Configuration

### 3.1 Server Overview

VibeCrew uses two MCP servers. Both are recommended but optional -- the setup wizard checks for them and warns if missing.

| Server | Package | Purpose | Used By |
|--------|---------|---------|---------|
| Context7 | `@upstash/context7-mcp@latest` | Library documentation lookup on demand | Stack Scout, Builder |
| Chrome DevTools | `chrome-devtools-mcp@latest` | Browser debugging and automation for research and visual testing | Stack Scout, Verifier |

### 3.2 .mcp.json Configuration

The plugin ships this `.mcp.json` at its root:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"],
      "env": {},
      "disabled": false
    },
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"],
      "env": {},
      "disabled": false
    }
  }
}
```

**Design decisions:** `npx -y` ensures latest versions are fetched automatically. No API keys are required (Context7 uses Upstash's free tier; Chrome DevTools connects to a local browser instance). Tool approval is managed by agent permissions and `settings.json`, not by MCP server configuration.

### 3.3 Graceful Degradation

If Context7 is missing, agents fall back to `WebSearch`/`WebFetch` (higher token cost). If Chrome DevTools is missing, Stack Scout skips browser-based research and Verifier skips visual regression tests. The setup wizard reports MCP server status and provides installation commands if either is missing.

---

## 4. Hook Configuration

### 4.1 Complete hooks.json

The `hooks/hooks.json` file wires Claude Code lifecycle events to VibeCrew automation scripts.

```json
{
  "description": "VibeCrew hook system -- lifecycle automation for vibe-coding",
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/session-startup.sh",
            "timeout": 10,
            "statusMessage": "Initializing VibeCrew session..."
          }
        ]
      },
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/compact-reinject.sh",
            "timeout": 5,
            "statusMessage": "Re-injecting project state after compaction..."
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/phase-gate.sh",
            "timeout": 5,
            "statusMessage": "Checking phase gate..."
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/restrict-paths.sh",
            "timeout": 5,
            "statusMessage": "Validating write target..."
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/protect-data.sh",
            "timeout": 5,
            "statusMessage": "Validating command safety..."
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format-code.sh",
            "timeout": 30,
            "statusMessage": "Formatting code..."
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh",
            "timeout": 10
          }
        ]
      },
      {
        "matcher": "idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "PostToolUseFailure": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/check-context.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

### 4.2 Hook-to-Script Mapping

| Event | Matcher | Script | Purpose | Can Block? |
|-------|---------|--------|---------|------------|
| SessionStart | `startup` | `session-startup.sh` | Environment check, state detection, run migrations, route to correct workflow | No |
| SessionStart | `compact` | `compact-reinject.sh` | Re-inject `.vibecrew/state.json` summary after context compaction | No |
| PreToolUse | `Write\|Edit` | `phase-gate.sh` | Block source code writes until `foundation.complete` is `true` | Yes (JSON deny) |
| PreToolUse | `Write\|Edit` | `restrict-paths.sh` | Sandbox path validation, block writes outside project root | Yes (JSON deny) |
| PreToolUse | `Bash` | `protect-data.sh` | Block destructive shell commands (rm -rf, force push, DROP TABLE) | Yes (JSON deny) |
| PostToolUse | `Write\|Edit` | `format-code.sh` | Auto-format written files with project formatter | No |
| Notification | `permission_prompt` | `notify.sh` | macOS notification with Warp deep-link when agent is blocked | No |
| Notification | `idle_prompt` | `notify.sh` | macOS notification when task completes | No |
| PostToolUseFailure | (all) | `notify.sh` | macOS notification on critical tool failures | No |
| Stop | (all) | `check-context.sh` | Warn at 60% and 80% context usage | No |

**Changes from pre-review design:**
- **Added:** `SessionStart` with `compact` matcher for context re-injection after compaction events. See [system-overview.md, Section 5.7](system-overview.md#57-context-re-injection-after-compaction).
- **Added:** `restrict-paths.sh` for sandbox path validation.
- **Removed:** `SessionEnd` / `coach-retro.sh` (Performance Coach deferred to v1.1; Vibe Score calculation handled by Verifier during `/wrap`).

### 4.3 Script Permissions

All scripts must be marked executable. The plugin build step ensures this:

```bash
chmod +x "${CLAUDE_PLUGIN_ROOT}/scripts/"*.sh
```

### 4.4 Hook Design Principles

All hooks run as external bash processes at zero token cost. PreToolUse hooks use `hookSpecificOutput` with `permissionDecision` for structured blocking. All scripts use `jq -r '.field // empty'` for defensive JSON parsing. Blocking hooks have 5-second timeouts -- if a script hangs, Claude Code proceeds rather than stalling.

---

## 5. Skills / Commands

VibeCrew exposes nine slash commands, each implemented as a `SKILL.md` file in the `skills/` directory. For full command specifications, invocation control matrix, and SKILL.md examples, see [system-overview.md, Section 6](system-overview.md#6-slash-commands).

### 5.1 Command Summary

| Skill | Invoke | Arguments | Context | Agent | Model-Invocable |
|-------|--------|-----------|---------|-------|-----------------|
| `/setup` | User only | None | Fork (general-purpose) | -- | No |
| `/new-project` | User only | None | Inline | Workflow Orchestrator | No |
| `/plan-features` | User only | None | Inline | Workflow Orchestrator | No |
| `/new-feature` | User only | `"feature name"` | Fork (general-purpose) | Builder | No |
| `/run-backlog` | User only | None | Inline | Workflow Orchestrator | No |
| `/idea` | User only | `"idea text"` | Inline | -- | No |
| `/status` | Both | None | Inline (read-only) | -- | Yes |
| `/check` | Both | None | Fork (Sonnet) | Verifier | Yes |
| `/wrap` | User only | None | Inline | Verifier | No |

### 5.2 Skill Namespacing

Skills are namespaced as `vibe-crew:<skill-name>`. Users can invoke with the short form (`/setup`) or fully qualified form (`/vibe-crew:setup`).

### 5.3 jq Paths Used by Skills

All `jq` field paths in skill scripts must match the canonical schemas in [schemas.md](schemas.md). Key paths used by `/status` and other skills:

| Path | Schema Source | Returns |
|------|-------------|---------|
| `.foundation.complete` | [schemas.md, Section 3](schemas.md#3-statejson) | Boolean (`true`/`false`) |
| `.active_feature.name` | [schemas.md, Section 3](schemas.md#3-statejson) | String or `null` |
| `.active_feature.phase` | [schemas.md, Section 3](schemas.md#3-statejson) | Enum or `null` |
| `.features \| length` | [schemas.md, Section 4](schemas.md#4-backlogjson) | Integer |
| `.features[] \| select(.column == "ready")` | [schemas.md, Section 4](schemas.md#4-backlogjson) | Feature objects |
| `.notifications.enabled` | [schemas.md, Section 2](schemas.md#2-configjson) | Boolean |
| `.cost_limits.session_max_usd` | [schemas.md, Section 2](schemas.md#2-configjson) | Number |

**Important:** The old `/status` skill used `jq -r '.project_foundation.status'`, which is incorrect. The canonical path is `.foundation.complete` (boolean). All skills have been updated to use the correct paths.

---

## 6. Agent Definitions

VibeCrew v1.0 uses 5 specialized sub-agents, consolidated from the original 9-agent design. For full agent specifications including YAML frontmatter, tool permissions, verification loops, and context budgets, see [agents.md](agents.md).

### 6.1 Agent Summary

| # | Agent | Model | Isolation | Primary Role |
|---|-------|-------|-----------|-------------|
| 1 | Session Startup | Haiku | Inline | Environment check, state detection, routing |
| 2 | Workflow Orchestrator | Sonnet | Inline | Routes between Tier 1/Tier 2, coordinates via Agent Teams API |
| 3 | Stack Scout | Sonnet | Worktree | Read-only research agent producing TDRs |
| 4 | Builder | Sonnet | Worktree | Merged UI Designer + Feature Developer: design system, component design, feature implementation |
| 5 | Verifier | Sonnet | Inline | Merged Test Writer + Quality Check + scoring: tests, build, lint, Vibe Score |

**Deferred to v1.1:** Performance Coach (scoring absorbed by Verifier) and Doc Generator (absorbed into `/wrap`).

---

## 7. Setup Wizard

### 7.1 Trigger

The `/setup` skill is the first command a user runs after installing VibeCrew. It is also triggered automatically by the SessionStart hook if `.vibecrew/config.json` does not exist.

### 7.2 Setup Flow

```
Step 1: Check Dependencies
  |
  +--> All required pass? --> Step 2
  +--> Any required fail? --> Show install commands, ask user to install, re-check
  |
Step 2: Configure MCP Servers
  |
  +--> Context7 available? --> Enable
  +--> Context7 missing? --> Warn, recommend (do not block)
  +--> Chrome DevTools available? --> Enable
  +--> Chrome DevTools missing? --> Warn, recommend (do not block)
  |
Step 3: Detect Terminal
  |
  +--> WARP_SESSION_ID set? --> "warp" (deep-links enabled)
  +--> TERM_PROGRAM = iTerm.app? --> "iterm" (standard notifications)
  +--> TERM_PROGRAM = Apple_Terminal? --> "terminal" (standard notifications)
  +--> Otherwise? --> "other" (fallback OSC 9)
  |
Step 4: Create .vibecrew/ Runtime Directory
  |
  +--> Write config.json (preferences from steps 1-3, schema_version: "1.0.0")
  +--> Write state.json (foundation.complete: false, schema_version: "1.0.0")
  +--> Write backlog.json (empty features array, schema_version: "1.0.0")
  +--> Create sessions/, scores/, signals/, locks/ directories
  |
Step 5: Report Readiness
  |
  +--> Print summary table
  +--> Confirm ready or list blockers
  +--> Instruct: "Run /new-project to begin"
```

### 7.3 Example Output

Each step produces a summary table. Missing required dependencies block progress; missing recommended dependencies produce warnings but do not block.

```
VibeCrew Dependency Check
-----------------------
  REQUIRED
  Claude Code      2.3.1     required 2.0+     PASS
  Git              2.44.0    required 2.30+    PASS
  GitHub CLI       2.49.2    required 2.0+     PASS
  Node.js          22.11.0   required 18+      PASS
  jq               1.7.1     required 1.6+     PASS

  RECOMMENDED
  terminal-notifier  2.0.0   recommended       PASS

MCP Server Check: Context7 AVAILABLE, Chrome DevTools AVAILABLE
Terminal Detection: Warp (deep-link notifications enabled)
```

### 7.4 Runtime Directory Creation

The wizard creates the `.vibecrew/` directory. All JSON files are initialized with `schema_version: "1.0.0"` and follow the canonical schemas defined in [schemas.md](schemas.md).

**Files created:**

| File | Schema Reference | Initial State |
|------|-----------------|---------------|
| `.vibecrew/config.json` | [schemas.md, Section 2](schemas.md#2-configjson) | Detected terminal, default notification/cost settings |
| `.vibecrew/state.json` | [schemas.md, Section 3](schemas.md#3-statejson) | `foundation.complete: false`, all artifacts `pending` |
| `.vibecrew/backlog.json` | [schemas.md, Section 4](schemas.md#4-backlogjson) | Empty `features` array, default `columns` definition |

**Directories created:**

| Directory | Purpose | Git-Tracked |
|-----------|---------|-------------|
| `.vibecrew/sessions/` | Per-session metadata | No (gitignored) |
| `.vibecrew/scores/` | Vibe Score breakdowns | Optional |
| `.vibecrew/signals/` | Ephemeral inter-agent signals | No (gitignored) |
| `.vibecrew/locks/` | Advisory lock files | No (gitignored) |

### 7.5 Readiness Report

The final output confirms all checks passed and directs the user to the next step:

```
VibeCrew Setup Complete
=====================
  Dependencies:     5/5 required passed, 1/1 recommended passed
  MCP Servers:      2/2 available
  Terminal:         Warp (deep-links enabled)
  State files:      config.json, state.json, backlog.json (schema v1.0.0)
  Foundation:       INCOMPLETE

  Next step: Run /new-project to create your project foundation.
```

---

## 8. Configuration Format

### 8.1 Schema Reference

The complete `config.json` schema -- including all fields, types, defaults, and descriptions -- is defined in [schemas.md, Section 2: config.json](schemas.md#2-configjson). This section covers only how hook scripts interact with the configuration.

### 8.2 Reading Config in Hook Scripts

All hook scripts read config values from `.vibecrew/config.json` using `jq`:

```bash
# Read notification preference
NOTIFICATIONS_ENABLED=$(jq -r '.notifications.enabled // true' .vibecrew/config.json 2>/dev/null)

if [ "$NOTIFICATIONS_ENABLED" = "false" ]; then
  exit 0  # Skip notification
fi

# Read terminal type
TERMINAL=$(jq -r '.terminal // "other"' .vibecrew/config.json 2>/dev/null)

# Read formatter preference
FORMATTER=$(jq -r '.formatting.formatter // "prettier"' .vibecrew/config.json 2>/dev/null)

# Read cost limits
SESSION_MAX=$(jq -r '.cost_limits.session_max_usd // 5.00' .vibecrew/config.json 2>/dev/null)
```

---

## 9. State File Initialization

### 9.1 Initial State Files

All state files are initialized during `/setup` (Step 4) with `schema_version: "1.0.0"`. Rather than defining schemas inline, this section specifies the initial values that differ from the full schema defaults.

**`.vibecrew/state.json`** -- `foundation.complete: false`, all 5 artifacts set to `"pending"`, `active_feature` fields set to `null`, `git.initialized: false`. See [schemas.md, Section 3](schemas.md#3-statejson) for the complete schema.

**`.vibecrew/backlog.json`** -- Empty `features` array, default 7-column Kanban definition. See [schemas.md, Section 4](schemas.md#4-backlogjson) for the complete schema.

**`.vibecrew/config.json`** -- Detected terminal type, MCP availability, default notification/cost settings. See [schemas.md, Section 2](schemas.md#2-configjson) for the complete schema.

### 9.2 Session Startup State Check

On every session start, the `session-startup.sh` script performs two tasks:

1. **Migration check:** Calls `migrate-state.sh` to verify `schema_version` on all `.vibecrew/*.json` files and apply any pending migrations.
2. **State routing:** Reads `foundation.complete` from `.vibecrew/state.json` and routes the user to the appropriate workflow.

```bash
# session-startup.sh (excerpt)
# Run migrations first
"${CLAUDE_PLUGIN_ROOT}/scripts/migrate-state.sh"

# Route based on foundation state
FOUNDATION=$(jq -r '.foundation.complete // false' .vibecrew/state.json 2>/dev/null)
ACTIVE_FEATURE=$(jq -r '.active_feature.name // empty' .vibecrew/state.json 2>/dev/null)

if [ "$FOUNDATION" = "false" ]; then
  echo "Foundation incomplete. Run /new-project to continue."
elif [ -n "$ACTIVE_FEATURE" ]; then
  PHASE=$(jq -r '.active_feature.phase // "unknown"' .vibecrew/state.json 2>/dev/null)
  echo "Active feature: $ACTIVE_FEATURE (phase: $PHASE)"
else
  echo "Foundation complete. Run /new-feature or /run-backlog to start building."
fi
```

---

## 10. CLAUDE.md Template

### 10.1 When It Is Generated

The CLAUDE.md file is generated during the `/new-project` skill execution, after the Tier 1 foundation artifacts are complete:

1. VISION.md -- project definition and goals
2. design-system.css -- CSS custom properties for all design tokens
3. TDR (Technology Decision Record) -- locked tech stack with justification
4. roadmap.md -- feature backlog with priority ordering

The `/new-project` skill's final step reads these four artifacts and populates the CLAUDE.md template with project-specific values.

### 10.2 Token Budget

The template must stay under **~500 lines**. CLAUDE.md is re-read on every API call, so every line costs tokens on every turn. Enforced by: references over inlining ("Reference: design-system.css"), imperative rules ("Always use X"), and no prose (bullet points only).

### 10.3 Complete CLAUDE.md Template

```markdown
# CLAUDE.md -- {{PROJECT_NAME}}

<!-- pinned -->
<!-- Lines between pinned markers are protected from Performance Coach mutations. -->
<!-- Only the user can edit pinned sections. -->

## Project Overview
{{PROJECT_DESCRIPTION}}
- Target users: {{TARGET_USERS}}
- Key differentiator: {{KEY_DIFFERENTIATOR}}
- Reference: VISION.md

## Tech Stack
- Frontend: {{FRONTEND_FRAMEWORK}}
- Styling: {{STYLING_SOLUTION}}
- Database: {{DATABASE}}
- Auth: {{AUTH_SOLUTION}}
- Hosting: {{HOSTING_PLATFORM}}
- Testing: {{TEST_FRAMEWORK}} + {{E2E_FRAMEWORK}}
- Reference: docs/{{TDR_FILENAME}}

<!-- /pinned -->

## Conventions
- TypeScript strict mode, no `any` types
- Named exports only (no default exports)
- Error boundaries on every route
- All async operations must have loading and error states
- Accessibility: all interactive elements must have labels, all images must have alt text
- If a command fails twice, try a different approach
- Always use Context7 MCP for API documentation lookups
- Never paste documentation into chat -- use Context7 or reference files
- Reference: design-system.css for all tokens (colors, spacing, typography, radii, shadows)
- Never use hardcoded colors, spacing, or typography values
- Always use CSS custom properties from design-system.css
- Mobile-first responsive design (breakpoints defined in design-system.css)
- WCAG AA contrast ratios enforced

## Architecture
- File structure: {{FRAMEWORK_CONVENTIONS}}
- State management: {{STATE_MANAGEMENT}}
- API pattern: {{API_PATTERN}}
- Routing: {{ROUTING_PATTERN}}

## Git Conventions
- Branch naming: feat/{{name}}, fix/{{name}}, chore/{{name}}
- Commit format: conventional commits (feat:, fix:, chore:, docs:, test:)
- Always commit working code -- no broken commits on main
- Never force push. Never rewrite history on shared branches.

## Commands
- /new-feature "name" -- Start a new feature development session
- /check -- Run tests, build, and lint
- /wrap -- End session with coaching, commit, and PR
- /status -- Show project status dashboard
- /idea "text" -- Add a feature idea to the backlog

## Session Learnings
<!-- Populated by Performance Coach after each session (v1.1) -->
<!-- In v1.0, the Verifier proposes suggestions during /wrap -->
<!-- Do not edit manually -- rules are proposed by the coach and approved by you -->
```

### 10.4 The `<!-- pinned -->` Marker

Lines between `<!-- pinned -->` and `<!-- /pinned -->` markers are protected from automatic mutation by the Performance Coach (v1.1). These sections contain project identity and tech stack decisions that should not change without explicit user approval. The Performance Coach can only append rules to the Session Learnings section or modify non-pinned sections.

### 10.6 Template Variables

All `{{VARIABLE}}` placeholders are populated by the `/new-project` skill from two sources:

- **VISION.md** provides: `PROJECT_NAME`, `PROJECT_DESCRIPTION`, `TARGET_USERS`, `KEY_DIFFERENTIATOR`
- **TDR** provides: `FRONTEND_FRAMEWORK`, `STYLING_SOLUTION`, `DATABASE`, `AUTH_SOLUTION`, `HOSTING_PLATFORM`, `TEST_FRAMEWORK`, `E2E_FRAMEWORK`, `FRAMEWORK_CONVENTIONS`, `STATE_MANAGEMENT`, `API_PATTERN`, `ROUTING_PATTERN`
- **Generated:** `TDR_FILENAME` (e.g., `tdr-001-tech-stack.md`)

### 10.7 Session Learnings Section

The "Session Learnings" section is the mutation target for the Performance Coach (v1.1). In v1.0, the Verifier proposes suggestions during `/wrap` but does not automatically write them. Each accumulated rule includes a date and source reference (e.g., `[2026-02-23] Always run npm run build after modifying config files (source: build failure loop in session #4)`) so the user can understand why the rule exists and remove it if stale.

---

## 11. State File Migration Strategy

### 11.1 Overview

All `.vibecrew/` JSON files include a top-level `schema_version` field, initialized to `"1.0.0"` by the setup wizard. The migration strategy is defined in [schemas.md, Section 9](schemas.md#9-migration-strategy). This section covers the operational details of how migrations run during installation and session startup.

### 11.2 Migration Trigger

The `session-startup.sh` script calls `migrate-state.sh` on every session start. This ensures state files are always up to date, even if the user updates the plugin without re-running `/setup`.

```bash
# session-startup.sh calls migrate-state.sh before any state reads
"${CLAUDE_PLUGIN_ROOT}/scripts/migrate-state.sh"
```

### 11.3 Migration Script

```bash
#!/usr/bin/env bash
# migrate-state.sh -- Run state file migrations
# Called by session-startup.sh on every session start
# Reads schema_version from each .vibecrew/*.json file and applies
# sequential migrations if the version is behind CURRENT_VERSION.

set -euo pipefail

CURRENT_VERSION="1.0.0"

version_lt() {
  # Returns 0 (true) if $1 < $2 using semver comparison
  [ "$(printf '%s\n%s' "$1" "$2" | sort -V | head -1)" != "$2" ]
}

migrate_file() {
  local file="$1"

  if [ ! -f "$file" ]; then
    return 0  # File does not exist, skip
  fi

  local version
  version=$(jq -r '.schema_version // "0.0.0"' "$file" 2>/dev/null)

  # Forward-compatibility guard
  if version_lt "$CURRENT_VERSION" "$version"; then
    echo "WARNING: $file has schema_version $version (newer than $CURRENT_VERSION). Skipping." >&2
    return 0
  fi

  if [ "$version" = "$CURRENT_VERSION" ]; then
    return 0  # Up to date
  fi

  # --- Future migrations go here ---
  # if version_lt "$version" "1.1.0"; then
  #   migrate_1_0_to_1_1 "$file"
  # fi
  # if version_lt "$version" "1.2.0"; then
  #   migrate_1_1_to_1_2 "$file"
  # fi

  # Update schema_version to current
  local tmp="${file}.tmp"
  jq --arg v "$CURRENT_VERSION" '.schema_version = $v' "$file" > "$tmp" && mv "$tmp" "$file"

  echo "Migrated $file from $version to $CURRENT_VERSION"
}

# Run on all state files
for f in .vibecrew/config.json .vibecrew/state.json .vibecrew/backlog.json; do
  migrate_file "$f"
done
```

### 11.4 Version Contract

From [schemas.md, Section 9](schemas.md#9-migration-strategy):

| `schema_version` State | Action |
|------------------------|--------|
| Matches current | Use as-is |
| Older than current | Apply sequential migrations |
| Missing entirely | Treat as `"0.0.0"` and migrate |
| Newer than current | Warn user, refuse to modify (forward-compatibility guard) |

### 11.5 Backward Compatibility Rules

1. **Additive changes** (new optional fields) -- minor version bump (1.0.0 to 1.1.0), auto-migrated by adding defaults
2. **Breaking changes** (field renames, structural changes) -- major version bump (1.0.0 to 2.0.0), requires explicit migration function
3. **Signal and lock files** are ephemeral and never migrated

The `/setup` wizard always writes fresh files with the current `schema_version`. Migrations only run on subsequent session starts when the plugin has been updated but the state files were created by an older version.

---

## Installation Verification

Verify the plugin loaded correctly with `claude --debug`. Expected output includes:

```
[plugin] Loading plugin: vibe-crew (1.0.0)
[plugin] Agents: 5 loaded from ./agents/
[plugin] Skills: 9 loaded from ./skills/
[plugin] Hooks: 10 event bindings from ./hooks/hooks.json
[plugin] MCP: context7, chrome-devtools from ./.mcp.json
```

### Troubleshooting

| Symptom | Fix |
|---------|-----|
| Plugin not loading | Validate JSON: `jq . .claude-plugin/plugin.json` |
| Skills not appearing | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Run `chmod +x scripts/*.sh` |
| MCP server fails | Install Node.js 18+: `brew install node` |
| Notifications silent | Install: `brew install terminal-notifier` (recommended) |
| Phase gate not blocking | Run `/setup` to initialize `.vibecrew/state.json` |
| Paths broken after install | Use `${CLAUDE_PLUGIN_ROOT}` for all plugin-internal paths |
| Migration warnings | Update plugin: `claude plugin update vibe-crew` |

---

## Summary

The VibeCrew installation design follows three principles:

1. **Self-contained.** Every asset the plugin needs -- agents, skills, hooks, scripts, templates, MCP configs -- lives inside the plugin directory. No external dependencies beyond the five required tools.

2. **Defensive.** The setup wizard validates every prerequisite before allowing the user to proceed. Hook scripts use defensive JSON parsing. State files carry `schema_version` for safe migration. Config changes preserve user preferences. Graceful degradation when optional components (MCP servers, terminal-notifier) are missing.

3. **Zero-friction for non-technical users.** One command to install (`claude plugin install vibe-crew`). One command to set up (`/setup`). One command to begin (`/new-project`). The wizard guides the user through every step and reports exactly what to do when something is missing.
