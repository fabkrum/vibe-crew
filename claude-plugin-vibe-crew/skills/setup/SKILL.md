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

Parse the JSON output. For each dependency:
- If present, report the version found.
- If missing and **required** (Git, Node.js, jq), flag it as blocking.
- If missing and **optional** (GitHub CLI, terminal-notifier), flag it as a warning.

### Auto-install flow

If any **required** dependency is missing, offer the user a choice:

> "Some required dependencies are missing. Want me to install them?"
> 1. **Install now** — I'll run the install commands for you
> 2. **Show commands** — I'll list the commands so you can run them yourself

If the user chooses "Install now":
1. Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-deps.sh" --auto-install` to get the exact install commands
2. Execute each install command from the `install_commands` array via Bash
3. Re-run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-deps.sh"` to verify
4. If verification passes, continue to Step 2
5. If verification still fails, show the remaining missing deps and stop

If the user chooses "Show commands", display the install commands and stop:
"Install the missing dependencies above and run /setup again."

If only **optional** dependencies are missing, warn but continue:
- **GitHub CLI** missing: "PR automation (/review, gh pr create) will be unavailable."
- **terminal-notifier** missing: "Desktop notifications will be disabled."

### GitHub CLI auth check

If `gh` is installed, check the `gh_authenticated` field in the output:
- If `"not_authenticated"`: warn "GitHub CLI is installed but not authenticated. PR features won't work until you run `gh auth login`." Do NOT block setup.
- If `"ok"`: report as authenticated.

Do NOT proceed past this step if **required** dependencies (Git, Node.js, jq) are missing.

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

## Step 4: Check MCP Server Health

Run the MCP health check script:

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-health.sh"
```

Parse the JSON output and display a results table:

```
MCP Servers
===========
Server            Status
------            ------
context7          ok
chrome-devtools   ok
playwright        failed — <error message>
```

Also show disabled servers from the plugin config for reference:

```bash
jq -r '.mcpServers | to_entries[] | select(.value.disabled == true) | .key' "${CLAUDE_PLUGIN_ROOT}/.mcp.json"
```

For each result:
- **ok**: Server started successfully and is ready to use.
- **failed**: Warn but do NOT block. Note: "Server X failed to start — features using it will fall back to alternatives."

If no servers are enabled, note: "MCP servers are optional but recommended. Context7 and Playwright are enabled by default."

For disabled servers:
- "Disabled servers are auto-enabled when matching technologies are selected in your TDR."
- "To manually enable: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/enable-mcp-server.sh <server-name> enable`"

## Step 5: Configure Claude Command

Ask the user which Claude Code command to use for this project:

> "Which Claude Code command should be used for this project?"
> 1. **claude** — Default (no profile flag)
> 2. **claude-p** — Personal/private profile
> 3. **claude-w** — Work profile
> 4. **Custom** — Enter a custom command

Store the answer as the `CLAUDE_COMMAND` environment variable. This value is written to `.vibecrew/config.json` and used in the Warp launch configuration. If the user skips this step or presses Enter, default to `claude`.

## Step 6: Initialize .vibecrew/ Directory

First, check if `.vibecrew/` already exists:

```bash
test -d ".vibecrew" && echo "exists" || echo "missing"
```

- If it **already exists**, ask the user: "A .vibecrew/ directory already exists. Do you want to reinitialize? This will reset all state. (yes/no)"
  - If the user says yes, proceed with initialization.
  - If the user says no, skip to Step 7 and use the existing configuration.
- If it does **not exist**, proceed with initialization.

Run the initialization script, passing the Claude command from Step 5:

```
CLAUDE_COMMAND="<value from step 5>" bash "${CLAUDE_PLUGIN_ROOT}/scripts/init-vibecrew-state.sh"
```

This script creates the `.vibecrew/` directory structure with `config.json`, `state.json`, `backlog.json`, and subdirectories for `sessions/`, `scores/`, `signals/`, `locks/`, `architecture/`, `releases/`, `handoffs/`, and `workflows/`. If running in Warp, it also generates a launch configuration at `~/.warp/launch_configurations/<project-name>.yaml` using the configured Claude command.

## Step 7: Git Repository Setup

Set up git version control and optionally create a remote repository.

### 7.1 Detect existing git state

```bash
git rev-parse --is-inside-work-tree 2>/dev/null && echo "has_git" || echo "no_git"
git remote get-url origin 2>/dev/null || echo "no_remote"
```

### 7.2 Existing repo WITH remote

