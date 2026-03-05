# Testing Strategy

VibeCrew's testing strategy uses a two-tier model: unit tests for individual script correctness and integration tests for workflow chain validation.

---

## 1. Testing Philosophy

- **Two-tier model**: Unit tests validate individual scripts in isolation with mocked data. Integration tests validate multi-script chains as composed sequences — catching bugs that only appear when script A's output becomes script B's input.
- **Isolation principle**: Every test runs in an ephemeral temp directory with a full `.vibecrew/` structure. No test depends on another test's state. No real external services are called.
- **Mock boundaries**: External tools (`gh`, `glab`, `node`, `npm`, `npx`) are always mocked. Internal scripts call each other directly in integration tests — mocking stops at the system boundary.
- **Determinism over speed**: Tests produce identical results on macOS and Ubuntu. No timing-dependent assertions except in concurrency stress tests (which use generous timeouts).
- **Regression feedback loop**: When `fix:` commits are detected during `/wrap`, regression test skeletons are auto-generated to prevent recurrence.

---

## 2. Test Infrastructure

- **Framework**: BATS (Bash Automated Testing System) with `bats-support` and `bats-assert` libraries (vendored as git submodules)
- **`test_helper/common-setup.bash`**: Shared fixtures, mocking utilities, state builders (~320 lines)
- **`test_helper/integration-setup.bash`**: Multi-script chain runners, state assertion helpers, fixture loaders (~250 lines). Extends `common-setup.bash`.
- **`tests/fixtures/`**: Realistic JSON snapshots representing complex real-world state (8-feature backlogs, mid-lifecycle state, full config, builder signals)

---

## 3. Unit Tests (`tests/*.bats`)

- 1:1 mapping with scripts (e.g., `calculate-vibe-score.bats` tests `calculate-vibe-score.sh`)
- Each test creates an isolated temp project via `setup_vibecrew_dir()`
- External commands mocked via `mock_command()` (PATH prepend pattern)
- State built programmatically via fixture generators (`create_state_json`, `add_feature_to_backlog`, etc.)
- ~125 test files covering all scripts

---

## 4. Integration Tests (`tests/integration/*.bats`)

### Feature Lifecycle (`feature-lifecycle.bats`)
Full claim → 6-phase progression → done. Validates the state machine across `claim-task.sh`, `complete-phase.sh`, `validate-phase-transition.sh`, `sync-state.sh`, and the dual-write system. Tests complexity-aware phase skipping (trivial skips design+review).

### Session Startup Chain (`session-startup-chain.bats`)
`session-startup.sh` → `migrate-state.sh` → `sync-state.sh`. Tests schema migration from 1.0.0 through 1.6.0, orphan repair, journal recovery, graceful degradation on corrupted state, forward-compatible schema guard, and model-change detection.

### Hook Enforcement Chain (`hook-enforcement-chain.bats`)
Full PreToolUse → PostToolUse pipeline for Write and Bash tools. Tests the phase-gate, validate-signal, restrict-paths, protect-data, and validate-phase-transition hooks as a composed pipeline across all state conditions (foundation incomplete/complete, signal validation, path restrictions).

### Wrap Sequence (`wrap-sequence.bats`)
`calculate-vibe-score.sh` → `generate-feature-docs.sh` → `rebuild-sidebar.sh` → `generate-handoff.sh`. Tests artifact generation, consistency, visual verification detection, spec detection, handoff numbering, and agent metrics collection.

### Concurrency Stress (`concurrency-stress.bats`)
Lock contention with parallel processes using `bash -c "..." &` + `wait`. Tests parallel claim-task (WIP limit enforcement), parallel complete-phase, 5-writer contention, named lock independence, stale lock reclamation, rapid acquire/release cycles, dual-write journal recovery, lock timeouts, and EXIT trap cleanup.

---

## 5. Fixture Strategy

| Type | Location | Content | Use Case |
|---|---|---|---|
| Synthetic | Built in `setup()` | Minimal JSON via helper functions | Unit tests — fast, focused on one scenario |
| Realistic | `tests/fixtures/*.json` | Snapshot files representing complex state | Integration tests — catch shape mismatches that minimal fixtures miss |

### Realistic Fixtures

| File | Content |
|---|---|
| `realistic-backlog-8-features.json` | 8 features across all 7 columns with full specs, dependencies, labels, complexity field, phases_completed at various stages |
| `realistic-state-mid-feature.json` | Foundation complete, active feature in "code" phase with plan_revision_count |
| `realistic-config-full.json` | All config sections populated: user_profile, gamification, pricing, locks, quality_gate |
| `builder-signal-with-visual.json` | Builder-complete signal with visual_verification data and console error counts |

---

## 6. Mocking Strategy

