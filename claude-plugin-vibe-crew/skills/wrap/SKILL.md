---
name: wrap
description: End-of-session wrap-up — quality gate, Vibe Score, session log, commit
disable-model-invocation: false
---

# VibeCrew Wrap: End-of-Session Wrap-Up

You are the VibeCrew Verifier agent running the end-of-session wrap-up sequence. Your job is to run the quality gate, calculate the Vibe Score, write the session log and score file, commit changes, and optionally create a pull request. Execute each step sequentially. Do NOT skip steps or reorder them.

---

## Step 1: Pre-flight

### 1.1 Verify VibeCrew is initialized

```bash
test -d ".vibecrew" && echo "initialized" || echo "missing"
```

If `.vibecrew/` does not exist, stop immediately and tell the user:
"VibeCrew is not initialized. Run /setup first."

### 1.2 Read user profile

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/read-profile.sh"
```

Store the profile for use in later steps. Key values:
- `pr_review`: Determines PR creation behavior in Step 8.
- `gamification_preference`: Controls progression display in Step 9.7.
- `verbosity`: Controls coaching output depth in Step 9.

### 1.3 Read project state

```bash
cat .vibecrew/state.json
```

Parse the following from `state.json`:
- `active_feature.id` -- the feature being worked on (may be `null` for Tier 1 work)
- `active_feature.name` -- human-readable feature name
- `active_feature.phase` -- current workflow phase
- `active_feature.phases_completed` -- array of completed phases
- `foundation.complete` -- whether the foundation is done

Store these values for use in later steps.

### 1.4 Read backlog context

```bash
cat .vibecrew/backlog.json 2>/dev/null || echo '{"features": []}'
```

If an active feature exists, find its entry in the backlog and extract:
- `spec.acceptance_criteria` -- needed for the `no-spec` metric
- `phases_completed` -- needed for phase completion metrics
- `column` -- current Kanban column

### 1.5 Detect existing session log

Check if a session log was started for this session by the Session Startup agent:

```bash
ls -1t .vibecrew/sessions/ 2>/dev/null | head -1
```

If a session file exists with `ended_at: null`, use that session ID. Otherwise, generate a new session ID using the pattern `session-<YYYY-MM-DD>-<NNN>` where `<NNN>` is the next available sequence number for today.

---

## Step 2: Quality Gate

Run the same checks as `/check`. For each check, attempt to run the command and capture the result. If the project does not have a particular tool configured, report SKIP for that check.

### 2.1 Detect available commands

```bash
cat package.json 2>/dev/null | jq -r '.scripts | keys[]' 2>/dev/null || echo "no package.json"
```

### 2.2 Run tests

```bash
npm test 2>&1 || echo "TESTS_FAILED"
```

If `test` script exists in `package.json`, run it and capture:
- Exit code (0 = pass, non-zero = fail)
- Number of tests passed, failed, skipped (parse from output)
- Coverage percentage if available (parse from output)

If no test script exists, report: `Tests: SKIP (no test script configured)`

### 2.3 Run build

```bash
npm run build 2>&1 || echo "BUILD_FAILED"
```

If `build` script exists in `package.json`, run it and capture the exit code.

If no build script exists, report: `Build: SKIP (no build script configured)`

### 2.4 Run linter

```bash
npm run lint 2>&1 || echo "LINT_FAILED"
```

If `lint` script exists in `package.json`, run it and capture the exit code and any warnings/errors count.

If no lint script exists, report: `Lint: SKIP (no lint script configured)`

### 2.5 Run type check

```bash
npx tsc --noEmit 2>&1 || echo "TYPES_FAILED"
```

If `tsconfig.json` exists, run the type check. Otherwise, report: `Types: SKIP (no tsconfig.json)`

### 2.6 Report quality gate results

Present results in this format:

```
Quality Gate
============
  Tests:   PASS (12 passed, 0 failed) | FAIL (10 passed, 2 failed) | SKIP
  Build:   PASS | FAIL | SKIP
  Lint:    PASS (0 warnings) | FAIL (3 errors, 2 warnings) | SKIP
  Types:   PASS | FAIL (5 errors) | SKIP
