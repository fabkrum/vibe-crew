---
name: perf-test
description: k6 performance testing — load, stress, spike, and soak test profiles
disable-model-invocation: false
args: test_type
category: action
---

# /perf-test

Performance testing with k6. Supports four test profiles: load, stress, spike, and soak. Scaffolds k6 scripts from the VibeCrew template with configurable thresholds, runs the test, parses latency and error rate metrics, and saves a pass/fail report.

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

Check if k6 is installed:

```bash
command -v k6 &>/dev/null && k6 version || echo "not installed"
```

If k6 is not installed, prompt:

```
k6 is not installed. Install it to run performance tests:
  macOS:  brew install k6
  Linux:  sudo apt install k6
  Docker: docker run grafana/k6 run script.js

See: https://grafana.com/docs/k6/latest/set-up/install-k6/
```

Stop.

Create the perf-tests directory:

```bash
mkdir -p .vibecrew/perf-tests
mkdir -p perf-tests
```

Parse the test type from `$ARGUMENTS`. Valid types: `load`, `stress`, `spike`, `soak`. Default to `load` if not provided.

---

## Step 1: Configure Test

### 1.1 Determine target endpoint

Ask the user if no endpoint is obvious from context:

```
What endpoint should be tested?
  Example: http://localhost:3000/api/users
  Default: http://localhost:3000
```

Store the target URL.

### 1.2 Scaffold k6 script

Check if a k6 script already exists for this feature:

```bash
FEATURE_ID=$(jq -r '.active_feature.id // "general"' .vibecrew/state.json 2>/dev/null || echo "general")
ls perf-tests/${FEATURE_ID}-*.js 2>/dev/null || echo "no existing script"
```

If no script exists, scaffold from the VibeCrew template:

```bash
cp "${CLAUDE_PLUGIN_ROOT}/templates/k6-config.js.template" "perf-tests/${FEATURE_ID}-perf.js"
```

Customize the scaffolded script:
- Set `BASE_URL` to the target endpoint
- Set the test type stages based on the selected profile
- Adjust thresholds if the user specified custom values

### 1.3 Display test configuration

```
Performance Test Configuration
================================
Target:     {url}
Type:       {load|stress|spike|soak}
Duration:   {estimated_total_duration}
Max VUs:    {max_virtual_users}
Thresholds:
  p95 latency: < 500ms
  p99 latency: < 1000ms
  Error rate:  < 1%

Script: perf-tests/{feature_id}-perf.js
```

Ask: **"Run this test? (yes/no)"**

If no, stop.

---

## Step 2: Run Test

### 2.1 Execute k6

```bash
K6_TEST_TYPE={test_type} BASE_URL={url} k6 run perf-tests/${FEATURE_ID}-perf.js 2>&1
echo "EXIT_CODE: $?"
```

Capture the full output including the JSON summary from the `handleSummary` hook.

### 2.2 Parse results

Extract from the k6 output or JSON summary:
- `http_req_duration` p95 and p99
- `http_req_duration` average
- `http_reqs` rate (requests per second)
- `errors` rate (error percentage)
- `vus_max` (peak concurrent users)
- `iterations` count
- Threshold pass/fail status for each configured threshold

---

## Step 3: Report Results

### 3.1 Display results

```
Performance Test Results
=========================
Type:       {test_type}
Target:     {url}
Duration:   {actual_duration}
Peak VUs:   {max_vus}

Latency:
  p95:  {value}ms  {PASS|FAIL} (threshold: 500ms)
  p99:  {value}ms  {PASS|FAIL} (threshold: 1000ms)
  avg:  {value}ms

Throughput:
  RPS:  {requests_per_second}
  Total: {total_requests}

Errors:
  Rate: {error_rate}%  {PASS|FAIL} (threshold: 1%)

Overall: {PASS|FAIL}
```

### 3.2 Save report

Write to `.vibecrew/perf-tests/perf-{feature-id}-{test-type}-{timestamp}.json`:

```json
{
  "schema_version": "1.0.0",
  "feature_id": "feat-NNN",
  "test_type": "load|stress|spike|soak",
  "target_url": "http://...",
  "timestamp": "ISO8601",
  "duration_seconds": 300,
  "metrics": {
    "p95_ms": 245,
    "p99_ms": 412,
    "avg_ms": 120,
    "rps": 450,
    "total_requests": 135000,
    "error_rate": 0.002,
    "max_vus": 20
  },
  "thresholds": {
    "p95_latency": {"limit_ms": 500, "actual_ms": 245, "pass": true},
    "p99_latency": {"limit_ms": 1000, "actual_ms": 412, "pass": true},
    "error_rate": {"limit_pct": 1.0, "actual_pct": 0.2, "pass": true}
  },
  "overall_pass": true
}
```

Use the temp file pattern for atomic writes.

---

## Step 4: Recommendations

Based on the results, provide actionable recommendations:

**If all thresholds pass:**

```
Performance baselines established. No issues detected at this load level.
Consider running a stress test to find the breaking point: /perf-test stress
```

**If latency thresholds fail:**

```
Latency exceeds thresholds. Consider:
- Profile the endpoint to identify bottlenecks
- Check database query performance (N+1 queries, missing indexes)
- Verify caching is active for repeated reads
- Consider pagination for large data sets
```

**If error rate threshold fails:**

```
Error rate exceeds threshold. Consider:
- Check server logs for error patterns
- Verify connection pool limits
- Check for rate limiting or throttling
- Ensure graceful degradation under load
```

---

## Rules

- Use `${CLAUDE_PLUGIN_ROOT}` for all plugin-relative paths.
- **Never run performance tests against production.** Only test against local dev servers or staging environments.
- **Always ask for user confirmation** before running a test. Performance tests generate real traffic.
- **Default to the load profile** if no test type is specified. Load tests are the safest starting point.
- **Save every result.** Even failed runs produce useful baseline data.
- **Do not modify application code** based on performance test results. Report findings and let the developer decide on optimizations.
- If k6 is not installed, do NOT attempt to install it automatically. Provide installation instructions and stop.
- The k6 script template uses `handleSummary` to output JSON. If the output cannot be parsed as JSON, fall back to parsing the text output.
- Soak tests can run for 30+ minutes. Warn the user about duration before starting soak tests.
