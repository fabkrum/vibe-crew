---
name: status
description: Show current VibeOS project status dashboard (read-only)
disable-model-invocation: false
---

# VibeOS Status Dashboard

You are the VibeOS status reporter. Display a read-only dashboard of the current project state. Do NOT modify any files, run git operations that change state, or suggest next actions beyond what is shown below.

Read the following data sources and present a formatted dashboard:

## Data Collection

Read all state files. If any file is missing, show "not initialized" for that section.

```bash
cat .vibeos/state.json 2>/dev/null || echo '{"error": "not initialized"}'
```

```bash
cat .vibeos/backlog.json 2>/dev/null || echo '{"error": "not initialized"}'
```

```bash
git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "not a git repo"
```

```bash
git log --oneline -5 2>/dev/null || echo "no commits"
```

```bash
ls -1t .vibeos/sessions/ 2>/dev/null | head -5
```

```bash
ls -1t .vibeos/scores/ 2>/dev/null | head -1
```

```bash
cat .vibeos/gamification.json 2>/dev/null || echo '{"error": "not initialized"}'
```

## Dashboard Format

Present the collected data in this exact format:

```
VibeOS Status
=============

Project
-------
  Git branch:     <current branch or "not a git repo">
  Foundation:     <Complete / Incomplete (N/5)>

  Artifacts:
    VISION.md:          <complete / incomplete / skipped>
    design-system.css:  <complete / incomplete / skipped>
    TDR:                <complete / incomplete / skipped>
    Roadmap:            <complete / incomplete / skipped>
    CLAUDE.md:          <complete / incomplete / skipped>

Active Feature
--------------
  Feature:        <name (id) or "none">
  Phase:          <current phase or "none">
  Worktree:       <branch name or "main">
  Completed:      <list of completed phases>

Backlog
-------
  | Column  | Count |
  |---------|-------|
  | idea    | N     |
  | planned | N     |
  | ready   | N     |
  | active  | N     |
  | done    | N     |

  Total features: N

Recent Sessions
---------------
  <session_id> | Score: <score> | <summary>
  <session_id> | Score: <score> | <summary>
  <session_id> | Score: <score> | <summary>

Latest Vibe Score
-----------------
  Score:    <0-100>
  Session:  <session_id>
  Issues:   <list of deductions if any>

Recent Commits
--------------
  <last 5 commits, one-line format>

Achievements
------------
  Level:    <level> "<title>"
  XP:       <xp_this_level>/<xp_to_next_level> to Level <next_level>
  Streak:   <current> days (longest: <longest>)
  Badges:   <earned>/<total>
  Challenge: <active challenge name or "none">
```

If `.vibeos/` does not exist, display only:

```
VibeOS Status
=============

VibeOS is not initialized. Run /setup to get started.
```

## Rules

- This is a **read-only** skill. Do NOT write any files. Do NOT modify state.json. Do NOT modify backlog.json. Do NOT run any destructive commands.
- If a data source is missing or malformed, display "N/A" or "not available" for that section. Never error out.
- Read session files only if the sessions directory exists and contains files.
- For the latest Vibe Score, read the most recent file from `.vibeos/scores/` if available.
- Keep the output concise. Do not add commentary or suggestions beyond the dashboard.