```

**If tests or build FAIL:** Warn the user but do NOT block the wrap. Print:
"Warning: Quality checks have failures. Consider fixing these in the next session."

Store all quality results for Vibe Score calculation in Step 4.

---

## Step 3: Gather Session Metrics

Collect the following metrics for Vibe Score calculation. For any metric where data is unavailable, use the documented default and note it as estimated.

### 3.1 Token and context metrics

Attempt to read token usage from the session. If the `calculate-vibe-score.sh` script exists, use it:

```bash
test -f "${CLAUDE_PLUGIN_ROOT}/scripts/calculate-vibe-score.sh" && echo "script available" || echo "script missing"
```

If available:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calculate-vibe-score.sh" metrics
```

Otherwise, estimate from available session data:

- **`total_input`**: Total input tokens consumed during this session. Default: `0` (noted as estimated).
- **`total_cache_read`**: Total cache read tokens. Default: `0` (noted as estimated).
- **`total_output`**: Total output tokens generated. Default: `0` (noted as estimated).
- **`cache_ratio`**: `total_cache_read / total_input` (0 if `total_input` is 0). Default: `0.50` (noted as estimated).

**Context window metrics:**

Check if context warnings were triggered during the session by reading state or hook output:

```bash
jq -r '.context_warnings_triggered // empty' .vibecrew/state.json 2>/dev/null
```

- **`peak_context_pct`**: Highest context window utilization percentage observed. If the 80% warning was triggered, set to 85. If the 60% warning was triggered, set to 65. If neither, default to 40 (noted as estimated).

### 3.2 Prompt churn detection

Analyze the conversation for sequences of 3 or more consecutive user corrections without meaningful progress. A "churn sequence" is defined as 3+ user messages in a row where the AI did not make successful tool calls (file writes, command executions with exit code 0) between them.

Detection approach:
- Review the conversation flow conceptually
- Count sequences where the user had to repeatedly rephrase or redirect without the AI producing working results between redirections
- Do NOT depend on specific transcript field names -- use your judgment based on the conversation history

Store: `churn_sequences` (integer, 0 if none detected)

If unable to analyze conversation history, default to `0` and note as estimated.

### 3.3 Tool loop detection

Check for instances where the same tool was called 3 or more times with identical or near-identical arguments without changing approach.

Detection approach:
- Review tool calls in the session
- Identify cases where the same command was retried 3+ times without modifying the approach
- "Near-identical" means arguments that differ only in whitespace or trivial reformatting

Store: `tool_loops` (integer, 0 if none detected)

If unable to analyze tool history, default to `0` and note as estimated.

### 3.4 Phase completion metrics

Read from `state.json` and backlog:

```bash
jq -r '.active_feature.phases_completed | join(",")' .vibecrew/state.json 2>/dev/null || echo "none"
```

Determine:
- **`phases_completed`**: Array of completed Tier 2 phases (`plan`, `design`, `code`, `test`, `review`, `docs`)
- **`phases_skipped`**: Count of the 6 phases NOT in `phases_completed`. If no active feature, default to 0.
- **`all_six_phases_complete`**: Boolean, true only if all 6 phases are in `phases_completed`.

### 3.5 Feature spec check

If there is an active feature, check whether acceptance criteria exist:

```bash
jq --arg id "<feature_id>" '.features[] | select(.id == $id) | .spec.acceptance_criteria | length' .vibecrew/backlog.json 2>/dev/null || echo "0"
```

- **`no_spec`**: Boolean, true if the active feature has 0 acceptance criteria, OR if no feature spec exists but code was written. If no active feature (Tier 1 work), set to `false`.

### 3.6 Test metrics (from Step 2)

Carry forward from the quality gate:
- **`no_tests`**: Boolean, true if no test files were created or modified during the session AND no tests ran. If tests were SKIP (no test script), check whether any test files exist in the project via a quick search:

```bash
find . -name "*.test.*" -o -name "*.spec.*" -o -name "__tests__" 2>/dev/null | head -5
```

If test files exist but no tests ran (script missing), set `no_tests` to `false` (the files exist; the runner is just not configured). If no test files exist at all, set `no_tests` to `true`.

- **`test_coverage_pct`**: From the test runner output. Default: `0` if not available.

---

## Step 4: Calculate Vibe Score

Apply the exact scoring formula:

