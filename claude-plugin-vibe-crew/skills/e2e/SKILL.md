---
name: e2e
description: Playwright E2E testing with Page Object Model — scaffold, generate, run
disable-model-invocation: false
args: scope
category: action
---

# /e2e

Structured end-to-end testing with Playwright using the Page Object Model pattern. Detects or scaffolds Playwright configuration, generates Page Object classes with accessible locators, creates spec files from acceptance criteria, and runs tests with trace-on-failure.

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

## Step 1: Detect or Scaffold Playwright

### 1.1 Check for existing Playwright config

```bash
ls playwright.config.* 2>/dev/null || echo "no config"
```

If a Playwright config exists, read it and report:

```
Playwright detected: {config_file}
Browsers: {configured_browsers}
Base URL: {baseURL_or_default}
```

### 1.2 Scaffold if missing

If no Playwright config exists, check if `@playwright/test` is installed:

```bash
jq -r '.devDependencies["@playwright/test"] // .dependencies["@playwright/test"] // empty' package.json 2>/dev/null
```

If not installed, prompt the user:

```
Playwright is not configured. Would you like to scaffold it now?
This will:
  1. Add @playwright/test to devDependencies
  2. Create playwright.config.ts from VibeCrew template
  3. Create e2e/ directory structure

Proceed? (yes/no)
```

If yes:

```bash
npm install -D @playwright/test
npx playwright install chromium
```

Copy the Playwright config template:

```bash
cp "${CLAUDE_PLUGIN_ROOT}/templates/playwright.config.ts.template" playwright.config.ts
mkdir -p e2e/pages e2e/fixtures
```

If no:

```
E2E testing requires Playwright. Run /e2e again after installing.
```

Stop.

---

## Step 2: Generate Page Object

### 2.1 Identify pages to test

Load the feature spec:

```bash
jq --arg id "$FEATURE_ID" '.features[] | select(.id == $id) | .spec' .vibecrew/backlog.json 2>/dev/null
```

From the spec's `ui_description` and acceptance criteria, identify:
- Which pages/routes the feature touches
- Key interactive elements on each page
- User flows to test

### 2.2 Create Page Object class

For each page involved in the feature, create a Page Object in `e2e/pages/`:

```typescript
// e2e/pages/{page-name}.page.ts
import { type Page, type Locator } from '@playwright/test';

export class {PageName}Page {
  readonly page: Page;

  // Locators — prefer accessible selectors
  readonly heading: Locator;
  readonly submitButton: Locator;
  readonly emailInput: Locator;

  constructor(page: Page) {
    this.page = page;
    // Use getByRole, getByText, getByLabel, getByTestId — in that priority order
    this.heading = page.getByRole('heading', { name: '{heading_text}' });
    this.submitButton = page.getByRole('button', { name: '{button_text}' });
    this.emailInput = page.getByLabel('{label_text}');
  }

  async goto() {
    await this.page.goto('/{route}');
  }

  // Action methods
  async fillForm(data: { email: string }) {
    await this.emailInput.fill(data.email);
  }

  async submit() {
    await this.submitButton.click();
  }
}
```

**Locator priority (accessibility-first):**
1. `getByRole` — buttons, links, headings, textboxes
2. `getByLabel` — form inputs with labels
3. `getByText` — elements with visible text
4. `getByTestId` — last resort for elements without semantic markup

### 2.3 Report

```
Page Objects created:
  - e2e/pages/{page-name}.page.ts ({N} locators, {M} actions)
  ...
```

---

## Step 3: Generate Spec File

Create a spec file from the acceptance criteria:

```typescript
// e2e/{feature-name}.spec.ts
import { test, expect } from '@playwright/test';
import { {PageName}Page } from './pages/{page-name}.page';

test.describe('{feature_name}', () => {
  let page: {PageName}Page;

  test.beforeEach(async ({ page: playwrightPage }) => {
    page = new {PageName}Page(playwrightPage);
    await page.goto();
  });

  // One test per acceptance criterion
  test('{acceptance_criterion_1}', async () => {
    // Arrange
    // Act
    // Assert
    await expect(page.heading).toBeVisible();
  });

  test('{acceptance_criterion_2}', async () => {
    // ...
  });
});
```

Report:

```
Spec file created: e2e/{feature-name}.spec.ts
Tests: {N} (one per acceptance criterion)
```

---

## Step 4: Run Tests

### 4.1 Execute Playwright tests

```bash
npx playwright test e2e/{feature-name}.spec.ts --trace on-first-retry --reporter=list 2>&1
echo "EXIT_CODE: $?"
```

### 4.2 Report results

**If all tests pass:**

```
E2E Results: {feature_name}
============================
  Total:   {N} tests
  Passed:  {N}
  Failed:  0
  Browser: {browser_name}

All E2E tests passing.
```

**If tests fail:**

```
E2E Results: {feature_name}
============================
  Total:   {N} tests
  Passed:  {P}
  Failed:  {F}
  Browser: {browser_name}

Failures:
  1. {test_name}
     Error: {error_message}
     Trace: test-results/{trace_path}

Tip: Run `npx playwright show-report` to view the HTML report.
```

### 4.3 Fix-and-retry cycle

If tests fail, analyze failures and fix test code (not source code):
- Fix selector mismatches (wrong locator)
- Fix timing issues (add appropriate waits)
- Fix assertion mismatches (update expectations)

Maximum 3 fix-and-retry cycles. After 3 failures, report:

```
E2E tests still failing after 3 attempts. Review the test traces and fix manually.
```

---

## Step 5: Summary

```
E2E Testing Summary
====================
Feature:      {feature_name} ({feature_id})
Page Objects: {N} created
Spec Files:   {N} created
Tests:        {total} total, {passed} passed, {failed} failed
Browsers:     {browser_list}

Files created:
  - e2e/pages/{page}.page.ts
  - e2e/{feature}.spec.ts
```

---

## Rules

- Use `${CLAUDE_PLUGIN_ROOT}` for all plugin-relative paths.
- **Accessible locators first.** Always prefer `getByRole`, `getByLabel`, `getByText` over CSS selectors or XPath. Only use `getByTestId` as a last resort.
- **Page Object Model is mandatory.** Never write locators directly in spec files. All page interaction goes through Page Object classes.
- **One test per acceptance criterion.** Each test should map to exactly one acceptance criterion from the feature spec.
- **Trace on failure.** Always run with `--trace on-first-retry` so failures produce visual traces for debugging.
- **Fix test code, not source code.** If E2E tests reveal source bugs, report them but do not fix the source.
- **Never use `page.waitForTimeout`.** Use `expect(locator).toBeVisible()`, `page.waitForURL()`, or other condition-based waits instead of arbitrary timeouts.
- If the Playwright MCP server is available, use it for interactive debugging of failing tests. It complements the standard `npx playwright test` workflow.
- If Context7 MCP is available, use it for Playwright documentation.
