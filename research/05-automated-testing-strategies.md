# Research: Automated Testing Strategies for AI-Assisted Development

> **Phase 1 Research** | Document 05 | February 2026
>
> This document covers automated testing strategies for AI-assisted development environments. It addresses unit testing frameworks, UI/visual regression testing, accessibility testing, test generation quality, the TDD-hybrid approach, dedicated test server infrastructure, CI/CD integration, and agent-level integration -- all critical for a system like VibeOS where AI agents generate, execute, and evaluate tests autonomously.

---

## Table of Contents

1. [Unit Testing Frameworks and Best Practices](#1-unit-testing-frameworks-and-best-practices)
2. [UI/Visual Regression Testing](#2-uivisual-regression-testing)
3. [Accessibility Testing Automation](#3-accessibility-testing-automation)
4. [Test Generation Strategies -- What Makes Tests Useful](#4-test-generation-strategies----what-makes-tests-useful)
5. [Dedicated Test Server Setup](#5-dedicated-test-server-setup)
6. [Test Runner Configuration for CI/CD](#6-test-runner-configuration-for-cicd)
7. [Integration with VibeOS Agents](#7-integration-with-vibeos-agents)
8. [Recommendations for VibeOS](#8-recommendations-for-vibeos)
9. [Sources](#9-sources)

---

## 1. Unit Testing Frameworks and Best Practices

### 1.1 Vitest vs Jest: Head-to-Head Comparison

| Criterion | Vitest | Jest |
|---|---|---|
| **Speed** | 2-10x faster (native ESM, Vite transform pipeline) | Slower cold starts; mature caching helps warm runs |
| **TypeScript support** | Native via Vite -- zero config, uses esbuild/SWC | Requires `ts-jest` or `@swc/jest` transformer |
| **ESM support** | First-class, native ESM throughout | Experimental `--experimental-vm-modules`, improving but not seamless |
| **Watch mode** | Instant HMR-based watch, only re-runs affected tests | `--watch` re-runs based on file changes, slower feedback loop |
| **Configuration** | `vitest.config.ts` -- shares config with Vite project | `jest.config.ts` -- separate config, more boilerplate |
| **API compatibility** | Jest-compatible API (`describe`, `it`, `expect`) | The original API standard |
| **Snapshot testing** | Supported, inline snapshots too | Supported, mature |
| **Coverage** | Built-in via `@vitest/coverage-v8` or `@vitest/coverage-istanbul` | Built-in via `--coverage` (istanbul/v8) |
| **Browser-based UI** | `@vitest/ui` -- test dashboard in the browser | No built-in UI |
| **In-source testing** | Supported -- tests can live alongside source code | Not supported |
| **Mocking API** | `vi.fn()`, `vi.mock()`, `vi.spyOn()` | `jest.fn()`, `jest.mock()`, `jest.spyOn()` |
| **Ecosystem maturity** | Rapidly growing, Vite ecosystem standard | Massive ecosystem, decade of plugins |

**Speed benchmarks** (approximate, ~500 test files):

| Metric | Vitest | Jest (with SWC) | Jest (with ts-jest) |
|---|---|---|---|
| Cold start | ~1.2s | ~3.5s | ~6.0s |
| Warm run (watch mode) | ~0.3s | ~1.5s | ~2.5s |
| Full suite | ~4s | ~12s | ~20s |

**When to choose Vitest:**
- New projects using Vite, SvelteKit, Nuxt 3, Astro, or any Vite-based framework
- TypeScript-first codebases that want zero-config TS support
- Speed-critical workflows where fast feedback matters (AI-assisted development)
- ESM-native codebases

**When to choose Jest:**
- Existing projects with extensive Jest configuration and custom transformers
- React Native projects (Jest is the standard test runner)
- Large legacy codebases where migration cost outweighs benefits

### 1.2 Vitest Configuration (Recommended for New Projects)

```bash
npm install -D vitest @vitest/coverage-v8 @vitest/ui
```

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,               // Use describe/it/expect without imports
    environment: 'jsdom',        // or 'happy-dom' for ~2-3x speed boost
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
    setupFiles: ['./test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'json-summary', 'html', 'lcov'],
      exclude: [
        'node_modules/',
        'src/**/*.d.ts',
        'src/**/*.stories.{ts,tsx}',
        'src/test/**',
        'src/mocks/**',
        'src/**/index.ts',        // Re-export barrel files
        'src/**/types.ts',        // Type-only files
      ],
      thresholds: {
        statements: 80,
        branches: 75,
        functions: 80,
        lines: 80,
      },
    },
  },
});
```

```json
// package.json scripts
{
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "test:ui": "vitest --ui"
  }
}
```

### 1.3 Jest Configuration (for Legacy/React Native Projects)

```bash
npm install -D jest @swc/jest @types/jest
```

```javascript
// jest.config.js
module.exports = {
  transform: {
    '^.+\\.(t|j)sx?$': ['@swc/jest'],
  },
  testEnvironment: 'jsdom',
  testMatch: ['<rootDir>/src/**/*.{test,spec}.{ts,tsx}'],
  setupFilesAfterSetup: ['<rootDir>/test/setup.ts'],
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{ts,tsx}',
    '!src/test/**',
  ],
  coverageThreshold: {
    global: {
      statements: 80,
      branches: 75,
      functions: 80,
      lines: 80,
    },
  },
};
```

### 1.4 Best Practices: Arrange-Act-Assert

Every test should follow the AAA pattern for clarity and consistency:

```typescript
describe('PricingService', () => {
  it('applies 10% volume discount for orders of 10-49 units', () => {
    // Arrange -- set up test data and preconditions
    const order = {
      basePrice: 100,
      quantity: 20,
    };

    // Act -- execute the behavior under test
    const total = calculatePrice(order);

    // Assert -- verify the expected outcome
    expect(total).toBe(1800); // 20 * 100 * 0.9
  });
});
```

**Naming conventions:**
- Test names should describe the scenario and expected outcome, not the implementation
- Use "it does X when Y" or "it returns X given Y" patterns
- Avoid vague names like "it works" or "it handles correctly"

### 1.5 Mock Strategies

#### Module Mocking with `vi.mock`

```typescript
// Mock an entire module
vi.mock('./services/api', () => ({
  fetchUser: vi.fn().mockResolvedValue({ id: '1', name: 'Alice' }),
  updateUser: vi.fn().mockResolvedValue({ success: true }),
}));

// Mock with factory function for per-test overrides
import { fetchUser } from './services/api';

it('handles API errors gracefully', async () => {
  vi.mocked(fetchUser).mockRejectedValueOnce(new Error('Network error'));

  const result = await loadUserProfile('1');

  expect(result.error).toBe('Failed to load profile');
});
```

#### API Mocking with MSW (Mock Service Worker)

MSW intercepts HTTP requests at the network level, providing realistic API mocking without modifying application code. This is the recommended approach for testing components that make API calls.

```bash
npm install -D msw
```

```typescript
// test/mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({
      id: params.id,
      name: 'Alice',
      email: 'alice@example.com',
    });
  }),

  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: 'new-1', ...body }, { status: 201 });
  }),

  http.put('/api/users/:id', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ ...body, updated: true });
  }),
];
```

```typescript
// test/mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

