---
name: tdd
description: Red-green-refactor TDD cycle — vertical-slice test-driven development
disable-model-invocation: false
---

# /tdd

Vertical-slice red-green-refactor TDD workflow. Plans the test surface, writes ONE failing test, implements the minimum code to pass it, then refactors with the full suite green. Repeats until all acceptance criteria are covered. Commits after each cycle with a TDD trailer.

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

## Step 1: Planning Phase

Load the feature spec and plan the test surface.

### 1.1 Load acceptance criteria

```bash
jq --arg id "$FEATURE_ID" '.features[] | select(.id == $id) | .spec.acceptance_criteria' .vibecrew/backlog.json 2>/dev/null || echo "[]"
```

If acceptance criteria are empty, prompt the user:

```
No acceptance criteria found. Define 3-5 testable criteria before starting TDD.
Use /plan-features to add criteria, or provide them now.
```

Wait for the user's response. Save any provided criteria to the backlog.

### 1.2 Identify the test surface

For each acceptance criterion, identify:

1. **Interface signatures** — function names, parameter types, return types
2. **Critical behaviors** — the core assertions each test will make
3. **Dependency injection points** — external services, databases, APIs that need mocking

Present the test plan:

```
TDD Test Plan for {feature_name}
=================================

Criterion 1: {criterion text}
  Test: {test_description}
  Interface: {function_signature}
  DI: {dependencies_to_mock}

Criterion 2: {criterion text}
  Test: {test_description}
  Interface: {function_signature}
  DI: {dependencies_to_mock}

...

Total cycles planned: {N}
```

### 1.3 Determine test infrastructure

```bash
# Detect test runner
if [[ -f "vitest.config.ts" || -f "vitest.config.js" ]]; then echo "vitest"
elif [[ -f "jest.config.ts" || -f "jest.config.js" || -f "jest.config.json" ]]; then echo "jest"
elif [[ -f "pyproject.toml" ]] || [[ -f "pytest.ini" ]]; then echo "pytest"
elif [[ -f "Cargo.toml" ]]; then echo "cargo-test"
elif [[ -f "go.mod" ]]; then echo "go-test"
else echo "unknown"
fi
```

If no test runner is detected, prompt the user to configure one before proceeding.

---

## Step 2: Red Phase — Write ONE Failing Test

For each TDD cycle, write exactly ONE test that targets ONE acceptance criterion or behavior.

### 2.1 Write the test file

Create or append to the appropriate test file based on the project's test file convention:

```bash
# Detect existing test file patterns
find . -name "*.test.*" -o -name "*.spec.*" -not -path "*/node_modules/*" 2>/dev/null | head -5
```

Write a single test that:
- Imports the expected module (which may not exist yet)
- Asserts the expected behavior from the acceptance criterion
- Uses meaningful variable names that describe the business intent
- Includes arrange/act/assert structure

### 2.2 Verify it fails

Run the test suite targeting only the new test:

```bash
# Vitest example — adjust for project's runner
npx vitest run --reporter=verbose <test_file> 2>&1
echo "EXIT_CODE: $?"
```

**Expected outcomes:**
- Module not found error — GOOD (module doesn't exist yet)
- Assertion failure — GOOD (module exists but behavior is wrong)
- Syntax error in test — BAD (fix the test, not the implementation)

If the test unexpectedly PASSES:
- The behavior already exists. Add a more specific assertion.
- If the criterion is already fully met, skip to the next cycle.

Report:

```
RED: Test "{test_name}" fails as expected.
  Error: {brief_error_description}
```

---

## Step 3: Green Phase — Minimal Implementation

Write the MINIMUM code to make the failing test pass. Nothing more.

### 3.1 Implement

- Create or modify the source file that the test imports.
- Write only the code necessary to satisfy the single test assertion.
- Do NOT implement future behavior, error handling for untested cases, or optimizations.
- Use hardcoded values if they satisfy the test — refactoring comes later.

### 3.2 Verify it passes

Run the full test suite (not just the new test) to ensure nothing is broken:

```bash
npm test 2>&1
echo "EXIT_CODE: $?"
```

If the new test passes but other tests fail:
- Fix the regression. The green phase means ALL tests pass.
- Maximum 3 fix attempts. If still failing, report the issue and pause.

Report:

```
GREEN: All tests pass ({passed} passed, {failed} failed).
```

---

## Step 4: Refactor Phase

With all tests green, refactor the implementation for clarity, DRY, and convention compliance.

### 4.1 Refactor checklist

- Remove duplication introduced by hardcoded values
- Extract named constants or configuration
- Improve variable and function naming
- Apply project conventions (import style, code style)
- Use design system tokens for any UI code
- Ensure no lint warnings are introduced

### 4.2 Verify tests still pass

After each refactoring change, re-run the full test suite:

```bash
npm test 2>&1
echo "EXIT_CODE: $?"
```

If tests break during refactoring, UNDO the refactoring change immediately. Refactoring must never change behavior.

Report:

```
REFACTOR: Code cleaned up. All tests still pass.
```

---

## Step 5: Commit the Cycle

After each successful red-green-refactor cycle, commit with a TDD trailer:

```bash
git add -A
git commit -m "feat(<scope>): <description of what this cycle implements>

TDD cycle: red-green-refactor
Criterion: <acceptance criterion text>
Co-Authored-By: Claude <noreply@anthropic.com>"
```

Report:

```
COMMITTED: Cycle {N}/{total} — {criterion_summary}
```

---

## Step 6: Repeat or Complete

After committing, check if more acceptance criteria remain uncovered.

- **If more criteria remain:** Return to Step 2 with the next criterion.
- **If all criteria are covered:** Proceed to the summary.

---

## Step 7: Summary Report

After all cycles complete, display the TDD summary:

```
TDD Summary for {feature_name}
===============================
Cycles completed: {N}/{total}
Tests written:    {test_count}
All passing:      {yes/no}

Criteria Coverage:
  [x] {criterion 1}
  [x] {criterion 2}
  [ ] {criterion 3 — if skipped}

Discipline Score: {N}/10
  - {N} cycles with clean red-green-refactor
  - {N} cycles with refactoring step
  - {N} cycles with immediate green (no refactor needed)

Commits: {commit_count} with TDD trailers
```

### Discipline score calculation

- Start at 10
- -1 for each cycle where the red phase test passed unexpectedly (criterion already met)
- -1 for each cycle where refactoring broke tests
- -2 for each cycle where the green phase required 3+ fix attempts
- -1 for each acceptance criterion left uncovered
- Clamp to 0-10

---

## Rules

- **One test per cycle.** Never write multiple tests in the red phase. Each cycle targets exactly one behavior.
- **Minimal green.** The green phase writes the minimum code to pass. No future-proofing, no optimization, no untested error handling.
- **All tests green before refactoring.** Never refactor with a failing test suite.
- **Commit after every cycle.** Each red-green-refactor cycle gets its own commit with the TDD trailer.
- **Never skip the red phase.** Always verify the test fails before writing implementation. A test that passes without implementation is not testing anything new.
- **Refactoring is optional per cycle.** If the code is already clean after the green phase, skip refactoring. Note it in the summary.
- Use `${CLAUDE_PLUGIN_ROOT}` for all plugin-relative paths.
- If the test runner is not configured, help the user set it up before starting TDD cycles. Use the project's existing test infrastructure if available.
- If Context7 MCP is available, use it for testing library documentation instead of pasting docs.
