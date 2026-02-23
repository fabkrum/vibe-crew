# Research: Claude Code Plugin Architecture

> **Phase 1 Research** | Document 01 | February 2026
>
> This document covers the complete Claude Code plugin architecture -- how to structure a plugin, the hooks system for lifecycle automation, sub-agents for context-isolated work, CLAUDE.md best practices, context window management, permission scoping, slash commands (skills), and MCP server integration. All findings are grounded in the official Claude Code documentation and validated against the VibeOS Architecture Design paper.

---

## Table of Contents

1. [Plugin Structure](#1-plugin-structure)
2. [Hooks System](#2-hooks-system)
3. [Sub-Agents](#3-sub-agents)
4. [Skills and Slash Commands](#4-skills-and-slash-commands)
5. [CLAUDE.md Best Practices](#5-claudemd-best-practices)
6. [Context Window Management](#6-context-window-management)
7. [--allowedTools and Permission Scoping](#7---allowedtools-and-permission-scoping)
8. [MCP Server Integration](#8-mcp-server-integration)
9. [Recommendations for VibeOS](#9-recommendations-for-vibeos)
10. [Sources](#10-sources)

---

## 1. Plugin Structure

### 1.1 What Is a Claude Code Plugin?

A Claude Code plugin is a self-contained directory of components that extends Claude Code with custom functionality. Plugin components include skills, agents, hooks, MCP servers, and LSP servers. Plugins are distributed as local directories, detected automatically by Claude Code when a `.claude-plugin/plugin.json` manifest file exists in the directory tree, and can be installed via CLI commands or plugin marketplaces.

The plugin system follows a convention-over-configuration pattern: if the manifest is omitted, Claude Code auto-discovers components in default locations and derives the plugin name from the directory name. The manifest is only strictly needed when providing metadata or custom component paths.

### 1.2 Directory Structure

A complete plugin follows this canonical layout:

```
my-plugin/
  .claude-plugin/
    plugin.json              # Plugin manifest (only manifest goes here)
  commands/                  # Default command location (legacy; use skills/)
    status.md
    logs.md
  skills/                    # Skill definitions (recommended for new skills)
    code-reviewer/
      SKILL.md
    pdf-processor/
      SKILL.md
      scripts/
  agents/                    # Specialized sub-agent definitions
    security-reviewer.md
    performance-tester.md
  hooks/
    hooks.json               # Hook configuration (event-to-script routing)
    security-hooks.json      # Additional hook configs
  scripts/                   # Hook and utility scripts
    format-code.sh
    phase-gate.sh
    notify.sh
  settings.json              # Default settings for the plugin
  .mcp.json                  # MCP server definitions
  .lsp.json                  # LSP server configurations (optional)
  LICENSE
  CHANGELOG.md
```

**Critical structural rule:** The `.claude-plugin/` directory contains only the `plugin.json` file. All other directories (commands/, agents/, skills/, hooks/) must be at the plugin root, not inside `.claude-plugin/`.

### 1.3 The plugin.json Manifest

The manifest is the entry point that Claude Code reads to identify and load a plugin. If included, `name` is the only required field.

**Complete schema:**

```json
{
  "name": "vibe-os",
  "version": "1.0.0",
  "description": "Autonomous vibe-coding operating system for Claude Code",
  "author": {
    "name": "SpeedKit",
    "email": "hello@speedkit.com",
    "url": "https://github.com/speedkit"
  },
  "homepage": "https://docs.vibeos.dev",
  "repository": "https://github.com/speedkit/vibe-os",
  "license": "MIT",
  "keywords": ["vibe-coding", "automation", "multi-agent"],
  "commands": ["./custom/commands/special.md"],
  "agents": "./agents/",
  "skills": "./skills/",
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json",
  "outputStyles": "./styles/",
  "lspServers": "./.lsp.json"
}
```

**Required fields:**

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Unique identifier (kebab-case, no spaces) |

**Metadata fields:**

| Field | Type | Description |
|-------|------|-------------|
| `version` | string | Semantic version string |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | Author info (`name`, `email`, `url`) |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | License identifier |
| `keywords` | array | Discovery tags |

**Component path fields:**

| Field | Type | Description |
|-------|------|-------------|
| `commands` | string or array | Additional command files/directories |
| `agents` | string or array | Additional agent files |
| `skills` | string or array | Additional skill directories |
| `hooks` | string, array, or object | Hook config paths or inline config |
| `mcpServers` | string, array, or object | MCP config paths or inline config |
| `lspServers` | string, array, or object | LSP server configurations |

**Path behavior:** Custom paths supplement default directories -- they do not replace them. All paths must be relative to the plugin root and start with `./`.

### 1.4 The `${CLAUDE_PLUGIN_ROOT}` Variable

Claude Code provides the `${CLAUDE_PLUGIN_ROOT}` environment variable containing the absolute path to the plugin directory. This must be used in hooks, MCP servers, and scripts to ensure correct paths regardless of installation location:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format-code.sh"
          }
        ]
      }
    ]
  }
}
```

### 1.5 Plugin Installation

Plugins support three installation methods and four installation scopes.

**Installation methods:**

```bash
# Method 1: CLI install from marketplace
claude plugin install vibe-os@my-marketplace

# Method 2: CLI install with scope
claude plugin install vibe-os@my-marketplace --scope project

# Method 3: Direct placement (copy or symlink into project)
cp -r /path/to/claude-plugin-vibe-os/ /path/to/project/
ln -s /path/to/claude-plugin-vibe-os /path/to/project/claude-plugin-vibe-os
```

**Installation scopes:**

| Scope | Settings File | Use Case |
|-------|--------------|----------|
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific plugins, gitignored |
| `managed` | `managed-settings.json` | Managed plugins (read-only, update only) |

**Plugin management commands:**

```bash
claude plugin install <plugin> [--scope user|project|local]
claude plugin uninstall <plugin> [--scope user|project|local]
claude plugin enable <plugin> [--scope user|project|local]
claude plugin disable <plugin> [--scope user|project|local]
claude plugin update <plugin> [--scope user|project|local|managed]
```

### 1.6 Plugin Caching

Marketplace plugins are copied to the user's local plugin cache (`~/.claude/plugins/cache`) rather than used in-place. This has important implications:

- Installed plugins cannot reference files outside their directory via path traversal (e.g., `../shared-utils` will not work after installation)
- Symlinks are honored during the copy process -- a useful workaround for shared dependencies
- Version changes in `plugin.json` trigger cache updates; if you change code but not the version, users will not see changes

### 1.7 Debugging Plugins

```bash
# Show plugin loading details
claude --debug

# Or use /debug within the interactive TUI
/debug
```

Debug output shows which plugins are being loaded, manifest errors, component registration, and MCP server initialization.

**Common issues:**

| Issue | Cause | Solution |
|-------|-------|----------|
| Plugin not loading | Invalid `plugin.json` | Validate JSON syntax |
| Commands not appearing | Wrong directory structure | Ensure `commands/` at root, not in `.claude-plugin/` |
| Hooks not firing | Script not executable | Run `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use the variable for all plugin paths |
| Path errors | Absolute paths used | All paths must be relative and start with `./` |

---

## 2. Hooks System

### 2.1 Overview

Hooks are user-defined shell commands, LLM prompts, or agent verifiers that execute automatically at specific points in Claude Code's lifecycle. They are the primary mechanism for enforcing rules, automating workflows, and controlling agent behavior **without consuming any AI context tokens**.

This zero-token cost is the critical architectural insight: hooks run as external processes, not as part of the AI conversation. They enforce rules deterministically rather than relying on the model to "remember" instructions.

### 2.2 Hook Event Types

Claude Code exposes a comprehensive set of lifecycle events:

| Event | When It Fires | Can Block? |
|-------|--------------|------------|
| **SessionStart** | When a session begins or resumes | No |
| **UserPromptSubmit** | When user submits a prompt, before processing | Yes (exit 2) |
| **PreToolUse** | Before a tool call executes | Yes (exit 2 or JSON deny) |
| **PermissionRequest** | When a permission dialog appears | Yes |
| **PostToolUse** | After a tool call succeeds | No (but can give feedback) |
| **PostToolUseFailure** | After a tool call fails | No |
| **Notification** | When Claude Code sends notifications | No |
| **SubagentStart** | When a subagent is spawned | No |
| **SubagentStop** | When a subagent finishes | Yes |
| **Stop** | When Claude finishes responding | Yes (can force continuation) |
| **TeammateIdle** | When an agent team teammate goes idle | Yes |
| **TaskCompleted** | When a task is marked completed | Yes |
| **ConfigChange** | When config files change during session | Yes |
| **WorktreeCreate** | When a worktree is created | Yes |
| **WorktreeRemove** | When a worktree is removed | No |
| **PreCompact** | Before context compaction | No |
| **SessionEnd** | When a session terminates | No |

### 2.3 hooks.json Configuration Format

The hooks configuration uses a three-level nesting structure: event, matcher group, and hook handler array.

**Full VibeOS hooks configuration:**

```json
{
  "description": "VibeOS hook system -- lifecycle automation for vibe-coding",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/phase-gate.sh"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/protect-data.sh"
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
            "timeout": 30
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
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh"
          }
        ]
      },
      {
        "matcher": "idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh"
          }
        ]
      }
    ],
    "PostToolUseFailure": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/check-context.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/session-startup.sh"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/coach-retro.sh"
          }
        ]
      }
    ]
  }
}
```

### 2.4 Matcher Patterns

Matchers are **regex strings** that filter when hooks fire. Each event type matches on a different field:

| Event | What Matcher Filters | Example Values |
|-------|---------------------|----------------|
| PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest | Tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| SessionStart | How session started | `startup`, `resume`, `clear`, `compact` |
| SessionEnd | Why session ended | `clear`, `logout`, `prompt_input_exit`, `other` |
| Notification | Notification type | `permission_prompt`, `idle_prompt`, `auth_success` |
| SubagentStart, SubagentStop | Agent type | `Bash`, `Explore`, `Plan`, or custom names |
| PreCompact | What triggered compaction | `manual`, `auto` |
| UserPromptSubmit, Stop, TeammateIdle, TaskCompleted, WorktreeCreate, WorktreeRemove | No matcher support | Always fires |

Use `"*"`, `""`, or omit `matcher` entirely to match all occurrences.

### 2.5 Hook Handler Types

Each hook handler can be one of three types:

**Command hooks** (`type: "command"`) -- run a shell command. The script receives JSON input on stdin and communicates results through exit codes and stdout. This is the most common type and what VibeOS uses for all its hooks.

```json
{
  "type": "command",
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/phase-gate.sh",
  "timeout": 600,
  "async": false
}
```

**Prompt hooks** (`type: "prompt"`) -- send a prompt to a fast Claude model for single-turn evaluation. The model returns a yes/no decision as JSON.

```json
{
  "type": "prompt",
  "prompt": "Evaluate if Claude should stop: $ARGUMENTS. Check if all tasks are complete.",
  "model": "haiku",
  "timeout": 30
}
```

**Agent hooks** (`type: "agent"`) -- spawn a subagent that can use tools (Read, Grep, Glob) to verify conditions before returning a decision. Good for complex verification.

```json
{
  "type": "agent",
  "prompt": "Verify that all unit tests pass. Run the test suite and check results. $ARGUMENTS",
  "timeout": 120
}
```

**Common handler fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `type` | Yes | `"command"`, `"prompt"`, or `"agent"` |
| `timeout` | No | Seconds before canceling. Defaults: 600 (command), 30 (prompt), 60 (agent) |
| `statusMessage` | No | Custom spinner message while hook runs |
| `once` | No | If `true`, runs only once per session then is removed (skills only) |

**Command-specific fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `command` | Yes | Shell command to execute |
| `async` | No | If `true`, runs in background without blocking |

### 2.6 JSON Payload (stdin)

When a hook fires, Claude Code passes a JSON payload via stdin. All events receive these common fields:

```json
{
  "session_id": "abc123",
  "transcript_path": "/home/user/.claude/projects/.../transcript.jsonl",
  "cwd": "/home/user/my-project",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse"
}
```

**PreToolUse payload (Write tool example):**

```json
{
  "session_id": "abc123",
  "transcript_path": "...",
  "cwd": "/home/user/my-project",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/home/user/my-project/src/app.tsx",
    "content": "..."
  },
  "tool_use_id": "toolu_01ABC123..."
}
```

**Notification payload:**

```json
{
  "session_id": "abc123",
  "transcript_path": "...",
  "cwd": "/home/user/my-project",
  "permission_mode": "default",
  "hook_event_name": "Notification",
  "message": "Claude needs your permission to use Bash",
  "title": "Permission needed",
  "notification_type": "permission_prompt"
}
```

**SessionEnd payload:**

```json
{
  "session_id": "abc123",
  "transcript_path": "/home/user/.claude/projects/.../transcript.jsonl",
  "cwd": "/home/user/my-project",
  "permission_mode": "default",
  "hook_event_name": "SessionEnd",
  "reason": "other"
}
```

### 2.7 Exit Codes and Decision Control

Exit codes are how command hooks communicate back to Claude Code:

| Exit Code | Meaning | Effect |
|-----------|---------|--------|
| **0** | Success / Allow | Operation proceeds. Stdout parsed for JSON output. |
| **2** | Block | Operation blocked (PreToolUse, UserPromptSubmit, Stop, etc.). Stderr fed to Claude as error. |
| **Other** | Non-blocking error | Stderr shown in verbose mode. Execution continues. |

**JSON decision control (exit 0 + stdout):**

For finer-grained control, exit 0 and print JSON to stdout. The `PreToolUse` event uses `hookSpecificOutput` for richer control:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Source code writes blocked until foundation is complete"
  }
}
```

PreToolUse supports three permission decisions: `"allow"` (bypass permission system), `"deny"` (block the tool call), and `"ask"` (prompt the user to confirm).

**Universal JSON fields:**

| Field | Default | Description |
|-------|---------|-------------|
| `continue` | `true` | If `false`, Claude stops entirely after the hook runs |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | If `true`, hides stdout from verbose mode |
| `systemMessage` | none | Warning message shown to the user |

### 2.8 Example: Phase Gate Script (PreToolUse Blocker)

```bash
#!/usr/bin/env bash
# phase-gate.sh -- Blocks source code writes until foundation is complete
# Hook: PreToolUse (Write|Edit)

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Allow if no file path (edge case)
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Read foundation status
STATE_FILE="$CLAUDE_PROJECT_DIR/.vibeos/state.json"
if [ ! -f "$STATE_FILE" ]; then
  # VibeOS not initialized -- output JSON deny
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "VibeOS not initialized. Run /setup first."
    }
  }'
  exit 0