```typescript
// test/setup.ts
import { server } from './mocks/server';

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

```typescript
// Override handlers per-test for error scenarios
import { server } from '../test/mocks/server';
import { http, HttpResponse } from 'msw';

it('shows error message when API returns 500', async () => {
  server.use(
    http.get('/api/users/:id', () => {
      return HttpResponse.json({ error: 'Server error' }, { status: 500 });
    })
  );

  render(<UserProfile userId="1" />);

  await waitFor(() => {
    expect(screen.getByRole('alert')).toHaveTextContent(/failed to load/i);
  });
});
```

### 1.6 Code Coverage: Thresholds and What Coverage Means

**What coverage measures:**
- **Statement coverage**: percentage of statements executed during tests
- **Branch coverage**: percentage of conditional branches (if/else, switch, ternary) taken
- **Function coverage**: percentage of functions called at least once
- **Line coverage**: percentage of lines executed

**What coverage does NOT measure:**
- Whether assertions are meaningful (a test with no `expect()` still counts toward coverage)
- Whether edge cases are tested
- Whether the right things are being tested
- Whether tests would catch real bugs

**Recommended thresholds:**
- 80% lines/statements as a floor -- not a ceiling
- 75% branches -- branch coverage is harder to achieve and more valuable
- Never aim for 100% -- the last 20% is often untestable boilerplate (type guards, error boundaries, framework glue)

```typescript
// vitest.config.ts -- coverage thresholds
coverage: {
  thresholds: {
    statements: 80,
    branches: 75,
    functions: 80,
    lines: 80,
  },
},
```

Coverage thresholds should be enforced in CI so that a PR cannot merge if it reduces coverage below the threshold.

---

## 2. UI/Visual Regression Testing

### 2.1 Playwright vs Cypress: Head-to-Head Comparison

| Criterion | Playwright | Cypress |
|---|---|---|
| **Browser support** | Chromium, Firefox, WebKit (Safari) | Chromium, Firefox, WebKit (limited) |
| **Architecture** | Out-of-process, CDP/BiDi protocol | In-process, runs inside the browser |
| **Speed** | Faster -- parallel by default, lightweight | Slower -- heavier runtime, sequential by default |
| **Multi-tab/multi-origin** | Full support | Limited (historically single-origin) |
| **Language support** | TypeScript, JavaScript, Python, Java, C# | TypeScript, JavaScript only |
| **Auto-wait** | Built-in, robust actionability checks | Built-in, different retry mechanics |
| **Test isolation** | Browser context isolation (fast, no full restart) | Full page reload between tests |
| **Parallel execution** | Native parallel across workers | Via `cypress-parallel` or CI parallelization |
| **API testing** | `request` context built in | `cy.request()` built in |
| **Network mocking** | Route-based interception | `cy.intercept()` |
| **Debugging** | Trace viewer, VS Code extension, headed mode | Time-travel debugging (excellent) |
| **Visual testing** | Built-in screenshot comparison | Via plugins (Percy, Applitools) |
| **iframe support** | Full support via `frameLocator()` | Limited |
| **Mobile emulation** | Device emulation, geolocation, permissions | Viewport resizing only |
| **Pricing** | Fully open source | Open source core, paid Dashboard |

**Verdict:** Playwright is the recommended choice for new projects in 2025-2026. Its true cross-browser support (including WebKit/Safari), out-of-process architecture, built-in visual regression, and faster execution make it the stronger option for AI-assisted workflows. Cypress remains viable for teams already invested in it; its time-travel debugger is still best-in-class.

### 2.2 Playwright Setup and Configuration

```bash
npm init playwright@latest
# or
npm install -D @playwright/test
npx playwright install  # Downloads browser binaries
```

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,        // Fail CI if .only is left in
  retries: process.env.CI ? 2 : 0,     // Retry on CI only
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { open: 'never' }],
    ['json', { outputFile: 'test-results/results.json' }],
    ...(process.env.CI ? [['github' as const]] : []),
  ],
  use: {
    baseURL: process.env.TEST_BASE_URL || 'http://localhost:4173',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'mobile-chrome', use: { ...devices['Pixel 5'] } },
    { name: 'mobile-safari', use: { ...devices['iPhone 13'] } },
  ],
  webServer: {
    command: 'npm run preview',
    port: 4173,
    reuseExistingServer: !process.env.CI,
  },
});
```

### 2.3 Page Object Model Pattern

The Page Object Model (POM) encapsulates page interactions into reusable classes, reducing duplication and making tests more maintainable -- especially important when AI agents generate many E2E tests.

```typescript
// e2e/pages/checkout.page.ts
import { type Page, type Locator } from '@playwright/test';

export class CheckoutPage {
  readonly page: Page;
  readonly nameInput: Locator;
  readonly emailInput: Locator;
  readonly addressInput: Locator;
  readonly submitButton: Locator;
  readonly confirmationHeading: Locator;
  readonly errorAlert: Locator;

  constructor(page: Page) {
    this.page = page;
    this.nameInput = page.getByLabel('Full name');
    this.emailInput = page.getByLabel('Email');
    this.addressInput = page.getByLabel('Address');
    this.submitButton = page.getByRole('button', { name: /place order/i });
    this.confirmationHeading = page.getByRole('heading', { name: /order confirmed/i });
    this.errorAlert = page.getByRole('alert');
  }

  async goto() {
    await this.page.goto('/checkout');
  }

  async fillShippingInfo(data: { name: string; email: string; address: string }) {
    await this.nameInput.fill(data.name);
    await this.emailInput.fill(data.email);
    await this.addressInput.fill(data.address);
  }

  async placeOrder() {
    await this.submitButton.click();
  }
}
```

