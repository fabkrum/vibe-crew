---
id: testing-discipline
title: Testing Discipline
level: 3
questions: 4
---

# Testing Discipline

## Q1

VibeOS uses a "TDD-hybrid" testing strategy. Which statement accurately describes how it works?

- A) All tests — both business logic and UI — must be written before any implementation code
- B) Business logic tests are written spec-first (before implementation), while UI tests are written after the component is built
- C) Tests are generated automatically by the Test Writer agent after each commit
- D) Spec-first testing applies only during Tier 1 foundation work; Tier 2 features always use implementation-first testing

**Answer:** B

**Explanation:** VibeOS's TDD-hybrid approach splits testing strategy by concern. Business logic (pure functions, API handlers, state management) gets spec-first tests — you write the test that describes the expected behavior before writing the implementation. UI components get implementation-first tests — you build the component, then write tests that verify it renders and behaves correctly. This reflects the practical reality that UI structure often emerges during design.

---

## Q2

Which tools does VibeOS's Test Writer agent use for each testing layer?

- A) Jest for unit tests and Cypress for end-to-end tests
- B) Vitest for unit and integration tests, Playwright for end-to-end browser tests
- C) Mocha for unit tests and Selenium for browser automation
- D) Vitest for all test types, with Puppeteer used only for visual regression

**Answer:** B

**Explanation:** VibeOS standardizes on Vitest for unit and integration testing (fast, Vite-native, compatible with the modern SaaS stack) and Playwright for end-to-end browser testing. Playwright is the same tool used by the Puppeteer MCP server in a different role. Cypress and Selenium are not part of the VibeOS recommended stack.

---

## Q3

What Vibe Score deduction does a session receive for completing a feature with no tests written?

- A) -5 points
- B) -10 points
- C) -15 points
- D) -20 points

**Answer:** B

**Explanation:** Shipping a feature without any tests earns a -10 Vibe Score deduction. This is intentionally higher than the -5 penalty for missing a feature spec because untested code creates compounding risk — bugs surface later, regressions are harder to detect, and the codebase becomes harder to refactor safely. The Test Writer agent is responsible for ensuring every feature lands with at least a baseline test suite.

---

## Q4

A developer is implementing a new authentication middleware function that validates JWT tokens and returns user roles. Should they write the test before or after the implementation, and why?

- A) After implementation, because middleware behavior is too complex to specify in advance
- B) After implementation, because this is a UI concern and VibeOS uses implementation-first for UI
- C) Before implementation, because JWT validation is pure business logic with clear, testable acceptance criteria
- D) Before implementation, because all Tier 2 feature tests must be written before any code

**Answer:** C

**Explanation:** JWT validation middleware is business logic — it takes an input (a token), applies rules (verify signature, check expiry, extract roles), and produces a deterministic output (valid user object or error). This is exactly the category where spec-first testing excels: you can write tests for "valid token returns user with roles," "expired token throws 401," and "malformed token throws 400" before writing a single line of implementation. The behavior is fully specifiable in advance.