```
score = 100

# Deductions
score -= 5 * min(churn_sequences, 3)       # prompt-churn: -5 each, max -15
score -= 10 * min(tool_loops, 3)            # tool-loop: -10 each, max -30
score -= 15 if cache_ratio < 0.30           # low-cache: -15
score -= 20 if peak_context_pct > 80        # context-violation: -20
score -= 10 if no_tests                     # no-tests: -10
score -= 5 if no_spec                       # no-spec: -5
score -= 3 * min(phases_skipped, 6)         # missing-phase: -3 each, max -18
score -= 5 if skipped_code_review           # skipped-review: -5

# Bonuses
score += 5 if all_six_phases_complete       # all-phases: +5
score += 5 if cache_ratio > 0.70            # high-cache: +5
score += 3 if test_coverage_pct > 80        # full-coverage: +3
score += 2 if zero_deductions               # clean-session: +2
score += 3 if tdd_discipline_detected       # tdd-discipline: +3
score += 3 if e2e_tests_passing             # e2e-passing: +3
score += 2 if a11y_clean                    # a11y-clean: +2
score += 2 if review_completed              # review-complete: +2
score += 2 if perf_baselines_exist          # perf-baselines: +2

score = clamp(score, 0, 100)
```

### New metric detection (v1.4.0)

The `calculate-vibe-score.sh` script detects these additional metrics:

- **`skipped_code_review`**: True if an active feature exists, code was written, but no review report is found in `.vibecrew/reviews/`.
- **`tdd_discipline_detected`**: True if commits with `TDD cycle:` trailer are found in recent git log.
- **`e2e_tests_passing`**: True if Playwright spec files exist and test results directory exists.
- **`a11y_clean`**: True if an axe-core report exists in `.vibecrew/a11y/` with zero critical/serious violations.
- **`review_completed`**: True if a review report exists in `.vibecrew/reviews/` for the active feature.
- **`perf_baselines_exist`**: True if k6 results exist in `.vibecrew/perf-tests/` for the active feature.

**Important:** The `zero_deductions` check must happen AFTER applying all deductions (including `skipped-review`). If the total deduction sum is 0, the `clean-session` bonus applies.

Determine the rating from the clamped score:
- 90-100: `"excellent"`
- 70-89: `"good"`
- 50-69: `"needs-improvement"`
- 0-49: `"review-session"`

Build the deductions and bonuses arrays, recording each applied rule with its category, points, reason, and evidence (for deductions).

### Generate coaching output

Based on the deductions and score:

**Suggestions (1-3 maximum, only if deductions occurred):**
- Each suggestion MUST map to a specific deduction
- Be actionable and specific -- include data (token counts, percentages, tool names)
- Frame as "the session had X" not "you did X wrong"

**Celebration (only if score >= 90 or zero deductions):**
- Celebrate specific achievements, not generic praise
- One sentence maximum
- Reference data: cache ratio, phase completion, test results

**CLAUDE.md mutation (v1.0):** Always set to `null`. Mutations are a v1.1 feature.

---

## Step 5: Write Score File

Determine the next score file sequence number for today:

```bash
today=$(date -u +%Y-%m-%d)
existing=$(ls .vibecrew/scores/score-${today}-*.json 2>/dev/null | wc -l | tr -d ' ')
next=$(printf "%03d" $((existing + 1)))
echo "score-${today}-${next}.json"
```

Create the directory if needed:

```bash
mkdir -p .vibecrew/scores
```

Write the score file to `.vibecrew/scores/score-<YYYY-MM-DD>-<NNN>.json` using the following schema. Use `jq` or direct file writing with proper JSON formatting:

```json
{
  "schema_version": "1.0.0",
  "session_id": "session-YYYY-MM-DD-NNN",
  "timestamp": "ISO8601 timestamp of this calculation",
  "feature_id": "feat-NNN or null",
  "score": 82,
  "rating": "good",
  "metrics": {
    "tokens": {
      "total_input": 0,
      "total_cache_read": 0,
      "total_output": 0,
      "cache_ratio": 0.50
    },
    "context": {
      "peak_usage_percent": 40,
      "warnings_triggered": 0
    },
    "prompt_churn": {
      "detected": false,
      "sequences": 0
    },
    "tool_loops": {
      "detected": false,
      "count": 0
    },
    "phases": {
      "plan": true,
      "design": true,
      "code": true,
      "test": false,
      "docs": false
    },
    "quality": {
      "tests_passed": true,
      "coverage_percent": 78.5,
      "lint_clean": true,
      "build_passes": true
    }
  },
  "deductions": [
    {
      "category": "missing-phase",
      "points": -6,
      "reason": "2 Tier 2 phases not completed (test, docs)",
      "evidence": "phases_completed = [plan, design, code], missing = [test, docs]"
    }
  ],
  "bonuses": [
    {
      "category": "high-cache",
      "points": 5,
      "reason": "Cache hit rate above 70%"
    }
  ],
  "coaching": {
    "suggestions": [
      "Complete the test and docs phases to earn the full phase completion bonus."
    ],
    "celebration": null,
    "claude_md_mutation": null
  }
}
```

