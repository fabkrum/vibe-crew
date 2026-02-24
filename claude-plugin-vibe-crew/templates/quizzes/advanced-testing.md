---
id: advanced-testing
title: Advanced Testing Strategies
level: 15
questions: 4
---

# Advanced Testing Strategies

## Q1

A VibeCrew project has a dashboard component that renders a data table with sortable columns and an export button. Which testing strategy correctly applies the TDD-hybrid approach to this component?

- A) Write Vitest unit tests for the sort logic before implementing it; write Playwright E2E tests for the export button before the button exists in the DOM
- B) Write Vitest unit tests for the sort logic before implementing it; write Playwright E2E tests for the full dashboard interaction after the component is built
- C) Write all tests after the full component is built since UI components are always implementation-first in the TDD-hybrid approach
- D) Use only Playwright for the entire component since it covers both logic and UI in a single test suite

**Answer:** B

**Explanation:** The TDD-hybrid correctly splits this component: the sort logic is pure business logic (given this array and sort key, return this sorted array) — it has fully specifiable behavior, so write Vitest unit tests first, before implementation. The dashboard rendering, column interaction, and export button behavior are UI concerns — their exact DOM structure emerges during building, so Playwright E2E tests are written after the component exists. Using only Playwright for the sort logic would make tests slow and fragile; unit tests run in milliseconds and have no browser dependency.

---

## Q2

What is the role of axe-core in VibeCrew's testing stack, and at which phase of the Tier 2 cycle should it run?

- A) axe-core is a bundle size analyzer; it runs during the Code phase to flag components that exceed size budgets
- B) axe-core is an accessibility testing library that audits rendered HTML for WCAG violations; it runs during the Test phase alongside Playwright E2E tests
- C) axe-core is a CSS linting tool that enforces design-system.css compliance; it runs during the UI Design phase
- D) axe-core is a security scanner that checks for XSS vulnerabilities in rendered output; it runs during the /check gate

**Answer:** B

**Explanation:** axe-core is an automated accessibility auditing library that analyzes rendered DOM against WCAG (Web Content Accessibility Guidelines) rules, flagging violations like missing alt text, insufficient color contrast, and broken ARIA roles. In VibeCrew, axe-core integrations run during the Test phase, typically embedded within Playwright tests so accessibility audits execute against real browser-rendered components. This catches accessibility regressions at the same time as functional regressions, rather than as a separate late-stage audit.

---

## Q3

A team is debating test coverage strategy. One engineer argues for 100% line coverage; another argues for testing only the "happy path." What does VibeCrew's testing discipline recommend, and what specific coverage focus does it prioritize?

- A) 100% line coverage is required; the phase gate blocks commits that fall below this threshold
- B) Happy-path-only testing is sufficient for Tier 2 features; edge cases are only required for Tier 1 foundation code
- C) Coverage targets are less important than covering critical paths, error states, and the specific acceptance criteria defined in the feature spec
- D) VibeCrew does not specify a coverage philosophy; test coverage is left entirely to the developer's judgment

**Answer:** C

**Explanation:** VibeCrew's testing discipline centers on the feature spec, not arbitrary line coverage percentages. 100% coverage can be gamed with trivial tests that touch code without asserting meaningful behavior; happy-path-only testing leaves error states untested. The correct approach is to derive test cases directly from the acceptance criteria in backlog.json: each acceptance criterion becomes one or more tests, error states specified in the constraints get explicit coverage, and edge cases called out in the spec are tested. This produces a test suite with meaningful coverage rather than optimized coverage metrics.

---

## Q4

A developer is writing Playwright tests for a multi-step checkout flow that requires authenticated user state. Setting up a real authenticated session through the UI login flow before every test is making the suite slow (45 seconds per test). What is the correct approach to solve this performance problem while maintaining test validity?

- A) Skip authentication tests entirely since authentication is infrastructure, not application logic
- B) Use Playwright's storageState feature to capture an authenticated browser state once and reuse it across tests, bypassing the UI login flow for tests that do not test authentication itself
- C) Switch to Vitest for all checkout tests since it runs faster than Playwright
- D) Mock the authentication layer at the API level so Playwright tests never interact with real auth endpoints

**Answer:** B

**Explanation:** Playwright's storageState API allows you to save an authenticated browser context (cookies, localStorage, session tokens) to a file after a single real login, then load that state for subsequent tests that need an authenticated user but are not specifically testing the login flow. This is the standard Playwright pattern for authentication performance: authenticate once in a global setup step, reuse the state across the entire suite. Switching to Vitest would lose the browser rendering context that makes E2E tests valuable; mocking auth at the API level undermines the integration fidelity that is the whole point of E2E testing.