fi

FOUNDATION_STATUS=$(jq -r '.project_foundation.status // "incomplete"' "$STATE_FILE")

if [ "$FOUNDATION_STATUS" != "complete" ]; then
  # Check if the file is a source code path (not a foundation artifact)
  if echo "$FILE_PATH" | grep -qE '(^|/)(src|app|lib|components|pages|features)/'; then
    jq -n '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: "Phase Gate: Source code writes are blocked. The project foundation is incomplete. Run /new-project to create VISION.md, design system, TDR, roadmap, and CLAUDE.md first."
      }
    }'
    exit 0
  fi
fi

# Allow the write
exit 0
```

### 2.9 Example: Notification Script with Warp Deep-Linking

```bash
#!/usr/bin/env bash
# notify.sh -- Sends native OS notifications on specific events
# Hook: Notification (permission_prompt|idle_prompt), PostToolUseFailure

set -euo pipefail

# Ensure jq is available
if ! command -v jq &> /dev/null; then
  echo "Error: jq is required for VibeOS notifications." >&2
  exit 0
fi

INPUT=$(cat)
TYPE=$(echo "$INPUT" | jq -r '.notification_type // empty')
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Attention required."')
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')

# Handle PostToolUseFailure
if [ "$EVENT" = "PostToolUseFailure" ]; then
  TITLE="Project: Error"
  BODY="A critical tool execution failed. Human intervention required."