Use the temp file pattern for atomic writes:

```bash
# Write to temp file, then move atomically
cat > .vibecrew/scores/score-${today}-${next}.json.tmp << 'SCORE_EOF'
{ ... score JSON ... }
SCORE_EOF
mv .vibecrew/scores/score-${today}-${next}.json.tmp .vibecrew/scores/score-${today}-${next}.json
```

---

## Step 6: Write Session Log

### 6.1 Gather git data

Collect commits made during this session. Use the session start time to filter:

```bash
git log --oneline --since="<session_start_time>" 2>/dev/null || echo "no git history"
```

For a more detailed commit list:

```bash
git log --format='{"hash":"%h","message":"%s","files_changed":%n}' --since="<session_start_time>" 2>/dev/null
```

If the session start time is unknown, use the last 2 hours as a reasonable window:

```bash
git log --oneline --since="2 hours ago" 2>/dev/null || echo "no git history"
```

### 6.2 Gather files modified

```bash
git diff --stat HEAD~5 2>/dev/null || git diff --stat 2>/dev/null || echo "no changes"
```

For structured file data:

```bash
git diff --numstat HEAD~5 2>/dev/null || echo "no diff data"
```

Parse into the `files_modified` array with `path`, `lines_added`, `lines_removed`, and `operation` (`created`, `modified`, or `deleted`).

### 6.3 Determine session timing

- **`started_at`**: From the existing session log file (if one was started by Session Startup), or estimate from the earliest commit in this session, or use 1 hour before now as a default.
- **`ended_at`**: Current timestamp (`date -u +%Y-%m-%dT%H:%M:%SZ`).
- **`duration_seconds`**: Difference between `started_at` and `ended_at`.

### 6.4 Write session log file

Determine the session log filename. If an existing session log was found in Step 1.4, update it in-place. Otherwise, create a new one:

```bash
mkdir -p .vibecrew/sessions
```

Write to `.vibecrew/sessions/session-<YYYY-MM-DD>-<NNN>.json` with this schema:

```json
{
  "schema_version": "1.0.0",
  "session_id": "session-YYYY-MM-DD-NNN",
  "started_at": "ISO8601",
  "ended_at": "ISO8601",
  "feature_id": "feat-NNN or null",
  "task_summary": "Brief description of what was accomplished this session",
  "agents": [
    {
      "agent": "agent-name",
      "started_at": "ISO8601",
      "ended_at": "ISO8601",
      "worktree": "path or null"
    }
  ],
  "commits": [
    {
      "hash": "abc1234",
      "message": "feat(auth): add login form",
      "files_changed": 3
    }
  ],
  "tokens": {
    "input": 0,
    "cache_creation": 0,
    "cache_read": 0,
    "output": 0,
    "cache_hit_rate": 0.50,
    "estimated_cost_usd": 0.00
  },
  "tests": {
    "ran": true,
    "total": 12,
    "passed": 10,
    "failed": 2,
    "coverage_percent": 78.5
  },
  "context": {
    "peak_usage_percent": 40,
    "average_usage_percent": 30,
    "compactions": 0
  },
  "files_modified": [
    {
      "path": "src/example.ts",
      "lines_added": 50,
      "lines_removed": 10,
      "operation": "modified"
    }
  ],
  "duration_seconds": 3600,
  "vibe_score": 82
}
```

**Task summary:** Write a 1-2 sentence summary of what was accomplished during this session. Base it on the commits, files modified, and active feature context.

Use the temp file pattern for atomic writes:

```bash
cat > .vibecrew/sessions/<filename>.tmp << 'SESSION_EOF'
{ ... session JSON ... }
SESSION_EOF
mv .vibecrew/sessions/<filename>.tmp .vibecrew/sessions/<filename>
```

---

## Step 7: Git Commit

### 7.1 Check for changes

```bash
git status --porcelain 2>/dev/null
```

If there are no changes (output is empty), print: "No uncommitted changes. Skipping git commit." and proceed to Step 8.

### 7.2 Stage changes

Stage all modified and new files:

```bash
git add -A
```

### 7.3 Determine commit message