```typescript
// e2e/checkout.spec.ts
import { test, expect } from '@playwright/test';
import { CheckoutPage } from './pages/checkout.page';

test.describe('Checkout Flow', () => {
  test('completes purchase with valid data', async ({ page }) => {
    const checkout = new CheckoutPage(page);
    await checkout.goto();

    await checkout.fillShippingInfo({
      name: 'Test User',
      email: 'test@example.com',
      address: '123 Test St',
    });
    await checkout.placeOrder();

    await expect(checkout.confirmationHeading).toBeVisible();
  });

  test('shows validation errors for empty fields', async ({ page }) => {
    const checkout = new CheckoutPage(page);
    await checkout.goto();
    await checkout.placeOrder();

    await expect(checkout.errorAlert).toContainText('Name is required');
  });
});
```

### 2.4 Visual Regression with Playwright Screenshots

Playwright has built-in screenshot comparison that works without third-party services:

```typescript
// e2e/visual/homepage.visual.spec.ts
import { test, expect } from '@playwright/test';

test('homepage visual regression', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('homepage.png', {
    fullPage: true,
    maxDiffPixelRatio: 0.01, // Allow 1% pixel difference
  });
});

test('responsive design regression', async ({ page }) => {
  const viewports = [
    { width: 375, height: 667, name: 'mobile' },
    { width: 768, height: 1024, name: 'tablet' },
    { width: 1440, height: 900, name: 'desktop' },
  ];

  for (const vp of viewports) {
    await page.setViewportSize({ width: vp.width, height: vp.height });
    await page.goto('/');
    await expect(page).toHaveScreenshot(`homepage-${vp.name}.png`);
  }
});

test('masks dynamic content to prevent false positives', async ({ page }) => {
  await page.goto('/feed');
  await expect(page).toHaveScreenshot('feed-page.png', {
    mask: [
      page.locator('.timestamp'),
      page.locator('.avatar'),
    ],
    maskColor: '#FF00FF',
  });
});
```

**Baseline management:**

```bash
# Generate initial screenshots (first run or after intentional changes)
npx playwright test --update-snapshots

# Run visual regression tests
npx playwright test

# Review failures in the HTML report
npx playwright show-report
```

Screenshots are stored in a `*-snapshots/` directory alongside the test file and should be committed to version control.

### 2.5 Visual Regression Services: Percy and Chromatic

For teams that need cross-browser visual regression at scale, cloud-based services offer additional capabilities:

| Tool | Approach | Strengths | Limitations |
|---|---|---|---|
| **Playwright screenshots** | Local pixel diff | Free, no external dependency, fast | Single OS rendering, sensitive to font rendering |
| **Percy (BrowserStack)** | Cloud rendering, cross-browser | Consistent rendering, team review UI | Paid service, requires network during CI |
| **Chromatic (Storybook)** | Component-level cloud rendering | Tight Storybook integration, interaction testing | Tied to Storybook, paid for large projects |

For VibeOS, **Playwright's built-in visual comparison** is the recommended starting point. It is free, requires no external services, and works well in CI. Percy or Chromatic can be added later if cross-browser rendering consistency becomes a concern.

### 2.6 Component Testing: Playwright vs Storybook + Chromatic

**Playwright Component Testing** (experimental): Renders components in a real browser via Vite, then runs Playwright tests against them. Best for testing complex interactions in isolation.

**Storybook + Chromatic**: Stories serve as both documentation and test fixtures. Chromatic captures screenshots of each story across browsers. Best for design systems with many visual states.

| Approach | Best For | Trade-off |
|---|---|---|
| Playwright Component Testing | Interaction-heavy components | Experimental API, less ecosystem support |
| Storybook + Chromatic | Design systems, visual state cataloging | Adds Storybook to the stack, paid service |
| Testing Library + Vitest | Behavior/logic-focused component tests | No real browser, JSDOM limitations |

For VibeOS projects, **Testing Library + Vitest** should be the primary component testing tool. Playwright should be reserved for E2E and visual regression. Storybook can be added optionally for design system documentation.

---

## 3. Accessibility Testing Automation

### 3.1 The Accessibility Testing Pyramid

```
        /\
       /  \         Manual Testing
      /    \        (screen reader, keyboard navigation audits)
     /------\
    /        \      E2E a11y Scans
   /          \     (axe-core in Playwright, pa11y CI scans)
  /------------\
 /              \   Component a11y Testing
/                \  (jest-axe / vitest-axe, Testing Library queries)
------------------
```

Automated tools catch approximately 30-50% of accessibility issues. The remainder requires manual testing with screen readers, keyboard-only navigation, and cognitive accessibility review. Automated testing is a floor, not a ceiling.

### 3.2 axe-core (Deque) -- Industry Standard

axe-core is the most widely adopted automated accessibility testing engine. It tests against WCAG 2.1 and 2.2 rules and is used by Playwright, Cypress, jest-axe, and Lighthouse.

#### Component-Level: jest-axe / vitest-axe

```bash
npm install -D jest-axe @types/jest-axe
# For Vitest:
npm install -D vitest-axe axe-core
```

```typescript
// components/Button.test.tsx
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';
import { Button } from './Button';

expect.extend(toHaveNoViolations);

describe('Button accessibility', () => {
  it('has no accessibility violations', async () => {
    const { container } = render(
      <Button onClick={() => {}}>Click me</Button>
    );
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  it('icon-only button has accessible name', async () => {
    const { container } = render(
      <Button onClick={() => {}} aria-label="Close dialog">
        <CloseIcon />
      </Button>
    );
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});
```

#### E2E-Level: @axe-core/playwright

```bash
npm install -D @axe-core/playwright
```

```typescript
// e2e/accessibility.spec.ts
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test.describe('Accessibility', () => {
  const pagesToTest = [
    { path: '/', name: 'Homepage' },
    { path: '/about', name: 'About' },
    { path: '/dashboard', name: 'Dashboard' },
    { path: '/settings', name: 'Settings' },
  ];

  for (const { path, name } of pagesToTest) {
    test(`${name} page has no WCAG 2.2 AA violations`, async ({ page }) => {
      await page.goto(path);

      const results = await new AxeBuilder({ page })
        .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'])
        .analyze();

      expect(results.violations).toEqual([]);
    });
  }

  test('modal dialog is accessible', async ({ page }) => {
    await page.goto('/dashboard');
    await page.getByRole('button', { name: /create new/i }).click();
    await expect(page.getByRole('dialog')).toBeVisible();

    const results = await new AxeBuilder({ page })
      .include('[role="dialog"]')
      .analyze();

    expect(results.violations).toEqual([]);
  });
});
```

#### Reusable Accessibility Test Helper

