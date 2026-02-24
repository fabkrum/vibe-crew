---
name: debug
description: Four-phase systematic debugging — observe, hypothesize, test, verify
disable-model-invocation: false
args: error_description
---

# /debug

Systematic four-phase debugging methodology. Gathers evidence, generates ranked hypotheses, tests each hypothesis with targeted checks, and verifies the fix with the full test suite. Saves a debug report for future reference.

---

## Pre-flight Check

Verify that VibeCrew is initialized:

```bash
test -d ".vibecrew" && echo "initialized" || echo "missing"
```

If `.vibecrew/` does not exist, output EXACTLY this and stop:

```
VibeCrew not initialized. Run /setup first.
```

Create the debug reports directory:

```bash
mkdir -p .vibecrew/debug-reports
```

Parse the error description from `$ARGUMENTS`. If empty, ask the user:

> Describe the bug or error you want to debug.

Wait for the response and store it as the error description.

---

## Phase 1: Observe

Gather all available evidence before forming any hypotheses.

### 1.1 Reproduce the error

If the error description includes a command or action to reproduce:

```bash
# Run the failing command and capture output
{command} 2>&1
echo "EXIT_CODE: $?"
```

If not reproducible from a command, ask the user for:
- Steps to reproduce
- Expected behavior
- Actual behavior
- Error message (exact text)

### 1.2 Read error logs

Check common error sources:

```bash
# Recent git changes (potential regression source)
git log --oneline -10 2>/dev/null

# Check for recent file changes
git diff --stat HEAD~3 2>/dev/null

# Check npm/build logs if applicable
cat npm-debug.log 2>/dev/null | tail -20
cat .next/trace 2>/dev/null | tail -20
```

### 1.3 Locate the error source

Use the error message to find the relevant code:

```bash
# Search for error message text in source
grep -rn "{error_text_fragment}" --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' 2>/dev/null | head -10
```

Read the file(s) containing the error source. Note:
- The function where the error occurs
- The call chain leading to it
- Any recent changes to those files (via `git log --follow -5 {file}`)

### 1.4 Evidence summary

Present the gathered evidence:

```
Observation Summary
===================
Error:     {error_type}: {error_message}
Location:  {file}:{line}
Trigger:   {action_or_command}
Recent:    {relevant_recent_changes}
Context:   {surrounding_code_or_state}
```

---

## Phase 2: Hypothesize

Generate 3-5 ranked root cause hypotheses based on the evidence.

### 2.1 Generate hypotheses

For each hypothesis, provide:
1. **Root cause** — What specifically is wrong
2. **Likelihood** — high / medium / low (based on evidence alignment)
3. **Evidence for** — Which observations support this hypothesis
4. **Evidence against** — Which observations contradict this hypothesis
5. **Test** — How to confirm or refute this hypothesis

Present hypotheses ranked by likelihood:

```
Hypotheses (ranked by likelihood)
==================================

1. [HIGH] {root_cause_description}
   Evidence for:     {supporting_evidence}
   Evidence against: {contradicting_evidence}
   Test:             {how_to_verify}

2. [MEDIUM] {root_cause_description}
   Evidence for:     {supporting_evidence}
   Evidence against: {contradicting_evidence}
   Test:             {how_to_verify}

3. [LOW] {root_cause_description}
   Evidence for:     {supporting_evidence}
   Evidence against: {contradicting_evidence}
   Test:             {how_to_verify}
```

---

## Phase 3: Test

Systematically confirm or refute each hypothesis, starting with the highest likelihood.

### 3.1 Test each hypothesis

For each hypothesis (in rank order):

1. Execute the test described in the hypothesis
2. Evaluate the result:
   - **CONFIRMED** — The test proves this is the root cause. Proceed to Phase 4.
   - **REFUTED** — The test disproves this hypothesis. Move to the next hypothesis.
   - **INCONCLUSIVE** — Need more evidence. Add a follow-up test.

Report after each test:

```
Hypothesis {N}: {CONFIRMED|REFUTED|INCONCLUSIVE}
  Test:   {what_was_tested}
  Result: {observation}
```

### 3.2 If all hypotheses are refuted

If none of the initial hypotheses are confirmed:

1. Re-examine the evidence with fresh eyes
2. Generate 2-3 new hypotheses based on what was learned from testing
3. Repeat the testing cycle
4. If still no root cause after 2 rounds, escalate:

```
Root cause not identified after systematic analysis.
Recommendation: Pair with a developer to investigate {specific_area}.
```

---

## Phase 4: Verify

Apply the fix and verify it resolves the issue without side effects.

### 4.1 Create checkpoint

Before making any changes:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/create-checkpoint.sh" "Before debug fix: {brief_description}"
```

### 4.2 Apply the fix

Implement the minimum change to resolve the confirmed root cause. Follow the same principles as CI Healer:
- One fix per issue
- Minimal diff
- Preserve intent

### 4.3 Verify the fix

Run the full test suite to confirm the fix works and causes no regressions:

```bash
npm test 2>&1
echo "EXIT_CODE: $?"
```

Additionally, reproduce the original error to confirm it no longer occurs:

```bash
# Re-run the original failing command
{original_command} 2>&1
echo "EXIT_CODE: $?"
```

### 4.4 Results

**If fix is verified:**

```bash
git add -A
git commit -m "fix(<scope>): {description}

Root-cause: {confirmed_hypothesis}
Co-Authored-By: Claude <noreply@anthropic.com>"
```

Report:

```
Fix Verified
============
Root cause:  {confirmed_hypothesis}
Fix:         {what_was_changed}
File(s):     {modified_files}
Tests:       {pass_count} passed, {fail_count} failed
Regression:  None detected
```

**If fix fails verification:**

Roll back to the checkpoint:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/rollback-checkpoint.sh"
```

Report the failure and suggest next steps.

---

## Step 5: Debug Report

Save a structured debug report for future reference:

```bash
TIMESTAMP=$(date -u +%Y%m%d-%H%M%S)
```

Write to `.vibecrew/debug-reports/debug-{timestamp}.json`:

```json
{
  "schema_version": "1.0.0",
  "timestamp": "ISO8601",
  "error_description": "original error description",
  "feature_id": "feat-NNN or null",
  "observations": [
    {"type": "error_message", "value": "..."},
    {"type": "source_location", "value": "file:line"},
    {"type": "recent_change", "value": "commit description"}
  ],
  "hypotheses": [
    {
      "rank": 1,
      "description": "...",
      "likelihood": "high",
      "result": "confirmed|refuted|inconclusive"
    }
  ],
  "root_cause": "confirmed hypothesis description",
  "fix": {
    "files_modified": ["file1.ts"],
    "description": "what was changed",
    "commit": "abc1234"
  },
  "resolved": true
}
```

Use the temp file pattern for atomic writes.

---

## Rules

- **Follow the four phases in order.** Do not skip to the fix without observing and hypothesizing first.
- **Never guess.** Every hypothesis must be testable and every fix must be verified.
- **Checkpoint before fixing.** Always create a checkpoint before applying any code changes.
- **Minimum viable fix.** Apply the smallest change that resolves the root cause. Do not refactor surrounding code.
- **Full test suite verification.** After fixing, run ALL tests — not just the ones related to the bug.
- **Save the debug report.** Every debug session produces a report, even if the root cause is not found.
- Use `${CLAUDE_PLUGIN_ROOT}` for all plugin-relative paths.
- If the error involves a third-party library, use Context7 MCP for documentation lookup instead of pasting docs.
- Maximum 3 hypothesis-testing rounds. After 3 rounds without a confirmed root cause, escalate to the developer with all gathered evidence.