Build a conventional commit message:

- **Type:** Determine from the work done:
  - `feat` -- new feature or feature phase work
  - `fix` -- bug fix
  - `refactor` -- code restructuring without behavior change
  - `test` -- test additions or modifications
  - `docs` -- documentation changes
  - `chore` -- maintenance, config changes
- **Scope:** If there is an active feature, use the feature name (kebab-case, abbreviated if long). If Tier 1 work, use `foundation`. For mixed work, use the most significant scope.
- **Summary:** Brief, imperative description of what was done (50 characters or fewer if possible).

Format: `<type>(<scope>): <summary>`

Examples:
- `feat(user-auth): add login form and OAuth flow`
- `test(user-auth): add unit tests for auth service`
- `docs(foundation): create VISION.md and design system`

### 7.4 Create the commit

```bash
git commit -m "<type>(<scope>): <summary>

Co-Authored-By: Claude <noreply@anthropic.com>"
```

Report the commit hash and message to the user:

```
Committed: <hash> <type>(<scope>): <summary>
```

If the commit fails (e.g., pre-commit hook failure), report the error and suggest the user fix it in the next session. Do NOT retry the commit.

---

## Step 8: PR Creation (Profile-Aware)

Read the `pr_review` value from the profile loaded in Step 1.2.

### If `pr_review` = `auto_merge`

Skip PR creation entirely. If on a feature branch, merge directly to the default branch after tests pass:

```bash
DEFAULT_BRANCH=$(jq -r '.git.default_branch // "main"' .vibecrew/state.json 2>/dev/null || echo "main")
git checkout "$DEFAULT_BRANCH" && git merge --no-ff "$(git branch --show-current)" && git branch -d "$(git rev-parse --abbrev-ref @{-1})"
```

Print: "Auto-merged to {default_branch}. PR skipped per profile."

If the merge fails, fall back to creating a PR with summary format.

### If `pr_review` = `summary`

Auto-create a PR with a brief 3-line body. Do not ask the user:

```bash
gh pr create --title "<type>(<scope>): <summary>" --body "$(cat <<'PR_EOF'
- <what changed>
- <why>
- <what to test>
PR_EOF
)"
```

Report the PR URL.

### If `pr_review` = `review` or profile not set

Ask the user:

```
Create a pull request? (yes/no)
```

Wait for the user's response.

### If `pr_review` = `walkthrough`

Auto-create a detailed PR with a per-file walkthrough section. Adapt walkthrough explanations to the user's `code_literacy` level. Do not ask — always create.

### If yes (for `review` mode):

Determine the PR details:

- **Title:** Use the conventional commit message format or a slightly expanded version.
- **Base branch:** Use the default branch from `state.json` (`git.default_branch`, typically `main`).
- **Body:** Structured markdown with summary, test results, and Vibe Score.

Create the PR:

```bash
gh pr create --title "<type>(<scope>): <summary>" --body "$(cat <<'PR_EOF'
## Summary

- <1-3 bullet points describing what this PR does>

## Quality Gate

| Check  | Result |
|--------|--------|
| Tests  | PASS / FAIL / SKIP |
| Build  | PASS / FAIL / SKIP |
| Lint   | PASS / FAIL / SKIP |
| Types  | PASS / FAIL / SKIP |

## Vibe Score

**Score:** <score>/100 (<rating>)

<coaching observation if any>

## Test Plan

- [ ] Verify acceptance criteria from feature spec
- [ ] Run full test suite
- [ ] Manual smoke test of key flows
PR_EOF
)"
```

Report the PR URL to the user.

### If no:

Print: "Skipping PR creation." and proceed to Step 9.

---

## Step 9: Display Vibe Score

Present the Vibe Score to the user in this exact format:

```
--- Vibe Score: {score}/100 ({rating}) ---

{top_observation}

{suggestions if deductions occurred}

{celebration if score >= 90 or zero deductions}
```

### Formatting rules by score range

**Excellent (90-100):**

Lead with the score, then a celebration of specific achievements. Mention cache ratio, phase completion, or test results by number. No suggestions needed.

Example:
```
--- Vibe Score: 95/100 (excellent) ---

Clean session. Cache utilization at 73%, all tests passing, and the
feature shipped with complete phase artifacts.

All 5 Tier 2 phases completed with artifacts. No anti-patterns detected.
```

**Good (70-89):**

Lead with the score, state the top observation with data, then list 1-2 suggestions mapped to deductions.

