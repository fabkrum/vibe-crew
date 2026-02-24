---
name: handoff
description: Generate a structured context transfer document for the next session — state, work done, blockers, next steps, decisions
disable-model-invocation: false
---

# VibeCrew Handoff: Cross-Session Context Transfer

You are the VibeCrew handoff generator. Your job is to create a concise, structured context document that transfers knowledge from the current session to the next. The handoff document enables seamless session continuation without losing context. Keep it under 500 words.

---

## Step 1: Gather Context

### 1.1 Read state

```bash
cat .vibecrew/state.json
```

Extract: active feature, current phase, phases completed, foundation status.

### 1.2 Read backlog

```bash
jq '{
  active: [.features[] | select(.column == "in-progress")],
  testing: [.features[] | select(.column == "testing")],
  review: [.features[] | select(.column == "review")]
}' .vibecrew/backlog.json 2>/dev/null || echo "{}"
```

### 1.3 Read recent commits

```bash
git log --oneline -10 2>/dev/null || echo "no git history"
```

### 1.4 Read latest session log

```bash
ls -1t .vibecrew/sessions/*.json 2>/dev/null | head -1 | xargs cat 2>/dev/null || echo "{}"
```

### 1.5 Read latest Vibe Score

```bash
ls -1t .vibecrew/scores/*.json 2>/dev/null | head -1 | xargs jq '{score, rating, deductions: [.deductions[].category]}' 2>/dev/null || echo "{}"
```

### 1.6 Check for blockers

Look for:
- Failing tests (from latest session log)
- Build errors (from latest session log)
- Unresolved signals in `.vibecrew/signals/`
- Stale locks

```bash
ls .vibecrew/signals/*.signal 2>/dev/null || echo "no signals"
```

---

## Step 2: Generate Handoff Document

Create the handoff document using the template structure. Write to `.vibecrew/handoffs/handoff-{YYYY-MM-DD}-{NNN}.md`.

```bash
mkdir -p .vibecrew/handoffs
today=$(date -u +%Y-%m-%d)
existing=$(ls .vibecrew/handoffs/handoff-${today}-*.md 2>/dev/null | wc -l | tr -d ' ')
next=$(printf "%03d" $((existing + 1)))
handoff_file=".vibecrew/handoffs/handoff-${today}-${next}.md"
```

### Handoff document structure

```markdown
# Session Handoff — {date}

## State
- **Active feature**: {name} ({id}) — Phase: {phase}
- **Phases done**: {list}
- **Branch**: {current branch}
- **Vibe Score**: {score}/100 ({rating})

## What Was Done
{2-4 bullet points summarizing commits and accomplishments}

## Blockers
{List any blocking issues, failing tests, build errors, or pending decisions}
{If none: "No blockers."}

## Next Steps
{2-4 prioritized action items for the next session}

## Key Decisions
{Any architectural or design decisions made this session that the next session must know}
{If none: "No new decisions."}

## Files Changed
{Top 5-10 files modified, with brief description of changes}
```

### Write the handoff

```bash
cat > "$handoff_file.tmp" << 'HANDOFF_EOF'
{generated handoff content}
HANDOFF_EOF
mv "$handoff_file.tmp" "$handoff_file"
```

---

## Step 3: Display and Confirm

Show the handoff document to the user:

```
--- Handoff Generated ---
File: {handoff_file}
Words: {word_count}

{handoff content}
```

Verify word count is under 500. If over, trim the "Files Changed" and "What Was Done" sections.

---

## Rules

- Keep the handoff under 500 words. Brevity is critical — the next session's startup agent reads this.
- Be specific: use file paths, commit hashes, test names, error messages.
- Do NOT include full code snippets. Reference file paths and line numbers instead.
- Do NOT repeat information already in state.json or backlog.json. Focus on context that is NOT captured elsewhere.
- The "Next Steps" section is the most important. Make it actionable.
- The "Blockers" section must be honest. Do not hide problems.
- The "Key Decisions" section prevents the next session from re-debating settled questions.
