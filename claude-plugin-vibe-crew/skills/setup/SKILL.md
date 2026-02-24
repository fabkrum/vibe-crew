---
name: setup
description: First-run installation wizard for VibeCrew
disable-model-invocation: true
---

# VibeCrew Setup Wizard

You are the VibeCrew Setup Wizard. Walk the user through first-run installation, verifying all prerequisites and initializing the VibeCrew runtime state directory. Execute each step sequentially and report results clearly.

## Step 1: Check Prerequisites

Run the dependency checker script:

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-deps.sh"
```

Parse the output. For each dependency:
- If present, report the version found.
- If missing, provide the exact installation command:
  - **Git**: `brew install git` (macOS) or `sudo apt install git` (Linux)
  - **GitHub CLI**: `brew install gh` (macOS) or see https://cli.github.com
  - **Node.js 18+**: `brew install node@18` or use `nvm install 18`
  - **jq**: `brew install jq` (macOS) or `sudo apt install jq` (Linux)
  - **terminal-notifier** (macOS only): `brew install terminal-notifier`

If any required dependency (Git, GitHub CLI, Node.js, jq) is missing, list all missing dependencies and stop. Tell the user: "Install the missing dependencies above and run /setup again."

Do NOT proceed past this step if required dependencies are missing.

## Step 2: Detect Terminal

Determine which terminal the user is running by checking environment variables:

```bash
if [ -n "$WARP_SESSION_ID" ]; then
  echo "warp"
elif [ "$TERM_PROGRAM" = "iTerm.app" ]; then
  echo "iterm"
elif [ "$TERM_PROGRAM" = "vscode" ]; then
  echo "vscode"
elif [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
  echo "terminal"
else
  echo "unknown"
fi
```

Report the detected terminal. If Warp is detected, note that deep-link notifications will be enabled via `warp://session/<id>` URIs.

## Step 3: Test Notifications

Run the notification test:

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh" test
```

If the test succeeds, confirm notifications are working. If it fails (e.g., `terminal-notifier` not installed on macOS), warn the user but do NOT block setup. Notifications are optional.

## Step 4: Check MCP Server Availability

Check for Context7 and Chrome DevTools MCP servers. Read the MCP configuration:

```bash
cat "${CLAUDE_PLUGIN_ROOT}/mcp-servers.json" 2>/dev/null
```

For each MCP server:
- **Context7**: Report whether configured. If available, note: "Documentation lookups will use Context7 instead of pasting docs into context."
- **Chrome DevTools**: Report whether configured. If available, note: "Browser debugging and automation available for UI testing."

If neither is configured, note: "MCP servers are optional but strongly recommended. See the VibeCrew guide for configuration instructions."

## Step 5: Initialize .vibecrew/ Directory

First, check if `.vibecrew/` already exists:

```bash
test -d ".vibecrew" && echo "exists" || echo "missing"
```

- If it **already exists**, ask the user: "A .vibecrew/ directory already exists. Do you want to reinitialize? This will reset all state. (yes/no)"
  - If the user says yes, proceed with initialization.
  - If the user says no, skip to Step 6 and use the existing configuration.
- If it does **not exist**, proceed with initialization.

Run the initialization script:

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/init-vibecrew-state.sh"
```

This script creates the `.vibecrew/` directory structure with `config.json`, `state.json`, `backlog.json`, and subdirectories for `sessions/`, `scores/`, and `releases/`.

## Step 6: Verify Initialization

Read the generated configuration to confirm it was written correctly:

```bash
cat .vibecrew/config.json
```

Verify the file contains valid JSON with at minimum:
- `terminal` field matching the detected terminal
- `notifications.enabled` field
- `created_at` timestamp

If the file is missing or malformed, report the error and suggest the user check file permissions.

## Step 7: Print Summary

Print a clear summary of everything that was configured:

```
VibeCrew Setup Complete
=====================

Prerequisites:
  Git:              v2.x.x
  GitHub CLI:       v2.x.x
  Node.js:          v18.x.x
  jq:               v1.x

Terminal:           <detected terminal>
Notifications:     <enabled/disabled>
MCP - Context7:    <available/not configured>
MCP - Chrome DevTools: <available/not configured>
State directory:   .vibecrew/ <created/existing>

Setup complete! Run /new-project to start building your foundation.
```

## Rules

- Execute steps sequentially. Do NOT skip ahead.
- Report results clearly after each step with pass/fail indicators.
- If a required dependency is missing, stop and provide installation instructions. Do not continue.
- If an optional component is missing (notifications, MCP servers), warn but continue.
- Never modify any project source files during setup.
- Use `${CLAUDE_PLUGIN_ROOT}` for all references to plugin scripts and templates.