else
  # Map notification types to specific alert configurations
  case "$TYPE" in
    "permission_prompt")
      TITLE="Project: Approval"
      BODY="Agent blocked. I need your Y/N approval to proceed."
      ;;
    "idle_prompt")
      TITLE="Project: Success"
      BODY="Complex task execution completed. Awaiting new instructions."
      ;;
    *)
      # Exit silently for non-critical notifications (preserve Deep Work)
      exit 0
      ;;
  esac
fi

# Detect terminal and construct appropriate notification
if [ -n "${WARP_SESSION_ID:-}" ]; then
  # Warp Terminal: use deep-link for tab focus
  DEEP_LINK="warp://session/$WARP_SESSION_ID"
  terminal-notifier \
    -title "$TITLE" \
    -message "$BODY" \
    -sound "Submarine" \
    -execute "open '$DEEP_LINK'"
elif command -v terminal-notifier &> /dev/null; then
  # Other terminals: standard macOS notification
  terminal-notifier \
    -title "$TITLE" \
    -message "$BODY" \
    -sound "Submarine"
else
  # Fallback: OSC 9 escape sequence
  printf '\e]9;%s\a' "$BODY"
fi

exit 0
```

### 2.10 Example: Async PostToolUse Hook for Auto-Testing

Hooks can run in the background using `"async": true`, allowing Claude to continue working while the hook executes. This is ideal for test suites:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/run-tests-async.sh",
            "async": true,
            "timeout": 300
          }
        ]
      }
    ]
  }
}
```

```bash
#!/usr/bin/env bash
# run-tests-async.sh -- Runs tests in background after file writes

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only run tests for source files
if [[ "$FILE_PATH" != *.ts && "$FILE_PATH" != *.tsx && "$FILE_PATH" != *.js && "$FILE_PATH" != *.jsx ]]; then
  exit 0
fi

RESULT=$(npm test 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo "{\"systemMessage\": \"Tests passed after editing $FILE_PATH\"}"
else
  echo "{\"systemMessage\": \"Tests FAILED after editing $FILE_PATH: $RESULT\"}"
fi
```

### 2.11 Hook Locations and Precedence

Hooks can be defined in multiple locations. All matching hooks run in parallel, and identical handlers are deduplicated automatically:

| Location | Scope | Shareable |
|----------|-------|-----------|
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes (bundled with plugin) |
| Skill or agent frontmatter | While component is active | Yes (defined in component) |

Plugin hooks are read-only in the `/hooks` menu.

### 2.12 Prompt and Agent Hooks

Beyond shell commands, hooks can delegate decisions to LLM evaluation. Prompt hooks send a single-turn evaluation; agent hooks spawn a subagent with tool access.

**Prompt hook example (Stop event):**

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Evaluate if Claude should stop: $ARGUMENTS. Check if all tasks are complete, tests pass, and documentation is updated.",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

The LLM must respond with `{"ok": true}` to allow or `{"ok": false, "reason": "..."}` to block.

**Agent hook example (Stop event with test verification):**

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "agent",
            "prompt": "Verify that all unit tests pass. Run the test suite and check the results. $ARGUMENTS",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

Agent hooks can use Read, Grep, Glob, and Bash tools to verify conditions before returning a decision.