```typescript
// e2e/helpers/a11y.ts
import { type Page } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

export async function checkAccessibility(
  page: Page,
  options?: {
    include?: string[];
    exclude?: string[];
    disableRules?: string[];
  }
) {
  let builder = new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa']);

  if (options?.include) {
    for (const selector of options.include) {
      builder = builder.include(selector);
    }
  }
  if (options?.exclude) {
    for (const selector of options.exclude) {
      builder = builder.exclude(selector);
    }
  }
  if (options?.disableRules) {
    builder = builder.disableRules(options.disableRules);
  }

  const results = await builder.analyze();

  if (results.violations.length > 0) {
    const formatted = results.violations.map((v) => ({
      rule: v.id,
      impact: v.impact,
      description: v.description,
      helpUrl: v.helpUrl,
      elements: v.nodes.map((n) => n.html).slice(0, 3),
    }));
    throw new Error(
      `Accessibility violations found:\n${JSON.stringify(formatted, null, 2)}`
    );
  }

  return results;
}
```

### 3.3 pa11y -- Command-Line Accessibility Testing

pa11y provides CLI-based accessibility scanning ideal for CI pipelines. It can test multiple URLs in batch mode:

```bash
npm install -D pa11y pa11y-ci
```

```json
// .pa11yci.json
{
  "defaults": {
    "timeout": 30000,
    "wait": 1000,
    "standard": "WCAG2AA",
    "runners": ["axe", "htmlcs"],
    "chromeLaunchConfig": {
      "args": ["--no-sandbox"]
    }
  },
  "urls": [
    "http://localhost:4173/",
    "http://localhost:4173/about",
    "http://localhost:4173/dashboard",
    {
      "url": "http://localhost:4173/login",
      "actions": [
        "set field #email to test@example.com",
        "set field #password to password123",
        "click element #login-button",
        "wait for element .dashboard to be visible"
      ]
    }
  ]
}
```

### 3.4 Lighthouse Accessibility Audit

Lighthouse is built into Chrome and can be run programmatically via Playwright for CI scoring:

```typescript
// e2e/lighthouse.spec.ts (requires @playwright/test and lighthouse)
import { test } from '@playwright/test';
import lighthouse from 'lighthouse';
import { chromium } from 'playwright';

test('homepage meets Lighthouse accessibility threshold', async () => {
  const browser = await chromium.launch({ args: ['--remote-debugging-port=9222'] });
  const result = await lighthouse('http://localhost:4173/', {
    port: 9222,
    onlyCategories: ['accessibility'],
  });

  const score = result?.lhr?.categories?.accessibility?.score ?? 0;
  expect(score).toBeGreaterThanOrEqual(0.9); // 90+ score

  await browser.close();
});
```

### 3.5 Common Automated Checks

| Check | Rule | Tools |
|---|---|---|
| Color contrast (4.5:1 for normal text, 3:1 for large text) | WCAG 1.4.3 | axe-core, pa11y |
| ARIA attributes match element roles | WCAG 4.1.2 | axe-core |
| Images have `alt` text | WCAG 1.1.1 | axe-core, pa11y, htmlcs |
| Form inputs have associated labels | WCAG 1.3.1, 4.1.2 | axe-core |
| Heading hierarchy is logical (no skipped levels) | WCAG 1.3.1 | axe-core |
| Focus is visible on interactive elements | WCAG 2.4.7 | Manual + partial automation |
| Language attribute set on `<html>` | WCAG 3.1.1 | axe-core, pa11y |
| Page has a main landmark | WCAG 1.3.1 | axe-core |

### 3.6 What Automated Testing CANNOT Catch

Automated accessibility tools have significant blind spots. The following issues require manual testing:

1. **Logical reading order** -- screen readers traverse the DOM; visual layout may differ from DOM order
2. **Keyboard trap detection** -- focus can get stuck in components (modals, date pickers) in ways tools miss
3. **Meaningful alternative text** -- tools check that `alt` exists, not that it is useful ("image.png" passes automation but fails usability)
4. **Cognitive load** -- overly complex forms, confusing navigation, unclear error messages
5. **Screen reader announcements** -- live regions (`aria-live`) may fire at wrong times or with wrong content
6. **Touch target size** -- WCAG 2.5.5 requires 44x44px minimum; automated tools check CSS but not actual rendered size
7. **Motion and animation** -- `prefers-reduced-motion` support, seizure-inducing patterns
8. **Custom widget behavior** -- a custom combobox may pass axe-core but be unusable with a screen reader

**Recommendation:** Automated tests are the floor. Every VibeOS-generated feature should include an accessibility testing phase, but the Performance Coach should flag features that lack manual accessibility review.

---

## 4. Test Generation Strategies -- What Makes Tests Useful

### 4.1 The Core Problem

AI can generate hundreds of tests that pass but test nothing meaningful. A test suite where every test passes and coverage is 95% is worthless if the tests are tautological, over-mocked, or coupled to implementation details.

### 4.2 Useful Test Characteristics

A useful test:

1. **Would actually fail if the feature broke** -- temporarily break the implementation; does the test catch it?
2. **Tests behavior, not implementation** -- refactoring internals should not break the test
3. **Has meaningful assertions** -- not just `toBeDefined()` or `toBeTruthy()`
4. **Covers edge cases and error paths** -- boundaries, empty inputs, malformed data
5. **Is readable as documentation** -- the test name and body describe what the system does
6. **Is deterministic** -- same result every run, no reliance on dates, random values, or network

### 4.3 The TDD-Hybrid Approach for VibeOS

#### Track 1: Spec-First Testing (Business Logic -- TDD)

For business logic, write specification tests *before* implementation. These come from acceptance criteria, not from looking at implementation code.

```typescript
// STEP 1: Write specs from acceptance criteria BEFORE implementation
// src/services/pricing.spec.ts

describe('PricingService', () => {
  describe('volume discounts', () => {
    it('applies no discount for quantities under 10', () => {
      const price = calculatePrice({ basePrice: 100, quantity: 5 });
      expect(price).toBe(500);
    });

    it('applies 10% discount for quantities 10-49', () => {
      const price = calculatePrice({ basePrice: 100, quantity: 20 });
      expect(price).toBe(1800); // 20 * 100 * 0.9
    });

    it('applies 20% discount for quantities 50-99', () => {
      const price = calculatePrice({ basePrice: 100, quantity: 75 });
      expect(price).toBe(6000); // 75 * 100 * 0.8
    });

    it('applies 30% discount for quantities 100+', () => {
      const price = calculatePrice({ basePrice: 100, quantity: 150 });
      expect(price).toBe(10500); // 150 * 100 * 0.7
    });
  });

  describe('edge cases', () => {
    it('throws for zero quantity', () => {
      expect(() => calculatePrice({ basePrice: 100, quantity: 0 }))
        .toThrow('Quantity must be positive');
    });

    it('throws for negative price', () => {
      expect(() => calculatePrice({ basePrice: -10, quantity: 5 }))
        .toThrow('Price must be non-negative');
    });
  });
});

// STEP 2: NOW implement the function
// The tests serve as a clear, unambiguous specification
```