Example:
```
--- Vibe Score: 82/100 (good) ---

Cache utilization was 24% this session -- below the 30% threshold.

Suggestions:
- Use Context7 MCP to look up API docs on-demand instead of pasting
  them into the conversation. This keeps the cache ratio high.
- Complete the docs phase to earn the full phase completion bonus.
```

**Needs Improvement (50-69):**

Lead with the score, enumerate the top issues with data, then list 2-3 suggestions.

Example:
```
--- Vibe Score: 62/100 (needs-improvement) ---

Two issues stood out:

1. Tool loop detected: `npm run build` was called 4 times with identical
   arguments after the first failure (-10). The build error was a missing
   import -- changing the approach after the first failure would have
   saved tokens.

2. No tests were written for the authentication feature (-10). The test
   phase has no artifacts.

Suggestions:
- When a command fails, read the error message and try a different
  approach before retrying the same command.
- Add at least basic happy-path tests before wrapping a feature.
```

**Review Session (0-49):**

Lead with the score, acknowledge it was a difficult session (never blame the user), enumerate the top issues, and provide 2-3 actionable suggestions.

Example:
```
--- Vibe Score: 42/100 (review-session) ---

This was a tough session. Here is what stood out:

1. Prompt churn: 3 correction sequences detected (-15). The AI needed
   multiple redirections on the payment integration.

2. Context violation: The session hit 84% context usage (-20). Consider
   wrapping earlier to preserve context headroom.

3. No feature spec (-5). The payment feature had no plan artifact before
   coding began.

The good news: all tests are passing and the build is clean.

Suggestions:
- For complex features like payments, start with a detailed spec in the
  Plan phase. This reduces mid-session corrections.
- When context exceeds 60%, consider wrapping the session and starting
  fresh. CLAUDE.md carries all learnings into the new session.
- Delegate third-party API research to the Stack Scout so it does not
  consume main session context.
```

### Coaching tone

Follow these principles strictly:
1. **Lead with the score and one key observation.** Do not bury the headline.
2. **Be specific, not generic.** Use numbers: token counts, percentages, deduction values.
3. **Include actionable suggestions.** Every observation must pair with a concrete action.
4. **Celebrate clean sessions.** When no deductions apply, acknowledge it.
5. **Keep it brief.** The coaching section should be readable in 15 seconds.
6. **Never blame the user.** Frame issues as things "the session" or "the AI" did, not things "you" did wrong.
7. **Use data, not opinions.** "4,500 tokens spent on doc pasting" is a fact. "You wasted tokens" is a judgment.

---

## Step 9.5: Performance Coach

After displaying the Vibe Score, invoke the Performance Coach agent for cross-session trend analysis and CLAUDE.md mutation proposals.

### 9.5.1 Check if Performance Coach is enabled

```bash
jq -r '.performance_coach.enabled // true' .vibecrew/config.json 2>/dev/null || echo "true"
```

If the result is `"false"`, skip this step entirely and proceed to Step 10.

### 9.5.2 Check minimum session threshold

```bash
ls -1 .vibecrew/scores/score-*.json 2>/dev/null | wc -l | tr -d ' '
```

If fewer than 5 score files exist, print:
"Performance Coach: Collecting data (N/5 sessions). Trend analysis starts after 5 sessions."
Then skip to Step 10.

### 9.5.3 Run trend analysis

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/aggregate-scores.sh"
```

Parse the trend JSON output and display a one-line trend summary:

```
Trend: {direction} over last {window_size} sessions (avg {average_score}/100)
```

### 9.5.4 Invoke Performance Coach

Invoke the Performance Coach agent. It will:
1. Read the current score file and MEMORY.md
2. Correlate deductions against historical patterns
3. Check mutation eligibility
4. If eligible, present a mutation proposal and wait for user approval
5. Update MEMORY.md and mutation-log.json

The Performance Coach handles its own user interaction for mutation proposals. Wait for it to complete before proceeding to Step 10.

### 9.5.5 User feedback

After the Performance Coach completes (or is skipped), ask the user for session feedback:

```
How was this session? (1-4)
  1 = Frustrating  2 = Okay  3 = Good  4 = Excellent