**Events supporting all three hook types:** PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, Stop, SubagentStop, TaskCompleted, UserPromptSubmit.

**Events supporting only command hooks:** SessionStart, SessionEnd, Notification, SubagentStart, TeammateIdle, ConfigChange, PreCompact, WorktreeCreate, WorktreeRemove.

### 2.13 SessionStart Environment Variables

SessionStart hooks have unique access to `CLAUDE_ENV_FILE`, which allows persisting environment variables for all subsequent Bash commands in the session:

```bash
#!/usr/bin/env bash
# session-startup.sh -- Set up VibeOS environment

if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo 'export VIBEOS_ACTIVE=true' >> "$CLAUDE_ENV_FILE"
  echo 'export VIBEOS_VERSION=1.0.0' >> "$CLAUDE_ENV_FILE"
fi

# Output additional context for Claude (stdout is added to Claude's context)
echo "VibeOS session initialized. Project state loaded."
exit 0
```

---

## 3. Sub-Agents

### 3.1 What Are Sub-Agents?

Sub-agents are specialized AI assistants that handle specific types of tasks. Each sub-agent runs in its own **separate context window** with a custom system prompt, specific tool access, and independent permissions. When Claude encounters a task matching a sub-agent's description, it can delegate automatically. The sub-agent works independently and returns results.

Sub-agents are the primary mechanism for performing expensive operations (research, testing, documentation) without degrading the main session's context efficiency.

### 3.2 Built-In Sub-Agents

Claude Code includes several built-in sub-agents:

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **Explore** | Haiku | Read-only (no Write/Edit) | Codebase search and analysis |
| **Plan** | Inherits | Read-only (no Write/Edit) | Research for planning mode |
| **General-purpose** | Inherits | All tools | Complex multi-step tasks |
| **Bash** | Inherits | Terminal commands | Separate context for shell work |
| **Claude Code Guide** | Haiku | -- | Answers questions about Claude Code features |

### 3.3 Defining Custom Sub-Agents

Sub-agents are markdown files with YAML frontmatter. Store them in different locations depending on scope:

| Location | Scope | Priority |
|----------|-------|----------|
| `--agents` CLI flag | Current session only | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All your projects | 3 |
| Plugin's `agents/` directory | Where plugin is enabled | 4 (lowest) |

**Full agent definition example (Stack Scout):**

```markdown
---
name: stack-scout
description: Evaluates tech stack options and produces Technology Decision Records. Use proactively for architecture research before any implementation begins.
tools: Read, Glob, Grep, WebSearch, WebFetch, mcp__context7__resolve-library-id, mcp__context7__get-library-docs
disallowedTools: Write, Edit
model: sonnet
maxTurns: 50
---

# Role

You are the Stack Scout, a read-only research agent specialized in technology
evaluation. You analyze project requirements against the current state of
technology, evaluate competitive tradeoffs, and generate definitive
architectural mandates in the form of Technology Decision Records (TDRs).

# Constraints

- You are READ-ONLY. Never create, modify, or delete source files.
- You may only create documentation files in the docs/ directory.
- Always use Context7 MCP before citing any library API or capability.
- Use WebSearch for current benchmarks, community data, and pricing.

# Output

Produce a TDR following this structure:
1. Context -- technical requirements and business goals
2. Options Considered -- comparative analysis of leading options
3. Decision -- the chosen stack with justification
4. Consequences -- projected impact on tokens, complexity, and performance
```

### 3.4 Supported Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier (lowercase, hyphens) |
| `description` | Yes | When Claude should delegate to this sub-agent |
| `tools` | No | Tools the sub-agent can use. Inherits all if omitted |
| `disallowedTools` | No | Tools to deny (removed from inherited list) |
| `model` | No | `sonnet`, `opus`, `haiku`, or `inherit` (default: `inherit`) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before the sub-agent stops |
| `skills` | No | Skills to preload into sub-agent's context at startup |
| `mcpServers` | No | MCP servers available to this sub-agent |
| `hooks` | No | Lifecycle hooks scoped to this sub-agent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as background task |
| `isolation` | No | `worktree` to run in an isolated git worktree |

### 3.5 Context Isolation

This is the most critical property of sub-agents for VibeOS:

- **Parent context is NOT shared** -- the sub-agent starts with a fresh context window
- **Only the task prompt is passed** -- the sub-agent receives the instruction text and any explicitly provided context
- **Only the result returns** -- when the sub-agent completes, only its final output is injected back into the parent's context
- **Token savings are significant** -- estimated 8,000-15,000 tokens saved per project initialization by isolating research

Sub-agents receive only their system prompt plus basic environment details (like working directory), not the full Claude Code system prompt.

### 3.6 Model Selection Strategy for VibeOS

| Agent Role | Model | Reasoning |
|------------|-------|-----------|
| Session Startup | Haiku | Fast, cheap, runs every session |
| Workflow Orchestrator | Sonnet | Routing decisions need moderate reasoning |
| Stack Scout (research) | Sonnet | Architecture decisions need strong reasoning |
| UI Designer | Sonnet | Design work needs creative capability |
| Feature Developer | Sonnet | Core implementation work |
| Test Writer | Sonnet | Testing patterns need understanding |
| Doc Generator | Sonnet | Clear writing ability |
| Performance Coach | Sonnet | Transcript analysis capability |
| Quality Check | Haiku | Simple pass/fail validation, runs frequently |

### 3.7 Restricting Sub-Agent Spawning

When an agent runs as the main thread with `claude --agent`, you can restrict which sub-agents it can spawn using `Task(agent_type)` syntax:

```yaml
---
name: coordinator
description: Coordinates work across specialized agents
tools: Task(worker, researcher), Read, Bash
---
```

To disable specific sub-agents entirely, use the permissions deny list:

```json
{
  "permissions": {
    "deny": ["Task(Explore)", "Task(my-custom-agent)"]
  }
}
```

### 3.8 Persistent Memory

Sub-agents can maintain persistent memory across sessions using the `memory` field:

```yaml
---
name: performance-coach
description: Calculates Vibe Score and proposes CLAUDE.md mutations
memory: project
---
```

| Scope | Location | Use When |
|-------|----------|----------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not committed |

When enabled, the sub-agent's system prompt includes the first 200 lines of `MEMORY.md` in the memory directory, and Read/Write/Edit tools are automatically enabled.

### 3.9 Sub-Agent Limitations