**Why spec-first works for business logic:** The acceptance criteria define exact input/output contracts. Tests become the specification. The AI agent receives the failing tests as a clear "prompt" for what to implement.

#### Track 2: Implementation-First Testing (UI Components)

For UI components, build the component first (possibly with AI assistance), then write behavioral tests to lock in the expected behavior:

```typescript
// STEP 1: Implement the component (with AI or manually)
// STEP 2: Write behavioral tests to verify and lock in behavior

// src/components/SearchBar.test.tsx
describe('SearchBar', () => {
  it('shows results after typing at least 3 characters', async () => {
    const user = userEvent.setup();
    render(<SearchBar onSearch={mockSearch} />);

    const input = screen.getByRole('searchbox');
    await user.type(input, 'ab');
    expect(mockSearch).not.toHaveBeenCalled();

    await user.type(input, 'c');
    await waitFor(() => {
      expect(mockSearch).toHaveBeenCalledWith('abc');
    });
  });

  it('debounces search requests', async () => {
    const user = userEvent.setup();
    render(<SearchBar onSearch={mockSearch} debounceMs={300} />);

    await user.type(screen.getByRole('searchbox'), 'test query');

    await waitFor(() => {
      expect(mockSearch).toHaveBeenCalledTimes(1);
      expect(mockSearch).toHaveBeenCalledWith('test query');
    });
  });
});
```

**Why implementation-first works for UI:** Visual and interactive behavior is hard to specify precisely upfront. Components evolve through iteration. Writing tests after confirms the behavior is correct and prevents regressions.

#### Decision Matrix

| Scenario | Approach | Reason |
|---|---|---|
| Business logic, calculations | Spec-first (TDD) | Clear input/output, acceptance criteria map directly |
| Data validation | Spec-first (TDD) | Rules are defined upfront |
| API service layer | Spec-first (TDD) | Contract is known before implementation |
| State machines / workflows | Spec-first (TDD) | States and transitions defined by requirements |
| UI components | Implementation-first | Visual/interactive behavior is iterative |
| Layouts, styling | Visual regression | Not testable with unit tests effectively |
| Integration between systems | E2E tests | Need the full stack running |

### 4.4 Anti-Patterns to Avoid

#### Anti-Pattern 1: Tautological Tests

```typescript
// BAD: Mirrors the implementation
it('returns the sum', () => {
  const a = 5, b = 3;
  expect(add(a, b)).toBe(a + b); // Tautology!
});

// GOOD: Tests against known values
it('adds two positive numbers', () => {
  expect(add(5, 3)).toBe(8);
});
```

#### Anti-Pattern 2: Over-Mocking

```typescript
// BAD: Everything is mocked -- testing mocks, not code
it('processes the order', async () => {
  const mockDb = { save: vi.fn().mockResolvedValue(true) };
  const mockEmail = { send: vi.fn().mockResolvedValue(true) };
  const mockPayment = { charge: vi.fn().mockResolvedValue({ id: '123' }) };

  const service = new OrderService(mockDb, mockEmail, mockPayment);
  await service.process(mockOrder);

  expect(mockDb.save).toHaveBeenCalled();
  expect(mockEmail.send).toHaveBeenCalled();
  // We verified mocks were called, not that the order was processed correctly
});

// GOOD: Test actual logic, mock only external boundaries
it('calculates order total with tax and discount', () => {
  const order = createOrder({
    items: [{ price: 100, quantity: 2 }, { price: 50, quantity: 1 }],
    discountCode: 'SAVE10',
    taxRate: 0.08,
  });

  const result = calculateOrderTotal(order);

  expect(result.subtotal).toBe(250);
  expect(result.discount).toBe(25);
  expect(result.tax).toBe(18);
  expect(result.total).toBe(243);
});
```

#### Anti-Pattern 3: Snapshot Overuse

```typescript
// BAD: Meaningless snapshot of entire component
expect(container).toMatchSnapshot(); // Noisy diffs, developers just update

// GOOD: Targeted assertions
expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent('Dashboard');
expect(screen.getByText('Revenue: $1,234')).toBeInTheDocument();
```

#### Anti-Pattern 4: Tests Coupled to Implementation

```typescript
// BAD: Tests internal state
expect(cart._items).toHaveLength(1);
expect(cart._items[0]._id).toBe('1');

// GOOD: Tests public behavior
const summary = cart.getSummary();
expect(summary.items).toHaveLength(1);
expect(summary.total).toBe(10);
```

#### Anti-Pattern 5: Tests Without Meaningful Assertions

```typescript
// BAD: Passes for ANY return value
const result = processData(input);
expect(result).toBeDefined();

// GOOD: Specific expected output
const result = processData([
  { date: '2025-01-01', value: 100 },
  { date: '2025-01-02', value: 200 },
]);
expect(result).toEqual({
  labels: ['Jan 1', 'Jan 2'],
  values: [100, 200],
  trend: 'increasing',
  average: 150,
});
```

### 4.5 Writing Test Specs That Produce Quality AI-Generated Tests

When prompting the Test Writer agent to generate tests, provide structured specifications rather than vague instructions:

```markdown
## Test Specification: OrderService.calculateShipping()

### Business Rules
1. Free shipping for orders over $100 (domestic only)
2. Weight-based pricing: $0.50/lb standard, $1.50/lb express
3. International: add $15 flat surcharge
4. Max weight per package: 70 lbs (throw if exceeded)
5. Minimum shipping cost: $5.99

### Test Cases
- Standard domestic under $100 (normal pricing)
- Standard domestic over $100 (free)
- Express domestic (no free shipping regardless)
- International standard / international express
- Exactly $100 threshold (boundary)
- Exactly 70 lbs / 70.1 lbs (boundary)
- Very light item (minimum $5.99 applies)

### Do NOT Test
- HTTP layer (integration testing)
- Database queries (repository's responsibility)
- Third-party shipping API (use mocked values)
```

This structured spec produces dramatically better AI-generated tests than "write tests for OrderService."

---

## 5. Dedicated Test Server Setup

### 5.1 Why Dual Servers

Running E2E tests against the development server creates problems:

1. **Port conflicts** -- dev server and test server fighting for the same port
2. **HMR noise** -- Hot Module Replacement during tests causes flakiness
3. **Data isolation** -- dev server may have user-modified state
4. **Performance** -- dev server is optimized for DX (source maps, etc.), not test speed
5. **Reliability** -- code changes mid-test run cause failures

