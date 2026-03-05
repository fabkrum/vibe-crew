---
name: resume
description: Resume a previously paused feature — restore state, recreate worktree, continue at last phase
disable-model-invocation: false
category: workflow
---

# VibeCrew Resume: Continue Paused Feature

You are VibeCrew resuming a previously paused feature.

## Step 1: Check for Paused Feature

```bash
PAUSED_ID=$(jq -r '.paused_feature.id // empty' .vibecrew/state.json 2>/dev/null)
if [[ -z "$PAUSED_ID" || "$PAUSED_ID" == "null" ]]; then
  echo "No paused feature found."
  exit 0
fi
PAUSED_NAME=$(jq -r '.paused_feature.name // "unknown"' .vibecrew/state.json)
PAUSED_PHASE=$(jq -r '.paused_feature.phase // "unknown"' .vibecrew/state.json)
PAUSED_AT=$(jq -r '.paused_feature.paused_at // "unknown"' .vibecrew/state.json)
echo "Paused feature: ${PAUSED_NAME} (${PAUSED_ID}) — Phase: ${PAUSED_PHASE} — Paused: ${PAUSED_AT}"
```

If no paused feature, tell the user: "No paused feature found. Use /new-feature to start one or /status to check current state."

## Step 2: Read Pause Handoff

```bash
HANDOFF=".vibecrew/handoffs/pause-${PAUSED_ID}.md"
if [[ -f "$HANDOFF" ]]; then
  cat "$HANDOFF"
fi
```

Display a brief summary of the handoff context to the user.

## Step 3: Run Resume Script

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/resume-feature.sh"
```

Parse the JSON output. If `resumed: true`, report success.

## Step 4: Report and Route

Output:

```
Feature resumed: {feature_name} ({feature_id})
  Phase: {phase}
  Branch: {branch}
  Worktree: {recreated | existing}

Continuing at the {phase} phase. Ready to work.
```

Then route to the appropriate next action based on the phase:
- `plan` → "Continue planning. The plan file is at docs/features/{name}/plan.md"
- `design` → "Continue the design phase."
- `code` → "Continue implementation."
- `test` → "Continue testing."
- `review` → "Continue code review."
- `docs` → "Continue documentation."

## Rules

- There can only be one paused feature at a time.
- If another feature is already active, tell the user to pause it first.
- The resume script restores state.json and optionally recreates the worktree.
- The pause handoff file is renamed to `.resumed.md` after consumption.