1. **No shared memory** -- sub-agents cannot access the parent's conversation history
2. **No real-time communication** -- the parent waits for the sub-agent to complete (unless background)
3. **File-based handoff** -- primary communication is: parent instructs, sub-agent writes to file, parent reads
4. **Cannot spawn other sub-agents** -- sub-agents cannot nest further sub-agents
5. **Cost accumulation** -- each sub-agent consumes its own tokens

### 3.10 Background Sub-Agents

Sub-agents can run in the background while the user continues working:

- Background sub-agents auto-deny permission prompts not pre-approved
- MCP tools are not available in background sub-agents
- Press **Ctrl+B** to background a running task
- Failed background sub-agents can be resumed in foreground

---

## 4. Skills and Slash Commands

### 4.1 Overview

Skills extend Claude Code's capabilities through `SKILL.md` files. They create `/name` shortcuts that users or Claude can invoke. Custom slash commands (`.claude/commands/`) have been merged into the skills system -- existing command files keep working, but skills are recommended for new development.

Skills follow the Agent Skills open standard (agentskills.io).

### 4.2 Skill Directory Structure

```
my-skill/
  SKILL.md           # Main instructions (required)
  template.md        # Template for Claude to fill in (optional)
  examples/
    sample.md        # Example output (optional)
  scripts/
    validate.sh      # Scripts Claude can execute (optional)
```

### 4.3 Skill Locations

| Location | Path | Applies To |
|----------|------|------------|
| Enterprise | Managed settings | All org users |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Plugin skills use a `plugin-name:skill-name` namespace to avoid conflicts.

### 4.4 SKILL.md Format

```yaml
---
name: new-feature
description: Start a new feature session with branch creation, spec loading, and phase tracking
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
context: fork
agent: general-purpose
---

# New Feature Session

Start a new feature development session.

## Steps

1. Verify project foundation is complete (check .vibeos/state.json)
2. Check for active features in progress
3. Create feature branch: `git checkout -b feat/$ARGUMENTS`
4. Load feature spec from .vibeos/backlog.json if it exists
5. Initialize 5-phase tracker in .vibeos/state.json
6. Present the feature session summary
```

### 4.5 Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | No | Display name (defaults to directory name). Lowercase, hyphens, max 64 chars |
| `description` | Recommended | What the skill does. Claude uses this for auto-invocation |
| `argument-hint` | No | Hint for autocomplete (e.g., `[feature-name]`) |
| `disable-model-invocation` | No | `true` to prevent Claude from auto-loading. Manual `/name` only |
| `user-invocable` | No | `false` to hide from `/` menu (background knowledge only) |
| `allowed-tools` | No | Tools Claude can use without asking permission when skill is active |
| `model` | No | Model to use when skill is active |
| `context` | No | `fork` to run in a forked sub-agent context |
| `agent` | No | Which sub-agent to use when `context: fork` (e.g., `Explore`, `Plan`, custom) |
| `hooks` | No | Hooks scoped to this skill's lifecycle |

### 4.6 String Substitutions

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed when invoking the skill |
| `$ARGUMENTS[N]` | Specific argument by 0-based index |
| `$N` | Shorthand for `$ARGUMENTS[N]` |
| `${CLAUDE_SESSION_ID}` | Current session ID |

### 4.7 Dynamic Context Injection

The `` !`command` `` syntax runs shell commands before the skill content is sent to Claude:

```yaml
---
name: status
description: Show current project status
---

## Current State
- Git status: !`git status --short`
- Active branch: !`git rev-parse --abbrev-ref HEAD`
- Foundation: !`jq -r '.project_foundation.status' .vibeos/state.json 2>/dev/null || echo "not initialized"`
- Active feature: !`jq -r '.active_feature.name // "none"' .vibeos/state.json 2>/dev/null || echo "none"`
```

### 4.8 Invocation Control

| Frontmatter | User Can Invoke | Claude Can Invoke | When Loaded |
|-------------|----------------|-------------------|-------------|
| (default) | Yes | Yes | Description always in context; full skill on invocation |
| `disable-model-invocation: true` | Yes | No | Not in context; loads when user invokes |
| `user-invocable: false` | No | Yes | Description in context; loads when Claude invokes |

### 4.9 VibeOS Skill Mapping

| Slash Command | Skill Name | Invocation | Context |
|--------------|------------|------------|---------|
| `/setup` | `setup` | User only | Fork (general-purpose) |
| `/new-project` | `new-project` | User only | Inline |
| `/plan-features` | `plan-features` | User only | Inline |
| `/new-feature` | `new-feature` | User only | Fork (general-purpose) |
| `/run-backlog` | `run-backlog` | User only | Inline |
| `/idea` | `idea` | User only | Inline |
| `/status` | `status` | Both | Inline (read-only) |
| `/check` | `check` | Both | Fork (Haiku) |
| `/wrap` | `wrap` | User only | Inline |

---

## 5. CLAUDE.md Best Practices

### 5.1 How CLAUDE.md Works

`CLAUDE.md` is a special markdown file that Claude Code reads **automatically at the start of every session**. Content is injected into the system prompt, directly shaping agent behavior. It serves as persistent memory and the project's rules file.

### 5.2 File Hierarchy and Loading Order

| Level | Location | Scope |
|-------|----------|-------|
| User-level | `~/.claude/CLAUDE.md` | All projects |
| Project-level (root) | `<project>/CLAUDE.md` | This project |
| Project-level (nested) | `<project>/src/CLAUDE.md` | Subdirectory-specific |
| Enterprise-level | Managed settings | Organization-wide |

Loading order: User-level first, then project root, then subdirectory. All are concatenated into the system prompt.

### 5.3 Effective Structure

```markdown
# CLAUDE.md -- TravelPack

## Project
Offline-first group travel organizer -- itinerary, budget, coordination in one PWA.

## Tech Stack
- Frontend: Remix 2.x + React 19
- Styling: Tailwind CSS 4.x + design-system.css tokens
- Database: Dexie.js (IndexedDB) for offline storage
- API: Cloudflare Workers
- Testing: Vitest + Testing Library + Playwright

## Architecture
- File structure: Remix conventions (app/routes/, app/components/)
- State management: Dexie.js for local, React context for UI
- API pattern: REST on Cloudflare Workers
- Reference: docs/tdr-001-tech-stack.md

## Design System
- Reference: design-system.css for all tokens
- Never use hardcoded colors, spacing, or typography values
- Always use CSS custom properties

## Conventions
- TypeScript strict mode
- Named exports only (no default exports)
- Error boundaries on every route
- Mobile-first responsive design
- All async operations must have loading states
- If a command fails twice, try a different approach
- Always use Context7 MCP for API documentation lookups

## Commands
- /new-feature "name" -- Start a new feature session
- /check -- Run tests, build, and lint
- /wrap -- End session with coaching and commit

## Session Learnings
[Populated by Performance Coach after each session]
```