The solution is a dedicated test server: the user sees a stable dev server in their browser, while agents run tests against a separate server with its own port and test database.

### 5.2 Architecture

```
Developer's Machine:
  |- Dev Server (port 5173) -----> Vite dev server with HMR
  |                                 User's browser points here
  |
  |- Test Server (port 4173) ----> Vite preview (production build)
  |                                 Playwright/agents test against this
  |
  |- Test Database (port 5433) --> Separate DB instance or in-memory
                                    Seeded/reset per test suite
```

### 5.3 Implementation: Playwright's Built-in `webServer`

The simplest approach uses Playwright's `webServer` configuration to automatically build and start a test server:

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  webServer: {
    command: 'npm run build && npm run preview -- --port 4173',
    port: 4173,
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
    env: {
      NODE_ENV: 'test',
      DATABASE_URL: 'postgresql://localhost:5433/testdb',
    },
  },
  use: {
    baseURL: 'http://localhost:4173',
  },
});
```

### 5.4 Test Database and Fixtures

```typescript
// test/fixtures/seed.ts
import { db } from '../src/lib/db';

export async function seedTestData() {
  await db.user.createMany({
    data: [
      { id: 'user-1', name: 'Alice', email: 'alice@test.com', role: 'admin' },
      { id: 'user-2', name: 'Bob', email: 'bob@test.com', role: 'user' },
    ],
  });

  await db.product.createMany({
    data: [
      { id: 'prod-1', name: 'Widget', price: 2999, stock: 100 },
      { id: 'prod-2', name: 'Gadget', price: 4999, stock: 50 },
    ],
  });
}

export async function cleanTestData() {
  await db.order.deleteMany();
  await db.product.deleteMany();
  await db.user.deleteMany();
}
```

### 5.5 Environment Variables

```bash
# .env.test
NODE_ENV=test
PORT=4173
DATABASE_URL=postgresql://test:test@localhost:5433/testdb
VITE_API_URL=http://localhost:3001/api

# Disable external services in test mode
STRIPE_SECRET_KEY=sk_test_fake
SENDGRID_API_KEY=disabled
```

### 5.6 Package.json Scripts

```json
{
  "scripts": {
    "dev": "vite --port 5173",
    "dev:test": "NODE_ENV=test vite --port 4173",
    "build:test": "NODE_ENV=test vite build",
    "preview:test": "NODE_ENV=test vite preview --port 4173",
    "test:seed": "tsx test/fixtures/seed.ts",
    "test:e2e": "playwright test",
    "test:e2e:setup": "npm run test:seed && npm run build:test"
  }
}
```

### 5.7 Startup/Teardown Script for the Test Server

```bash
#!/usr/bin/env bash
# scripts/test-server.sh
# Manages the test server lifecycle for E2E testing.

set -euo pipefail

ACTION="${1:-start}"
TEST_PORT="${TEST_PORT:-4173}"
PID_FILE=".vibeos/test-server.pid"

case "$ACTION" in
  start)
    # Kill any existing test server
    if [ -f "$PID_FILE" ]; then
      kill "$(cat "$PID_FILE")" 2>/dev/null || true
      rm -f "$PID_FILE"
    fi

    # Build and start the preview server
    echo "Building application for testing..."
    NODE_ENV=test npm run build

    echo "Starting test server on port $TEST_PORT..."
    NODE_ENV=test npx vite preview --port "$TEST_PORT" &
    echo $! > "$PID_FILE"

    # Wait for server to be ready
    for i in $(seq 1 30); do
      if curl -s "http://localhost:$TEST_PORT" > /dev/null 2>&1; then
        echo "Test server ready at http://localhost:$TEST_PORT"
        exit 0
      fi
      sleep 1
    done

    echo "ERROR: Test server did not start within 30 seconds."
    exit 1
    ;;

  stop)
    if [ -f "$PID_FILE" ]; then
      kill "$(cat "$PID_FILE")" 2>/dev/null || true
      rm -f "$PID_FILE"
      echo "Test server stopped."
    else
      echo "No test server PID file found."
    fi
    ;;

  *)
    echo "Usage: test-server.sh [start|stop]"
    exit 1
    ;;
esac
```

---

## 6. Test Runner Configuration for CI/CD

### 6.1 GitHub Actions: Complete Testing Pipeline

```yaml
# .github/workflows/test.yml
name: Test Suite

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  # ============================================
  # Job 1: Unit & Component Tests
  # ============================================
  unit-tests:
    name: Unit & Component Tests
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'npm'

      - run: npm ci

      - name: Run unit tests with coverage
        run: npx vitest run --coverage --reporter=json --outputFile=test-results.json

      - name: Upload coverage report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/
          retention-days: 7

      - name: Coverage PR comment
        if: github.event_name == 'pull_request'
        uses: davelosert/vitest-coverage-report-action@v2
        with:
          json-summary-path: coverage/coverage-summary.json
          json-final-path: coverage/coverage-final.json

  # ============================================
  # Job 2: Accessibility Tests
  # ============================================
  a11y-tests:
    name: Accessibility Tests
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'npm'
      - run: npm ci

      - name: Component a11y tests
        run: npx vitest run --reporter=verbose -- a11y

      - name: Build and run pa11y-ci
        run: |
          npm run build
          npx serve -l 4173 dist &
          sleep 5
          npx pa11y-ci

  # ============================================
  # Job 3: E2E Tests (Sharded)
  # ============================================
  e2e-tests:
    name: E2E Tests (${{ matrix.shard }})
    runs-on: ubuntu-latest
    timeout-minutes: 30
    needs: [unit-tests]
    strategy:
      fail-fast: false
      matrix:
        shard: [1/4, 2/4, 3/4, 4/4]

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'npm'
      - run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps chromium firefox webkit

      - name: Build application
        run: npm run build

      - name: Run Playwright tests
        run: npx playwright test --shard=${{ matrix.shard }}
        env:
          CI: true

      - name: Upload test artifacts
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report-${{ strategy.job-index }}
          path: |
            playwright-report/
            test-results/
          retention-days: 7

  # ============================================
  # Job 4: Visual Regression
  # ============================================
  visual-regression:
    name: Visual Regression
    runs-on: ubuntu-latest
    timeout-minutes: 20
    needs: [unit-tests]

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'npm'
      - run: npm ci
      - run: npx playwright install --with-deps chromium
      - run: npm run build

      - name: Run visual regression tests
        run: npx playwright test --project=chromium e2e/visual/

      - name: Upload visual diff artifacts
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: visual-regression-diffs
          path: test-results/
          retention-days: 30

  # ============================================
  # Job 5: Test Gate
  # ============================================
  test-gate:
    name: All Tests Pass
    if: always()
    needs: [unit-tests, a11y-tests, e2e-tests, visual-regression]
    runs-on: ubuntu-latest

    steps:
      - name: Check results
        run: |
          if [ "${{ needs.unit-tests.result }}" != "success" ] || \
             [ "${{ needs.a11y-tests.result }}" != "success" ] || \
             [ "${{ needs.e2e-tests.result }}" != "success" ] || \
             [ "${{ needs.visual-regression.result }}" != "success" ]; then
            echo "One or more test jobs failed"
            exit 1
          fi
          echo "All tests passed!"
