# Skill Evaluation Framework

> **Phase 2 Architecture** | Document 12 | March 2026
>
> Framework for evaluating VibeCrew skill quality, detecting model-change impacts, and tracking retirement readiness. Covers skill categories, the `/validate-skills` command, the `validate-skill-schema.sh` hook, and model-version tracking.

---

## 1. Skill Categories

Every skill has a `category` field in its YAML frontmatter. Categories determine maintenance strategy and evaluation frequency.

| Category | Count | Skills | Maintenance Strategy |
|---|---|---|---|
| `workflow` | 7 | setup, new-project, plan-features, new-feature, run-backlog, wrap, release | Encode preferences — durable, optimize triggers |
| `analysis` | 6 | review, simplify, audit, onboard, system-review, check | Capability uplift — A/B test after model upgrades |
| `action` | 8 | fix-issue, heal, apply-simplifications, tdd, e2e, a11y, perf-test, debug | Capability uplift — A/B test after model upgrades |
| `dashboard` | 4 | status, cost, achievements, handoff | Route to cheapest model (Haiku) |
| `utility` | 9 | idea, undo, recover-state, replay, reconsider, sync-issues, profile, quiz, validate-skills | Low maintenance — test on regression only |

**Capability-uplift skills** (`analysis` + `action`) are the primary candidates for re-evaluation after model upgrades, because the model's improved base capabilities may exceed the skill's uplift value.

---

## 2. Model-Version Tracking

### 2.1 Detection (SessionStart)

`session-startup.sh` compares `$CLAUDE_MODEL` against `${CLAUDE_PLUGIN_ROOT}/.last-validated-model.txt`. If different, outputs a one-line warning:

```
Model changed (opus-4-6 → opus-5-0). Run /validate-skills to check skill health.
```

### 2.2 Evaluation (`/validate-skills`)

Three-tier evaluation:

1. **Tier 1 — Static Schema Check**: Validates frontmatter completeness (name, description, category, model, allowed-tools, argument-hint). Reports schema score per skill.
2. **Tier 2 — Model-Version Tracking**: Compares current model against last validated model. Flags all capability-uplift skills for re-evaluation if model changed.
3. **Tier 3 — A/B Test Recommendation**: For flagged skills, recommends A/B testing via the Skill Creator plugin.

### 2.3 Health Report

Written to `.vibecrew/reviews/skill-health-<timestamp>.json` with per-skill records:

```json
{
  "skill": "review",
  "model_version": "opus-4-6",
  "validated_at": "2026-03-05T12:00:00Z",
  "tier1_score": "5/5",
  "needs_ab_test": true
}
```

---

## 3. Schema Validation Hook

`validate-skill-schema.sh` is a PostToolUse hook that fires on every Write/Edit to a `SKILL.md` file.

**Checks:**
- Required: `name`, `description` (exit 2 to block if missing)
- Recommended: `category` (warn if missing)
- Consistency: `argument-hint` required when `$ARGUMENTS`/`$0` used in body
- Consistency: `agent:` required when `context: fork` is set
- Category values: must be one of `workflow`, `analysis`, `action`, `dashboard`, `utility`

---

## 4. Retirement Criteria

A skill is a candidate for retirement when:

- **Usage = 0** for 90+ days (from telemetry)
- **A/B test shows no improvement** over the model's base capability
- **Model's base capability exceeds** the skill's uplift value

---

## 5. Modern Skill Patterns

### 5.1 Dynamic Injection (`!` backtick)

Skills pre-load data at skill load time using `!` backtick syntax. This eliminates the first "read state" turn, saving tokens. Used by: `/status`, `/cost`, `/fix-issue`, `/heal`, `/check`, `/wrap`.

### 5.2 Native Substitution (`$0` / `$ARGUMENTS`)

Skills accept arguments via `$0` (first argument) and `$ARGUMENTS` (full string). Claude Code replaces these before the model sees the prompt. Used by: `/fix-issue`, `/reconsider`, `/debug`, `/a11y`, `/e2e`, `/perf-test`, `/release`, `/quiz`, `/replay`.

### 5.3 Forked Skills (`context: fork`)

Skills with `context: fork` + `agent:` run their agent in an isolated subagent context. The agent produces complete output (including terminal formatting) and returns only the result. Used by: `/review`, `/simplify`, `/audit`, `/system-review`.

### 5.4 Model Routing (`model:`)

Dashboard skills route to `haiku` for cost optimization. Doc-generation skills route to `sonnet`. Complex orchestration skills use the default (Opus).

### 5.5 Tool Restriction (`allowed-tools:`)

Read-only skills restrict tool access to prevent accidental writes. Dashboard skills use `Read, Bash, Glob, Grep`.