### 5.4 Best Practices

1. **Be specific, not vague.** "Use Vitest for testing" beats "write tests." "Named exports only" beats "follow best practices."
2. **Put the most important rules first.** Content near the top receives marginally higher attention.
3. **Keep it under 500 lines.** A bloated CLAUDE.md wastes tokens every session (it is re-read on every API call).
4. **Use imperative language.** "Always use X" and "Never do Y" are clearer than "Consider X."
5. **Reference files, don't inline content.** Write "Reference: design-system.css" instead of pasting the design system.
6. **Separate project-level from user-level.** Personal preferences in `~/.claude/CLAUDE.md`; project rules in the project's `CLAUDE.md`.
7. **Evolve it continuously.** The Performance Coach pattern ensures CLAUDE.md improves with every session.
8. **Review periodically.** Monthly: remove stale rules, consolidate duplicates, promote critical rules to top.

### 5.5 Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Inlining large code blocks | Wastes tokens every session | Reference external files |
| Vague instructions ("be careful") | AI cannot act on vague guidance | Be specific |
| Duplicating documentation | Same info in multiple places | Reference the canonical source |
| Never updating it | Stale rules cause confusion | Review monthly |
| Too many rules | Dilutes important rules | 20-40 high-impact rules, not 200 minor ones |

---

## 6. Context Window Management

### 6.1 Token Types

Claude Code tracks three distinct token metrics:

| Metric | What It Measures | Cost |
|--------|------------------|------|
| `input_tokens` | Total tokens sent to the model | Full price |
| `cache_read_input_tokens` | Tokens from prompt cache | ~10% of input cost (90% discount) |
| `output_tokens` | Tokens generated by the model | Higher than input |

### 6.2 Cache Utilization as Efficiency Signal

The ratio of `cache_read_input_tokens` to total `input_tokens` is a powerful efficiency metric:

- **High (>50%):** Session efficiently reusing cached context. Same CLAUDE.md, files, and conversation prefix served from cache.
- **Low (<20%):** Context churning -- new content pushing old content out of cache. Indicates doc pasting, excessive corrections, or rapid changes.

The Vibe Score uses this: `cache_read_input_tokens < 20%` of `input_tokens` results in -15 points.

### 6.3 Transcript Analysis

Claude Code writes session transcripts to `.claude/sessions/<session-id>.jsonl`. Each line contains usage data:

```json
{
  "type": "assistant",
  "message": {
    "usage": {
      "input_tokens": 15234,
      "cache_read_input_tokens": 8901,
      "output_tokens": 2456
    }
  }
}
```

**Context calculation script:**

```bash
#!/usr/bin/env bash
# calculate-context.sh -- Estimate context usage from transcript

TRANSCRIPT="$1"
if [ -z "$TRANSCRIPT" ]; then
  echo "Usage: calculate-context.sh <transcript.jsonl>"
  exit 1
fi

# Get the latest usage entry
LATEST_INPUT=$(tail -1 "$TRANSCRIPT" | jq '.message.usage.input_tokens // 0')
LATEST_CACHE=$(tail -1 "$TRANSCRIPT" | jq '.message.usage.cache_read_input_tokens // 0')

# Claude Sonnet 4 has a 200k token context window
MAX_CONTEXT=200000
USAGE_PERCENT=$((LATEST_INPUT * 100 / MAX_CONTEXT))

if [ "$LATEST_INPUT" -gt 0 ]; then
  CACHE_PERCENT=$((LATEST_CACHE * 100 / LATEST_INPUT))
else
  CACHE_PERCENT=0
fi

echo "Context usage: ${USAGE_PERCENT}% (${LATEST_INPUT}/${MAX_CONTEXT} tokens)"
echo "Cache utilization: ${CACHE_PERCENT}%"

if [ "$USAGE_PERCENT" -ge 80 ]; then
  echo "WARNING: High risk of context exhaustion. Run /wrap now."
elif [ "$USAGE_PERCENT" -ge 60 ]; then
  echo "NOTICE: Consider wrapping up soon."
fi
```

### 6.4 Strategies for Staying Under 50%

| Strategy | Token Savings | Implementation |
|----------|---------------|----------------|
| Use MCP servers (Context7) instead of pasting docs | ~1,500 tokens per lookup | Configure Context7; add CLAUDE.md rule |
| Isolate research in sub-agents | 8,000-15,000 tokens per research session | Spawn Stack Scout as isolated sub-agent |
| Write clear initial prompts | ~500 tokens per avoided correction | Spend 30 seconds writing precise instructions |
| Reference files instead of inlining | Hundreds to thousands | "Read design-system.css" instead of pasting |
| Wrap at 60-80% | Prevents context exhaustion | Use Stop hook for warnings |
| Keep CLAUDE.md concise | Saves tokens on every turn | CLAUDE.md is re-read on every API call |
| Use Haiku for routine tasks | Lower token costs | Session startup, quality checks |
| Avoid tool loops | ~1,000 tokens per loop | CLAUDE.md rule: "If a command fails twice, try a different approach" |

### 6.5 Stop Hook for Context Warnings

The `Stop` hook fires when Claude finishes responding, making it suitable for context checks. Combined with a prompt hook, it can evaluate whether to let Claude stop or force continuation:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/check-context.sh"
          }
        ]
      }
    ]
  }
}
```

**Important:** The `stop_hook_active` field in the Stop input indicates whether Claude Code is already continuing due to a Stop hook. Check this value to prevent infinite loops.

### 6.6 Auto-Compaction

Sub-agents support automatic compaction at approximately 95% capacity. The `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` environment variable can trigger compaction earlier (e.g., set to `50` for 50%).

---

## 7. --allowedTools and Permission Scoping

### 7.1 Overview

The `--allowedTools` flag and the permissions system in `settings.json` restrict which tools a Claude Code agent can use. This implements the principle of least privilege: agents should only have access to the tools they need.

### 7.2 Available Tool Names

| Tool Name | Capability |
|-----------|------------|
| `Read` | Read file contents |
| `Write` | Create or overwrite files |
| `Edit` | Modify specific parts of files |
| `Bash` | Execute shell commands |
| `Glob` | Search for files by pattern |
| `Grep` | Search file contents |
| `WebSearch` | Search the web |
| `WebFetch` | Fetch content from URLs |
| `Task` | Spawn sub-agents |
| `Task(agent-name)` | Spawn specific sub-agent types only |
| `mcp__<server>__<tool>` | MCP server tools |

### 7.3 Permission Configuration

**Project-level settings (`.claude/settings.json`):**

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Write",
      "Edit",
      "Bash",
      "mcp__context7__resolve-library-id",
      "mcp__context7__get-library-docs"
    ],
    "deny": [
      "Bash(rm -rf /)",
      "Bash(rm -rf ~)",
      "Bash(sudo *)",
      "Bash(git push --force*)",
      "Bash(git reset --hard*)",
      "Bash(chmod 777 *)",
      "Bash(DROP TABLE*)",
      "Bash(DROP DATABASE*)"
    ]
  }
}
```

