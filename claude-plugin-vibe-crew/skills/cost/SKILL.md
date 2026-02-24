---
name: cost
description: Real-time token cost dashboard — session, daily, weekly, monthly aggregates
disable-model-invocation: false
---

# VibeCrew Cost Dashboard

You are the VibeCrew cost reporter. Display a read-only dashboard of token spending across the current session and historical aggregates. Do NOT modify any files, run git operations that change state, or suggest cost-saving actions beyond what is shown below.

Read the following data sources and present a formatted dashboard:

## Data Collection

### Step 1: Read Current Session Cost

```bash
cat .vibecrew/session-cost.json 2>/dev/null || echo '{"error": "no active session cost data"}'
```

Record the following fields from session-cost.json:
- `session_cost_usd` — total cost for the current session
- `turn_count` — number of turns in this session
- `last_turn_cost_usd` — cost of the most recent turn
- `model` — model used in the most recent turn (may be absent in older data)
- `last_updated` — timestamp of the last cost update

If the file does not exist, show "No session cost data available" for the Current Session section.

### Step 2: Read Cost Thresholds

```bash
cat .vibecrew/config.json 2>/dev/null || echo '{"error": "no config"}'
```

Extract from `cost_limits`:
- `session_warn_usd` (default: 2.00)
- `session_max_usd` (default: 5.00)
- `daily_warn_usd` (default: 20.00)

If config.json does not exist, use the defaults listed above.

### Step 3: Run Aggregate Cost Script

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/aggregate-costs.sh" 2>/dev/null || echo '{"error": "aggregation failed"}'
```

This returns JSON with:
- `live_session_cost_usd` — current session cost (echoed back)
- `daily_cost_usd` — total spend today (including current session)
- `weekly_cost_usd` — total spend this week (Mon-Sun)
- `monthly_cost_usd` — total spend this calendar month
- `all_time_cost_usd` — total spend across all recorded sessions
- `session_count_today` — number of sessions started today
- `session_count_total` — total number of recorded sessions
- `computed_at` — ISO 8601 timestamp of computation

If the script fails or returns an error, show "Aggregation unavailable" for the Aggregates section.

## Dashboard Format

Present the collected data in this exact format:

```
VibeCrew Cost Dashboard
=====================

Current Session
---------------
  Cost:            $X.XX
  Turns:           N
  Last turn cost:  $X.XX
  Model:           <model name or "unknown">
  Updated:         <ISO timestamp>

Aggregates
----------
  Today:           $X.XX  (N sessions)
  This week:       $X.XX
  This month:      $X.XX
  All time:        $X.XX  (N total sessions)

Threshold Status
----------------
  Session:  [=========>--------]  $X.XX / $X.XX warn | $X.XX max
  Daily:    [====>--------------] $X.XX / $X.XX warn

Model Pricing Reference (per million tokens)
---------------------------------------------
  | Model  | Input   | Cache Write | Cache Read | Output  |
  |--------|---------|-------------|------------|---------|
  | Opus   | $15.00  | $18.75      | $1.50      | $75.00  |
  | Sonnet | $3.00   | $3.75       | $0.30      | $15.00  |
  | Haiku  | $0.25   | $0.30       | $0.03      | $1.25   |
```

### Threshold Status Bars

For each threshold bar:
1. Calculate the fill percentage: `current_cost / threshold_value * 100`, capped at 100%.
2. Use a 20-character bar: filled characters are `=`, the tip is `>`, empty characters are `-`.
3. If current cost exceeds the warning threshold, prefix the bar with `WARNING:` instead of two spaces.
4. If current cost exceeds the hard max (session only), prefix the bar with `OVER LIMIT:` instead of two spaces.

Example at 60% of session warning ($1.20 / $2.00 warn):
```
  Session:  [===========>--------]  $1.20 / $2.00 warn | $5.00 max
```

Example over session warning ($3.50 / $2.00 warn):
```
  WARNING:  [===================>]  $3.50 / $2.00 warn | $5.00 max
```

Example over session hard max ($6.00 / $5.00 max):
```
  OVER LIMIT: [===================>]  $6.00 / $2.00 warn | $5.00 max
```

### Handling Missing Data

- If `.vibecrew/` does not exist, display only:

```
VibeCrew Cost Dashboard
=====================

VibeCrew is not initialized. Run /setup to get started.
```

- If session-cost.json does not exist but .vibecrew/ does, show "No active session" for the Current Session section and still attempt to show aggregates.
- If aggregation fails, show "Aggregation unavailable" and still show the current session data and pricing table.
- Never error out. Always display whatever data is available.

## Rules

- This is a **read-only** skill. Do NOT write any files. Do NOT modify state.json, config.json, or session-cost.json. Do NOT run any destructive commands.
- If a data source is missing or malformed, display "N/A" or "not available" for that section. Never error out.
- Always show the Model Pricing Reference table, even if no cost data is available.
- Keep the output concise. Do not add commentary or suggestions beyond the dashboard.
- Use `${CLAUDE_PLUGIN_ROOT}` for any references to plugin-relative paths or scripts.
- Format all dollar amounts with exactly two decimal places (e.g., `$0.00`, `$12.34`).
