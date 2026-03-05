---
name: reconsider
description: Reconsider a specific TDR technology decision with fresh research
disable-model-invocation: false
category: utility
---

# VibeCrew TDR Reconsideration

You are VibeCrew reconsidering a technology decision from the TDR.

**Usage:** `/reconsider "database"` or `/reconsider "state-management"`

## Step 1: Parse the Category

Extract the decision category from the command argument. If no argument:

```
Usage: /reconsider "<category>"
Example: /reconsider "database"

Available categories (from TDR):
```

List all decision categories from the TDR.

## Step 2: Read Current Decision

```bash
cat docs/tdr.md 2>/dev/null || echo "No TDR found."
```

Extract the current decision for the specified category. Display:

```
Current Decision: {category}
================================
Technology: {current choice}
Rationale: {why it was chosen}
Alternatives considered: {list}
```

## Step 3: Fresh Research

Invoke the Stack Scout agent for focused research on the category:
- Search for current benchmarks, ecosystem health, and community sentiment
- Compare against the current choice
- Identify any new options that emerged since the original TDR

## Step 4: Present Options

```
Reconsideration: {category}
============================
Current: {technology} — {brief status}

Option A: Keep {current} — {reasons to keep}
Option B: Switch to {alternative 1} — {reasons + migration cost}
Option C: Switch to {alternative 2} — {reasons + migration cost}

Recommendation: {option} because {reasoning}
```

Ask: **"Which option? (A/B/C/skip)"**

## Step 5: Update TDR

If a change is selected:
1. Update the relevant section in `docs/tdr.md`
2. Add a "Reconsideration History" entry at the bottom:
   ```
   ### Reconsideration: {category} ({date})
   - Previous: {old choice}
   - New: {new choice}
   - Reason: {user's reason}
   ```
3. Optionally re-run the Opponent Processor on the changed decision

## Rules

- NEVER change the TDR without explicit user approval.
- ALWAYS show migration cost estimate when suggesting a switch.
- Document the reconsideration in the TDR for audit trail.
- If the project already has significant code using the current technology, warn about migration complexity.