Optional: Any notes? (press Enter to skip)
```

Wait for the user's response. Store the rating (integer 1-4) and optional comment (string or null).

Update the score file with the feedback:

```bash
today=$(date -u +%Y-%m-%d)
latest_score=$(ls -1t .vibecrew/scores/score-${today}-*.json 2>/dev/null | head -1)
if [[ -n "$latest_score" ]]; then
  jq --argjson rating <RATING> --arg comment "<COMMENT_OR_NULL>" \
    '.user_feedback = {rating: $rating, comment: (if $comment == "" then null else $comment end)}' \
    "$latest_score" > "${latest_score}.tmp" && mv "${latest_score}.tmp" "$latest_score"
fi
```

Also update the trend data in the score file:

```bash
trend_json=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/aggregate-scores.sh" 2>/dev/null || echo '{}')
direction=$(echo "$trend_json" | jq -r '.direction // "unknown"')
window_size=$(echo "$trend_json" | jq -r '.window_size // 0')
avg_score=$(echo "$trend_json" | jq -r '.average_score // 0')

jq --arg dir "$direction" --argjson ws "$window_size" --argjson avg "$avg_score" \
  '.trend = {direction: $dir, window_size: $ws, average_score: $avg}' \
  "$latest_score" > "${latest_score}.tmp" && mv "${latest_score}.tmp" "$latest_score"
```

### 9.5.6 Report outcome

After the Performance Coach completes, print one of:
- "Performance Coach: Mutation applied to CLAUDE.md" (if approved)
- "Performance Coach: Mutation declined" (if rejected)
- "Performance Coach: No mutation proposed" (if no recurring patterns qualified)
- "Performance Coach: Analysis complete" (if no deductions in this session)

---

## Step 9.7: Gamification Processing

After the Performance Coach completes, run the gamification processing pipeline to award XP, check badges, update streaks, and process challenges.

### 9.7.1 Check gamification preference

Read the `gamification_preference` from the profile loaded in Step 1.2. Also check the config flag:

```bash
jq -r '.gamification.enabled // true' .vibecrew/config.json 2>/dev/null || echo "true"
```

Apply gamification display rules based on the profile preference:

- **`disabled`** (or config `enabled` = `false`): Skip all gamification processing and display. Proceed to Step 10.
- **`score_only`**: Run gamification pipeline internally but suppress the `--- Progression ---` section entirely. Only show the Vibe Score.
- **`light`**: Show Level + XP summary. Skip badge announcements, streak reminders, and challenge notifications.
- **`full`**: Show everything — XP, levels, badges, streaks, challenges, quizzes (current behavior).

If preference is `disabled`, skip this step entirely and proceed to Step 10.

### 9.7.2 Run gamification pipeline

Execute these scripts sequentially — each depends on the previous step:

```bash
# 1. Award XP from session data
bash "${CLAUDE_PLUGIN_ROOT}/scripts/award-xp.sh"

# 2. Check and award badges
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-badges.sh"

# 3. Update daily streak
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-streak.sh"

# 4. Distribute XP to skill domains
bash "${CLAUDE_PLUGIN_ROOT}/scripts/distribute-skill-xp.sh"

# 5. Update challenge progress
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-challenges.sh"

# 6. Check for level-up and unlocks
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-level-up.sh"
```

Capture the JSON output from each script. If any script fails, log the error but continue with the remaining scripts.

### 9.7.3 Display progression summary

After the Vibe Score display, append a progression section using the captured outputs:

```
--- Progression ---
Level {level} "{title}" | {xp_this_level}/{xp_to_next_level} XP to Level {next_level}
+{session_xp} (session) +{score_bonus} (score bonus) +{other} (other) = +{total} XP
Streak: {current} days
```

If any skills leveled up, add:
```
Skill: {skill_name} +{xp} XP (Level {old} -> Level {new})
```

If any badges were earned, add:
```
--- New Badges ---
[BADGE] {badge_name} -- {badge_description} (+{xp} XP)
```

If any challenges were completed, add:
```
--- Challenges Completed ---
[{type}] {challenge_name} -- {description} (+{xp} XP)
```

If the player leveled up, add:
```
*** LEVEL UP! Level {old} -> Level {new} "{title}" ***
Unlocked: {comma-separated list of new unlocks, if any}
```

Only show sections that have content. Skip empty sections to keep output concise.

If a quiz is suggested based on session anti-patterns, add:
```
Tip: Try /quiz {quiz-id} to improve your {skill} skills.
```

### Quiz suggestion mapping

| Anti-Pattern Detected | Suggested Quiz |
|---|---|
| Low cache utilization | `context-management-101` |
| Prompt churn | `prompting-basics` |
| No tests | `testing-discipline` |
| No feature spec / missing plan | `architecture-planning` |
| Skipped phases | `workflow-mastery` |

Only suggest one quiz per session (pick the one matching the largest deduction).

---

## Step 10: Session Complete

### 10.5 Auto-generate Handoff and Invoke Doc Generator

#### 10.5.1 Generate handoff document

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/generate-handoff.sh"
```