```

### 6.2 Parallel Test Execution

Playwright supports native parallelism across workers and CI sharding:

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';
import os from 'os';

export default defineConfig({
  workers: process.env.CI ? 2 : Math.max(1, Math.floor(os.cpus().length / 2)),
  fullyParallel: true,

  projects: [
    {
      name: 'smoke',
      testMatch: /.*\.smoke\.spec\.ts/,
      retries: 0,
    },
    {
      name: 'full',
      testMatch: /.*\.spec\.ts/,
      testIgnore: /.*\.smoke\.spec\.ts/,
      dependencies: ['smoke'], // Only run if smoke passes
    },
  ],
});
```

Sharding across CI machines:

```bash
# Each CI job gets a portion of the test suite
npx playwright test --shard=1/4
npx playwright test --shard=2/4
npx playwright test --shard=3/4
npx playwright test --shard=4/4
```

### 6.3 Flaky Test Detection and Retry Strategies

```typescript
// playwright.config.ts
export default defineConfig({
  retries: process.env.CI ? 2 : 0,  // Retry failed tests on CI
  reporter: [
    ['html'],
    // Flaky test detection: tests that pass on retry are flagged
    ['json', { outputFile: 'test-results/results.json' }],
  ],
});
```

In the GitHub Actions workflow, flaky tests that pass on retry are reported as "flaky" in the HTML report. Teams should track flaky tests over time and fix the root causes rather than relying on retries.

### 6.4 Pre-Commit Test Hooks with Husky

```bash
npm install -D husky
npx husky init
```

```bash
# .husky/pre-commit
npx lint-staged
npx vitest run --changed  # Only run tests for changed files
```

```json
// package.json
{
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md,yml}": ["prettier --write"]
  }
}
```

The `vitest run --changed` flag is especially valuable for AI-assisted workflows: it runs only the tests affected by the current changes, keeping the feedback loop fast.

### 6.5 Test Reporting and Coverage Uploads

```yaml
# Add to CI workflow for inline PR annotations
- name: Annotate test failures
  if: failure() && github.event_name == 'pull_request'
  uses: dorny/test-reporter@v1
  with:
    name: Unit Test Results
    path: test-results.json
    reporter: jest-junit
```

---

## 7. Integration with VibeOS Agents

### 7.1 Test Writer Agent Workflow

The Test Writer agent (Sonnet model) is responsible for generating, validating, and maintaining tests. It follows the TDD-hybrid approach described in Section 4.

**Step-by-step workflow:**

1. **Read the feature spec** from `.vibeos/backlog.json`. The spec contains acceptance criteria, business rules, and UI description.

2. **Determine the testing track:**
   - If the feature involves business logic, data validation, API services, or state machines --> **Spec-first (TDD track)**
   - If the feature involves UI components, layouts, or interactive elements --> **Implementation-first track**

3. **For TDD track (business logic):**
   ```
   a. Parse acceptance criteria from the feature spec
   b. Generate failing test file (*.spec.ts) with tests derived from the criteria
   c. Run the tests to verify they FAIL (red phase confirmation)
   d. Signal the Feature Developer agent to implement the code
   e. After implementation, run tests again to verify they PASS
   f. If tests still fail, provide error context back to Feature Developer
   ```

4. **For implementation-first track (UI components):**
   ```
   a. Wait for the Feature Developer agent to complete the component
   b. Read the implemented component source code
   c. Generate behavioral tests (*.test.tsx) for user interactions
   d. Generate accessibility tests (*.a11y.test.tsx) using jest-axe
   e. Run all tests to verify they pass
   f. If tests fail, determine whether the test or the component has a bug
   ```

5. **Run the full affected test suite** to check for regressions.

**Signal file protocol:**

The Test Writer communicates with other agents via signal files in `.vibeos/`:

```json
// .vibeos/signals/test-writer-complete.json
{
  "timestamp": "2026-02-23T14:30:00Z",
  "feature": "user-authentication",
  "status": "complete",
  "results": {
    "unit_tests": { "pass": 12, "fail": 0, "skip": 0 },
    "component_tests": { "pass": 8, "fail": 0, "skip": 0 },
    "a11y_tests": { "pass": 5, "fail": 0, "skip": 0 },
    "coverage": { "statements": 87, "branches": 82, "functions": 85, "lines": 87 }
  },
  "files_created": [
    "src/services/auth.spec.ts",
    "src/components/LoginForm.test.tsx",
    "src/components/LoginForm.a11y.test.tsx"
  ]
}
```

### 7.2 Quality Check Agent Workflow

The Quality Check agent (Haiku model) is a lightweight gate that runs the full validation suite. It is invoked by `/check`, `/wrap`, and `/run-backlog` commands.

**Step-by-step workflow:**

1. **Run the full test suite:**
   ```bash
   npx vitest run --reporter=json --outputFile=.vibeos/test-results.json
   ```

2. **Run the linter:**
   ```bash
   npx eslint src/ --format json --output-file .vibeos/lint-results.json
   ```

3. **Run the build:**
   ```bash
   npm run build 2>&1 | tee .vibeos/build-output.txt
   echo $? > .vibeos/build-exit-code.txt
   ```

4. **Run E2E tests** (if applicable to the current feature):
   ```bash
   npx playwright test --reporter=json --output=.vibeos/e2e-results.json
   ```

5. **Report results** via signal file:

```json
// .vibeos/signals/quality-check-complete.json
{
  "timestamp": "2026-02-23T14:35:00Z",
  "status": "pass",
  "checks": {
    "tests": { "status": "pass", "total": 156, "passed": 156, "failed": 0 },
    "lint": { "status": "pass", "errors": 0, "warnings": 3 },
    "build": { "status": "pass", "exit_code": 0 },
    "e2e": { "status": "pass", "total": 24, "passed": 24, "failed": 0 }
  }
}
```

If any check fails, the Quality Check agent reports the specific failures so the Workflow Orchestrator can route the issue back to the appropriate agent (Feature Developer for code bugs, Test Writer for test issues).

### 7.3 Test Server Management by the Orchestrator