If the project already has a git remote, auto-detect the provider and store it. No questions needed.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/setup-git-repo.sh" --provider local
```

Parse the JSON output. If `action` is `"detected_existing"`, report:

> Git repository detected: **{provider}** ({repo}). Provider stored in config.

Skip to Step 8.

### 7.3 No remote (or no repo)

Ask the user:

> "Where would you like to host your code?"
> 1. **GitHub** — Create a GitHub repository (requires `gh` CLI)
> 2. **GitLab** — Create a GitLab repository (requires `glab` CLI)
> 3. **Local only** — Git version control without a remote

If the user chooses **GitHub** or **GitLab**:
- Ask visibility: "Should the repository be **private** (recommended) or **public**?"
- Ask repo name: "Repository name?" (default: current directory name)
- Run:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/setup-git-repo.sh" --provider <github|gitlab> --visibility <public|private> --repo-name "<name>"
```

If the user chooses **Local only**:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/setup-git-repo.sh" --provider local
```

### 7.4 Handle errors

Parse the JSON output. If `status` is `"error"`:
- If `check` is `"gh_installed"` or `"glab_installed"`: "The CLI is not installed. Would you like to continue with **local only** instead?"
- If `check` is `"gh_authenticated"` or `"glab_authenticated"`: "The CLI is not authenticated. Run `gh auth login` / `glab auth login` first, or continue with **local only**."
- If `check` is `"repo_create"`: "Repository creation failed. Would you like to continue with **local only**?"

On fallback to local, run:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/setup-git-repo.sh" --provider local
```

### 7.5 Report result

Report the git setup result:

```
Git:               initialized (local)
  — or —
Git:               initialized (github: owner/repo)
  — or —
Git:               detected (github: owner/repo)
```

## Step 8: Verify Initialization

Read the generated configuration to confirm it was written correctly:

```bash
cat .vibecrew/config.json
```

Verify the file contains valid JSON with at minimum:
- `terminal` field matching the detected terminal
- `notifications.enabled` field
- `created_at` timestamp
- `git_provider` field (should no longer be `null`)

If the file is missing or malformed, report the error and suggest the user check file permissions.

## Step 9: Print Summary

Print a clear summary of everything that was configured:

```
VibeCrew Setup Complete
=====================

Prerequisites:
  Git:              v2.x.x
  Node.js:          v18.x.x
  jq:               v1.x

Optional:
  GitHub CLI:       v2.x.x (or "not installed — PR automation disabled")
  terminal-notifier: installed (or "not installed — desktop notifications disabled")

Terminal:           <detected terminal>
Claude command:    <configured command>
Notifications:     <enabled/disabled>
MCP Servers:       <N healthy / M enabled>
Git:               <initialized (local) / initialized (github: owner/repo) / detected (github: owner/repo)>
State directory:   .vibecrew/ <created/existing>
Warp launch config: <created/existing/skipped (not Warp)>

Setup complete! Run /new-project to start building your foundation.
```

If optional dependencies are missing, append a note:

```
Optional features not available:
  - PR automation (install: brew install gh)
  - Desktop notifications (install: brew install terminal-notifier)
```

## Step 10: Launch Dashboard

After the summary, check if the docs site has been scaffolded and launch the dashboard:

```bash
if [[ -f "$PROJECT_ROOT/docs/package.json" ]]; then
  echo "Launching Vibe Dashboard..."
  nohup bash "${CLAUDE_PLUGIN_ROOT}/scripts/start-dashboard.sh" --no-open &>/dev/null &
  sleep 2
  DASH_PORT=$(jq -r '.port // 5173' "$PROJECT_ROOT/.vibecrew/dashboard.pid" 2>/dev/null || echo "5173")
  echo "Dashboard: http://localhost:$DASH_PORT"
fi
```

If the docs site does not exist yet (first setup before `/new-project`), skip this step. The dashboard will be launched after the docs site is scaffolded during project creation.

## Step 11: Prompt for Profile

After the summary, check if the user has completed the profile interview:

```bash
jq -r '.user_profile.interview_completed // false' .vibecrew/config.json 2>/dev/null || echo "false"
```

If the result is `false`, print:

```
One more step: run /profile to personalize VibeCrew to your workflow.
This takes ~2 minutes and adapts messages, autonomy, PRs, and more to your preferences.
```

If `true`, skip this step silently.

---

## Rules

- Execute steps sequentially. Do NOT skip ahead.
- Report results clearly after each step with pass/fail indicators.
- If a **required** dependency is missing AND the user declines auto-install, stop and provide installation instructions. Do not continue.
- If an **optional** component is missing (GitHub CLI, terminal-notifier, notifications, MCP servers), warn but continue.
- Never modify any project source files during setup.
- Use `${CLAUDE_PLUGIN_ROOT}` for all references to plugin scripts and templates.
