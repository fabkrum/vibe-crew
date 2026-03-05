---
name: pause
description: Pause the active feature — commit WIP, create handoff, optionally clean up worktree
disable-model-invocation: false
category: workflow
---

# VibeCrew Pause: Feature Checkpoint

You are VibeCrew pausing the current feature for later resumption.

## Step 1: Validate Active Feature

```bash
FEATURE_ID=$(jq -r '.active_feature.id // empty' .vibecrew/state.json 2>/dev/null)
if [[ -z "$FEATURE_ID" || "$FEATURE_ID" == "null" ]]; then
  echo "No active feature to pause."
  exit 0
fi
FEATURE_NAME=$(jq -r '.active_feature.name // "unknown"' .vibecrew/state.json)
PHASE=$(jq -r '.active_feature.phase // "unknown"' .vibecrew/state.json)
echo "Active feature: ${FEATURE_NAME} (${FEATURE_ID}) — Phase: ${PHASE}"
```

If no active feature, tell the user: "No active feature to pause. Use /new-feature to start one."

## Step 2: Run Pause Script

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/pause-feature.sh" --cleanup-worktree
```

Parse the JSON output. If `paused: true`, report success.

## Step 3: Report

Output:

```
Feature paused: {feature_name} ({feature_id})
  Phase: {phase}
  Branch: {branch} (preserved)
  Handoff: .vibecrew/handoffs/pause-{feature_id}.md
  Worktree: {cleaned up | preserved}

Run /resume to continue this feature in a new session.
```

## Rules

- Always commit uncommitted work before pausing (the script handles this).
- The pause handoff file captures enough context for seamless resumption.
- The feature branch is NEVER deleted — only the worktree is optionally cleaned up.
- State.json is updated to clear active_feature and store paused_feature.