The Workflow Orchestrator is responsible for managing the test server lifecycle:

1. **Before any testing phase:** Start the test server
   ```bash
   bash scripts/test-server.sh start
   ```

2. **During testing:** The test server runs on port 4173 while the user's dev server runs on port 5173. Both can run simultaneously without conflict.

3. **After testing is complete:** Stop the test server
   ```bash
   bash scripts/test-server.sh stop
   ```

4. **For `/run-backlog`** (batch mode): The test server stays up for the entire backlog run and is stopped only when all features are complete.

### 7.4 Test Results in the Vibe Score

The Performance Coach uses test results as inputs to the Vibe Score calculation:

| Condition | Score Impact |
|---|---|
| No tests written for a feature | -10 |
| Tests exist but coverage below threshold | -5 |
| All tests pass, coverage above threshold | +5 (bonus) |
| No accessibility tests for a UI feature | -5 |
| E2E tests exist for critical user flows | +5 (bonus) |

---

## 8. Recommendations for VibeOS

### 8.1 Recommended Test Stack

| Layer | Tool | Why |
|---|---|---|
| **Unit tests** | Vitest | Native Vite integration, fastest, TypeScript-first |
| **Component tests** | Testing Library + Vitest | Behavior-focused, framework-agnostic |
| **E2E tests** | Playwright | Cross-browser, built-in visual regression, fastest |
| **A11y (component)** | jest-axe / vitest-axe | Catches violations at component level |
| **A11y (E2E)** | @axe-core/playwright | Full-page scans with real rendering |
| **A11y (CI)** | pa11y-ci | Lightweight CI pipeline gate |
| **Visual regression** | Playwright screenshots | Built-in, no third-party service needed |
| **API mocking** | MSW (Mock Service Worker) | Network-level interception, realistic |
| **Coverage** | @vitest/coverage-v8 | V8 native coverage, fast |
| **CI** | GitHub Actions | Industry standard, excellent Playwright support |

### 8.2 Directory Structure

```
project/
  src/
    components/
      Button/
        Button.tsx
        Button.test.tsx          # Component tests (Vitest + Testing Library)
        Button.a11y.test.tsx     # A11y tests (jest-axe)
    services/
      pricing/
        pricing.ts
        pricing.spec.ts          # Spec-first business logic tests (TDD)
    utils/
      formatters.ts
      formatters.test.ts
  e2e/
    pages/                       # Page object models
      checkout.page.ts
    checkout.spec.ts             # E2E tests (Playwright)
    navigation.spec.ts
    visual/
      homepage.visual.spec.ts    # Visual regression tests
    accessibility/
      pages.a11y.spec.ts         # E2E accessibility scans
  test/
    setup.ts                     # Vitest global setup
    mocks/
      handlers.ts                # MSW request handlers
      server.ts                  # MSW server setup
    fixtures/
      seed.ts                    # Test data seeding
  vitest.config.ts
  playwright.config.ts
```

### 8.3 Agent Responsibilities Summary

| Agent | Testing Role |
|---|---|
| **Test Writer** (Sonnet) | Generates unit tests, component tests, a11y tests; follows TDD-hybrid approach |
| **Quality Check** (Haiku) | Runs full suite: tests, lint, build, E2E; reports pass/fail |
| **Feature Developer** (Sonnet) | Implements code to pass Test Writer's specs; does not write tests |
| **Workflow Orchestrator** (Sonnet) | Manages test server lifecycle; routes failures to correct agent |
| **Performance Coach** (Sonnet) | Incorporates test metrics into Vibe Score; flags missing tests |

### 8.4 Testing Phase in the Feature Development Cycle

Within Tier 2's 5-phase cycle (Plan > UI Design > Code > Test > Docs), the Test phase should:

1. **Start by reading the feature spec** from `backlog.json`
2. **Generate spec tests first** for any business logic identified in the plan
3. **Generate component tests** for all UI components after the Code phase
4. **Generate accessibility tests** for every user-facing component
5. **Run the full suite** including regressions from previous features
6. **Report coverage delta** compared to the previous feature's baseline

### 8.5 Key Configuration Defaults

VibeOS should set up the following configuration in every new project during Tier 1:

- `vitest.config.ts` with 80/75/80/80 coverage thresholds
- `playwright.config.ts` with `webServer` pointing to port 4173
- MSW handlers directory at `test/mocks/`
- GitHub Actions workflow at `.github/workflows/test.yml`
- Pre-commit hook running `vitest run --changed`
- pa11y-ci configuration at `.pa11yci.json`

---

## 9. Sources

The following sources informed this research:

- **Vitest Documentation**: https://vitest.dev/
- **Vitest Configuration Reference**: https://vitest.dev/config/
- **Vitest Comparisons (vs Jest)**: https://vitest.dev/guide/comparisons.html
- **Jest Documentation**: https://jestjs.io/docs/getting-started
- **Testing Library Guiding Principles**: https://testing-library.com/docs/guiding-principles
- **Testing Library Queries Priority**: https://testing-library.com/docs/queries/about
- **Playwright Documentation**: https://playwright.dev/docs/
- **Playwright Visual Comparisons**: https://playwright.dev/docs/test-snapshots
- **Playwright Page Object Model**: https://playwright.dev/docs/pom
- **Cypress Documentation**: https://docs.cypress.io/
- **MSW (Mock Service Worker) Documentation**: https://mswjs.io/docs/
- **axe-core (Deque Systems)**: https://github.com/dequelabs/axe-core
- **@axe-core/playwright**: https://github.com/dequelabs/axe-core-npm/tree/develop/packages/playwright
- **jest-axe**: https://github.com/nickcolley/jest-axe
- **pa11y Documentation**: https://pa11y.org/
- **WCAG 2.2 Specification**: https://www.w3.org/TR/WCAG22/
- **Percy (BrowserStack) Visual Testing**: https://www.browserstack.com/percy
- **Chromatic (Storybook Visual Testing)**: https://www.chromatic.com/
- **Husky Documentation (v9)**: https://typicode.github.io/husky/
- **lint-staged**: https://github.com/lint-staged/lint-staged
- **GitHub Actions Documentation**: https://docs.github.com/en/actions
- **Kent C. Dodds, "Testing Implementation Details"**: https://kentcdodds.com/blog/testing-implementation-details
- **Kent C. Dodds, "Write tests. Not too many. Mostly integration."**: https://kentcdodds.com/blog/write-tests
- **Martin Fowler, "TestPyramid"**: https://martinfowler.com/bliki/TestPyramid.html
- **ThoughtWorks Technology Radar (Testing Tools)**: https://www.thoughtworks.com/radar
