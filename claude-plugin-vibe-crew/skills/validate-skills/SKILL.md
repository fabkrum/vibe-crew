---
name: validate-skills
description: Evaluate VibeCrew skill quality, trigger reliability, and retirement readiness
disable-model-invocation: true
model: opus
allowed-tools: Read, Bash, Glob, Grep
category: utility
---

# VibeCrew Skill Validation

Evaluate all VibeCrew skills across three tiers: static schema check, model-version tracking, and A/B test recommendations.

## Tier 1: Static Schema Check (always runs)

Enumerate all skills and validate their frontmatter quality.

```bash
# List all skills
for skill_dir in "${CLAUDE_PLUGIN_ROOT}/skills/"*/; do
  skill_file="${skill_dir}SKILL.md"
  if [[ -f "$skill_file" ]]; then
    # Extract frontmatter
    name=$(sed -n 's/^name: *//p' "$skill_file" | head -1)
    desc=$(sed -n 's/^description: *//p' "$skill_file" | head -1)
    hint=$(sed -n 's/^argument-hint: *//p' "$skill_file" | head -1)
    model=$(sed -n 's/^model: *//p' "$skill_file" | head -1)
    tools=$(sed -n 's/^allowed-tools: *//p' "$skill_file" | head -1)
    category=$(sed -n 's/^category: *//p' "$skill_file" | head -1)
    context=$(sed -n 's/^context: *//p' "$skill_file" | head -1)
    agent=$(sed -n 's/^agent: *//p' "$skill_file" | head -1)
    disable=$(sed -n 's/^disable-model-invocation: *//p' "$skill_file" | head -1)

    # Token cost estimate
    bytes=$(wc -c < "$skill_file" | tr -d ' ')

    # Check for modern patterns
    has_args=$(grep -c '\$ARGUMENTS\|\$0' "$skill_file" 2>/dev/null || echo "0")
    has_backtick=$(grep -c '^.*!`' "$skill_file" 2>/dev/null || echo "0")

    # Schema score: +1 for each present field
    score=0
    [[ -n "$name" ]] && score=$((score + 1))
    [[ -n "$desc" ]] && score=$((score + 1))
    [[ -n "$category" ]] && score=$((score + 1))
    [[ -n "$model" || "$disable" == "true" ]] && score=$((score + 1))
    [[ "$has_args" -gt 0 || -z "$(sed -n 's/^args: *//p' "$skill_file" | head -1)" ]] && score=$((score + 1))

    echo "$name|$category|$score/5|${model:-—}|${context:-—}|${bytes}B|args:$has_args|inject:$has_backtick|${hint:+hint}${hint:-—}"
  fi
done
```

Display results as a table:

```
Skill Health Report
===================

| Skill | Category | Schema | Model | Context | Size | Modern Patterns | Hint |
|-------|----------|--------|-------|---------|------|-----------------|------|
```

Flag skills missing:
- `category` — "MISSING: add category field"
- `model` (when not `disable-model-invocation: true`) — "MISSING: consider model routing"
- `argument-hint` (when skill accepts args) — "MISSING: add argument-hint"

## Tier 2: Model-Version Tracking (always runs)

Check if the model version has changed since last validation.

```bash
# Read current model version
CURRENT_MODEL="${CLAUDE_MODEL:-unknown}"

# Read last validated model
LAST_MODEL=$(cat "${CLAUDE_PLUGIN_ROOT}/.last-validated-model.txt" 2>/dev/null || echo "none")

echo "Current model: $CURRENT_MODEL"
echo "Last validated: $LAST_MODEL"
```

Compare against each skill's last validation record in `.vibecrew/reviews/skill-health-*.json`.

If the model has changed since last validation:
- Flag ALL `analysis` and `action` category skills as "needs re-evaluation"
- Cross-reference with telemetry for usage counts

Write a per-skill validation record:

```bash
mkdir -p .vibecrew/reviews
TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
```

Write to `.vibecrew/reviews/skill-health-${TIMESTAMP}.json` with fields:
- `skill`: skill name
- `model_version`: current model
- `validated_at`: ISO timestamp
- `tier1_score`: schema completeness score
- `needs_ab_test`: boolean (true if model changed + category is analysis/action)

Update the last-validated-model file:

```bash
echo "$CURRENT_MODEL" > "${CLAUDE_PLUGIN_ROOT}/.last-validated-model.txt"
```

## Tier 3: A/B Test Recommendation (capability-uplift skills only)

For skills flagged by Tier 2 (model changed) or with `category: analysis|action`:
- Output: "Recommend A/B test via Skill Creator plugin"
- Generate the exact command: `/skill-creator test <skill-name>`
- If Skill Creator plugin not installed, output install instructions

For skills with existing A/B test results in `.vibecrew/reviews/`:
- Show last test date, model version, success rate delta, token impact

## Output

Display a summary table and write the health report:

```
Skill Validation Summary
========================
Total skills:           N
Schema score avg:       X.X/5
Missing category:       N skills
Missing model routing:  N skills
Model changed:          yes/no (current vs last)
Needs re-evaluation:    N skills (analysis + action category)

Health report: .vibecrew/reviews/skill-health-<timestamp>.json
```

If the model has changed, add a prominent alert:

```
MODEL CHANGE DETECTED
=====================
Previous: <old-model>
Current:  <new-model>

N capability-uplift skills flagged for re-evaluation.
Run /skill-creator test <skill-name> to A/B test flagged skills.
```

## Evaluation Workflow Reference

For users who want to set up ongoing skill evaluation:

1. **Detection:** SessionStart warns when the model changes
2. **Evaluation:** `/validate-skills` flags capability-uplift skills needing A/B tests
3. **Testing:** Run Skill Creator A/B tests on flagged skills (`/skill-creator test <name>`)
4. **Tracking:** Results stored in `.vibecrew/reviews/` with model version

**Retirement criteria:**
- Usage = 0 for 90+ days (from telemetry)
- A/B test shows no improvement over base model
- Model's base capability exceeds skill's uplift

**Trigger optimization:**
- Use Skill Creator's 60/40 train/test split for trigger refinement
- Re-evaluate triggers after every model upgrade

## Rules

- This is a **read-only analysis** skill (except for writing the health report and model tracking file).
- Do NOT modify any SKILL.md files. Only report findings.
- Use `${CLAUDE_PLUGIN_ROOT}` for all plugin-relative paths.
- Keep the output concise. The JSON health report has all details.
