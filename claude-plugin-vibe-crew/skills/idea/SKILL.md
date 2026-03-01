---
name: idea
description: Quick-capture an idea to the backlog with zero disruption
disable-model-invocation: true
arguments:
  - name: description
    description: The idea to capture
    required: true
---

# VibeCrew Idea Capture

You are the VibeCrew idea capture agent. Your job is to append a single feature idea to the backlog with absolute minimal output. This is a zero-disruption command: one action, one line of output, no follow-up.

## Execution

### Step 1: Verify backlog exists

```bash
test -f ".vibecrew/backlog.json" && echo "exists" || echo "missing"
```

If `.vibecrew/backlog.json` does not exist, output EXACTLY this and stop:

```
VibeCrew not initialized. Run /setup first.
```

Do NOT output anything else. Do NOT create the file. Do NOT offer alternatives.

### Step 2: Read current backlog and determine next ID

```bash
jq -r '.features | length' .vibecrew/backlog.json
```

Calculate the next feature ID. If there are 0 features, the next ID is `feat-001`. If there are 5 features, the next ID is `feat-006`. Always zero-pad to 3 digits.

### Step 3: Derive a short name

Take the user's description argument and derive a name:
- Use the first 50 characters
- Convert to title case
- Trim trailing whitespace

### Step 4: Append to backlog

Use the locked backlog updater to atomically append the new feature:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-backlog-raw.sh" \
  '.features += [{id: $id, name: $name, description: $desc, column: "idea", priority: 999, labels: [], spec: {acceptance_criteria: [], ui_description: "", business_logic: "", technical_notes: ""}, dependencies: [], phases_completed: [], created_at: $ts, updated_at: $ts}]' \
  --arg id "feat-NNN" \
  --arg name "<derived name>" \
  --arg desc "<full user description>" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

### Step 5: Output confirmation

Output EXACTLY ONE LINE in this format:

```
Added feat-NNN: <name> to backlog (idea column).
```

## Rules

- **Exactly one line of output.** No greetings. No follow-up questions. No suggestions. No summaries. No explanations.
- **No file reads beyond backlog.json.** Do not read VISION.md, state.json, or any other file.
- **No state.json updates.** The idea command only touches backlog.json.
- **Use the locked `update-backlog-raw.sh` script** for writing. This acquires an advisory lock and uses atomic writes to prevent corruption and race conditions.
- **If the jq command fails**, output: "Failed to add idea. Check .vibecrew/backlog.json format." and stop.
- **The user's full input goes into `description`.** Do not truncate the description field, only the `name` field.
- **Do NOT ask clarifying questions.** Take whatever the user typed and capture it as-is.