### 7.4 Permission Precedence

1. **Enterprise/managed settings** (highest)
2. **Project-level settings** (`.claude/settings.json`)
3. **User-level settings** (`~/.claude/settings.json`)
4. **CLI flags** (`--allowedTools`, `--disallowedTools`)

Deny rules at any level override allow rules at lower levels.

### 7.5 Agent-Specific Tool Scoping

| Agent Role | Recommended allowedTools |
|------------|-------------------------|
| Stack Scout (read-only research) | `Read, Glob, Grep, WebSearch, WebFetch, mcp__context7__*` |
| Feature Developer (implementation) | `Read, Write, Edit, Bash, Glob, Grep, mcp__context7__*` |
| Test Writer | `Read, Write, Edit, Bash, Glob, Grep` |
| Quality Check (validation) | `Read, Bash, Glob, Grep` |
| Doc Generator | `Read, Write, Edit, Glob, Grep` |
| UI Designer | `Read, Write, Edit, Glob, Grep, mcp__context7__*` |

---

## 8. MCP Server Integration

### 8.1 What Are MCP Servers?

MCP (Model Context Protocol) servers are external tool providers that extend Claude Code's capabilities. They run as separate processes and expose tools that Claude Code can call during a session. MCP servers allow agents to fetch external data on-demand rather than requiring data to be pasted into the conversation.

### 8.2 Configuration Format

MCP servers are configured in `.mcp.json` at the plugin root or the project level:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"],
      "env": {},
      "disabled": false
    },
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-puppeteer"],
      "env": {},
      "disabled": false
    }
  }
}
```

### 8.3 Configuration Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `command` | string | Yes | Executable to run (e.g., `npx`, `node`, `python`) |
| `args` | string[] | Yes | Command-line arguments |
| `env` | object | No | Environment variables for the server process |
| `disabled` | boolean | No | `true` to disable without removing config |
| `alwaysAllow` | string[] | No | Tool names that skip user approval |
| `cwd` | string | No | Working directory for the server |

### 8.4 Configuration Locations

| Level | Location | Scope |
|-------|----------|-------|
| Plugin-level | `<plugin>/.mcp.json` | Active when plugin is loaded |
| Project-level | `.claude/mcp-servers.json` | Active for this project |
| User-level | `~/.claude/mcp-servers.json` | Active for all projects |

All levels are merged. More specific levels take precedence.

### 8.5 Key MCP Servers for VibeOS

#### Context7 -- Library Documentation

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

**Tools exposed:**
- `mcp__context7__resolve-library-id` -- Find a library's Context7 ID
- `mcp__context7__get-library-docs` -- Fetch current documentation

**Token savings:** ~1,500 tokens per API lookup vs. pasting documentation.

#### Puppeteer -- Browser Automation

```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-puppeteer"]
    }
  }
}
```

**Tools exposed:**
- `mcp__puppeteer__navigate` -- Navigate to a URL
- `mcp__puppeteer__screenshot` -- Take a screenshot
- `mcp__puppeteer__click` -- Click an element
- `mcp__puppeteer__fill` -- Fill form fields
- `mcp__puppeteer__evaluate` -- Execute JavaScript in the page

**Use cases:** Web research (Stack Scout), visual regression testing, screenshot verification.

### 8.6 Referencing MCP Tools in Agent Definitions

When defining agents, explicitly list which MCP tools they can access:

```yaml
---
name: stack-scout
model: sonnet
tools:
  - Read
  - Glob
  - Grep
  - WebSearch
  - WebFetch
  - mcp__context7__resolve-library-id
  - mcp__context7__get-library-docs
  - mcp__puppeteer__navigate
  - mcp__puppeteer__screenshot
---
```

### 8.7 MCP Tool Matching in Hooks

MCP tools can be matched in hooks using the `mcp__<server>__<tool>` naming pattern:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "mcp__memory__.*",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Memory operation initiated' >> ~/mcp-operations.log"
          }
        ]
      }
    ]
  }
}
```

### 8.8 Security Considerations

- MCP servers run as separate processes with their own permissions
- `alwaysAllow` bypasses user approval -- use cautiously
- Puppeteer has significant capabilities (arbitrary browsing, JS execution) -- restrict to research agents only
- MCP server processes persist for the session duration: started on first use, stopped at session end
- Background sub-agents do not have access to MCP tools

---

## 9. Recommendations for VibeOS

Based on this research, here are the specific recommendations for implementing the VibeOS plugin.

### 9.1 Plugin Structure

Adopt the standard plugin layout with all components at the root level. Use `${CLAUDE_PLUGIN_ROOT}` for all path references in hooks and scripts. Set up the manifest with proper metadata for marketplace distribution:

```json
{
  "name": "vibe-os",
  "version": "1.0.0",
  "description": "Autonomous vibe-coding operating system for Claude Code",
  "author": {
    "name": "SpeedKit"
  },
  "keywords": ["vibe-coding", "automation", "multi-agent", "sdlc"],
  "agents": "./agents/",
  "skills": "./skills/",
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

### 9.2 Hook Implementation Priority

| Priority | Hook | Script | Purpose |
|----------|------|--------|---------|
| 1 | PreToolUse (Write\|Edit) | `phase-gate.sh` | Block source code writes until foundation complete |
| 2 | PreToolUse (Bash) | `protect-data.sh` | Block dangerous shell commands |
| 3 | Notification (permission_prompt\|idle_prompt) | `notify.sh` | Interrupt Protocol with Warp deep-links |
| 4 | PostToolUseFailure | `notify.sh` | Error notifications |
| 5 | PostToolUse (Write\|Edit) | `format-code.sh` | Auto-format written files |
| 6 | SessionStart (startup) | `session-startup.sh` | Environment check, state detection |
| 7 | Stop | `check-context.sh` | Context usage warnings |
| 8 | SessionEnd | `coach-retro.sh` | Performance Coach retrospective |

### 9.3 Use the New Hook JSON Decision Format

The official documentation has shifted from exit-code-based blocking to JSON decision control for `PreToolUse`. Use `hookSpecificOutput` with `permissionDecision` instead of exit code 2:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Phase Gate: Source code writes blocked."
  }
}
```

