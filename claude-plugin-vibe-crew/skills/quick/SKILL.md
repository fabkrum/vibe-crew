---
name: quick
description: Fast-track small fixes — code, quality gate, commit. No backlog, no phases, no Vibe Score.
disable-model-invocation: false
category: development
---

# VibeCrew Quick Fix

You are running a lightweight quick-fix workflow. This bypasses the full Tier 2 feature lifecycle for small, self-contained changes like typo fixes, config tweaks, copy updates, or minor bug fixes.

---

## Step 1: Pre-flight

### 1.1 Verify foundation is complete

```bash
jq -r '.foundation.complete' .vibecrew/state.json 2>/dev/null || echo "error"
```

If the result is not `true`, stop and output EXACTLY:

```
Foundation must be complete before making changes. Run /new-project first.
```

### 1.2 Check for active feature

```bash
jq -r '.active_feature.id // "none"' .vibecrew/state.json 2>/dev/null || echo "none"
```

If an active feature exists, warn (but do NOT block):

```
Note: Feature {id} ({name}) is currently in-progress. /quick commits to the current branch and does not affect feature state.
```

### 1.3 Parse description

The user invokes this as `/quick "description"`. Extract the description from the argument.

If no description is provided, ask: "What would you like to fix?"

Store the description for use in later steps.

---

## Step 2: Scope Guard

Analyze the description for keywords that suggest this is actually a feature, not a quick fix:

**Feature indicators** (any match triggers the warning):
- `new page`, `new route`, `new component`, `new endpoint`, `new table`
- `schema`, `migration`, `database`
- `authentication`, `authorization`, `permissions`
- `API endpoint`, `REST`, `GraphQL`
- `dashboard`, `admin panel`
- Multiple files mentioned (3+)

If feature indicators are detected, warn:

```
This looks like it might be a feature rather than a quick fix:
  Detected: {indicators}

Features get proper planning, testing, and review. Consider /new-feature instead.
Proceed with /quick anyway? (yes/no)
```

- If **yes**: continue.
- If **no**: stop. Suggest `/new-feature "{description}"`.

If no feature indicators are detected, proceed silently.

---

## Step 3: Implement

1. Read the relevant file(s) based on the description. Use `Grep` and `Glob` to locate the target code.
2. Apply the minimal change to address the description.
3. Do NOT create a worktree — work inline on the current branch.
4. Do NOT create a feature branch — commit directly to the current branch.
5. Keep changes minimal. If the fix touches more than 5 files, pause and confirm with the user.

---

## Step 4: Quality Gate

Run the standard quality checks:

```bash
npm run build 2>&1
BUILD_EXIT=$?

npm run lint 2>&1
LINT_EXIT=$?

npm run typecheck 2>&1 || npx tsc --noEmit 2>&1
TYPES_EXIT=$?

npm test 2>&1
TEST_EXIT=$?
```

Evaluate results:
- **PASS**: All checks return exit code 0 (lint warnings are acceptable).
- **FAIL**: Any check returns a non-zero exit code.

If any check fails:
1. Attempt to fix the issue (max 2 fix-and-retry cycles).
2. On retry, try `npm install` first in case of missing dependencies.
3. If still failing after 2 retries, report the failure and ask the user whether to commit anyway or abort.

---

## Step 5: Commit

Create a conventional commit with only the changed files:

```bash
git add <specific-changed-files>
git commit -m "fix(<scope>): <description from Step 1>

Co-Authored-By: Claude <noreply@anthropic.com>"
```

Rules:
- Stage only changed files by name — NEVER use `git add -A` or `git add .`.
- Use `fix()` type for bug fixes, `style()` for styling, `docs()` for documentation, `chore()` for config changes.
- Infer the scope from the changed file paths (e.g., `auth`, `ui`, `config`).
- Keep the commit message concise (under 72 characters for the first line).

---

## Step 6: Log

Write a lightweight session log:

```bash
mkdir -p .vibecrew/sessions
```

Write to `.vibecrew/sessions/quick-fix-<timestamp>.json`:

```json
{
  "type": "quick_fix",
  "description": "<user's description>",
  "files_changed": ["<file1>", "<file2>"],
  "commit_sha": "<sha>",
  "quality_gate": "pass|fail",
  "timestamp": "<ISO 8601>"
}
```

Report to the user:

```
Quick fix applied and committed.
  Commit: <sha> — <commit message>
  Files: <N> changed
```

---

## Rules

- **No backlog entry.** Quick fixes are ephemeral — visible in git log and session log only.
- **No feature branch.** Commits to the current branch (main, feature branch, whatever is checked out).
- **No state mutation.** Does NOT set `active_feature` in `state.json`. Does not interfere with in-progress features.
- **No Vibe Score.** Too lightweight to score meaningfully.
- **Quality gate is mandatory.** Every change must pass build + lint + typecheck + tests before commit. The only exception is if the user explicitly approves committing with failures.
- **No phase tracking.** Does not call `complete-phase.sh` or `validate-phase-transition.sh`.
- **Foundation required.** The phase gate check ensures the project has been set up before any code changes.
- **Minimal footprint.** This workflow should complete in under 2 minutes for typical fixes.
- **Use `${CLAUDE_PLUGIN_ROOT}`** for all plugin-relative paths.
