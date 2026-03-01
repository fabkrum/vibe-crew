# Vibe Score System

> **Architecture Document 2.6** | VibeCrew Plugin | v1.0
>
> This document defines the Vibe Score system -- a per-session metric (0-100) that measures developer-AI collaboration efficiency. The Verifier agent calculates the score during the `/wrap` command. Score file schemas are defined in [`architecture/schemas.md` Section 6](schemas.md#6-score-files); this document provides the rationale, detection methods, metric collection, coaching output format, and v1.1 roadmap.

---

## Table of Contents

1. [Vibe Score Overview](#1-vibe-score-overview)
2. [Score Calculation](#2-score-calculation)
3. [Metric Collection](#3-metric-collection)
4. [Coaching Output](#4-coaching-output)
5. [Rating Thresholds](#5-rating-thresholds)
6. [v1.1 Roadmap](#6-v11-roadmap)

---

## 1. Vibe Score Overview

### Purpose

The Vibe Score answers one question: **"How efficient was this session?"** It is a coaching tool, not a report card. Every deduction maps to a specific behavior the user or AI can change in the next session.

### Scale

- **Range:** 0-100 (clamped)
- **Base score:** 100 (every session starts perfect)
- **Direction:** Subtractive -- anti-patterns reduce the score from 100
- **Bonuses:** Quality signals can add points back, up to a maximum of +27

### Why Subtractive?

A subtractive model is easier to reason about than a weighted additive model. Developers intuitively understand "I lost 10 points for tool loops" better than "my tool efficiency weight contributed 0.73 to my composite score." The deduction framing also makes the coaching actionable: each deduction maps to a specific behavior to change.

### v1.0 Scope

In v1.0, the Vibe Score is:

- **Per-session only.** Calculated once during `/wrap` by the Verifier agent (see [agents.md Section 7](agents.md#7-verifier-agent), `maxTurns: 60`).
- **No cross-session trends.** The Verifier does not read historical score files or maintain persistent memory.
- **No CLAUDE.md mutations.** The system provides suggestions but does not propose rule changes.
- **Simple output.** A suggestions array and an optional celebration string.

Features deferred to v1.1 are documented in [Section 6](#6-v11-roadmap).

---

## 2. Score Calculation

### 2.1 Formula

```
score = 100

# Apply deductions (each category has a per-category cap)
score -= 5  * min(churn_sequences, 3)                          # prompt-churn: -5 each, max -15
score -= 10 * min(tool_loops, 3)                               # tool-loop: -10 each, max -30
score -= 15 * (1 if cache_ratio < 0.30 else 0)                # low-cache: max -15
score -= 20 * (1 if peak_context_pct > 80 else 0)             # context-violation: max -20
score -= 10 * (1 if no_tests else 0)                           # no-tests: max -10
score -= 5  * (1 if no_spec else 0)                            # no-spec: max -5
score -= 3  * min(phases_skipped, 6)                           # missing-phase: -3 each, max -18
score -= 5  * (1 if skipped_review else 0)                     # skipped-review: max -5
score -= 3  * min(stale_docs, 3)                               # doc-drift: -3 each, max -9

# Apply bonuses
score += 5  * (1 if all_six_phases_complete else 0)            # all-phases: +5
score += 5  * (1 if cache_ratio > 0.70 else 0)                # high-cache: +5
score += 3  * (1 if test_coverage_pct > 80 else 0)            # full-coverage: +3
score += 2  * (1 if zero_deductions else 0)                    # clean-session: +2
score += 3  * (1 if tdd_discipline else 0)                     # tdd-discipline: +3
score += 3  * (1 if e2e_tests_passing else 0)                  # e2e-passing: +3
score += 2  * (1 if a11y_clean else 0)                         # a11y-clean: +2
score += 2  * (1 if review_complete else 0)                    # review-complete: +2
score += 2  * (1 if perf_baselines else 0)                     # perf-baselines: +2

# Clamp
score = max(0, min(100, score))
```

### 2.2 Deduction Rules

Each deduction category has a per-category cap. Deductions are applied at most to the cap per session.

| Category | Points | Per-Category Cap | Detection Method | Rationale |
|----------|--------|------------------|------------------|-----------|
| `prompt-churn` | -5 per sequence | -15 (3 sequences) | 3+ consecutive user messages that rephrase the same request without meaningful progress between them. See [Section 3.2](#32-prompt-churn-detection). | Indicates vague initial instructions. Each correction wastes ~300-500 tokens re-reading context. |
| `tool-loop` | -10 per loop | -30 (3 loops) | Same tool called 3+ times with identical or near-identical arguments. See [Section 3.3](#33-tool-loop-detection). | Agent stuck in a retry loop without adapting. Each loop wastes ~1,000 tokens and wall-clock time. |
| `low-cache` | -15 | -15 | Cache hit rate below 30%. See [Section 3.1](#31-token-and-context-metrics). | Context is churning -- new content is pushing cached content out. Likely caused by doc pasting, excessive corrections, or rapidly changing instructions. |
| `context-violation` | -20 | -20 | Context usage exceeded 80%. See [Section 3.1](#31-token-and-context-metrics). | Session pushed into the danger zone for context exhaustion. Risk of forced compaction and lost state. |
| `no-tests` | -10 | -10 | No test files created or modified during the session. See [Section 3.4](#34-test-and-quality-metrics). | Feature shipped without test coverage. Higher defect risk and harder to refactor. |
| `no-spec` | -5 | -5 | Feature work started without acceptance criteria in `backlog.json`. See [Section 3.5](#35-phase-completion-metrics). | Implementation began without a deliberate plan. Increases rework probability. |
| `missing-phase` | -3 per phase | -18 (6 phases) | Any Tier 2 phase skipped (no artifacts recorded in `state.json`). See [Section 3.5](#35-phase-completion-metrics). | Skipping phases reduces the quality feedback loop. |
| `doc-drift` | -3 per stale doc | -9 (3 docs) | Source code changed but matching feature docs not updated. New API endpoints/routes without doc coverage. See [Section 3.6](#36-documentation-drift-detection). | Stale docs mislead future sessions and accumulate technical debt. Counted within the `missing-phase` category for the Docs phase. |

**Total deduction caps:**

- Sum of all per-category caps: -15 + -30 + -15 + -20 + -10 + -5 + -18 + -5 + -9 = **-127** (theoretical maximum if every rule fires at its cap)
- Practical maximum: **-75** (unlikely that all categories fire simultaneously at cap)
- Minimum possible score: **0** (clamped). Realistically around **25** in a worst-case session.

### 2.3 Bonus Rules

Bonuses reward quality signals. They are applied after deductions but cannot push the score above 100.

| Category | Points | Detection | Rationale |
|----------|--------|-----------|-----------|
| `all-phases` | +5 | All 6 Tier 2 phases completed (Plan, Design, Code, Test, Review, Docs all have artifacts in `state.json`) | Full lifecycle discipline. Features with all phases have lower defect rates. |
| `high-cache` | +5 | Cache hit rate above 70% | Session efficiently reusing cached context. Indicates clear prompts and stable conversation structure. |
| `full-coverage` | +3 | Test coverage above 80% (from test runner output) | High test coverage reduces regression risk and improves confidence in the codebase. |
| `clean-session` | +2 | Zero deductions applied | Flawless session with no detected anti-patterns. |
| `tdd-discipline` | +3 | Commits with `TDD cycle:` trailer detected via `detect-tdd-discipline.sh` | Test-driven development produces higher-quality code with fewer regressions. |
| `e2e-passing` | +3 | Playwright spec files exist and test results show pass | End-to-end tests validate full user flows, catching integration issues unit tests miss. |
| `a11y-clean` | +2 | axe-core report in `.vibecrew/a11y/` with zero critical/serious violations | Accessible software reaches more users and avoids legal risk. |
| `review-complete` | +2 | Review report exists in `.vibecrew/reviews/` for active feature | Code review catches defects, enforces conventions, and validates TDR compliance. |
| `perf-baselines` | +2 | k6 results exist in `.vibecrew/perf-tests/` for active feature | Performance baselines prevent regressions and set expectations for scaling. |

**Maximum total bonuses:** +27. **Maximum possible score:** 100 (clamped).

### 2.4 Why Bonuses Cannot Compensate for Anti-Patterns

Bonuses are capped at +27 total. A session with 3 tool loops (-30) but clean lint, high cache, and TDD (+13) should still score poorly (83). Bonuses reward completeness; they do not compensate for waste.

---

## 3. Metric Collection

The Verifier agent gathers metrics from four sources during `/wrap`. No external analytics services are required -- all data comes from the Claude Code session environment and project state files.

### 3.1 Token and Context Metrics

**Source:** The Verifier reads token usage data from the session. Claude Code provides token counts (input tokens, cache read tokens, output tokens) in its usage reporting.

**Calculated values:**

| Metric | Calculation | Used For |
|--------|-------------|----------|
| `cache_ratio` | `total_cache_read / total_input` (0 if `total_input` is 0) | `low-cache` deduction (<0.30), `high-cache` bonus (>0.70) |
| `peak_usage_percent` | Highest context utilization observed during the session, as a percentage of the model's context window | `context-violation` deduction (>80%) |

**Implementation note:** The Verifier should read the context usage percentage from the `check-context.sh` hook output stored in `state.json`, which tracks whether the 60% or 80% warning thresholds were triggered during the session. If the hook data is not available, the Verifier estimates peak usage from the token counts available in the session.

### 3.2 Prompt Churn Detection

**What to look for:** Sequences of 3 or more consecutive user messages that rephrase the same request without meaningful progress between them. This indicates the initial instruction was vague or incorrect, forcing the user to repeatedly redirect the AI.

**Detection logic:**

```
churn_sequences = 0
consecutive_user_messages = 0

For each turn in the session:
  If the turn is a user message:
    consecutive_user_messages += 1
  If the turn includes successful tool completions:
    If consecutive_user_messages >= 3:
      churn_sequences += 1
    consecutive_user_messages = 0
```

**Important:** The Verifier does not depend on specific transcript field names or event type identifiers -- Claude Code's internal transcript format may change between versions. Instead, the Verifier examines the conversation flow conceptually: user messages that occur in rapid succession without the AI making progress (creating files, running commands successfully, etc.) indicate churn.

**Cap:** `min(churn_sequences, 3)` -- maximum 3 sequences counted, maximum -15 deduction.

### 3.3 Tool Loop Detection

**What to look for:** The same tool called 3 or more times with identical or near-identical arguments without changing approach. This indicates the agent is retrying a failed operation rather than diagnosing and fixing the root cause.

**Detection logic:**

```
recent_tools = []   # sliding window of (tool_name, arguments_summary) tuples
tool_loops = 0

For each tool call in the session:
  recent_tools.append((tool_name, arguments_summary))
  If len(recent_tools) > 3:
    recent_tools.pop(0)
  If len(recent_tools) == 3:
    If all three entries are identical or near-identical:
      tool_loops += 1
      recent_tools = []   # reset window to avoid double-counting
```

**Near-identical:** Arguments that differ only in whitespace, trailing newlines, or trivial reformatting are treated as identical. The Verifier uses its judgment for this comparison -- it does not require exact string equality.

**Cap:** `min(tool_loops, 3)` -- maximum 3 loops counted, maximum -30 deduction.

### 3.4 Test and Quality Metrics

**Source:** The Verifier runs (or reads cached results from) the project's test runner and linter as part of the `/check` step that precedes scoring in `/wrap`.

| Metric | Source | Used For |
|--------|--------|----------|
| Tests exist | Whether any test files were created or modified during the session (checked via `state.json` Test phase artifacts) | `no-tests` deduction |
| Test coverage percent | Parsed from test runner output (e.g., Vitest coverage summary) | `full-coverage` bonus (>80%) |
| Tests passing | Exit code from `npm test` or equivalent | Coaching commentary |
| Lint clean | Exit code and output from project linter | Coaching commentary |
| Build passes | Exit code from `npm run build` or equivalent | Coaching commentary |

**Note:** Test coverage is used only for the `full-coverage` bonus, not as a deduction. Coverage targets vary dramatically by project type (a CLI tool vs. a UI-heavy app), so the system does not penalize based on a fixed threshold.

### 3.5 Phase Completion Metrics

**Source:** `.vibecrew/state.json` -- the feature's phase tracking object.

| Metric | Source | Used For |
|--------|--------|----------|
| All phases complete | All 6 Tier 2 phases (Plan, Design, Code, Test, Review, Docs) have artifacts in `state.json` | `all-phases` bonus |
| Phases skipped | Count of Tier 2 phases without artifacts | `missing-phase` deduction (-3 per phase, max -18) |
| Spec before code | Plan phase has artifacts AND Code phase start timestamp is after Plan phase completion timestamp | `no-spec` deduction (if false) |

**Schema reference:** See [`architecture/schemas.md` Section 3](schemas.md#3-statejson) for the `state.json` feature phase structure.

### 3.6 Documentation Drift Detection

**Source:** Git diff of the current session combined with feature doc file timestamps.

**What to look for:** Source code files modified during the session that have corresponding feature documentation which was NOT updated in the same session.

**Detection logic:**

```
stale_docs = 0

# Get source files changed in this session (from git diff or state.json session artifacts)
changed_source_files = files modified in session (excluding test files, config, docs)

# For each active/completed feature with code changes:
For each feature with modified source files:
  feature_doc_path = "docs/features/{feature-id}/"
  If feature_doc_path exists:
    If no doc files in feature_doc_path were modified this session:
      stale_docs += 1
  Else if feature is in "done" or "review" status:
    stale_docs += 1   # completed feature with no docs at all

# Also check for new API routes/endpoints without doc coverage
new_routes = scan changed files for new route/endpoint definitions
For each new_route:
  If no matching API reference section exists in feature docs:
    stale_docs += 1
```

**Cap:** `min(stale_docs, 3)` -- maximum 3 drift items counted, maximum -9 deduction. This counts within the `missing-phase` Docs phase category. If the Docs phase is already marked as skipped entirely, the `doc-drift` sub-deductions are not applied on top (no double-counting).

**Scope:** `stale_docs` includes both feature documentation in `docs/features/` AND architecture diagrams in `.vibecrew/architecture/*.mmd`. A stale architecture diagram (e.g., `schema.mmd` not updated after a migration change) counts as one stale doc toward the cap.

**Implementation:** The `calculate-vibe-score.sh` script detects drift by comparing `git diff --name-only` output against doc directory modification times and architecture diagram stale detection rules. The Doc Generator agent resolves drift during `/wrap` by auto-generating or updating stale docs and diagrams.

---

## 4. Coaching Output

### 4.1 v1.0 Output Structure

The Verifier produces two coaching fields in the score file (see [`architecture/schemas.md` Section 6](schemas.md#6-score-files) for the full schema):

```jsonc
{
  "coaching": {
    "suggestions": [
      // 1-3 actionable suggestions, only if deductions occurred
      "Use Context7 MCP to look up API docs on-demand instead of pasting them into the conversation.",
      "Complete the docs phase to earn the full phase completion bonus."
    ],
    "celebration": "Cache utilization at 72% -- great context management this session."
    // celebration is null if there is nothing to celebrate
  }
}
```

**v1.0 does not include `claude_md_mutation`.** That field is always `null`. See [Section 6](#6-v11-roadmap) for the mutation system planned for v1.1.

### 4.2 Suggestion Rules

- **1-3 suggestions maximum.** More than 3 creates decision fatigue.
- **Only if deductions occurred.** A clean session gets a celebration, not suggestions.
- **Each suggestion maps to a deduction.** The user can trace every suggestion back to a specific score impact.
- **Actionable and specific.** "Your cache utilization was 18%" is useful. "Try to be more efficient" is not.
- **Include data.** Reference token counts, percentages, and tool names where available.

### 4.3 Celebration Rules

- **Celebrate when the session has zero deductions.** A clean session deserves recognition.
- **Celebrate specific achievements.** "All 6 phases completed" or "Cache utilization at 72%" -- not generic "good job" messages.
- **Keep it brief.** One sentence is enough.

### 4.4 Coaching Tone

The Verifier's coaching output follows these tone principles:

1. **Lead with the score and one key observation.** Do not bury the headline.
2. **Be specific, not generic.** Use numbers: token counts, percentages, deduction values.
3. **Include actionable suggestions.** Every observation must pair with a concrete action.
4. **Celebrate clean sessions.** When no deductions apply, acknowledge it.
5. **Keep it brief.** The coaching section should be readable in 15 seconds. Developers skip walls of text.
6. **Never blame the user.** Frame issues as things "the session" or "the AI" did, not things "you" did wrong.
7. **Use data, not opinions.** "4,500 tokens spent on doc pasting" is a fact. "You wasted tokens" is a judgment.

### 4.5 Coaching Display Format

The Verifier presents the score to the user as part of the `/wrap` output:

```
--- Vibe Score: {score}/100 ({rating}) ---

{top_observation}

{suggestions}  (1-3 bullet points, only if deductions occurred)

{celebration}  (only if score >= 90 or zero deductions)
```

### 4.6 Example Outputs by Score Range

**Excellent (90-100):**

```
--- Vibe Score: 94/100 (Excellent) ---

Clean session. Cache utilization at 72%, all tests passing, and the
feature shipped with complete phase artifacts.

All 5 Tier 2 phases completed with artifacts. No anti-patterns detected.
```

**Good (70-89):**

```
--- Vibe Score: 82/100 (Good) ---

Cache utilization was 22% this session -- below the 30% threshold. The
session included several large documentation blocks pasted into the
conversation (~4,500 tokens).

Suggestions:
- Use Context7 MCP to look up API docs on-demand instead of pasting
  them into the conversation.
- Complete the Docs phase to earn the full phase completion bonus.
```

**Needs Improvement (50-69):**

```
--- Vibe Score: 65/100 (Needs Improvement) ---

Two issues stood out:

1. Tool loop detected: `npm run build` was called 4 times with identical
   arguments after the first failure (-10). The build error was a missing
   import -- changing the approach after the first failure would have
   saved ~3,000 tokens.

2. No tests were written for the authentication feature (-10). The Test
   phase has no artifacts.

Suggestions:
- When a command fails, read the error message and try a different
  approach before retrying the same command.
- Add at least basic happy-path tests before wrapping a feature.
```

**Review Session (0-49):**

```
--- Vibe Score: 42/100 (Review Session) ---

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

---

## 5. Rating Thresholds

| Range | Rating | Interpretation |
|-------|--------|----------------|
| 90-100 | `excellent` | Efficient, well-structured session. Minimal waste. |
| 70-89 | `good` | Minor inefficiencies. One or two coaching suggestions. |
| 50-69 | `needs-improvement` | Notable token waste or missing quality artifacts. Multiple suggestions. |
| 0-49 | `review-session` | Significant anti-patterns. Review the workflow before the next session. |

**Note:** These thresholds match [`architecture/schemas.md` Section 6](schemas.md#6-score-files) rating definitions. Both documents must stay in sync -- schemas.md is the source of truth for the enum values and ranges.

---

## 6. v1.1 Roadmap

The following features are deferred from v1.0 and planned for v1.1 when the Performance Coach agent is introduced as a standalone agent with persistent memory.

### 6.1 Performance Coach Agent

In v1.1, a dedicated Performance Coach agent replaces the Verifier's scoring responsibilities:

- **Model:** Opus
- **Isolation:** Inline (runs in the main context)
- **Memory:** `memory: project` -- persistent cross-session memory stored at `.claude/agent-memory/performance-coach/MEMORY.md`
- **Trigger:** Invoked by `/wrap` after the Verifier completes quality checks

The Performance Coach is defined in [`architecture/agents.md`](agents.md). In v1.0, its scoring logic is absorbed by the Verifier agent (`maxTurns: 60`).

### 6.2 Cross-Session Trend Analysis

The Performance Coach reads historical score files from `.vibecrew/scores/` to identify trends across the last 10 sessions:

| Trend | Signal | Coach Response |
|-------|--------|----------------|
| Improving scores (3+ sessions) | System is learning effectively | Celebrate: "Your scores have improved 3 sessions in a row." |
| Declining scores (3+ sessions) | New complexity or degrading habits | Investigate and suggest workflow changes |
| Recurring anti-pattern | Same deduction appearing across sessions | Escalate mutation priority |
| Score plateau below 90 | Stable but suboptimal | Suggest new strategies |
| High score volatility | Wide swings between sessions | Identify patterns in low-scoring sessions |

### 6.3 CLAUDE.md Mutation System

The mutation system is the mechanism by which session-level observations become permanent project rules:

1. **Detection** -- Performance Coach identifies a recurring anti-pattern
2. **Correlation** -- Coach checks `MEMORY.md` for prior occurrences
3. **Proposal** -- Coach formulates a concrete, actionable CLAUDE.md rule
4. **Presentation** -- Coach presents the proposal with context and data
5. **Decision** -- User approves or rejects
6. **Application** -- If approved, rule is appended to CLAUDE.md's "Session Learnings" section
7. **Recording** -- Decision is written to `MEMORY.md`

**Guardrails:**

- Never auto-apply. Every mutation requires explicit user approval.
- One mutation per session maximum (to avoid decision fatigue).
- No duplicate rules -- check CLAUDE.md before proposing.
- Respect rejections -- do not re-propose a rejected rule unless the anti-pattern recurs 3+ more times.

### 6.4 Anti-Pattern to Rule Mapping (v1.1)

| Anti-Pattern | Rule Template |
|--------------|---------------|
| Low cache utilization from doc pasting | "Always use Context7 MCP to look up {library} API documentation instead of pasting docs into chat." |
| Tool loops on failed bash commands | "If a command fails twice, try a different approach before retrying." |
| Context violation from long research | "Delegate research tasks to the Stack Scout sub-agent to preserve main session context." |
| No feature spec before coding | "Always create a feature spec (Plan phase) before writing any implementation code." |
| Repeated prompt corrections | "Write detailed initial prompts that include: what to build, acceptance criteria, and file paths." |

### 6.5 Persistent Memory Format (v1.1)

The Performance Coach's `MEMORY.md` will track:

- Anti-patterns seen in previous sessions (with counts and session IDs)
- Mutations proposed and their acceptance/rejection status
- Score trends (last 5 scores for quick reference)
- User preferences expressed during feedback

### 6.6 User Feedback Collection (v1.1)

The `/wrap` command will collect user feedback after presenting the Vibe Score:

```
How was this session?
  1. Great     -- smooth, productive, no friction
  2. Good      -- minor issues, overall positive
  3. Okay      -- could be better, some friction
  4. Rough     -- significant issues, frustrating at times

Optional: Any specific feedback? (press Enter to skip)
```

Feedback-score correlation allows the Performance Coach to calibrate its analysis: a high score with low satisfaction means the system is missing a pain point; a low score with high satisfaction means the session was exploratory.

---

## Design Decisions Log

### Why per-category caps instead of "uncapped" deductions?

An earlier draft described deductions as "uncapped" while simultaneously showing per-category maximums in the deduction table. This was contradictory. The resolution: each deduction category has an explicit per-category cap (e.g., `prompt-churn` caps at -15 for 3 sequences). The theoretical maximum deduction is -110 (sum of all caps), but practically a session is unlikely to hit every cap simultaneously. The floor is 0 (clamped).

### Why defer CLAUDE.md mutations to v1.1?

Mutations require cross-session memory (`memory: project`) and a dedicated agent context to correlate anti-patterns across sessions. In v1.0, the Verifier handles scoring as a secondary responsibility alongside testing and quality checks. Adding mutation logic would bloat the Verifier's prompt and risk exceeding its context budget. A standalone Performance Coach agent with persistent memory is a cleaner fit.

### Why not use specific transcript field names?

Claude Code's internal transcript format is not a public API and may change between versions. The detection algorithms describe what patterns to look for (consecutive user messages without progress, repeated tool calls with identical arguments) rather than relying on specific JSON field names like `UserPromptSubmit` or `PreToolUse`. The Verifier, as a Sonnet-class agent reading the session, can identify these patterns conceptually without depending on a fixed schema.

### Why is test coverage a bonus, not a deduction?

Coverage targets vary dramatically by project type. A CLI tool might reasonably have 95% coverage; a UI-heavy app might sit at 60% and still be well-tested through component tests. The system rewards high coverage (+3 for >80%) without penalizing projects that have a legitimate reason for lower numbers.
