---
name: simplify
description: Analyze feature code for simplification opportunities — dead code, abstraction flattening, API reduction
disable-model-invocation: false
---

# /simplify

Analyze the current feature's code for simplification opportunities. Identifies dead code, unnecessary abstractions, reducible API surface, and consolidation targets. Each suggestion is presented individually for user approval, applied atomically, and verified by tests. Reverts automatically on test failure.

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

Do NOT output anything else. Do NOT create the file. Do NOT offer alternatives.

If `.vibecrew/state.json` exists, read it and check for an active feature:

```bash
jq -r '.active_feature.id // empty' .vibecrew/state.json
```

If the active feature ID is empty, output EXACTLY this and stop:

```
No active feature. Start a feature with /new-feature "name" first.
```

Do NOT output anything else. Do NOT offer alternatives.

If an active feature exists, read the feature details:

```bash
FEATURE_ID=$(jq -r '.active_feature.id' .vibecrew/state.json)
FEATURE_NAME=$(jq -r '.active_feature.name' .vibecrew/state.json)
echo "Feature: $FEATURE_ID — $FEATURE_NAME"
```

---

## Step 1: Collect Feature Files

Run the file collector script to determine which files were changed on the current feature branch:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/collect-feature-files.sh"
```

Capture the JSON array output. This contains the list of source files changed on the feature branch relative to the default branch.

If the output is an empty array `[]`, output EXACTLY this and stop:

```
No source files changed on this feature branch. Nothing to simplify.
```

Otherwise, report the file count:

```
Found N files changed on feature branch. Starting analysis...
```

Store the file list for the next step.

---

## Step 2: Invoke Code Simplifier Agent

Create the output directory for the simplification report:

```bash
mkdir -p .vibecrew/simplifications
```

Launch the `code-simplifier` agent in worktree isolation with the collected file list.

The code-simplifier agent will:

1. Read each file from the collected file list
2. Analyze for simplification opportunities across four categories:
   - **Dead code**: unused exports, unreachable branches, unused imports, commented-out code
   - **Abstraction flattening**: single-use wrappers, unnecessary inheritance, over-abstracted utilities
   - **API simplification**: redundant parameters, overlapping functions, complex return types
   - **Dependency reduction**: packages used for trivial operations, duplicate functionality
3. Produce a structured simplification report JSON written to `.vibecrew/simplifications/simplify-<feature_id>-<timestamp>.json`

Wait for the agent to complete and read the report file:

```bash
ls -t .vibecrew/simplifications/simplify-*.json 2>/dev/null | head -1
```

If no report file is found, output:

```
Code simplifier agent did not produce a report. This may indicate insufficient code to analyze or an agent budget issue. Try running /simplify again.
```

And stop.

If the report has zero suggestions:

```
Analysis complete. No simplification opportunities found. Your code is already clean!
```

And stop.

---

## Step 3: Display Suggestions

Read the simplification report and present each suggestion to the user one at a time.

For each suggestion, display the following:

```
Suggestion N of M
=================
Category:    <dead_code | abstraction_flattening | api_simplification | dependency_reduction>
File:        <relative file path>
Lines:       <start_line>-<end_line>
Confidence:  <high | medium | low>
Description: <what the simplification does and why>

Estimated Impact:
  Lines saved:        <number>
  Complexity change:  <description, e.g., "-2 nesting levels", "removes 1 abstraction layer">

Before:
```<language>
<before_snippet>
```

After:
```<language>
<after_snippet>
```

Apply this suggestion? (y/n/skip-all)
```

Wait for the user's response before proceeding to the next suggestion.

- **y**: Mark the suggestion as accepted, proceed to Step 4 for this suggestion.
- **n**: Mark the suggestion as rejected, move to the next suggestion.
- **skip-all**: Skip all remaining suggestions, proceed directly to Step 5.

Sort suggestions by confidence (high first), then by estimated lines saved (descending).

If there are more than 15 suggestions, inform the user:

```
Found M suggestions. Showing high-confidence suggestions first.
Tip: Use "skip-all" to skip remaining suggestions after reviewing enough.
```

---

## Step 4: Apply with Test Verification

For each accepted suggestion, apply the change atomically with test verification:

### 4a: Create Checkpoint

Before applying any change, record the file state for potential rollback:

```bash
CHECKPOINT_FILE=$(mktemp)
cp "<target_file>" "$CHECKPOINT_FILE"
echo "Checkpoint saved: $CHECKPOINT_FILE"
```

### 4b: Apply the Change

Apply the code change described in the suggestion's `after_snippet` to the target file. Use the Edit tool to replace the `before_snippet` content with the `after_snippet` content at the specified line range.

### 4c: Run Tests

Execute the test suite to verify the change does not break anything:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/phase-gate.sh" check 2>/dev/null || true
```

