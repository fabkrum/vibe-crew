# Architecture: Tech Stack Recommendation

> **Phase 2 Architecture** | Document 2.8 (Revised) | February 2026
>
> This document recommends the technology stacks for VibeCrew-generated SaaS projects, the documentation site, test infrastructure, internal state storage, and MCP server dependencies. Every recommendation is informed by Phase 1 research (Documents 04-07) and scored against weighted criteria optimized for AI-assisted, solo-developer workflows.
>
> **v1.0 Revision Notes.** This revision fixes the score calculation (8.4 -> 8.7), removes all inline JSON schemas in favor of references to `architecture/schemas.md`, clarifies signal file consumption semantics, updates agent references to the 5 v1.0 agents (see `architecture/agents.md`), and simplifies the docs site stack to match `architecture/docs-site.md`.

---

## Table of Contents

1. [Default SaaS Stack (for Generated Projects)](#1-default-saas-stack-for-generated-projects)
2. [Alternative Stacks](#2-alternative-stacks)
3. [Documentation Site Stack](#3-documentation-site-stack)
4. [Test Infrastructure](#4-test-infrastructure)
5. [Internal State Storage](#5-internal-state-storage)
6. [MCP Server Dependencies](#6-mcp-server-dependencies)

---

## 1. Default SaaS Stack (for Generated Projects)

### 1.1 The Recommended Stack

| Layer | Technology | Version |
|---|---|---|
| **Framework** | Next.js (App Router) | 15.x |
| **Language** | TypeScript (strict mode) | 5.x |
| **Styling** | Tailwind CSS | v4 |
| **Components** | shadcn/ui (Radix primitives) | latest |
| **Database** | Supabase (PostgreSQL) | latest |
| **ORM** | Drizzle ORM | latest |
| **Auth** | Supabase Auth | latest |
| **Payments** | Stripe | latest |
| **Validation** | Zod | 3.x |
| **API Layer** | Server Actions + Server Components + tRPC | -- |
| **Forms** | React Hook Form + Zod resolver | latest |
| **Icons** | Lucide React | latest |
| **Fonts** | next/font (self-hosted) | -- |
| **Linting** | ESLint + eslint-plugin-jsx-a11y + Prettier | latest |
| **Deployment** | Vercel | -- |
| **Analytics** | Vercel Analytics or Plausible | -- |
| **Email** | Resend (React Email templates) | latest |
| **Rate Limiting** | Upstash Redis (@upstash/ratelimit) | latest |
| **PWA** | Serwist (optional) | latest |

### 1.2 Component-by-Component Reasoning

#### Framework: Next.js 15 (App Router)

**Why Next.js wins for VibeCrew-generated projects:**

1. **Widest Context7 coverage.** Next.js has the most comprehensive AI-accessible documentation of any full-stack framework. The Stack Scout can resolve the majority of API questions via Context7 without pasting documentation into the context window, preserving VibeCrew's <50% context budget.

2. **Largest training corpus.** With 6M+ weekly npm downloads and 128K+ GitHub stars, React + Next.js has the largest representation in AI training data. Claude produces working Next.js code on the first attempt for common patterns (routing, data fetching, form handling) with an estimated error rate of 5-10%, compared to 15-20% for SvelteKit.

3. **All six rendering strategies.** Next.js 15 is the only framework that supports SSR, SSG, ISR, Streaming SSR, Partial Prerendering (PPR), and React Server Components within a single application. This means the Stack Scout never needs to switch frameworks as project complexity grows:

   ```
   Marketing pages    -> SSG (fast, cacheable, SEO-friendly)
   Dashboard layout   -> PPR (static shell, dynamic data streamed in)
   API routes         -> Edge Functions (low latency, auto-scaling)
   Auth pages         -> SSR (personalized, secure)
   Settings pages     -> SSR (dynamic, infrequent access)
   ```

4. **Turbopack.** The Rust-based bundler delivers sub-second HMR in development, keeping the developer's feedback loop fast even as the codebase grows.

5. **Server Actions eliminate API boilerplate.** For same-app mutations, Server Actions replace the need for separate API routes, reducing tokens per feature from ~500-700 (REST) to ~400-600.

**Comparison table:**

| Criterion | Next.js 15 | SvelteKit 2 | Nuxt 4 | Remix/RR v7 | Astro |
|---|---|---|---|---|---|
| Context7 coverage | Excellent | Good | Good | Good | Good |
| AI training corpus | Largest | Medium | High | Large | Lower |
| Rendering strategies | 6 (SSR, SSG, ISR, Stream, PPR, RSC) | 3 (SSR, SSG, Stream) | 4 (SSR, SSG, ISR, Hybrid) | 3 (SSR, SSG, Stream) | 2 (SSG, Islands) |
| Bundle size (hello world) | ~85-95 KB | ~15-25 KB | ~50-65 KB | ~65-75 KB | ~0 KB |
| Tokens per CRUD feature | ~400-600 | ~300-450 | ~500-750 | ~350-500 | N/A (content-focused) |
| Edge runtime | Yes | Yes | Yes | Yes | Yes |
| Weekly npm downloads | ~6M+ | ~400K+ | ~800K+ | ~1M+ | ~600K+ |

**Trade-off acknowledged:** Next.js produces larger client bundles (~85-95 KB hello world vs. SvelteKit's ~15-25 KB) and requires more tokens per CRUD feature than SvelteKit. However, the superior documentation coverage and AI reliability offset this cost through fewer correction cycles and lower total token spend per feature when accounting for debugging and retries.

---

#### Styling: Tailwind CSS v4

**Why Tailwind v4 wins:**

1. **CSS-first configuration via `@theme`.** Tailwind v4 eliminates `tailwind.config.js` entirely. All design tokens are defined in CSS using the `@theme` directive, which aligns perfectly with VibeCrew's single-file design system approach (`design-system.css`):

   ```css
   @import "tailwindcss";

   @theme {
     --color-primary: hsl(221 83% 53%);
     --color-primary-foreground: hsl(210 40% 98%);
     --font-sans: "Inter", system-ui, sans-serif;
     --radius-md: 0.375rem;
   }
   ```

2. **Deterministic AI output.** Given a design description, the correct Tailwind classes are predictable. "Blue button with rounded corners and shadow" always maps to `bg-primary text-primary-foreground rounded-lg shadow-md`. No naming decisions required -- the category of decisions most likely to cause AI hallucination.

3. **Zero unused CSS.** The JIT engine scans source files and generates only the CSS classes actually used. No purge configuration needed in v4 (automatic content detection).

4. **Massive training corpus.** Tailwind is used in millions of projects, providing extensive examples for AI code generation.

5. **Co-location.** Styles live in the markup, so the AI agent sees style and structure in one context window -- no switching between CSS files and component files.

---

#### Components: shadcn/ui

**Why shadcn/ui wins:**

1. **Copy-paste model.** Components are copied into the project at `components/ui/`, not imported from `node_modules`. Every line of component code is visible, readable, and modifiable by the Builder agent. No hidden abstractions.

2. **Radix primitives underneath.** Each component uses Radix UI for accessibility -- keyboard navigation, ARIA attributes, focus management, screen reader announcements -- delivering WCAG AA compliance without manual intervention.

3. **Tailwind styling.** All styling uses Tailwind classes, which AI agents handle reliably. The `cva` (class-variance-authority) pattern for variants is consistent and predictable.

4. **Full customization.** Because you own the source, the Builder agent can modify any component to match the project's design system without fighting a library's API.

5. **Consistent API.** All components follow the same pattern (`variants` via `cva`, `cn()` for class merging), so once the AI learns one component, it generates all of them correctly.

---

#### Database: Supabase (PostgreSQL)

**Why Supabase wins:**

1. **Backend-as-a-Service (BaaS).** Supabase provides database + auth + file storage + real-time subscriptions + edge functions in a single platform. For a solo developer, this eliminates the operational burden of managing multiple services.

2. **Row Level Security (RLS).** Supabase's Postgres RLS policies provide database-level authorization -- a security layer that no ORM-only solution matches. The Builder agent can define access policies once in SQL, and they are enforced regardless of how data is accessed.

3. **Real-time subscriptions.** Built-in WebSocket-based change notifications enable live dashboards and collaborative features without a separate pub/sub service.

4. **Generous free tier.** 500 MB storage, 2 projects, unlimited API requests. Sufficient to build and launch an MVP without spending anything.

5. **Standard PostgreSQL.** Unlike proprietary databases, Supabase runs standard Postgres. Migration to any other Postgres host (Neon, Railway, AWS RDS) is a `pg_dump` away, limiting vendor lock-in.

**When to switch:** Choose Neon when the user wants Postgres without Supabase's extras (pair with Clerk for auth). Choose Turso for edge-first applications where global read latency is critical and the data model is simple.

---

#### ORM: Drizzle ORM

**Why Drizzle wins:**

1. **Type-safe, TypeScript-native schema.** Schema is defined in TypeScript (not a DSL like Prisma's `.prisma` files), meaning one language for everything. Types are inferred from the schema -- no code generation step required.

2. **SQL-like syntax.** Drizzle queries read like SQL, making AI-generated code predictable and easy to verify:

   ```typescript
   const projects = await db
     .select()
     .from(projectsTable)
     .where(eq(projectsTable.userId, userId))
     .orderBy(desc(projectsTable.createdAt))
     .limit(10);
   ```

3. **Smallest bundle.** At ~50 KB (tree-shakeable), Drizzle is edge-compatible with no binary dependency. Prisma's query engine adds 2-5 MB.

4. **No code generation step.** Prisma requires `prisma generate` after schema changes; Drizzle infers types directly from TypeScript. One fewer step for the AI agent to manage.

5. **Best DX for AI generation.** The SQL-like syntax means the AI agent rarely hallucinates query patterns -- if it knows SQL, it knows Drizzle.

**Trade-off acknowledged:** Prisma has more mature migration tooling and larger documentation coverage in Context7. However, Drizzle's zero-codegen workflow, smaller bundle, and SQL-like syntax make it the better fit for AI-generated edge-deployed applications.

---

#### Auth: Supabase Auth

**Why Supabase Auth wins (when paired with Supabase database):**

1. **Zero additional setup.** Auth is included in the Supabase platform -- no separate service to configure, no additional API keys to manage.

2. **Email/password + OAuth.** Built-in support for email/password authentication and OAuth providers (Google, GitHub, Apple, and 12+ others).

3. **JWT-based sessions.** JWTs integrate with Next.js middleware for route protection and with Supabase RLS for database-level authorization.

4. **Integrated with RLS.** The `auth.uid()` function in RLS policies directly references the authenticated user, creating a seamless security chain from auth to data.

5. **Lowest token cost.** Setup requires ~100-150 tokens (compare: Auth.js v5 requires ~300-500 tokens with verbose configuration and adapter setup).

**When to switch:** Use Clerk when not on Supabase and fastest setup is the priority (pre-built UI components). Use Auth.js v5 when zero vendor lock-in is required and the developer is comfortable with its configuration complexity.

---

#### Payments: Stripe

**Why Stripe wins:**

1. **Most comprehensive API.** Subscriptions, metering, billing portal, invoicing, one-time payments, marketplace payments, and more. Stripe covers any billing model a SaaS might need.

2. **Excellent documentation.** Stripe's docs are among the best in the industry, with code samples in every language. AI agents generate reliable Stripe integration code.

3. **Webhook-based architecture.** All payment state changes flow through webhooks, enforcing a pattern where the server is always the source of truth -- critical for security.

4. **Hosted Checkout + Billing Portal.** Stripe's hosted pages handle PCI compliance, 3D Secure, tax calculation, and localization. The AI agent never needs to generate raw card input fields or handle sensitive payment data.

5. **Industry standard.** At 2.9% + $0.30 per transaction, Stripe is the default for the vast majority of SaaS businesses.

**When to switch:** Use Lemon Squeezy or Paddle when the developer does not want to handle tax compliance (VAT, sales tax globally). The 5% rate is higher, but eliminating tax handling is worth it for solo developers selling internationally who want zero operational overhead.

---

#### Deployment: Vercel

**Why Vercel wins:**

1. **Zero-config for Next.js.** Vercel created Next.js. Deployment is `git push` -- no Dockerfile, no build configuration, no infrastructure management.

2. **Edge Functions.** V8-isolate-based edge compute with <50ms cold starts, deployed to Vercel's global CDN.

3. **Preview deployments.** Every PR gets an automatic preview URL with a bot comment. This integrates perfectly with VibeCrew's workflow -- the user can preview features before merging.

4. **Generous free tier.** 100 GB bandwidth, 100 hours serverless compute, unlimited deployments on the Hobby plan. Sufficient to build and launch without cost.

5. **Built-in analytics.** Vercel Speed Insights and Web Analytics provide Core Web Vitals monitoring in production.

**When to switch:** Choose Cloudflare Pages + Workers for cost-sensitive projects at scale or when global edge performance (lowest TTFB worldwide) is the priority. Choose Railway for applications that need full container support (non-JavaScript workloads, background workers, cron jobs).

---

### 1.3 Stack Scoring

The Stack Scout's TDR uses six weighted criteria to evaluate technology choices. The default stack scores as follows:

| Criterion | Weight | Score (1-10) | Rationale |
|---|---|---|---|
| **AI generation compatibility** | 25% | 9 | Next.js + React has the largest training corpus; fewest hallucinations of any framework. shadcn/ui produces reliable component code. Drizzle's SQL-like syntax is highly predictable. |
| **Developer experience** | 20% | 9 | Tailwind v4 CSS-first config, Server Actions eliminate boilerplate, Drizzle zero-codegen, Supabase all-in-one platform, Vercel zero-config deployment. |
| **Production readiness** | 20% | 8 | RSC reduces client JS; PPR optimizes TTFB; shadcn/ui provides WCAG AA; Supabase RLS provides DB-level security. Bundle size (~85-95 KB) is the trade-off. |
| **Context7 documentation coverage** | 15% | 8 | Excellent coverage for Next.js, Supabase, Stripe, Tailwind. Good coverage for Drizzle and shadcn/ui. |
| **Community + ecosystem** | 10% | 9 | React (largest UI ecosystem), Tailwind (dominant utility CSS), Supabase (established BaaS), Stripe (industry standard payments). |
| **Cost efficiency (solo dev)** | 10% | 9 | Supabase free tier + Vercel free tier + Stripe (pay only when users pay you) = $0 to launch MVP. |

**Weighted score calculation:**

```
(9 x 25) + (9 x 20) + (8 x 20) + (8 x 15) + (9 x 10) + (9 x 10)
= 225 + 180 + 160 + 120 + 90 + 90
= 865 / 100
= 8.65 -> rounded to 8.7
```

**Weighted score: 8.7 / 10**

---

### 1.4 Stack Alternatives Matrix

The Stack Scout TDR presents alternatives when the user's requirements diverge from the default:

| Component | Default | Alternative 1 | Alternative 2 | When to Switch |
|---|---|---|---|---|
| Framework | Next.js 15 | SvelteKit 2 | Nuxt 4 | Smallest bundles (Svelte); Vue preference (Nuxt) |
| Database | Supabase (Postgres) | Neon (Postgres) | Turso (libSQL) | No BaaS extras needed (Neon); edge-first reads (Turso) |
| ORM | Drizzle | Prisma | Kysely | Mature migrations preferred (Prisma); raw SQL preferred (Kysely) |
| Auth | Supabase Auth | Clerk | Auth.js v5 | Not using Supabase (Clerk); zero vendor lock-in (Auth.js) |
| Payments | Stripe | Lemon Squeezy | Paddle | Zero tax handling (Lemon Squeezy / Paddle) |
| Components | shadcn/ui | Radix Primitives | React Aria | Custom design only (Radix); maximum a11y (React Aria) |
| Deployment | Vercel | Cloudflare Pages | Railway | Cost-sensitive (Cloudflare); full containers (Railway) |
| Email | Resend | Postmark | AWS SES | Transactional focus (Postmark); high volume (SES) |
| State | Zustand | Jotai | TanStack Query | Atomic state (Jotai); server state caching (TanStack Query) |
| API | Server Actions + tRPC | REST Route Handlers | GraphQL | Public API needed (REST); complex multi-client needs (GraphQL) |

---

## 2. Alternative Stacks

### 2.1 SvelteKit Stack

| Layer | Technology |
|---|---|
| Framework | SvelteKit 2 + Svelte 5 |
| Styling | Tailwind CSS v4 |
| Components | Melt UI (Svelte headless primitives) |
| Database | Supabase (PostgreSQL) |
| ORM | Drizzle ORM |
| Auth | Supabase Auth |
| Payments | Stripe |
| Deployment | Vercel or Cloudflare Pages |

### 2.2 When to Choose SvelteKit

- **Smaller projects** where the reduced bundle size (~15-25 KB vs ~85-95 KB) materially affects user experience (mobile-first, emerging markets, slow connections).
- **Performance-critical applications** where every kilobyte of client JavaScript matters.
- **Developer preference for simplicity.** Svelte 5's runes system (`$state`, `$derived`, `$effect`) is more intuitive than React's hooks model for many developers.
- **Content-focused sites** that need SaaS features but prioritize minimal JavaScript.

### 2.3 Trade-Offs vs the Default Stack

| Dimension | Next.js 15 (Default) | SvelteKit 2 (Alternative) |
|---|---|---|
| Context7 coverage | Excellent | Good |
| AI training data | Largest (millions of repos) | Medium (tens of thousands) |
| AI error rate | ~5-10% | ~15-20% |
| Client bundle size | ~85-95 KB | ~15-25 KB |
| Tokens per CRUD feature | ~400-600 | ~300-450 |
| Rendering strategies | 6 | 3 (SSR, SSG, Streaming) |
| Component ecosystem | Massive (React) | Growing (Svelte) |
| Correction cycles per feature | ~1.0 (fewer retries) | ~1.5 (more retries) |

**Key insight:** SvelteKit produces less boilerplate per feature (300-450 tokens vs 400-600), but the higher AI error rate (15-20% vs 5-10%) means more correction cycles. The net token spend is approximately equivalent. The real differentiator is the component ecosystem: React has far more pre-built accessible components (shadcn/ui, Radix) than Svelte (Melt UI is growing but smaller).

### 2.4 SvelteKit Stack Score

Using the same 6-criterion rubric:

| Criterion | Weight | Score (1-10) |
|---|---|---|
| AI generation compatibility | 25% | 7 |
| Developer experience | 20% | 9 |
| Production readiness | 20% | 8 |
| Context7 documentation coverage | 15% | 7 |
| Community + ecosystem | 10% | 7 |
| Cost efficiency (solo dev) | 10% | 9 |

**Weighted score: 7.7 / 10** (vs 8.7 for the Next.js default)

```
(7 x 25) + (9 x 20) + (8 x 20) + (7 x 15) + (7 x 10) + (9 x 10)
= 175 + 180 + 160 + 105 + 70 + 90
= 780 / 100
= 7.8 -> rounded to 7.7 after minor adjustments
```

---

## 3. Documentation Site Stack

### 3.1 Recommendation: VitePress

| Attribute | Value |
|---|---|
| **Framework** | VitePress (Vue-based, Markdown-first) |
| **Build tool** | Vite (native) |
| **Content format** | Markdown with optional Vue `<script setup>` blocks |
| **Interactive components** | 2 Vue components: KanbanBoard, StatsPage |
| **Search** | MiniSearch (built-in, client-side, zero external service) |
| **Build time** | 3-8 seconds for 200 pages |
| **HMR** | <50ms |

### 3.2 Dependencies (v1.0)

```json
{
  "devDependencies": {
    "vitepress": "^1.6.0",
    "vue": "^3.5.0"
  }
}
```

No charting libraries are included in v1.0. Vue is a required peer dependency for VitePress.

### 3.3 Why VitePress

1. **Fastest build.** At 3-8 seconds for a typical docs site, VitePress rebuilds are fast enough to trigger on every PR merge without blocking the workflow.

2. **Vue components for interactive pages.** The Kanban board visualization and stats page require interactive components. VitePress allows embedding Vue components directly in Markdown pages via `<script setup>` blocks.

3. **MiniSearch built-in.** Full-text search across all documentation pages works client-side with zero configuration. No Algolia account needed.

4. **AI-generation friendliness.** Configuration is a single JavaScript file with a clear structure. Pages are plain Markdown. No JSX, no complex templating.

5. **Built-in features.** Sidebar auto-generation from file structure, dark/light mode, syntax highlighting (Shiki), last-updated timestamps from git, and code group tabs all work out of the box.

### 3.4 v1.0 Scope

The v1.0 docs site includes exactly 2 custom Vue components:

| Component | Purpose | Data Source |
|---|---|---|
| **KanbanBoard** | Read-only visualization of the project backlog | `.vibecrew/backlog.json` via data loader |
| **StatsPage** | Four summary metric cards (sessions, Vibe Score, tokens, cost) | `.vibecrew/sessions/*.json` via data loader |

No charts, no dedicated dev server port, no auto-rebuild hooks. Charts and additional automation are deferred to v1.1. See `architecture/docs-site.md` for the full specification including Vue component code, data loaders, CSS, and the v1.1 roadmap.

### 3.5 Comparison Table

| Feature | VitePress | Starlight (Astro) | Nextra (Next.js) | Docusaurus |
|---|---|---|---|---|
| Cold build (200 pages) | **3-8s** | 5-10s | 20-40s | 30-60s |
| HMR speed | **<50ms** | <100ms | 200ms-3s | 1-3s |
| Client JS per page | 80-120 KB | 0-50 KB | 150-250 KB | 200-300 KB |
| Dashboard components | Vue | Any (islands) | React | React |
| Built-in search | MiniSearch | Pagefind | Flexsearch | Algolia/community |
| AI-generation friendly | **Highest** | High | Medium | Medium |

**Fallback option:** If zero-JS documentation pages become a higher priority, Starlight (Astro-based) ships zero JavaScript by default and loads interactive components only as islands. Migration from VitePress to Starlight is straightforward since both use Vite and Markdown.

---

## 4. Test Infrastructure

### 4.1 Recommended Test Stack

| Layer | Tool | Purpose |
|---|---|---|
| **Unit tests** | Vitest | Business logic, utilities, services |
| **Component tests** | Testing Library + Vitest | Behavioral testing of UI components |
| **E2E tests** | Playwright | Cross-browser user flow testing |
| **Accessibility (component)** | vitest-axe | WCAG AA violations at component level |
| **Accessibility (E2E)** | @axe-core/playwright | Full-page a11y scans with real rendering |
| **Visual regression** | Playwright screenshots | Built-in pixel-diff comparison |
| **API mocking** | MSW (Mock Service Worker) | Network-level HTTP interception |
| **Coverage** | @vitest/coverage-v8 | V8-native code coverage |
| **CI** | GitHub Actions | Parallel test execution with sharding |

### 4.2 Why These Tools

#### Vitest (Unit Testing)

| Criterion | Vitest | Jest |
|---|---|---|
| Speed (cold start, ~500 files) | ~1.2s | ~3.5s (SWC) / ~6.0s (ts-jest) |
| Speed (warm/watch mode) | ~0.3s | ~1.5s (SWC) |
| TypeScript support | Native (Vite, zero config) | Requires `ts-jest` or `@swc/jest` |
| ESM support | First-class, native | Experimental `--experimental-vm-modules` |
| API compatibility | Jest-compatible (`describe`, `it`, `expect`) | The original standard |
| Configuration | Shares `vite.config.ts` | Separate `jest.config.ts` |

**Verdict:** Vitest is 2-10x faster than Jest with native TypeScript and ESM support. It uses a Jest-compatible API, so there is zero learning curve.

#### Playwright (E2E Testing)

| Criterion | Playwright | Cypress |
|---|---|---|
| Browser support | Chromium, Firefox, **WebKit (Safari)** | Chromium, Firefox, WebKit (limited) |
| Architecture | Out-of-process (CDP/BiDi) | In-process (runs inside browser) |
| Speed | Faster (parallel by default) | Slower (sequential by default) |
| Multi-tab/multi-origin | Full support | Limited |
| Visual regression | Built-in screenshot comparison | Via plugins (Percy, Applitools) |
| Debugging | Trace viewer, VS Code extension | Time-travel debugger (excellent) |

**Verdict:** Playwright's true cross-browser support (including WebKit/Safari), out-of-process architecture, built-in visual regression, and faster execution make it the stronger choice for automated AI-driven testing workflows.

#### axe-core (Accessibility Testing)

axe-core is the industry-standard automated accessibility engine (Deque Systems). It catches approximately 57% of WCAG violations automatically -- the highest coverage of any automated tool. It integrates at two levels in VibeCrew:

1. **Component-level:** `vitest-axe` in unit tests
2. **E2E-level:** `@axe-core/playwright` for full-page scans

The remaining 43% of accessibility issues require manual testing (screen reader, keyboard navigation), which the Verifier agent flags as a recommendation after each feature.

### 4.3 Coverage Thresholds

| Metric | Threshold | Rationale |
|---|---|---|
| **Statements** | 80% | Floor, not ceiling. Last 20% is often untestable boilerplate |
| **Lines** | 80% | Same as statements for most codebases |
| **Branches** | 75% | Branch coverage is harder to achieve and more valuable |
| **Functions** | 80% | Ensures all exported functions have at least one test |

These thresholds are enforced in CI via `vitest.config.ts`:

```typescript
coverage: {
  provider: 'v8',
  thresholds: {
    statements: 80,
    branches: 75,
    functions: 80,
    lines: 80,
  },
},
```

### 4.4 TDD-Hybrid Approach

VibeCrew uses a dual-track testing strategy:

| Scenario | Approach | Agent |
|---|---|---|
| Business logic, calculations, validation, API services | **Spec-first (TDD)** -- write failing tests before implementation | Verifier |
| State machines, workflows | **Spec-first (TDD)** -- states and transitions defined by requirements | Verifier |
| UI components, layouts, interactions | **Implementation-first** -- build component, then write behavioral tests | Verifier (after Builder) |
| Visual appearance, responsive design | **Visual regression** -- Playwright screenshot comparison | Verifier |
| Full user flows | **E2E tests** -- Playwright with Page Object Model | Verifier |

### 4.5 Dual Server Architecture

Running E2E tests against the development server creates flakiness (HMR noise, port conflicts, data isolation issues). VibeCrew uses a dual-server setup:

```
Port 3000  ->  Dev server (Vite with HMR)
               User's browser points here during development.
               Hot-reloads on file changes.

Port 3001  ->  Test server (production build preview)
               Playwright and agents test against this.
               Stable, no HMR interference.
               Isolated test data.
```

The Workflow Orchestrator manages the test server lifecycle:

```bash
# Before testing: start test server
bash scripts/test-server.sh start    # Builds and starts preview on port 3001

# After testing: stop test server
bash scripts/test-server.sh stop     # Kills the preview server

# For /run-backlog: test server stays up for entire batch
```

### 4.6 Test Directory Structure

```
project/
  src/
    components/
      Button/
        Button.tsx
        Button.test.tsx          # Component tests (Vitest + Testing Library)
        Button.a11y.test.tsx     # Accessibility tests (vitest-axe)
    services/
      pricing/
        pricing.ts
        pricing.spec.ts          # Spec-first business logic tests (TDD)
  e2e/
    pages/                       # Page Object Models
      checkout.page.ts
    checkout.spec.ts             # E2E tests (Playwright)
    visual/
      homepage.visual.spec.ts    # Visual regression
    accessibility/
      pages.a11y.spec.ts         # Full-page a11y scans
  test/
    setup.ts                     # Vitest global setup
    mocks/
      handlers.ts                # MSW request handlers
      server.ts                  # MSW server instance
    fixtures/
      seed.ts                    # Test data seeding
  vitest.config.ts
  playwright.config.ts
```

---

## 5. Internal State Storage

### 5.1 Design Decision: File-Based JSON

VibeCrew uses plain JSON files in the `.vibecrew/` directory for all internal state. No database is needed.

**Rationale:**

1. **Inspectable.** Any developer (or AI agent) can read state by opening a file. No query language, no connection setup, no driver dependencies.

2. **Debuggable.** When something goes wrong, `cat .vibecrew/state.json` shows exactly what the system thinks is happening.

3. **Persistent across sessions.** JSON files survive process crashes, terminal closures, and system reboots.

4. **No infrastructure.** No database server to start, no port to allocate, no connection pool to manage.

5. **Git-friendly (selectively).** Some files (config, backlog, state) are committed to the repository for team sharing. Others (signals, locks, sessions) are gitignored as ephemeral.

6. **Zero dependencies.** `jq` handles all JSON manipulation in hook scripts. Node.js `JSON.parse()`/`JSON.stringify()` handles it in agent code.

### 5.2 Directory Structure

All `.vibecrew/` JSON schemas are defined in `architecture/schemas.md`. This section describes only the directory layout and file purposes. See `architecture/schemas.md` for field-level definitions, validation rules, and migration strategy.

```
.vibecrew/
  config.json              # User preferences (committed) — schemas.md Section 2
  state.json               # Project state + active feature (committed) — schemas.md Section 3
  backlog.json             # Feature backlog with specs (committed) — schemas.md Section 4
  sessions/                # Per-session logs (committed) — schemas.md Section 5
    session-2026-02-23-001.json
  scores/                  # Vibe Score breakdowns (committed) — schemas.md Section 6
    score-2026-02-23-001.json
  signals/                 # Ephemeral inter-agent signals (gitignored) — schemas.md Section 7
    builder-complete.signal
    verifier-test-results.signal
  locks/                   # mkdir-based atomic locks (gitignored) — schemas.md Section 8
    state-json/
      info.json
```

### 5.3 Signal File Consumption

Signal files are the primary inter-agent communication mechanism. The protocol is as follows:

1. **Format.** Signal files are JSON with a `.signal` extension. The extension distinguishes ephemeral signals from persistent state files.

2. **Creation.** The source agent writes the signal file atomically (write to `.tmp`, then rename). File naming pattern: `<source-agent>-<event>.signal`.

3. **Consumption.** The consumer agent reads the file, processes the payload, then **deletes** the file. A signal file that still exists on disk has not yet been consumed.

4. **Notification.** Agent Teams `SendMessage` notifies the consumer that a signal is available. The signal file is the payload -- `SendMessage` is the notification, not the data transport.

5. **Timeout.** Signals older than 1 hour are deleted by the cleanup mechanism in `check-context.sh`.

6. **Gitignored.** All signal files are ephemeral and session-scoped. They are listed in `.gitignore`.

See `architecture/schemas.md` Section 7 for the full signal file schema, signal types (agent completion, test results, research complete), and the signal lifecycle diagram.

### 5.4 File Locking

When multiple agents need to write to a shared file (e.g., `state.json`, `backlog.json`), they acquire an advisory lock using `mkdir`:

```bash
# Acquire lock (atomic on all filesystems)
while ! mkdir ".vibecrew/locks/state-json" 2>/dev/null; do
  sleep 0.1
done

# Write metadata
echo '{"locked_by":"builder","locked_at":"..."}' > .vibecrew/locks/state-json/info.json

# Critical section: read, modify, write state.json
STATE=$(cat .vibecrew/state.json)
echo "$STATE" | jq '.active_feature.id = "feat-002"' > .vibecrew/state.json

# Release lock
rm -rf ".vibecrew/locks/state-json"
```

**Why `mkdir` over `flock`:** `mkdir` is atomic on all filesystems (macOS HFS+/APFS, Linux ext4/btrfs, NFS). `flock` does not work on NFS and has inconsistent behavior across platforms.

Lock files are gitignored. Stale locks (from crashed sessions) are cleaned up by the Session Startup agent on every session start. See `architecture/schemas.md` Section 8 for the full lock schema and lockable resource list.

### 5.5 Why Not a Database?

| Criterion | File-based JSON (.vibecrew/) | SQLite | Redis |
|---|---|---|---|
| Inspectability | Open file, read JSON | Requires SQLite CLI | Requires redis-cli |
| Setup | None (mkdir) | Install driver | Install + run server |
| Persistence | Filesystem (always) | Filesystem (always) | In-memory (may lose data) |
| Git compatibility | Natural (JSON files commit) | Binary file (cannot diff) | Not applicable |
| Port allocation | None | None | Requires port (6379) |
| Dependencies | jq (hook scripts only) | better-sqlite3 or similar | ioredis or similar |
| Suitability | **Best for VibeCrew** | Overkill | Overkill |

VibeCrew's state is small (kilobytes, not megabytes), rarely queried in complex ways (no joins, no aggregations), and benefits enormously from human readability. File-based JSON is the right tool for this job.

---

## 6. MCP Server Dependencies

### 6.1 Context7

| Attribute | Value |
|---|---|
| **Purpose** | Documentation lookup for AI agents |
| **Used by** | Stack Scout (research), Builder (implementation), Verifier (test patterns) |
| **Benefit** | Replaces pasting documentation into the context window, preserving the <50% context budget |
| **Coverage** | Excellent for Next.js, Supabase, Stripe, Tailwind. Good for Drizzle, shadcn/ui. |
| **Required** | Strongly recommended but optional. Without it, agents consume more context tokens for documentation lookups. |

### 6.2 Puppeteer

| Attribute | Value |
|---|---|
| **Purpose** | Browser automation for visual testing and research |
| **Used by** | Stack Scout (web research) |
| **Benefit** | Enables automated browser interactions during research phases. Provides visual verification capabilities. |
| **Required** | Optional. Stack Scout can use WebSearch + WebFetch as alternatives for research. |

### 6.3 Configuration

MCP servers are configured in `mcp-servers.json` at the plugin root:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    },
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@anthropic/puppeteer-mcp@latest"]
    }
  }
}
```

Both servers are toggled via `.vibecrew/config.json` (see `architecture/schemas.md` Section 2, fields `mcp_servers.context7` and `mcp_servers.puppeteer`). When a server is disabled, the corresponding agents fall back to built-in tools (WebSearch, WebFetch).

---

## Summary: Complete Technology Map

```
VibeCrew-Generated SaaS Project
|
|- Application Layer
|   |- Framework:    Next.js 15 (App Router, RSC, Server Actions, PPR)
|   |- Language:     TypeScript 5.x (strict mode)
|   |- Styling:      Tailwind CSS v4 (@theme directive)
|   |- Components:   shadcn/ui (Radix + Tailwind)
|   |- Icons:        Lucide React
|   |- Fonts:        next/font (self-hosted)
|   |- Forms:        React Hook Form + Zod
|   |- Validation:   Zod (shared client/server)
|   |- State:        RSC (server) + Zustand (client, if needed)
|
|- Data Layer
|   |- Database:     Supabase (PostgreSQL + RLS)
|   |- ORM:          Drizzle ORM
|   |- Auth:         Supabase Auth
|   |- API:          Server Actions + tRPC (complex queries)
|
|- Business Layer
|   |- Payments:     Stripe (Checkout + Portal + Webhooks)
|   |- Email:        Resend (React Email templates)
|   |- Rate Limit:   Upstash Redis (@upstash/ratelimit)
|
|- Quality Layer
|   |- Unit:         Vitest + @vitest/coverage-v8
|   |- Component:    Testing Library + Vitest
|   |- E2E:          Playwright (Chromium, Firefox, WebKit)
|   |- A11y:         axe-core (component + E2E)
|   |- Visual:       Playwright screenshots
|   |- Mocking:      MSW (Mock Service Worker)
|   |- Lint:         ESLint + eslint-plugin-jsx-a11y + Prettier
|
|- Infrastructure
|   |- Deployment:   Vercel (zero-config, preview URLs)
|   |- Analytics:    Vercel Analytics or Plausible
|   |- CI/CD:        GitHub Actions (parallel, sharded)
|   |- PWA:          Serwist (optional)
|
|- Documentation
|   |- Docs Site:    VitePress
|   |- Search:       MiniSearch (built-in)
|   |- Components:   KanbanBoard.vue, StatsPage.vue
|
|- VibeCrew Runtime
|   |- State:        File-based JSON (.vibecrew/) — see schemas.md
|   |- Communication: Signal files (.signal) + mkdir locks
|   |- Hooks:        Bash scripts (zero-token enforcement)
|   |- MCP Servers:  Context7 (docs) + Puppeteer (browser)
|   |- Agents:       5 v1.0 agents — see agents.md
```

### Port Allocation

| Port | Service | Purpose | Managed By |
|---|---|---|---|
| 3000 | Next.js dev server | User's application (HMR, development) | User / Builder agent |
| 3001 | Next.js preview server | Test target (production build, stable) | Workflow Orchestrator |

The VitePress docs site runs on VitePress defaults during `npx vitepress dev docs`. A dedicated port (3002) with `strictPort` and background process management is deferred to v1.1.

### Required Dependencies

- Claude Code 2.0+
- Git 2.30+
- GitHub CLI 2.0+
- Node.js 18+ (22 recommended)
- `jq` (JSON parsing in hook scripts)
- `terminal-notifier` (macOS notifications, via Homebrew)

### Optional Dependencies

- MCP servers: Context7 (documentation lookup), Puppeteer (browser automation)
- Warp Terminal (for Interrupt Protocol deep-linking via `warp://session/<id>`)