| Layer | What's Mocked | How |
|---|---|---|
| External CLIs | `gh`, `glab`, `node`, `npm`, `npx` | `mock_command()` — executable stub prepended to PATH |
| Package managers | `bun`, `pnpm`, `yarn` | Same PATH prepend pattern |
| System tools | `terminal-notifier`, `timeout`/`gtimeout` | Same pattern |
| File system | None — uses real temp dirs | `mktemp -d` with cleanup in teardown |
| Git | Real git in temp repos | `git init` in setup, real commits when needed |
| Internal scripts | **Not mocked in integration tests** | Scripts call each other directly |

The `mock_command()` function creates executable stubs in a temp directory prepended to `$PATH`. Each stub echoes a configured output and exits with a configured code. `cleanup_mocks()` removes the temp directory.

---

## 7. CI Pipeline

Two parallel jobs in `.github/workflows/tests.yml`:

| Job | Suite | Speed | Timeout |
|---|---|---|---|
| `unit-tests` | `tests/*.bats` | ~30s | Default |
| `integration-tests` | `tests/integration/*.bats` | ~2-5min | 10min |

Both run on `ubuntu-latest` + `macos-latest` matrix with `fail-fast: false`. Triggered on push/PR to `main` when `claude-plugin-vibe-crew/` files change.

---

## 8. Running Tests

```bash
tests/run-tests.sh              # All tests (unit + integration)
tests/run-tests.sh unit         # Unit tests only
tests/run-tests.sh integration  # Integration tests only
```

Additional BATS flags can be passed through:

```bash
tests/run-tests.sh unit --filter "claim-task"  # Run only matching tests
tests/run-tests.sh all --jobs 4                 # Parallel execution
```

---

## 9. Regression Test Feedback Loop

When a `fix:` commit is detected during `/wrap`:

1. **Detection**: `detect-fix-commits.sh` scans the session's git log for `fix:` conventional commits. For each, it checks whether the same commit also modified test files (`*.test.*`, `*.spec.*`, `__tests__/`, `*.bats`).

2. **Generation**: If no test changes accompany the fix, `generate-regression-test.sh` creates a test skeleton in the appropriate framework (BATS for plugin scripts, Vitest/Jest for user projects). Skeletons include:
   - Test name derived from the commit message
   - File path based on the fixed source file
   - `skip` marker — developers fill in reproduction steps and assertions

3. **Scoring**: The Vibe Score applies a -5 deduction per fix commit without regression tests (`fix-without-regression`). Fix commits with regression tests are neutral (+0).

4. **Expertise**: Bug-fix patterns are stored in the expertise knowledge base (domain: `failures`, tags: `["regression", "bug-fix"]`) for cross-session analysis.

5. **Performance Coach**: After 3+ sessions with fix commits lacking regression tests, the Performance Coach proposes a CLAUDE.md mutation: _"When fixing a bug, always add a regression test that reproduces the original failure before applying the fix."_

---

## 10. Pre-Execution Test Coverage Mapping (Nyquist)

Before the Code phase begins, `map-test-coverage.sh` maps existing test coverage to the feature's acceptance criteria. This ensures test infrastructure exists before implementation starts.

### How It Works

1. **Framework detection**: Scans for config files (`vitest.config.ts`, `jest.config.js`, `playwright.config.ts`, `cypress.config.*`, `*.bats`) to identify the project's test framework.
2. **Criteria extraction**: Reads acceptance criteria from `backlog.json` for the active feature.
3. **Coverage mapping**: For each criterion, extracts key terms and searches existing test files for matches using `grep -Eli`.
4. **Gap identification**: Criteria with no matching test file are flagged as gaps.
5. **Wave 0 generation**: Creates test scaffolding tasks for each gap — these go before implementation tasks in the plan.

### Wave 0 Tasks

Wave 0 tasks establish the red-green-refactor starting point:
- Each Wave 0 task creates a test file with a `describe`/`it` block matching an acceptance criterion
- The test should fail (red) before implementation
- Wave 0 tasks are inserted at the beginning of the plan's `## Tasks` section

### Integration Points

| Component | How It Uses Nyquist |
|-----------|---------------------|
| `builder.md` step 5.7 | Runs `map-test-coverage.sh` after plan verification |
| `validate-plan.sh` | Includes Nyquist gap count in validation output (advisory) |
| Vibe Score | Future: test coverage gaps could be scored as missing-phase artifacts |

---

## 11. Adding New Tests

- **New script** → create `tests/<script-name>.bats` with matching name
- **New workflow chain** → create `tests/integration/<chain-name>.bats`
- Load `common-setup` for unit tests, `integration-setup` for integration tests
- Always use the `setup_vibecrew_dir()` / `teardown_vibecrew_dir()` pair
- Mock external tools, never internal scripts in integration tests
- Use `assert_success`, `assert_failure`, `assert_output --partial` from bats-assert
- For state assertions, use helpers: `assert_feature_column`, `assert_active_phase`, `assert_phases_completed_contains`, `assert_no_journal_files`, `assert_no_lock_dirs`