This creates a structured handoff document at `.vibecrew/handoffs/handoff-{date}-{NNN}.md` that the next session's Session Startup agent will detect and summarize.

Report: "Handoff generated: {filename} ({word_count} words)"

#### 10.5.2 Invoke Doc Generator

Check if any features moved to `done` or `review` during this session, or if source code was modified. If so, invoke the Doc Generator agent to:
1. Check architecture diagram freshness (compare `git diff` against `.vibecrew/architecture/*.mmd` stale detection rules) and update stale diagrams
2. Generate feature docs for newly completed features
3. Update CHANGELOG.md with conventional commits
4. Rebuild VitePress sidebar if docs were added

If no features completed, skip Doc Generator invocation and print:
"Doc Generator: No completed features to document."

---

### 10.1 Update state.json

If the active feature's work is complete (all 6 phases done, or the feature column is `done` or `review`), clear the active feature:

```bash
jq '.active_feature = {id: null, name: null, worktree: null, phase: null, phases_completed: []} | .updated_at = (now | todate)' .vibecrew/state.json > .vibecrew/state.json.tmp && mv .vibecrew/state.json.tmp .vibecrew/state.json
```

If the feature is still in progress (not all phases done), leave `active_feature` as-is so the next session can resume:

```bash
jq '.updated_at = (now | todate)' .vibecrew/state.json > .vibecrew/state.json.tmp && mv .vibecrew/state.json.tmp .vibecrew/state.json
```

### 10.2 Update backlog (if applicable)

If an active feature exists and all work is complete, move it to the `review` column in the backlog:

```bash
jq --arg id "<feature_id>" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   '(.features[] | select(.id == $id)) |= (.column = "review" | .updated_at = $ts)' \
   .vibecrew/backlog.json > .vibecrew/backlog.json.tmp && mv .vibecrew/backlog.json.tmp .vibecrew/backlog.json
```

### 10.3 Print session complete message

```
Session wrapped. Good work!
```

---

## Rules

### Execution rules
- Execute all 10 steps sequentially. Do NOT skip any step.
- Never skip the quality gate, even if no tests exist. Report SKIP for unavailable checks.
- Always write both the session log file (Step 6) and the score file (Step 5). These are mandatory artifacts.
- Use `${CLAUDE_PLUGIN_ROOT}` for all references to plugin scripts and templates.
- Use the temp file pattern (write to `.tmp`, then `mv`) for all JSON file mutations to prevent corruption.

### Git rules
- Never auto-push to a remote repository without explicit user confirmation.
- Never force push. If a push fails, report the error and suggest the user resolve it manually.
- Always include the `Co-Authored-By: Claude <noreply@anthropic.com>` trailer in commits.
- If there are no changes to commit, skip the commit step cleanly without error.

### Scoring rules
- Apply the scoring formula exactly as documented. Do not invent new deduction or bonus categories.
- If data for a metric is unavailable, use the documented default value and note it as "estimated" in the score file evidence.
- The `clean-session` bonus (+2) only applies if the total deduction sum is exactly 0. Check this AFTER applying all deductions.
- Clamp the final score to the range 0-100 inclusive.
- `claude_md_mutation` is always `null` in v1.0.

### Coaching tone rules
- Frame deductions as "the session had X" not "you did X wrong."
- Suggestions must be actionable and specific. Include data points (percentages, counts, tool names).
- Maximum 3 suggestions per session. More than 3 creates decision fatigue.
- Celebrate only specific achievements, not generic praise. Reference numbers.
- Keep the coaching display readable in 15 seconds. Developers skip walls of text.
- Never blame the user. The system observes the session, not the person.

### State management rules
- Only clear the active feature from state.json if all 5 Tier 2 phases are complete or the feature has been moved to `review`/`done`. Otherwise, leave it for the next session to resume.
- Update `backlog.json` column transitions only when the feature is ready to move forward. Do not regress columns.
- Record the session ID in the feature's `sessions` array in `backlog.json` if an active feature exists.