This provides clearer error messages and more granular control (allow/deny/ask).

### 9.4 Migrate Commands to Skills

The official documentation recommends skills over the legacy commands format. Each VibeOS slash command should be a `SKILL.md` file in the `skills/` directory with proper frontmatter:

- All VibeOS commands should use `disable-model-invocation: true` since they are user-triggered workflows
- Use `context: fork` for expensive operations (`/setup`, `/new-feature`, `/check`)
- Use `$ARGUMENTS` for parameterized commands (`/new-feature`, `/idea`)
- Use `` !`command` `` syntax for dynamic status injection in `/status`

### 9.5 Agent Architecture

Define all 9 agents as markdown files in `agents/` with explicit tool restrictions:

- **Read-only agents** (Stack Scout): use `disallowedTools: Write, Edit` rather than an allowlist, so they automatically inherit new read tools
- **Quality Check agent**: use `model: haiku` for fast, cheap execution
- **Performance Coach**: use `memory: project` for persistent cross-session learning
- Use agent `description` fields that include "use proactively" where auto-delegation is desired

### 9.6 Leverage Prompt/Agent Hooks for Quality Gates

Use prompt hooks for the Stop event to enforce quality gates before Claude considers a feature complete:

```json
{
  "type": "prompt",
  "prompt": "Evaluate if Claude should stop. Check: 1) All acceptance criteria met, 2) Tests passing, 3) No lint errors. Context: $ARGUMENTS",
  "timeout": 30
}
```

For more thorough validation, use agent hooks that can actually run tests and inspect files.

### 9.7 Context Window Discipline

- Use sub-agents for all research operations (Stack Scout isolation saves 8,000-15,000 tokens)
- Configure Context7 MCP and add a CLAUDE.md rule: "Always use Context7 for API documentation"
- Use Haiku for Session Startup and Quality Check agents
- Implement the Stop hook for 60% and 80% context warnings
- Leverage `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` for sub-agents doing heavy research

### 9.8 Safety Layer

Implement a dual-safety approach:

1. **settings.json deny rules** for simple pattern blocking (no token cost, declarative)
2. **PreToolUse hooks** for complex validation logic (e.g., phase gate checking `.vibeos/state.json`)

The settings.json approach is simpler but less flexible. Hooks provide custom error messages and conditional logic. Use both together.

### 9.9 Gaps and Risks

1. **Plugin manifest format evolution** -- design for graceful degradation if fields change
2. **Hook payload schema** -- use defensive parsing (`jq -r '.field // empty'`) for missing fields
3. **Stop hook infinite loops** -- always check `stop_hook_active` to prevent runaway hooks
4. **Background sub-agent MCP limitation** -- MCP tools are not available in background sub-agents; Stack Scout must run in foreground
5. **Notification deep-link scope** -- Warp deep-linking requires `WARP_SESSION_ID`; gracefully degrade for other terminals
6. **Skill character budget** -- many skills may exceed the 2% context budget; monitor with `/context`

---

## 10. Sources

### Official Documentation
- **Plugins reference** -- Claude Code Docs: https://code.claude.com/docs/en/plugins-reference
- **Create plugins** -- Claude Code Docs: https://code.claude.com/docs/en/plugins
- **Hooks reference** -- Claude Code Docs: https://code.claude.com/docs/en/hooks
- **Automate workflows with hooks** -- Claude Code Docs: https://code.claude.com/docs/en/hooks-guide
- **Create custom subagents** -- Claude Code Docs: https://code.claude.com/docs/en/sub-agents
- **Extend Claude with skills** -- Claude Code Docs: https://code.claude.com/docs/en/skills
- **Manage costs effectively** -- Claude Code Docs: https://code.claude.com/docs/en/costs
- **Plugin marketplaces** -- Claude Code Docs: https://code.claude.com/docs/en/plugin-marketplaces
- **Discover and install plugins** -- Claude Code Docs: https://code.claude.com/docs/en/discover-plugins
- **MCP integration** -- Claude Code Docs: https://code.claude.com/docs/en/mcp
- **Memory (CLAUDE.md)** -- Claude Code Docs: https://code.claude.com/docs/en/memory
- **Settings** -- Claude Code Docs: https://code.claude.com/docs/en/settings
- **Permissions** -- Claude Code Docs: https://code.claude.com/docs/en/permissions

### Community References (cited in the VibeOS Architecture Design paper)
- Pedro H. C. Sant'Anna, "My Claude Code Setup": https://psantanna.com/claude-code-my-workflow/workflow-guide.html
- alexop.dev, "Claude Code Notifications: Get Alerts When Tasks Finish": https://alexop.dev/posts/claude-code-notification-hooks/
- disler/claude-code-hooks-mastery -- GitHub: https://github.com/disler/claude-code-hooks-mastery
- Codelynx, "How to Calculate Your Claude Code Context Usage": https://codelynx.dev/posts/calculate-claude-code-context
- Reddit r/Anthropic, "Finally got observability working for Claude Code": https://www.reddit.com/r/Anthropic/comments/1qd1rto/
- GitHub anthropics/claude-code Issue #5531, "Make transcript path more globally available": https://github.com/anthropics/claude-code/issues/5531
- Dennis Adolfi, "AI generated Architecture Decision Records": https://adolfi.dev/blog/ai-generated-adr/
- me2resh/agent-decision-record -- GitHub: https://github.com/me2resh/agent-decision-record
- wyattjoh/claude-code-notification -- GitHub: https://github.com/wyattjoh/claude-code-notification

### Project-Local References
- VibeOS Architecture Design paper (`docs/VibeOS_ Claude Plugin Architecture Design.pdf`) -- 19-page technical paper with 34 cited sources
- VibeOS Complete Guide (`docs/vibeos-guide-complete.md`) -- Full user-facing guide covering all slash commands, hook system, agent architecture, and Vibe Score system
- Agent Skills open standard: https://agentskills.io
