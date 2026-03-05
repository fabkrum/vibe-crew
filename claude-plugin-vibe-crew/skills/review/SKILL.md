---
name: review
description: Structured code review with severity levels — invoke code-reviewer agent in worktree
disable-model-invocation: false
category: analysis
---

# /review

Structured code review for the active feature. Collects changed files, loads the feature spec as the review contract, invokes the code-reviewer agent in worktree isolation, and displays findings with severity levels. Tracks review completion for Vibe Score bonus.

---

## Pre-flight Check

Verify that VibeCrew is initialized and an active feature exists:

```bash
test -f ".vibecrew/state.json" && echo "exists" || echo "missing"
```

If `.vibecrew/state.json` does not exist, output EXACTLY this and stop:

```
VibeCrew not initialized. Run /setup first.
```

Do NOT output anything else. Do NOT offer alternatives.

Read active feature:

```bash
FEATURE_ID=$(jq -r '.active_feature.id // empty' .vibecrew/state.json)
FEATURE_NAME=$(jq -r '.active_feature.name // empty' .vibecrew/state.json)
echo "Feature: $FEATURE_ID — $FEATURE_NAME"
```

If the active feature ID is empty, output EXACTLY this and stop:

```
No active feature. Start a feature with /new-feature "name" first.
```

---

## Step 1: Collect Changed Files

Run the file collector to determine which files were changed on the feature branch:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/collect-feature-files.sh"
```

If the output is an empty array `[]`, output EXACTLY this and stop:

```
No source files changed on this feature branch. Nothing to review.
```

Report the file count:

```
Found {N} files changed on feature branch. Starting review...
```

---

## Step 2: Load Review Contract

Load the context that the code-reviewer agent will evaluate against:

```bash
# Feature spec (acceptance criteria)
jq --arg id "$FEATURE_ID" '.features[] | select(.id == $id) | .spec' .vibecrew/backlog.json 2>/dev/null

# TDR boundaries
cat docs/tdr.md 2>/dev/null | head -100
```

If the feature has no acceptance criteria, warn:

```
Warning: No acceptance criteria found. The review will focus on code quality
and conventions only. Consider adding criteria with /plan-features for a
more thorough review.
```

---

## Step 3: Invoke Code Reviewer Agent

Create the review output directory:

```bash
mkdir -p .vibecrew/reviews
```

Launch the `code-reviewer` agent in worktree isolation. The agent will:

1. Read each changed file
2. Analyze against the feature spec, TDR, conventions, design system
3. Classify findings by severity (critical / warning / info)
4. Determine verdict (approve / request-changes / comment-only)
5. Write a structured review report to `.vibecrew/reviews/review-{feature-id}-{timestamp}.json`

Wait for the agent to complete and read the report:

```bash
ls -1t .vibecrew/reviews/review-${FEATURE_ID}-*.json 2>/dev/null | head -1
```

If no report file is found:

```
Code reviewer agent did not produce a report. Try running /review again.
```

And stop.

---

## Step 4: Display Review Results

Read the review report and present findings to the user.

### 4.1 Verdict header

```
Code Review: {feature_name} ({feature_id})
=============================================
Files reviewed: {N}
Verdict:        {APPROVE | REQUEST CHANGES | COMMENT ONLY}
```

### 4.2 Critical findings (if any)

```
--- Critical (blocks merge) ---

1. [{category}] {file}:{line}
   {title}
   {description}
   Suggestion: {suggestion}

2. [{category}] {file}:{line}
   ...
```

### 4.3 Warning findings (if any)

```
--- Warnings ---

1. [{category}] {file}:{line}
   {title}
   {description}

2. ...
```

### 4.4 Info findings (if any, show max 5)

```
--- Info ---

1. {title} — {file}:{line}
2. ...
{and N more in full report}
```

### 4.5 Acceptance criteria coverage

```
Acceptance Criteria: {covered}/{total} covered
  [x] {criterion 1}
  [x] {criterion 2}
  [ ] {criterion 3 — not implemented}
```

### 4.6 Summary line

```
Review complete: {critical} critical, {warning} warnings, {info} info
Full report: .vibecrew/reviews/review-{feature-id}-{timestamp}.json
```

---

## Step 5: Next Actions

Based on the verdict, suggest next steps:

**APPROVE:**
```
Review passed. Feature is ready for merge.
```

**REQUEST CHANGES:**
```
Critical issues found. Address the {N} critical findings before merging.
Run /review again after fixing to verify.
```

**COMMENT ONLY:**
```
No blockers found. Consider addressing the {N} warnings before merging.
```

---

## Rules

- Use `${CLAUDE_PLUGIN_ROOT}` for all plugin-relative paths.
- The code-reviewer agent runs in **worktree isolation** and is **read-only**. It analyzes code but never modifies files.
- Display critical findings first, then warnings, then info. Users read top-down.
- Show at most 5 info-level findings in the terminal. Reference the full report for the rest.
- If the review report has more than 20 findings total, show a summary count and direct the user to the full JSON report.
- The review is optional in manual workflows (`/new-feature` flow) but earns a +2 Vibe Score bonus.
- In automated workflows (`/run-backlog`), review runs automatically after the test phase.
- Keep terminal output scannable. The JSON report has all details.
- Never modify source code during review. The review is read-only analysis.