Run the project's test command. Detect the test runner first:

```bash
if [[ -f "vitest.config.ts" || -f "vitest.config.js" ]]; then
  npx vitest run --reporter=verbose 2>&1
elif [[ -f "jest.config.ts" || -f "jest.config.js" || -f "jest.config.json" ]]; then
  npx jest --verbose 2>&1
elif [[ -f "package.json" ]] && jq -e '.scripts.test' package.json >/dev/null 2>&1; then
  npm test 2>&1
elif [[ -f "pyproject.toml" ]] || [[ -f "pytest.ini" ]]; then
  python -m pytest -v 2>&1
elif [[ -f "Cargo.toml" ]]; then
  cargo test 2>&1
elif [[ -f "go.mod" ]]; then
  go test ./... 2>&1
else
  echo "NO_TEST_RUNNER"
fi
```

### 4d: Evaluate Results

**If tests pass** (exit code 0):

```
Suggestion N: APPLIED — tests pass.
```

Keep the change and move to the next suggestion.

**If tests fail** (non-zero exit code):

Immediately revert:

```bash
cp "$CHECKPOINT_FILE" "<target_file>"
```

Report:

```
Suggestion N: REVERTED — tests failed after applying change.
  Test output: <first 5 lines of failure>
```

Move to the next suggestion.

**If no test runner is found** (`NO_TEST_RUNNER`):

```
Suggestion N: APPLIED (unverified) — no test runner detected. Manual verification recommended.
```

Keep the change but flag it in the summary.

### 4e: Cleanup

Remove the checkpoint temp file:

```bash
rm -f "$CHECKPOINT_FILE"
```

---

## Step 5: Summary

After all suggestions have been processed (or skip-all was chosen), display the summary:

```
Simplification Summary
======================
Feature:     <feature_name> (<feature_id>)
Files:       <N files analyzed>
Suggestions: <M total>

Results:
  Applied:   A
  Rejected:  R
  Reverted:  V
  Skipped:   S

Net lines changed: <+/-N>
Report: .vibecrew/simplifications/simplify-<feature_id>-<timestamp>.json
```

If any suggestions were applied, also show:

```
Applied changes:
  1. <file> — <short description> (lines saved: N)
  2. <file> — <short description> (lines saved: N)
  ...
```

If any suggestions were reverted, also show:

```
Reverted (test failures):
  1. <file> — <short description>
  ...
```

Update the simplification report with the final applied/rejected/reverted counts:

```bash
REPORT_FILE=$(ls -t .vibecrew/simplifications/simplify-*.json 2>/dev/null | head -1)
if [[ -n "$REPORT_FILE" ]]; then
  jq '.summary.applied = APPLIED | .summary.rejected = REJECTED | .summary.reverted = REVERTED' \
    "$REPORT_FILE" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "$REPORT_FILE"
fi
```

---

## Rules

- Use `${CLAUDE_PLUGIN_ROOT}` for all plugin-relative paths (scripts, agents, templates).
- The code-simplifier agent runs in **worktree isolation** and is **read-only**. It analyzes code but never modifies files. All modifications happen in this skill's main context.
- **User approves each suggestion individually.** Never batch-apply without explicit confirmation.
- **Revert on test failure.** If tests fail after applying a change, revert immediately. Do not attempt to fix the test or modify the suggestion.
- **Never force changes.** If the Edit tool cannot find the exact `before_snippet` match (e.g., code has been reformatted), skip the suggestion and report it as skipped.
- **Atomic changes only.** Apply one suggestion at a time. Do not combine multiple suggestions into a single edit.
- **Preserve formatting.** Applied changes must match the project's existing code style (indentation, quotes, semicolons).
- **No new dependencies.** Simplification must never introduce new imports or packages.
- **No behavioral changes.** Every simplification must preserve the existing public API and behavior. If a suggestion changes function signatures, parameter types, or return types, warn the user before applying.
- Save the full simplification report to `.vibecrew/simplifications/` before exiting.
- If the report contains more than 20 suggestions in a single category, show the first 10 and note `... and N more in full report`.
- Keep terminal output concise. The JSON report has all details; the terminal display is for quick review and decision-making.
- If the user provides arguments (e.g., `/simplify --category dead_code`), filter suggestions to only the specified category. Supported filters: `dead_code`, `abstraction_flattening`, `api_simplification`, `dependency_reduction`.
- If running on a feature branch with uncommitted changes, warn the user:
  ```
  Warning: You have uncommitted changes. Consider committing or stashing before running /simplify.
  ```
  Continue if the user confirms, otherwise stop.
