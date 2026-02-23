# Research: Modern SaaS Architecture and Tech Stack Evaluation

> **Phase 1 Research** | Document 04 | February 2026
>
> This document evaluates modern web architecture patterns, frontend frameworks, backend services, databases, authentication, payments, deployment platforms, accessibility, performance, and security for AI-generated SaaS applications. It informs the Stack Scout agent's Technology Decision Record (TDR) evaluation criteria and establishes the VibeOS default stack recommendation optimized for solo developers using AI-assisted development.

---

## Table of Contents

1. [Full-Stack SaaS Best Practices (2025-2026)](#1-full-stack-saas-best-practices-2025-2026)
2. [Frontend Frameworks](#2-frontend-frameworks)
3. [Styling and Component Libraries](#3-styling-and-component-libraries)
4. [Backend and API Patterns](#4-backend-and-api-patterns)
5. [Database Options](#5-database-options)
6. [Authentication](#6-authentication)
7. [Payments](#7-payments)
8. [Deployment Platforms](#8-deployment-platforms)
9. [Accessibility Standards (WCAG AA)](#9-accessibility-standards-wcag-aa)
10. [Performance Best Practices (Core Web Vitals)](#10-performance-best-practices-core-web-vitals)
11. [Security Best Practices for SaaS](#11-security-best-practices-for-saas)
12. [AI-Assisted Development Considerations](#12-ai-assisted-development-considerations)
13. [Recommended Default Stack for VibeOS](#13-recommended-default-stack-for-vibeos)
14. [Sources](#14-sources)

---

## 1. Full-Stack SaaS Best Practices (2025-2026)

### 1.1 The Shift Toward Edge-First Architectures

The dominant architectural trend from 2024 through 2026 is the migration from region-locked server deployments to globally distributed edge compute. Three platforms lead this shift:

| Platform | Runtime | Key Feature | Cold Start | Free Tier |
|----------|---------|-------------|------------|-----------|
| **Vercel Edge Functions** | V8 isolates | Next.js-native, middleware | <50ms | 100 hours/month |
| **Cloudflare Workers** | V8 isolates | Largest edge network (300+ cities) | <5ms | 100K requests/day |
| **Deno Deploy** | Deno runtime | Native TypeScript, Web APIs | <25ms | 1M requests/month |

**What "edge-first" means for SaaS:**

1. **Compute moves to the user.** Instead of a single `us-east-1` origin server, code runs in the data center closest to the requesting user. A user in Tokyo hits a Tokyo edge node; a user in London hits a London edge node.
2. **Sub-100ms global response times.** For read-heavy SaaS dashboards, edge-cached pages and edge-computed API responses eliminate the latency penalty that plagues centralized architectures.
3. **Constraints drive simplicity.** Edge runtimes have limited APIs (no filesystem, no long-running processes, restricted Node.js module compatibility). This forces leaner code that is easier for AI agents to generate correctly.
4. **Edge databases emerge.** Turso (libSQL at the edge), Cloudflare D1 (SQLite at the edge), and Neon's serverless driver enable database reads at the edge. Writes typically still route to a primary region.

**VibeOS implication:** The Stack Scout should evaluate whether the project's data access patterns benefit from edge deployment. Read-heavy dashboards and content sites benefit enormously. Write-heavy transactional apps (e.g., inventory management) may not.

### 1.2 Rendering Strategies: SSR vs SSG vs ISR vs Streaming

Modern frameworks offer multiple rendering strategies that can be mixed within a single application. Understanding when to use each is critical for the TDR.

| Strategy | Abbreviation | How It Works | Best For | Trade-Off |
|----------|-------------|--------------|----------|-----------|
| **Server-Side Rendering** | SSR | Page rendered on the server per request | Dynamic, personalized content (dashboards) | Higher server load, slower TTFB than static |
| **Static Site Generation** | SSG | Page rendered at build time | Marketing pages, documentation | Stale until next build; doesn't scale for many pages |
| **Incremental Static Regeneration** | ISR | Static page regenerated in the background after a timeout | Blog posts, product pages | Stale-while-revalidate semantics; first visitor gets stale page |
| **Streaming SSR** | Streaming | HTML streamed in chunks as components resolve | Complex pages with multiple data sources | Requires Suspense boundaries; more complexity |
| **Partial Prerendering** | PPR | Static shell rendered instantly, dynamic holes streamed in | SaaS dashboards (static nav + dynamic content) | Next.js 15 only; experimental in early 2025, stable in late 2025 |
| **React Server Components** | RSC | Components execute on the server, send serialized UI to client | Any component that does not need interactivity | New mental model; learning curve |

**Recommended approach for SaaS:**

```
Marketing pages    -> SSG (fast, cacheable, SEO-friendly)
Dashboard layout   -> PPR or Streaming SSR (static shell, dynamic data)
API routes         -> Edge Functions (low latency, auto-scaling)
Auth pages         -> SSR (personalized, secure)
Settings pages     -> SSR (dynamic, infrequent access)
```

**Next.js 15 supports all six strategies** within a single application via the App Router. This is the primary reason it remains the recommended framework for VibeOS -- no other framework offers this breadth of rendering control with a unified developer experience.

### 1.3 Progressive Web Apps (PWAs) vs Native Apps

For SaaS applications, PWAs have effectively won the debate against native mobile apps for most use cases:

| Factor | PWA | Native App (React Native / Flutter) |
|--------|-----|-------------------------------------|
| **Development cost** | 1x (same codebase as web) | 2-3x (separate mobile codebase) |
| **Distribution** | URL-based (no app store) | App Store + Play Store (review process) |
| **Updates** | Instant (service worker refresh) | Requires store submission and user update |
| **Offline support** | Service Workers + Cache API | Full native offline |
| **Push notifications** | Web Push API (supported on iOS since 16.4) | Native push |
| **Hardware access** | Limited (camera, GPS, Bluetooth via Web APIs) | Full native access |
| **Performance** | Good (improves yearly with browser engines) | Excellent (native compiled) |
| **AI code generation** | Easy (web technologies, huge training corpus) | Harder (platform-specific APIs, smaller corpus) |

**Recommendation for VibeOS:** Default to PWA for SaaS projects. Only recommend native if the project requires deep hardware integration (camera-heavy apps, Bluetooth, NFC) or needs to be distributed through app stores for business reasons.

**Minimal PWA setup for Next.js:**

```typescript
// next.config.ts
import withSerwist from '@serwist/next';

export default withSerwist({
  swSrc: 'app/sw.ts',
  swDest: 'public/sw.js',
})({
  // standard Next.js config
});
```

```json
// public/manifest.json
{
  "name": "My SaaS App",
  "short_name": "MySaaS",
  "start_url": "/dashboard",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "icons": [
    { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

### 1.4 WebAssembly (WASM) for Performance-Critical Paths

WebAssembly has matured significantly but remains a targeted tool rather than a general replacement for JavaScript:

**Where WASM makes sense in SaaS (2025-2026):**

| Use Case | WASM Benefit | Example Tools |
|----------|-------------|---------------|
| **Image/video processing** | 10-100x faster than JS | Sharp (Node.js, uses native code), Photon (Rust->WASM) |
| **PDF generation** | Complex rendering in the browser | pdf-lib, typst (Rust->WASM) |
| **Data visualization** | Real-time processing of large datasets | Perspective (Apache Arrow) |
| **Cryptography** | Constant-time operations, security | libsodium.js |
| **Search/indexing** | Client-side full-text search | Pagefind, tinysearch |
| **Compression** | File compression in the browser | fflate, brotli-wasm |

**Where WASM does not make sense:**
- Standard CRUD operations
- Form handling
- Routing and navigation
- Simple data transformations
- Most SaaS business logic

**Recommendation for VibeOS:** Do not include WASM in the default stack. The Stack Scout should flag it as an option only when the TDR identifies performance-critical computation requirements (image processing, data visualization, client-side search over large datasets).

### 1.5 API Patterns: REST vs GraphQL vs tRPC

| Pattern | Best For | Trade-offs | AI Generation Quality |
|---------|----------|------------|----------------------|
| **REST** | Public APIs, third-party integrations, simple CRUD | Widely understood; can lead to over/under-fetching | Excellent (most training data) |
| **GraphQL** | Complex data requirements, multiple clients with different needs | Powerful but complex; requires schema design, resolvers, tooling | Good (Apollo/urql well documented) |
| **tRPC** | TypeScript monorepos where client and server share types | End-to-end type safety with zero schema definition; only works with TypeScript clients | Good (growing, simple API surface) |
| **Server Actions** | Same-app mutations (Next.js 15) | Simplest possible pattern; no API layer to build | Excellent (minimal boilerplate) |

**Decision matrix for the Stack Scout:**

```
Need a public API consumed by third parties?     -> REST
Need to serve multiple clients (web, mobile, API)?  -> GraphQL or REST
Building a TypeScript monorepo with a single client? -> tRPC
Building with Next.js, data stays within the app?   -> Server Actions + tRPC for complex queries
```

**tRPC example (token-efficient, type-safe):**

```typescript
// server/routers/project.ts (~60 tokens)
import { router, protectedProcedure } from '../trpc';
import { z } from 'zod';

export const projectRouter = router({
  list: protectedProcedure.query(async ({ ctx }) => {
    return ctx.db.select().from(projects).where(eq(projects.userId, ctx.user.id));
  }),
  create: protectedProcedure
    .input(z.object({ name: z.string().min(1).max(100) }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db.insert(projects).values({ ...input, userId: ctx.user.id });
    }),
});
```

```typescript
// Client usage -- fully typed, zero schema duplication (~20 tokens)
const { data: projects } = trpc.project.list.useQuery();
const createProject = trpc.project.create.useMutation();
```

**Recommendation for VibeOS:** Default to **Server Actions** for simple mutations combined with **tRPC** for complex query patterns. This eliminates the need for a separate API layer while maintaining full type safety. Reserve REST for projects that explicitly need a public API.

### 1.6 Monorepo vs Polyrepo

| Factor | Monorepo | Polyrepo |
|--------|----------|----------|
| **Code sharing** | Trivial (import from sibling package) | Requires publishing packages to npm |
| **Dependency management** | Single lockfile, consistent versions | Each repo has its own versions |
| **CI/CD** | One pipeline, affected-only builds | Independent pipelines |
| **Type safety** | Full cross-package type inference | Requires published type packages |
| **Complexity** | Higher tooling overhead (Turborepo, Nx) | Simpler per-repo, harder cross-repo |
| **AI agent complexity** | Single context window can see everything | Must switch contexts between repos |
| **Solo developer** | Overkill for small projects | Simpler mental model |

**Recommended monorepo tools (if needed):**

| Tool | Type | Key Feature | Complexity |
|------|------|-------------|------------|
| **Turborepo** | Build orchestrator | Intelligent caching, parallel tasks | Low |
| **Nx** | Full monorepo framework | Dependency graph, generators, plugins | High |
| **pnpm workspaces** | Package manager native | Simple, fast, disk-efficient | Low |

**Recommendation for VibeOS:** Default to **single repo** (not monorepo) for most SaaS projects. A solo developer building one application does not benefit from monorepo tooling overhead. The Stack Scout should recommend a monorepo (Turborepo + pnpm workspaces) only when the project explicitly has multiple deployable units (e.g., a web app + a marketing site + a shared component library).

---

## 2. Frontend Frameworks

### 2.1 Framework Comparison

| Criteria | Next.js 15 | Remix / React Router v7 | SvelteKit 2 | Nuxt 4 | Astro |
|----------|-----------|------------------------|-------------|--------|-------|
| **Language** | TypeScript/React | TypeScript/React | TypeScript/Svelte 5 | TypeScript/Vue 3 | TypeScript (multi-framework) |
| **Rendering** | SSR, SSG, ISR, RSC, PPR, Streaming | SSR, SSG, Streaming | SSR, SSG, Streaming | SSR, SSG, ISR, Hybrid | SSG + Islands (partial hydration) |
| **Server Components** | Yes (React Server Components) | Yes (via React 19) | No (uses `+page.server.ts`) | No (uses `server/` directory) | Islands Architecture (partial hydration) |
| **App Router maturity** | Stable since v13.4, refined in v15 | Mature (v7 merged with React Router) | Stable, simple routing model | Stable, file-based routing | Stable, content-first routing |
| **Turbopack/build** | Turbopack (Rust-based, very fast) | Vite (fast, well-established) | Vite (native) | Vite + Nitro server engine | Vite (native) |
| **Bundle size (hello world)** | ~85-95 KB | ~65-75 KB | ~15-25 KB | ~50-65 KB | ~0 KB (zero JS by default) |
| **Learning curve** | Medium-high (RSC complexity) | Medium (web-standard patterns) | Low-medium (Svelte simplicity) | Medium (Vue ecosystem) | Low (content-focused) |
| **Ecosystem size** | Largest (React ecosystem) | Large (React ecosystem) | Growing rapidly | Large (Vue ecosystem) | Growing (framework-agnostic) |
| **Edge runtime** | Yes (middleware, edge functions) | Yes (Cloudflare, Deno) | Yes (multiple adapters) | Yes (Nitro presets) | Yes (multiple adapters) |
| **API routes** | Built-in (`app/api/`) | Built-in (loaders/actions) | Built-in (`+server.ts`) | Built-in (`server/api/`) | Built-in (endpoints) |

### 2.2 Next.js 15 Deep Dive

Next.js 15 represents the most feature-complete full-stack framework available. Key capabilities for SaaS development:

**React Server Components (RSC):**
```typescript
// app/dashboard/page.tsx -- Server Component by default (zero client JS)
import { db } from '@/lib/db';
import { projects } from '@/lib/schema';

export default async function DashboardPage() {
  // This query runs on the server. No API route needed.
  // The data never touches the client as raw JSON.
  const userProjects = await db.select().from(projects);

  return (
    <div>
      <h1>Dashboard</h1>
      {userProjects.map((p) => (
        <ProjectCard key={p.id} project={p} />
      ))}
    </div>
  );
}
```

**Server Actions (form mutations without API routes):**
```typescript
// app/projects/new/page.tsx
import { db } from '@/lib/db';
import { projects } from '@/lib/schema';
import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';

export default function NewProjectPage() {
  async function createProject(formData: FormData) {
    'use server';
    const name = formData.get('name') as string;
    await db.insert(projects).values({ name });
    revalidatePath('/dashboard');
    redirect('/dashboard');
  }

  return (
    <form action={createProject}>
      <input name="name" required />
      <button type="submit">Create Project</button>
    </form>
  );
}
```

**Partial Prerendering (PPR) -- static shell + dynamic holes:**
```typescript
// app/dashboard/layout.tsx -- static navigation shell
export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div>
      <Sidebar />       {/* Static, prerendered at build time */}
      <TopNav />         {/* Static */}
      <Suspense fallback={<DashboardSkeleton />}>
        {children}       {/* Dynamic, streamed on request */}
      </Suspense>
    </div>
  );
}
```

### 2.3 Remix / React Router v7

Since the merger of Remix into React Router v7, the framework emphasizes web-standard patterns:

**Key differentiators:**
- **Loaders and actions** map directly to HTTP GET and POST semantics
- **Progressive enhancement** -- forms work without JavaScript
- **Nested routing** with parallel data loading per route segment
- **Platform-agnostic** -- runs on any JavaScript runtime (Node, Deno, Cloudflare Workers, Bun)

```typescript
// app/routes/projects.tsx -- Remix loader/action pattern
import { type LoaderFunctionArgs, type ActionFunctionArgs } from 'react-router';
import { db } from '~/lib/db';

export async function loader({ request }: LoaderFunctionArgs) {
  const user = await requireAuth(request);
  return { projects: await db.select().from(projects).where(eq(projects.userId, user.id)) };
}

export async function action({ request }: ActionFunctionArgs) {
  const user = await requireAuth(request);
  const formData = await request.formData();
  await db.insert(projects).values({ name: formData.get('name'), userId: user.id });
  return redirect('/projects');
}

export default function ProjectsPage() {
  const { projects } = useLoaderData<typeof loader>();
  return (
    <div>
      {projects.map((p) => <ProjectCard key={p.id} project={p} />)}
      <Form method="post">
        <input name="name" required />
        <button type="submit">New Project</button>
      </Form>
    </div>
  );
}
```

### 2.4 SvelteKit 2

SvelteKit compiles away the framework at build time, producing the smallest client bundles:

**Key differentiators:**
- **Compiled reactivity** -- no virtual DOM, no runtime framework overhead
- **Svelte 5 runes** (`$state`, `$derived`, `$effect`) replace the previous magical reactivity
- **Form actions** for progressive enhancement
- **Smallest bundle sizes** of any major framework

```svelte
<!-- src/routes/projects/+page.svelte -->
<script>
  let { data } = $props();  // Svelte 5 runes syntax
</script>

<h1>Projects</h1>
{#each data.projects as project}
  <div>{project.name}</div>
{/each}

<form method="POST" action="?/create">
  <input name="name" required />
  <button>Create</button>
</form>
```

```typescript
// src/routes/projects/+page.server.ts
import { db } from '$lib/db';
import { projects } from '$lib/schema';

export async function load({ locals }) {
  return { projects: await db.select().from(projects).where(eq(projects.userId, locals.user.id)) };
}

export const actions = {
  create: async ({ request, locals }) => {
    const data = await request.formData();
    await db.insert(projects).values({ name: data.get('name'), userId: locals.user.id });
  },
};
```

### 2.5 Nuxt 4

Nuxt 4 leverages the Nitro server engine for universal deployment:

**Key differentiators:**
- **Auto-imports** -- no import statements needed for composables, components, or utilities
- **Nitro server engine** -- deploys to 15+ platforms with a single `nitro.preset` config
- **`useFetch` composable** -- type-safe data fetching with automatic SSR/client handling
- **Vue 3 ecosystem** -- access to the full Vue component and plugin ecosystem

### 2.6 Astro

Astro is content-first and uses Islands Architecture for partial hydration:

**Key differentiators:**
- **Zero JavaScript by default** -- static HTML unless you opt components into hydration
- **Islands Architecture** -- interactive components hydrate independently
- **Multi-framework** -- use React, Vue, Svelte, or Solid components in the same project
- **Content Collections** -- type-safe content management for Markdown/MDX

**Best for:** Marketing sites, documentation sites, blogs, content-heavy applications where interactivity is minimal.

**Not ideal for:** Full SaaS dashboards with heavy interactivity (every component would need `client:load` directives, defeating the purpose).

### 2.7 Context7/Documentation Coverage for AI-Assisted Development

This is a critical factor for VibeOS. Context7 provides AI-accessible documentation, and coverage breadth directly affects how efficiently an AI agent can generate code.

| Framework | Context7 Coverage | NPM Weekly Downloads | GitHub Stars | Stack Overflow Questions |
|-----------|-------------------|---------------------|-------------|------------------------|
| **Next.js** | Excellent | ~6M+ | ~128K+ | 60K+ |
| **Remix/React Router** | Good | ~1M+ (combined) | ~30K+ | 8K+ |
| **SvelteKit** | Good | ~400K+ | ~20K+ | 5K+ |
| **Nuxt** | Good | ~800K+ | ~55K+ | 15K+ |
| **Astro** | Good | ~600K+ | ~48K+ | 3K+ |

**Key finding:** Next.js has the widest documentation coverage and the largest training corpus for AI models. AI agents produce the most reliable Next.js code with the fewest hallucinations. Context7 can resolve Next.js API questions more completely than for any other framework.

### 2.8 Token Efficiency (Boilerplate Analysis)

Less boilerplate means fewer tokens per feature, which matters for VibeOS's context window discipline.

**API Route (simple GET endpoint returning JSON):**

| Framework | Lines of Code | Estimated Tokens |
|-----------|---------------|-----------------|
| Next.js 15 (App Router) | 8-12 | ~80-120 |
| Remix (loader) | 6-10 | ~60-100 |
| SvelteKit (+server.ts) | 5-8 | ~50-80 |
| Nuxt (server/api/) | 4-7 | ~40-70 |

**Full CRUD page with form:**

| Framework | Lines of Code | Estimated Tokens |
|-----------|---------------|-----------------|
| Next.js 15 (Server Actions) | 60-90 | ~600-900 |
| Remix (action/loader) | 50-70 | ~500-700 |
| SvelteKit (form actions) | 40-60 | ~400-600 |
| Nuxt (useFetch + server routes) | 50-75 | ~500-750 |

**Key finding:** SvelteKit produces the least boilerplate, followed by Remix. Next.js requires the most code, especially with React Server Components patterns. However, Next.js's superior documentation coverage means AI agents need fewer correction rounds, which can offset the boilerplate cost in practice.

---

## 3. Styling and Component Libraries

### 3.1 Styling Solutions Comparison

| Solution | Approach | Bundle Impact | DX | AI Generation Quality | Type Safety |
|----------|----------|--------------|----|-----------------------|-------------|
| **Tailwind CSS v4** | Utility-first CSS | Zero unused CSS (JIT) | Excellent (fast iteration) | Excellent (deterministic classes) | Via config |
| **CSS Modules** | Scoped CSS files | Only used styles | Good (standard CSS) | Good (familiar syntax) | No |
| **Vanilla Extract** | Zero-runtime CSS-in-TS | Only used styles | Good (TypeScript API) | Fair (niche, less training data) | Full |
| **Panda CSS** | Build-time CSS-in-JS | Only used styles | Good (type-safe tokens) | Fair (newer, less training data) | Full |
| **styled-components** | Runtime CSS-in-JS | Runtime overhead (3-12KB) | Good (familiar) | Good (large corpus) | Via props |
| **Plain CSS / CSS Variables** | Standard CSS | Minimal | Basic | Good (universal) | No |

### 3.2 Tailwind CSS v4

Tailwind CSS v4 (released early 2025) represents a major architectural overhaul:

**Key changes from v3 to v4:**
- **New engine built on Oxide** (Rust-based, 10x faster builds)
- **CSS-first configuration** -- design tokens defined in CSS instead of `tailwind.config.js`
- **No separate config file** for most projects (zero-config by default)
- **First-party container queries** via `@container`
- **First-party `@starting-style`** for entry animations
- **Automatic content detection** (no `content` array needed)
- **`@theme` directive** for design token definition

```css
/* app/globals.css -- Tailwind v4 configuration via CSS */
@import "tailwindcss";

@theme {
  --color-primary: #3b82f6;
  --color-primary-foreground: #ffffff;
  --color-secondary: #6b7280;
  --color-destructive: #ef4444;
  --color-background: #ffffff;
  --color-foreground: #0a0a0a;

  --font-sans: 'Inter', sans-serif;
  --font-mono: 'JetBrains Mono', monospace;

  --radius-sm: 0.25rem;
  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;

  --shadow-sm: 0 1px 2px rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px rgb(0 0 0 / 0.1);
}
```

**Why Tailwind is ideal for AI code generation:**
1. **Deterministic output.** Given a design description, the correct Tailwind classes are predictable. "Blue button with rounded corners and shadow" always translates to `bg-blue-500 text-white rounded-lg shadow-md`.
2. **No naming decisions.** AI agents struggle with naming CSS classes meaningfully. Tailwind eliminates this problem entirely.
3. **Massive training corpus.** Tailwind is used in millions of projects, providing extensive examples in AI training data.
4. **Co-location.** Styles live in the markup, so the AI agent sees style and structure in one context window.

### 3.3 CSS Modules

CSS Modules provide scoped styling without a runtime library:

```typescript
// components/Button.module.css
.button {
  background-color: var(--color-primary);
  color: white;
  border-radius: 0.5rem;
  padding: 0.5rem 1rem;
}

.button:hover {
  opacity: 0.9;
}
```

```typescript
// components/Button.tsx
import styles from './Button.module.css';

export function Button({ children }: { children: React.ReactNode }) {
  return <button className={styles.button}>{children}</button>;
}
```

**Trade-offs:** Excellent for teams that prefer standard CSS. Scoping prevents conflicts. However, AI agents must generate separate `.module.css` files, adding context-switching overhead. Less token-efficient than Tailwind for rapid prototyping.

### 3.4 Vanilla Extract (Type-Safe CSS)

Vanilla Extract generates static CSS from TypeScript at build time:

```typescript
// Button.css.ts
import { style } from '@vanilla-extract/css';
import { vars } from './theme.css';

export const button = style({
  backgroundColor: vars.color.primary,
  color: 'white',
  borderRadius: vars.radius.md,
  padding: '0.5rem 1rem',
  ':hover': { opacity: 0.9 },
});
```

**Trade-offs:** Full type safety for design tokens. Zero runtime CSS. But it has a smaller training corpus, meaning AI agents produce more errors. Best suited for larger teams that value type safety over AI generation speed.

### 3.5 Component Libraries

| Library | Framework | A11y Quality | Bundle Impact | Customization | AI Generation Quality |
|---------|-----------|-------------|--------------|---------------|----------------------|
| **shadcn/ui** | React (Next.js) | Excellent (built on Radix) | Zero dependency (copy-paste) | Full (Tailwind) | Excellent |
| **Radix UI** | React | Excellent (unstyled, ARIA-complete) | Small (tree-shakeable) | Full (bring your own styles) | Good |
| **React Aria (Adobe)** | React | Excellent (most comprehensive ARIA) | Medium | Full (hooks-based) | Good |
| **Headless UI** | React/Vue | Good | Small | Full (unstyled) | Good |
| **Melt UI** | Svelte | Good | Small | Full (unstyled) | Fair |
| **Ark UI** | React/Vue/Solid | Good (built on Zag.js) | Small | Full (unstyled) | Fair |
| **DaisyUI** | Any (Tailwind plugin) | Fair (class-based, manual ARIA) | Zero (Tailwind classes) | Moderate (theme-based) | Good |

### 3.6 shadcn/ui Deep Dive

shadcn/ui is the recommended component library for VibeOS. Its architecture is uniquely suited to AI-assisted development:

**How shadcn/ui works (copy-paste model):**
```bash
# Add a component to your project
npx shadcn@latest add button dialog table form

# This copies the component source into your project:
# components/ui/button.tsx
# components/ui/dialog.tsx
# components/ui/table.tsx
# components/ui/form.tsx
```

**Why this matters for AI agents:**
1. **Full source control.** Components live in your codebase at `components/ui/`. The AI agent can read, understand, and modify any component.
2. **No hidden abstractions.** Unlike importing from `node_modules`, every line of component code is visible and editable.
3. **Radix primitives underneath.** Each component uses Radix UI for accessibility (keyboard navigation, ARIA attributes, focus management) -- you get WCAG AA compliance without thinking about it.
4. **Tailwind styling.** All styling is Tailwind classes, which AI agents handle reliably.
5. **Consistent API.** Components follow a consistent pattern (`variants` via `cva`, `cn()` for class merging), so once the AI learns one component, it can generate all of them.

**shadcn/ui component example:**
```typescript
// components/ui/button.tsx (after copy-paste)
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground hover:bg-primary/90',
        destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
        outline: 'border border-input bg-background hover:bg-accent',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm: 'h-9 rounded-md px-3',
        lg: 'h-11 rounded-md px-8',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: { variant: 'default', size: 'default' },
  }
);

export function Button({ className, variant, size, ...props }: ButtonProps) {
  return <button className={cn(buttonVariants({ variant, size, className }))} {...props} />;
}
```

---

## 4. Backend and API Patterns

### 4.1 Backend Options Comparison

| Solution | Type | Runtime | Cold Start | Bundle Size | Best For |
|----------|------|---------|------------|-------------|----------|
| **Next.js API Routes** | Serverless functions | Node.js/Edge | ~250ms (Node), ~50ms (Edge) | Varies | Next.js apps (built-in) |
| **Vercel Functions** | Serverless | Node.js/Edge | ~250ms (Node) | N/A (platform) | Vercel-deployed Next.js |
| **Cloudflare Workers** | Edge compute | V8 isolates | <5ms | 1MB limit | Low-latency global APIs |
| **Hono** | Web framework | Any (Workers, Deno, Bun, Node) | Depends on runtime | ~14KB (core) | Lightweight APIs, Cloudflare-native |
| **Express** | Web framework | Node.js | N/A (long-running) | ~200KB | Traditional Node.js servers |
| **Fastify** | Web framework | Node.js | N/A (long-running) | ~250KB | High-performance Node.js APIs |
| **tRPC** | Type-safe RPC layer | Any (over HTTP) | N/A (adapter-dependent) | ~20KB client | TypeScript monorepos |

### 4.2 Serverless Functions (Vercel, Cloudflare Workers)

For most SaaS applications built with Next.js, serverless functions are the default backend pattern:

```typescript
// app/api/projects/route.ts -- Next.js Route Handler (serverless)
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@/lib/auth';
import { db } from '@/lib/db';
import { projects } from '@/lib/schema';

export async function GET(req: NextRequest) {
  const session = await auth();
  if (!session) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const userProjects = await db.select().from(projects).where(eq(projects.userId, session.user.id));
  return NextResponse.json(userProjects);
}

export async function POST(req: NextRequest) {
  const session = await auth();
  if (!session) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const body = await req.json();
  const parsed = createProjectSchema.safeParse(body);
  if (!parsed.success) return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });

  const [project] = await db.insert(projects).values({ ...parsed.data, userId: session.user.id }).returning();
  return NextResponse.json(project, { status: 201 });
}
```

**When Server Actions replace API routes:** For same-app data mutations (form submissions, button actions), Server Actions are simpler and more token-efficient. Reserve API Route Handlers for endpoints that external clients or webhooks need to access.

### 4.3 Hono (Lightweight, Cloudflare-Native)

Hono is a small, fast web framework built for edge runtimes:

```typescript
// Hono on Cloudflare Workers (~40 tokens for a full CRUD route)
import { Hono } from 'hono';
import { jwt } from 'hono/jwt';

const app = new Hono();

app.use('/api/*', jwt({ secret: Deno.env.get('JWT_SECRET')! }));

app.get('/api/projects', async (c) => {
  const userId = c.get('jwtPayload').sub;
  const projects = await db.select().from(projectsTable).where(eq(projectsTable.userId, userId));
  return c.json(projects);
});

app.post('/api/projects', async (c) => {
  const userId = c.get('jwtPayload').sub;
  const body = await c.req.json();
  const [project] = await db.insert(projectsTable).values({ ...body, userId }).returning();
  return c.json(project, 201);
});

export default app;
```

**When to use Hono:** When building standalone API services (not embedded in Next.js), when deploying to Cloudflare Workers, or when you need a framework-agnostic HTTP layer that works across runtimes.

### 4.4 tRPC (End-to-End Type Safety)

tRPC eliminates the API contract layer entirely by sharing TypeScript types between client and server:

```typescript
// server/trpc.ts -- tRPC setup (~50 tokens)
import { initTRPC, TRPCError } from '@trpc/server';
import { z } from 'zod';

const t = initTRPC.context<{ user?: User; db: Database }>().create();

export const router = t.router;
export const publicProcedure = t.procedure;
export const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.user) throw new TRPCError({ code: 'UNAUTHORIZED' });
  return next({ ctx: { ...ctx, user: ctx.user } });
});
```

```typescript
// server/routers/index.ts -- Router composition
import { router } from '../trpc';
import { projectRouter } from './project';
import { billingRouter } from './billing';

export const appRouter = router({
  project: projectRouter,
  billing: billingRouter,
});

export type AppRouter = typeof appRouter;
```

**tRPC + Next.js App Router integration** works via the `@trpc/next` adapter or the newer `@trpc/tanstack-react-query` adapter. The client gets full autocompletion on all procedures without any code generation step.

### 4.5 Recommendation for VibeOS

**Default backend pattern:**
1. **Server Actions** for all same-app mutations (forms, button clicks, data updates)
2. **Server Components** for all data fetching (direct database queries in components)
3. **Route Handlers** (`app/api/`) for webhook endpoints (Stripe), external API access, and cron jobs
4. **tRPC** when the project grows complex enough to benefit from a typed API layer

This eliminates the need for a separate backend framework in 90% of SaaS projects. The Stack Scout should recommend Hono or Fastify only when the project requires a standalone API server decoupled from the frontend.

---

## 5. Database Options

### 5.1 Comparison Table

| Criteria | Supabase (Postgres) | Neon (Postgres) | Turso (libSQL) | PlanetScale (MySQL) |
|----------|-------------------|-----------------|---------------|-------------------|
| **Engine** | PostgreSQL 15+ | PostgreSQL 16+ | libSQL (SQLite fork) | MySQL 8.0 (Vitess) |
| **Serverless** | Yes | Yes (branching, autoscale) | Yes (embedded + remote) | Yes |
| **Free tier** | 500 MB, 2 projects | 0.5 GB, autosuspend | 9 GB storage, 500M rows read | Hobby plan (limited) |
| **Branching** | No native branching | Yes (instant branching) | Yes (database branching) | Yes (schema branching) |
| **Realtime** | Yes (built-in subscriptions) | No | No | No |
| **Built-in Auth** | Yes (GoTrue-based) | No | No | No |
| **Built-in Storage** | Yes (S3-compatible) | No | No | No |
| **Edge support** | Via edge functions | Via serverless driver | Native (embedded SQLite) | Via serverless driver |
| **Connection method** | Connection pooling (Supavisor) | Serverless driver (WebSocket) | HTTP / libSQL protocol | Serverless driver |
| **Row Level Security** | Yes (Postgres RLS) | Yes (Postgres RLS) | No | No |
| **Best for** | Full-stack SaaS (all-in-one) | Serverless Postgres purists | Edge-first / embedded apps | High-scale MySQL shops |

### 5.2 Offline-First with IndexedDB + Dexie.js

For SaaS applications that require offline capability (field service apps, note-taking, offline dashboards):

```typescript
// lib/db-local.ts -- Dexie.js for offline storage
import Dexie, { type EntityTable } from 'dexie';

interface Project {
  id: string;
  name: string;
  syncedAt?: Date;
  updatedAt: Date;
}

const db = new Dexie('my-saas-db') as Dexie & {
  projects: EntityTable<Project, 'id'>;
};

db.version(1).stores({
  projects: 'id, name, syncedAt, updatedAt',
});

// Sync pattern: write locally first, sync to server when online
export async function createProjectOffline(name: string) {
  const project = { id: crypto.randomUUID(), name, updatedAt: new Date() };
  await db.projects.add(project);
  if (navigator.onLine) await syncToServer(project);
  return project;
}
```

**Recommendation:** Offline-first is not the default for most SaaS. The Stack Scout should recommend IndexedDB/Dexie.js only when the TDR identifies explicit offline requirements.

### 5.3 ORM Comparison: Drizzle vs Prisma

| Criteria | Drizzle ORM | Prisma |
|----------|------------|--------|
| **Schema definition** | TypeScript (code-first) | `.prisma` file (DSL) |
| **Bundle size** | ~50 KB (tree-shakeable) | ~2-5 MB (query engine binary) |
| **Type safety** | Full (inferred from schema) | Full (generated client) |
| **Query style** | SQL-like (relational queries) | Object-oriented (fluent API) |
| **Raw SQL** | First-class support | Supported but discouraged |
| **Migrations** | `drizzle-kit` (push/generate) | `prisma migrate` (robust) |
| **Edge/serverless** | Excellent (no binary, tiny) | Poor-Good (edge adapter, still large) |
| **Learning curve** | Medium (SQL knowledge needed) | Low (abstracted from SQL) |
| **Context7 coverage** | Good (growing docs) | Excellent (large docs, many examples) |
| **AI generation quality** | Good (SQL-like = predictable) | Good (well-known patterns) |
| **Token cost per query** | Lower (terse, SQL-like) | Higher (verbose fluent API) |
| **Performance** | Better (thin layer over SQL) | Good (optimized query engine) |
| **Code generation step** | None (TypeScript inference) | Required (`prisma generate`) |

**Drizzle schema example:**

```typescript
// lib/schema.ts -- Drizzle schema (TypeScript-native)
import { pgTable, text, timestamp, uuid, boolean } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  email: text('email').notNull().unique(),
  name: text('name'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const projects = pgTable('projects', {
  id: uuid('id').defaultRandom().primaryKey(),
  name: text('name').notNull(),
  description: text('description'),
  userId: uuid('user_id').notNull().references(() => users.id),
  isPublic: boolean('is_public').default(false),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
});
```

**Drizzle query examples:**

```typescript
// Type-safe queries -- types inferred from schema
const userProjects = await db
  .select()
  .from(projects)
  .where(and(eq(projects.userId, userId), eq(projects.isPublic, true)))
  .orderBy(desc(projects.createdAt))
  .limit(10);

// Relational queries (Drizzle's query builder)
const projectsWithOwner = await db.query.projects.findMany({
  with: { user: true },
  where: eq(projects.isPublic, true),
  limit: 10,
});

// Insert with returning
const [newProject] = await db
  .insert(projects)
  .values({ name: 'My Project', userId })
  .returning();
```

### 5.4 Recommendation for VibeOS

**Primary: Supabase (PostgreSQL) + Drizzle ORM**

Rationale:
1. **Supabase is all-in-one:** Database + Auth + Storage + Realtime + Edge Functions. For a solo developer, minimizing the number of services to manage is critical.
2. **Drizzle over Prisma:** TypeScript-native schema (one language for everything), tiny bundle (edge-compatible), SQL-like queries (predictable AI output), no code generation step.
3. **PostgreSQL is the safest bet:** Widest ORM support, best feature set (JSON, full-text search, row-level security, arrays, enums), largest community.
4. **Row Level Security:** Supabase's RLS policies provide database-level authorization -- a security layer that no ORM-only solution matches.

**Alternative: Neon (Postgres) + Drizzle** when the user wants Postgres without Supabase's extras. Neon's instant branching (create a database branch per PR) is powerful for development workflows. Pair with separate auth (Clerk or Auth.js) and storage (Uploadthing or S3).

**Alternative: Turso (libSQL) + Drizzle** for edge-first applications where global read latency matters most and the data model is relatively simple.

---

## 6. Authentication

### 6.1 Comparison Table

| Criteria | Auth.js v5 (NextAuth) | Clerk | Supabase Auth | Better Auth |
|----------|----------------------|-------|---------------|-------------|
| **Type** | Open-source library | Managed service (SaaS) | Managed service (part of Supabase) | Open-source library |
| **Pricing** | Free | Free to 10K MAU, then $0.02/MAU | Free (part of Supabase plan) | Free |
| **Setup complexity** | Medium (config-heavy) | Low (drop-in components) | Low (integrated with Supabase) | Medium (TypeScript config) |
| **Token cost (setup)** | ~300-500 tokens | ~100-200 tokens | ~100-150 tokens | ~200-400 tokens |
| **Token cost (per auth check)** | ~30-50 tokens | ~20-30 tokens | ~20-30 tokens | ~30-40 tokens |
| **OAuth providers** | 80+ (via providers) | 20+ built-in | 15+ built-in | 20+ (via plugins) |
| **Email/password** | Yes (with adapter) | Yes (built-in) | Yes (built-in) | Yes (built-in) |
| **MFA/2FA** | Community adapters | Built-in | Built-in (TOTP) | Plugin-based |
| **Session management** | JWT or database sessions | Managed (short-lived tokens) | JWT (configurable) | Database sessions |
| **UI components** | None (build your own) | Pre-built, customizable | Pre-built (basic) | None |
| **Edge runtime** | Partial (v5 improved) | Yes | Yes (edge functions) | Yes |
| **Vendor lock-in** | None | High (proprietary) | Medium (Supabase-tied) | None |
| **Maintenance** | Active (v5 rewrite) | Active (well-funded startup) | Active (part of Supabase) | Active (growing) |

**Note on Lucia Auth:** Lucia Auth was archived by its maintainer in January 2025. The author recommended using the underlying concepts (session tokens in database) but building your own implementation. Better Auth has emerged as a spiritual successor, providing a maintained library with similar philosophy. For VibeOS, neither Lucia (archived) nor a hand-rolled approach should be the default.

### 6.2 Recommendation for VibeOS

**If using Supabase stack: Supabase Auth** (zero additional setup, integrated with database RLS)

**If not using Supabase: Clerk** for fastest setup, or **Auth.js v5** for zero vendor lock-in.

Reasoning for AI-assisted development:
- **Clerk** has the lowest token cost for setup (pre-built components, minimal config) but creates vendor lock-in and costs money at scale.
- **Auth.js v5** is free and flexible but its configuration is verbose and error-prone for AI generation (many edge cases around session handling, database adapters, provider configs).
- **Supabase Auth** wins when you are already on Supabase -- zero marginal setup cost, and Row Level Security policies provide database-level authorization.

**Default: Supabase Auth** (paired with Supabase database recommendation).

---

## 7. Payments

### 7.1 Comparison Table

| Criteria | Stripe | Lemon Squeezy | Paddle |
|----------|--------|---------------|--------|
| **Pricing** | 2.9% + $0.30/txn | 5% + $0.50/txn | 5% + $0.50/txn |
| **Merchant of Record** | No (you handle tax) | Yes (handles VAT, sales tax) | Yes (handles VAT, sales tax) |
| **Setup complexity** | Medium | Low | Medium |
| **SaaS features** | Full (subscriptions, metering, billing portal, invoicing) | Good (subscriptions, license keys) | Good (subscriptions, one-time) |
| **Tax handling** | Stripe Tax (add-on, extra fee) | Included (MoR) | Included (MoR) |
| **API quality** | Excellent (gold standard) | Good | Good |
| **Documentation** | Excellent (most comprehensive) | Good | Good |
| **AI generation tokens** | ~260 tokens (core pattern) | ~200 tokens (simpler API) | ~250 tokens |
| **Webhook reliability** | Excellent (retry logic, dashboard) | Good | Good |
| **Global coverage** | 195+ countries | Most countries | Most countries |

### 7.2 Stripe Integration Patterns for SaaS

Stripe remains the gold standard for SaaS billing. The key architectural patterns:

**Subscription billing flow:**

```
User signs up (free tier)
  -> Stripe Customer created (store stripe_customer_id in users table)
  -> User upgrades
    -> Stripe Checkout Session (hosted payment page)
    -> Webhook: checkout.session.completed
      -> Store subscription_id, price_id, status in subscriptions table
    -> Webhook: invoice.paid (recurring)
      -> Update subscription status, record payment
    -> Webhook: customer.subscription.updated
      -> Handle plan changes, cancellations
    -> Webhook: customer.subscription.deleted
      -> Downgrade to free tier
```

**Key Stripe best practices for AI-generated code:**

1. **Always use Stripe Checkout (hosted).** Never build custom payment forms. Stripe Checkout handles PCI compliance, 3D Secure, tax calculation, and localization. AI agents should never generate raw card input fields.

2. **Webhook-first architecture.** Never trust client-side payment confirmation. All subscription state changes must flow through webhooks. Store webhook events idempotently (check event ID before processing).

3. **Stripe Billing Portal.** Use Stripe's hosted customer portal for subscription management (upgrade, downgrade, cancel, update payment method). This eliminates building an entire settings page.

4. **Price IDs, not amounts.** Define prices in the Stripe Dashboard, reference them by `price_id` in code. Never hardcode dollar amounts.

**Minimal Stripe setup (token-efficient):**

```typescript
// lib/stripe.ts -- Shared Stripe client (~30 tokens)
import Stripe from 'stripe';
export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);
```

```typescript
// app/api/checkout/route.ts -- Create checkout session (~80 tokens)
import { stripe } from '@/lib/stripe';
import { auth } from '@/lib/auth';

export async function POST(req: Request) {
  const session = await auth();
  if (!session) return new Response('Unauthorized', { status: 401 });

  const { priceId } = await req.json();
  const checkoutSession = await stripe.checkout.sessions.create({
    mode: 'subscription',
    customer: session.user.stripeCustomerId,
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${process.env.NEXT_PUBLIC_URL}/dashboard?success=true`,
    cancel_url: `${process.env.NEXT_PUBLIC_URL}/pricing`,
  });
  return Response.json({ url: checkoutSession.url });
}
```

```typescript
// app/api/webhook/route.ts -- Handle Stripe webhooks (~150 tokens)
import { stripe } from '@/lib/stripe';
import { db } from '@/lib/db';
import { subscriptions } from '@/lib/schema';

export async function POST(req: Request) {
  const body = await req.text();
  const sig = req.headers.get('stripe-signature')!;
  const event = stripe.webhooks.constructEvent(body, sig, process.env.STRIPE_WEBHOOK_SECRET!);

  switch (event.type) {
    case 'checkout.session.completed': {
      const session = event.data.object;
      await db.insert(subscriptions).values({
        userId: session.metadata!.userId,
        stripeSubscriptionId: session.subscription as string,
        status: 'active',
      });
      break;
    }
    case 'invoice.paid': {
      const invoice = event.data.object;
      await db
        .update(subscriptions)
        .set({ status: 'active' })
        .where(eq(subscriptions.stripeSubscriptionId, invoice.subscription as string));
      break;
    }
    case 'customer.subscription.deleted': {
      const sub = event.data.object;
      await db
        .update(subscriptions)
        .set({ status: 'canceled' })
        .where(eq(subscriptions.stripeSubscriptionId, sub.id));
      break;
    }
  }
  return new Response('OK');
}
```

**Total Stripe integration: ~260 tokens for the core pattern.**

### 7.3 Lemon Squeezy as Alternative

**When to recommend Lemon Squeezy over Stripe:**
- Solo developer who does not want to handle tax compliance (VAT, sales tax)
- Selling to global customers (Lemon Squeezy handles all merchant-of-record responsibilities)
- Willing to pay higher per-transaction fees (5% vs 2.9%) for zero tax headaches
- Digital products, indie SaaS, or projects where simplicity beats cost optimization

**Default for VibeOS: Stripe** (industry standard, best documentation for AI generation, most flexible).

---

## 8. Deployment Platforms

### 8.1 Comparison Table

| Criteria | Vercel | Cloudflare Pages/Workers | Railway | Fly.io |
|----------|--------|------------------------|---------|--------|
| **Best for** | Next.js (creators of Next.js) | Edge-first, global performance | Full-stack containers | Global edge containers |
| **Free tier** | 100 GB bandwidth, 100hrs serverless | Unlimited bandwidth, 100K workers/day | $5 free credit/month | 3 shared VMs, 160GB transfer |
| **Pricing model** | Per-seat + usage | Usage-based (very cheap) | Usage-based (compute time) | Usage-based (compute + memory) |
| **Next.js support** | Best (first-party) | Good (via `@opennextjs/cloudflare`) | Good (Docker-based) | Good (Docker-based) |
| **Edge functions** | Yes (V8 isolates) | Yes (Workers, best-in-class) | No (container-based) | Yes (Fly Machines at edge) |
| **Build speed** | Fast (Turbo Remote Cache) | Fast | Medium | Medium |
| **Preview deployments** | Yes (per-PR, with comments) | Yes (per-branch) | Yes (per-PR) | Manual |
| **Custom domains** | Yes (free SSL) | Yes (free SSL) | Yes (free SSL) | Yes (free SSL) |
| **DDoS protection** | Included | Best (Cloudflare network) | Basic | Basic |
| **Built-in database** | Vercel Postgres (Neon), KV, Blob | D1 (SQLite), KV, R2 (S3) | Postgres, Redis, MySQL | Postgres (Fly Postgres) |
| **Cron jobs** | Vercel Cron | Cron Triggers (Workers) | Native cron | Fly Machines scheduled |
| **Solo dev cost** | $0-20/month | $0-5/month | $5-20/month | $0-15/month |
| **Vendor lock-in** | Medium (Next.js optimizations) | Medium (Workers API) | Low (Docker) | Low (Docker) |

### 8.2 Vercel Deep Dive

**Pros:**
- Zero-config Next.js deployment (they build Next.js)
- Best preview deployment experience (bot comments on PR with preview URL)
- Vercel AI SDK integration for AI-powered SaaS
- Fastest iteration for Next.js projects (sub-second deploys for frontend changes)
- Speed Insights and Web Analytics built in
- Edge Middleware for geolocation, A/B testing, feature flags

**Cons:**
- Per-seat pricing hurts teams (but solo developer pays $0)
- Some Next.js features are Vercel-optimized (ISR, image optimization work best on Vercel)
- Serverless function cold starts (mitigated by edge functions)

### 8.3 Cloudflare Pages + Workers Deep Dive

**Pros:**
- Cheapest at scale (generous free tier, low per-request pricing)
- Best global edge network (fastest TTFB worldwide, 300+ cities)
- D1 database + R2 storage (S3-compatible, zero egress fees) + KV store
- DDoS protection included (Cloudflare's core business)
- Workers AI for inference at the edge

**Cons:**
- Next.js support requires `@opennextjs/cloudflare` adapter (not first-party, may lag)
- Workers runtime has constraints (no full Node.js API, V8 isolates only)
- More configuration needed than Vercel
- Some Next.js features may not work or work differently

### 8.4 Railway

**Pros:**
- Full container support (run anything: Node.js, Python, Go, Rust)
- Built-in Postgres, Redis, MySQL
- Simple usage-based pricing (no per-seat)
- Great for backend services, workers, cron jobs, microservices

**Cons:**
- No edge network (single region or limited multi-region)
- No built-in CDN for static assets
- Less optimized for frontend framework deployment

### 8.5 Fly.io

**Pros:**
- Deploy Docker containers to edge locations globally
- Fly Postgres (distributed PostgreSQL replicas)
- Good for long-running processes, WebSockets, real-time apps
- Generous free tier for small projects

**Cons:**
- More DevOps overhead (Dockerfile management)
- Less polished DX compared to Vercel
- Database management requires more hands-on work

### 8.6 Recommendation for VibeOS

**Primary: Vercel**

Rationale for solo developer SaaS:
1. Zero friction with Next.js: `git push` and you are deployed
2. Preview URLs per PR integrate perfectly with VibeOS's workflow
3. Free tier is sufficient until you have paying users
4. Built-in analytics for monitoring Core Web Vitals in production
5. AI SDK integration if building AI-powered SaaS

**Secondary: Cloudflare Pages + Workers** for cost-sensitive projects or when global edge performance is the priority.

---

## 9. Accessibility Standards (WCAG AA)

### 9.1 WCAG 2.2 AA Requirements Summary

WCAG 2.2 (published October 2023) is the current standard for web accessibility. Level AA is the legal and practical baseline for commercial web applications. The standard is organized around four principles: Perceivable, Operable, Understandable, and Robust (POUR).

#### Perceivable

| Criterion | Requirement | Implementation |
|-----------|------------|----------------|
| **1.1.1 Non-text Content** | All images have alt text | `<img alt="descriptive text">` or `alt=""` for decorative |
| **1.3.1 Info and Relationships** | Semantic HTML structure | Use `<nav>`, `<main>`, `<header>`, `<section>`, headings in order |
| **1.3.5 Identify Input Purpose** | Autocomplete attributes on form fields | `autocomplete="email"`, `autocomplete="name"` |
| **1.4.1 Use of Color** | Color is not the only indicator | Add icons/text alongside color cues (error states, status) |
| **1.4.3 Contrast (Minimum)** | 4.5:1 for normal text, 3:1 for large text | Use contrast-checked color palette |
| **1.4.4 Resize Text** | Usable at 200% zoom | Use `rem`/`em` units, responsive layout |
| **1.4.10 Reflow** | No horizontal scrolling at 320px width | Responsive design, no fixed widths |
| **1.4.11 Non-text Contrast** | 3:1 for UI components and graphics | Visible focus rings, button borders |

#### Operable

| Criterion | Requirement | Implementation |
|-----------|------------|----------------|
| **2.1.1 Keyboard** | All functionality via keyboard | Tab order, Enter/Space activation, Escape to close |
| **2.1.2 No Keyboard Trap** | User can always tab away | Test all modals, dropdowns, custom widgets |
| **2.4.3 Focus Order** | Logical tab sequence | Source order matches visual order |
| **2.4.6 Headings and Labels** | Descriptive headings | `<h1>` through `<h6>` in hierarchical order |
| **2.4.7 Focus Visible** | Visible focus indicator | `:focus-visible` styles on all interactive elements |
| **2.4.11 Focus Not Obscured (New in 2.2)** | Focus indicator not hidden by sticky headers, etc. | `scroll-margin-top` for sticky nav, z-index management |
| **2.5.3 Label in Name** | Accessible name matches visible label | `aria-label` contains visible text |
| **2.5.7 Dragging Movements (New in 2.2)** | Non-drag alternative for drag actions | Provide buttons/menus for reorder, move, resize |
| **2.5.8 Target Size (New in 2.2)** | Minimum 24x24 CSS pixels for touch targets | Set minimum button/link sizes |

#### Understandable

| Criterion | Requirement | Implementation |
|-----------|------------|----------------|
| **3.1.1 Language of Page** | Declare page language | `<html lang="en">` |
| **3.2.1 On Focus** | No unexpected context changes on focus | No auto-submit, no navigation on focus |
| **3.3.1 Error Identification** | Errors clearly identified | Inline error messages with `aria-describedby` |
| **3.3.2 Labels or Instructions** | Form fields have labels | `<label>` elements linked to inputs via `htmlFor` |
| **3.3.7 Redundant Entry (New in 2.2)** | Do not ask for same info twice | Auto-fill previously entered data |
| **3.3.8 Accessible Authentication (New in 2.2)** | No cognitive function test for login | Support password managers, passkeys, OAuth |

#### Robust

| Criterion | Requirement | Implementation |
|-----------|------------|----------------|
| **4.1.2 Name, Role, Value** | Custom components expose correct semantics | Use ARIA roles, states, properties correctly |
| **4.1.3 Status Messages** | Status updates announced to screen readers | `aria-live="polite"` for dynamic content |

### 9.2 Automated Accessibility Testing

| Tool | Type | Integration | Coverage | False Positive Rate |
|------|------|-------------|----------|-------------------|
| **axe-core** | Rule engine (library) | Jest, Playwright, Cypress, CI | ~57% of WCAG issues | Low |
| **pa11y** | CLI/CI runner | CLI, CI, npm scripts | ~55% of WCAG issues | Medium |
| **Lighthouse** | Audit tool (uses axe) | Chrome DevTools, CI, Playwright | ~40% of WCAG issues | Low |
| **eslint-plugin-jsx-a11y** | Static analysis (lint) | ESLint, IDE | ~20% of WCAG issues (compile-time) | Very low |
| **Playwright + axe** | E2E + accessibility | Playwright tests | ~57% + interaction testing | Low |

**Key insight:** Automated tools catch only 30-57% of WCAG issues. The remainder requires manual testing (screen reader testing, cognitive load assessment, keyboard navigation walkthrough). However, automating the detectable portion prevents regressions and catches the most common violations.

### 9.3 Recommended Testing Pipeline for VibeOS

```
1. Build-time:       eslint-plugin-jsx-a11y    (catches ~20% at lint time, zero runtime cost)
2. Component-level:  @axe-core/react            (dev overlay, immediate feedback during development)
3. Integration:      Playwright + @axe-core/playwright  (per-page audits in CI)
4. CI gate:          pa11y-ci                   (fail build on new violations)
5. Manual:           Screen reader testing checklist (before each release)
```

**Playwright + axe-core integration:**

```typescript
// tests/accessibility.spec.ts
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

const pages = ['/', '/pricing', '/dashboard', '/settings', '/login', '/signup'];

for (const path of pages) {
  test(`${path} has no accessibility violations`, async ({ page }) => {
    await page.goto(path);
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag22aa'])
      .analyze();
    expect(results.violations).toEqual([]);
  });
}
```

### 9.4 Common Accessibility Violations and Fixes

| Violation | Frequency | Fix |
|-----------|-----------|-----|
| **Missing alt text** | Very common | Add descriptive `alt` to all `<img>`, `alt=""` for decorative images |
| **Low color contrast** | Very common | Use contrast checker; minimum 4.5:1 for body text |
| **Missing form labels** | Common | Every `<input>` needs a `<label>` linked via `htmlFor` |
| **Missing landmark regions** | Common | Wrap content in `<main>`, `<nav>`, `<header>`, `<footer>` |
| **No focus indicator** | Common | Add `:focus-visible` styles; never use `outline: none` without replacement |
| **Keyboard inaccessible menus** | Common | Use Radix/shadcn/ui components that handle keyboard navigation |
| **Missing ARIA on custom widgets** | Moderate | Use Radix primitives or add `role`, `aria-expanded`, `aria-controls` manually |
| **Auto-playing media** | Moderate | Never auto-play with sound; provide pause control |

### 9.5 ARIA Patterns for Common SaaS Components

**Modal Dialog:**
```typescript
// Using shadcn/ui Dialog (built on Radix, handles ARIA automatically)
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from '@/components/ui/dialog';

<Dialog open={isOpen} onOpenChange={setIsOpen}>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Delete Project</DialogTitle>
      <DialogDescription>
        This action cannot be undone. This will permanently delete the project.
      </DialogDescription>
    </DialogHeader>
    {/* Radix automatically manages: role="dialog", aria-modal, focus trap, Escape to close */}
  </DialogContent>
</Dialog>
```

**Dropdown Menu:**
```typescript
// Using shadcn/ui DropdownMenu (Radix-based)
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from '@/components/ui/dropdown-menu';

<DropdownMenu>
  <DropdownMenuTrigger asChild>
    <Button variant="ghost" size="icon">
      <MoreHorizontal />
      <span className="sr-only">Open menu</span>
    </Button>
  </DropdownMenuTrigger>
  <DropdownMenuContent>
    <DropdownMenuItem>Edit</DropdownMenuItem>
    <DropdownMenuItem className="text-destructive">Delete</DropdownMenuItem>
  </DropdownMenuContent>
</DropdownMenu>
{/* Radix handles: arrow keys, typeahead, focus management, role="menu", aria-expanded */}
```

### 9.6 Accessibility in the Design System

VibeOS's Tier 1 workflow creates a `design-system.css` file. Accessibility must be embedded at this level:

```css
/* design-system.css accessibility foundations */
@theme {
  /* Contrast-checked color pairs (all pass WCAG AA 4.5:1) */
  --color-foreground: #0a0a0a;       /* on background: 19.5:1 */
  --color-background: #ffffff;
  --color-muted-foreground: #6b7280; /* on background: 4.6:1 (passes AA) */
  --color-primary: #2563eb;          /* on white: 4.6:1 (passes AA) */
  --color-primary-foreground: #ffffff;
  --color-destructive: #dc2626;      /* on white: 4.5:1 (passes AA) */
}

/* Focus ring -- visible, high contrast, consistent */
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

/* Screen reader only utility */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}

/* Minimum touch target size (WCAG 2.2 2.5.8) */
button, a, [role="button"] {
  min-height: 44px;
  min-width: 44px;
}

/* Reduced motion preference */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## 10. Performance Best Practices (Core Web Vitals)

### 10.1 Core Web Vitals Targets

Google's Core Web Vitals are the primary performance metrics. As of March 2024, Interaction to Next Paint (INP) replaced First Input Delay (FID).

| Metric | What It Measures | Good | Needs Improvement | Poor |
|--------|-----------------|------|-------------------|------|
| **LCP** (Largest Contentful Paint) | Loading speed | <= 2.5s | <= 4.0s | > 4.0s |
| **INP** (Interaction to Next Paint) | Responsiveness | <= 200ms | <= 500ms | > 500ms |
| **CLS** (Cumulative Layout Shift) | Visual stability | <= 0.1 | <= 0.25 | > 0.25 |

### 10.2 LCP Optimization Strategies

| Strategy | Implementation | Impact |
|----------|---------------|--------|
| **Preload hero image** | `<link rel="preload" as="image" fetchpriority="high">` | Major (eliminates discovery delay) |
| **Server-render above-fold** | Next.js SSR/RSC/PPR | Major (HTML arrives with content) |
| **Optimize images** | `next/image` component (auto WebP/AVIF, responsive) | Major (30-50% size reduction) |
| **Edge caching** | Vercel/Cloudflare edge cache headers | Major (sub-100ms responses) |
| **Font optimization** | `next/font` (self-hosted, no layout shift) | Moderate (eliminates font request) |
| **Minimize server time** | Database connection pooling, query optimization | Moderate |
| **Eliminate render-blocking CSS** | Critical CSS inline, defer non-critical | Moderate |

```typescript
// Optimal image loading in Next.js
import Image from 'next/image';

// Hero image: priority loading (preloaded, no lazy loading)
<Image
  src="/hero.webp"
  alt="Dashboard overview showing project metrics"
  width={1200}
  height={630}
  priority                    // Adds fetchpriority="high" and preload
  placeholder="blur"          // Shows blurred placeholder while loading
  blurDataURL="data:image/..."
/>

// Below-fold image: lazy loading (default)
<Image
  src="/feature-screenshot.webp"
  alt="Feature configuration panel"
  width={800}
  height={450}
  // lazy loading is the default -- no extra props needed
/>
```

### 10.3 INP Optimization Strategies

| Strategy | Implementation | Impact |
|----------|---------------|--------|
| **React Server Components** | Move computation server-side | Major (less client JS) |
| **Break long tasks** | `scheduler.yield()` or `requestIdleCallback()` | Major |
| **Minimize JavaScript** | Tree-shaking, dynamic imports, bundle analysis | Major |
| **Virtualize long lists** | `@tanstack/react-virtual` for lists > 50 items | Moderate |
| **Debounce input handlers** | 150-300ms debounce on search/filter | Moderate |
| **Use `useTransition`** | Mark non-urgent updates as transitions | Moderate |
| **Avoid layout thrashing** | Batch DOM reads/writes | Moderate |

```typescript
// Using React's useTransition for non-urgent updates
import { useTransition, useState } from 'react';

function SearchPage() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [isPending, startTransition] = useTransition();

  function handleSearch(e: React.ChangeEvent<HTMLInputElement>) {
    setQuery(e.target.value);  // Urgent: update input immediately
    startTransition(() => {
      setResults(filterResults(e.target.value));  // Non-urgent: can be interrupted
    });
  }

  return (
    <div>
      <input value={query} onChange={handleSearch} />
      {isPending ? <Spinner /> : <ResultsList results={results} />}
    </div>
  );
}
```

### 10.4 CLS Optimization Strategies

| Strategy | Implementation | Impact |
|----------|---------------|--------|
| **Explicit image dimensions** | Always set `width` and `height` on `<Image>` | Major |
| **Reserve dynamic content space** | `min-height` on Suspense fallbacks | Major |
| **Font display swap with size-adjust** | `next/font` handles this automatically | Major |
| **No content injection above fold** | Avoid banners/bars that push content down | Major |
| **CSS `contain` property** | `contain: layout` on independent sections | Moderate |
| **Skeleton loaders** | Match dimensions of loaded content | Moderate |

### 10.5 Image Optimization

| Technique | Implementation | Size Reduction |
|-----------|---------------|---------------|
| **Next.js `<Image>`** | `import Image from 'next/image'` | Auto-optimization |
| **WebP format** | Automatic with Next.js Image | ~25-30% vs JPEG |
| **AVIF format** | Automatic with Next.js Image (where supported) | ~40-50% vs JPEG |
| **Responsive `sizes`** | `sizes="(max-width: 768px) 100vw, 50vw"` | Serves appropriate size |
| **Blur placeholder** | `placeholder="blur"` + `blurDataURL` | Perceived performance |
| **SVG for icons** | Use `lucide-react` | Zero raster overhead |

### 10.6 Font Optimization

```typescript
// app/layout.tsx -- Optimal font loading with next/font
import { Inter, JetBrains_Mono } from 'next/font/google';

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',          // Show fallback font immediately
  variable: '--font-sans',   // CSS variable for Tailwind
});

const jetbrainsMono = JetBrains_Mono({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-mono',
});

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${inter.variable} ${jetbrainsMono.variable}`}>
      <body>{children}</body>
    </html>
  );
}
```

**Why `next/font` matters:**
- Self-hosted (no network request to Google Fonts)
- Automatic `font-display: swap` and size-adjust (zero CLS from fonts)
- Subsetted to only used character ranges
- Cached at the edge alongside the application

### 10.7 Bundle Analysis and Tree-Shaking

```bash
# Install bundle analyzer
npm install --save-dev @next/bundle-analyzer

# next.config.ts
import withBundleAnalyzer from '@next/bundle-analyzer';

const config = withBundleAnalyzer({
  enabled: process.env.ANALYZE === 'true',
})({
  // Next.js config
});

# Run analysis
ANALYZE=true npm run build
```

**Target bundle sizes for SaaS:**
- First load JS: < 100 KB (gzipped)
- Per-page JS: < 50 KB (gzipped)
- Total page weight: < 500 KB (including images)

**Common offenders to watch for:**
| Library | Typical Size (gzipped) | Lighter Alternative |
|---------|----------------------|-------------------|
| `moment.js` | ~72 KB | `date-fns` (~6 KB per function, tree-shakeable) |
| `lodash` (full) | ~71 KB | `lodash-es` (tree-shakeable) or native JS |
| `chart.js` | ~63 KB | `recharts` (~45 KB) or `@visx` (tree-shakeable) |
| `axios` | ~13 KB | Native `fetch()` (0 KB) |

### 10.8 Edge Caching Strategies

```typescript
// app/api/public-data/route.ts -- Aggressive caching for public data
export async function GET() {
  const data = await db.select().from(publicContent);

  return Response.json(data, {
    headers: {
      'Cache-Control': 'public, s-maxage=3600, stale-while-revalidate=86400',
      // CDN caches for 1 hour, serves stale for 24 hours while revalidating
    },
  });
}
```

```typescript
// app/dashboard/page.tsx -- Dynamic but cached per-user
export const dynamic = 'force-dynamic';  // Always SSR
// But the static shell (layout, sidebar, nav) is PPR-cached
```

### 10.9 Service Workers for Offline-First

```typescript
// app/sw.ts -- Service Worker with Serwist (successor to next-pwa)
import { defaultCache } from '@serwist/next/worker';
import { Serwist } from 'serwist';

const serwist = new Serwist({
  precacheEntries: self.__SW_MANIFEST,  // Auto-generated precache list
  skipWaiting: true,
  clientsClaim: true,
  runtimeCaching: defaultCache,
  // Default caching strategies:
  // - Static assets: Cache-first
  // - Pages: Network-first with cache fallback
  // - API routes: Network-only (do not cache user data)
});

serwist.addEventListeners();
```

**Recommendation:** Use `serwist` for PWA support. Cache the app shell and static assets. Do not cache user-specific API responses unless the SaaS specifically needs offline capability.

---

## 11. Security Best Practices for SaaS

### 11.1 OWASP Top 10 Summary

The OWASP Top 10 (2021 edition, with 2025 updates under discussion) identifies the most critical web application security risks:

| # | Vulnerability | SaaS Impact | Mitigation |
|---|---|---|---|
| **A01** | Broken Access Control | Users accessing other users' data | Row Level Security (RLS), middleware auth checks, authorization middleware |
| **A02** | Cryptographic Failures | Exposed secrets, weak hashing | Environment variables, bcrypt/argon2, HTTPS only |
| **A03** | Injection | SQL injection, XSS, command injection | Parameterized queries (ORM), input validation (Zod), CSP |
| **A04** | Insecure Design | Architecture-level flaws | Threat modeling, principle of least privilege, defense in depth |
| **A05** | Security Misconfiguration | Default configs, open ports, verbose errors | Secure defaults, environment-specific configs, disable debug in production |
| **A06** | Vulnerable Components | Outdated dependencies with CVEs | `npm audit`, Dependabot, Socket.dev, lockfile maintenance |
| **A07** | Auth Failures | Weak passwords, session hijacking | Managed auth (Supabase/Clerk), MFA, secure cookies, rate limiting |
| **A08** | Software/Data Integrity | Supply chain attacks, CI/CD tampering | Lockfiles, signed commits, verified GitHub Actions, npm provenance |
| **A09** | Logging Failures | No audit trail for security events | Structured logging, audit events for auth, payments, data changes |
| **A10** | SSRF | Server making unauthorized requests | Validate/allowlist outbound URLs, never pass raw user URLs to fetch |

### 11.2 Input Validation and Sanitization

```typescript
// lib/validations.ts -- Zod schemas for runtime validation
import { z } from 'zod';

// Shared schema: used by both client forms and server actions
export const createProjectSchema = z.object({
  name: z.string()
    .min(1, 'Project name is required')
    .max(100, 'Project name must be under 100 characters')
    .trim(),
  description: z.string()
    .max(500, 'Description must be under 500 characters')
    .optional(),
  slug: z.string()
    .regex(/^[a-z0-9-]+$/, 'Slug must contain only lowercase letters, numbers, and hyphens')
    .min(1)
    .max(50),
});

// Server-side validation in Server Action
export async function createProject(formData: FormData) {
  'use server';
  const parsed = createProjectSchema.safeParse({
    name: formData.get('name'),
    description: formData.get('description'),
    slug: formData.get('slug'),
  });

  if (!parsed.success) {
    return { errors: parsed.error.flatten().fieldErrors };
  }

  // parsed.data is guaranteed safe
  await db.insert(projects).values({ ...parsed.data, userId: session.user.id });
  revalidatePath('/dashboard');
  redirect('/dashboard');
}
```

**Validation strategy for VibeOS-generated code:**
1. **Client-side:** Zod schemas for immediate form feedback (shared with server)
2. **Server-side:** Same Zod schemas re-validated (never trust the client)
3. **Database-level:** PostgreSQL CHECK constraints, NOT NULL, foreign keys
4. **ORM-level:** Drizzle schema types enforce column constraints

### 11.3 CSRF, XSS, and SQL Injection Prevention

**CSRF:** Next.js Server Actions automatically include CSRF tokens. No additional configuration needed when using Server Actions or Route Handlers with proper auth checks.

**XSS:** React automatically escapes rendered content. Combined with CSP headers, XSS risk is minimal:

```typescript
// SAFE: React escapes this automatically
<p>{userProvidedContent}</p>

// DANGEROUS: Never do this
<div dangerouslySetInnerHTML={{ __html: userProvidedContent }} />
// If you must render HTML, sanitize with DOMPurify first:
import DOMPurify from 'isomorphic-dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userContent) }} />
```

**SQL Injection:** Drizzle ORM parameterizes all queries by default:

```typescript
// SAFE: Drizzle parameterizes automatically
const user = await db.select().from(users).where(eq(users.email, userInput));

// SAFE: Raw SQL with template literal (parameterized)
const result = await db.execute(sql`SELECT * FROM users WHERE email = ${userInput}`);

// DANGEROUS: Never string-interpolate into SQL
// const result = await db.execute(`SELECT * FROM users WHERE email = '${userInput}'`);
```

### 11.4 Content Security Policy (CSP)

```typescript
// middleware.ts -- CSP headers for Next.js
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const nonce = Buffer.from(crypto.randomUUID()).toString('base64');
  const response = NextResponse.next();

  const csp = [
    `default-src 'self'`,
    `script-src 'self' 'nonce-${nonce}'`,
    `style-src 'self' 'unsafe-inline'`,                       // Tailwind needs unsafe-inline
    `img-src 'self' blob: data: https:`,
    `font-src 'self'`,
    `connect-src 'self' https://*.supabase.co https://api.stripe.com`,
    `frame-src https://js.stripe.com https://hooks.stripe.com`,
    `object-src 'none'`,
    `base-uri 'self'`,
    `form-action 'self'`,
    `frame-ancestors 'none'`,
    `upgrade-insecure-requests`,
  ].join('; ');

  response.headers.set('Content-Security-Policy', csp);
  response.headers.set('x-nonce', nonce);
  return response;
}
```

### 11.5 Rate Limiting and DDoS Protection

```typescript
// lib/rate-limit.ts -- Serverless rate limiting with Upstash Redis
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const redis = Redis.fromEnv();

// Different rate limits for different endpoints
export const authRateLimit = new Ratelimit({
  redis,
  limiter: Ratelimit.slidingWindow(5, '1 m'),  // 5 attempts per minute
  prefix: 'ratelimit:auth',
});

export const apiRateLimit = new Ratelimit({
  redis,
  limiter: Ratelimit.slidingWindow(100, '1 m'),  // 100 requests per minute
  prefix: 'ratelimit:api',
});

export const uploadRateLimit = new Ratelimit({
  redis,
  limiter: Ratelimit.slidingWindow(10, '1 m'),  // 10 uploads per minute
  prefix: 'ratelimit:upload',
});
```

**Rate limiting recommendations:**
- Authentication endpoints: 5 attempts/minute per IP
- API endpoints: 100 requests/minute per authenticated user
- Webhook endpoints: No rate limiting (Stripe needs to reach you)
- File uploads: 10/minute per user
- Public endpoints: 30 requests/minute per IP

### 11.6 Secrets Management

```bash
# .env.local (never committed -- in .gitignore)
DATABASE_URL=postgresql://...
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_...
```

**Rules for AI-generated code:**
1. **Never hardcode secrets.** Always use `process.env.VARIABLE_NAME`.
2. **Prefix with `NEXT_PUBLIC_`** only for values that are safe to expose to the browser (publishable keys, public URLs).
3. **Never log secrets.** Add a pre-commit hook that scans for secret patterns.
4. **Use platform secrets** in production (Vercel Environment Variables, Cloudflare Secrets).

### 11.7 Dependency Scanning

```bash
# Built-in npm audit
npm audit

# More comprehensive: Socket.dev (supply chain attack detection)
npx socket-security scan

# GitHub: Enable Dependabot
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
```

### 11.8 Security Headers

```typescript
// next.config.ts -- Security headers for all responses
const securityHeaders = [
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
  { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
  { key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains; preload' },
];

export default {
  async headers() {
    return [{ source: '/(.*)', headers: securityHeaders }];
  },
};
```

---

## 12. AI-Assisted Development Considerations

### 12.1 Token Efficiency: Which Stacks Are Most AI-Friendly?

The number of tokens required to express a feature directly affects VibeOS's context window budget. Token-efficient stacks allow more features per session.

| Stack Component | Tokens per CRUD Feature | Notes |
|-----------------|------------------------|-------|
| **Next.js Server Actions + RSC** | ~400-600 | No separate API layer; data fetching inline |
| **Remix loaders/actions** | ~350-500 | Slightly less boilerplate; web-standard patterns |
| **SvelteKit form actions** | ~300-450 | Most concise; compiled reactivity |
| **tRPC procedures** | ~200-300 per endpoint | Extremely concise; full type inference |
| **REST API routes** | ~500-700 | Most verbose; separate client fetch code needed |
| **GraphQL resolvers + queries** | ~600-900 | Schema definition, resolvers, client queries, types |

**Key finding:** The combination of Server Components (data fetching) + Server Actions (mutations) + tRPC (complex typed queries) produces the most token-efficient full-stack pattern. GraphQL is the least token-efficient for AI-generated code due to the schema/resolver/query triplication.

### 12.2 Framework Familiarity: AI Models and Training Data

AI models generate better code for frameworks with more training data. This is not about framework quality -- it is about corpus size and documentation clarity.

| Framework | Relative Training Data Volume | AI Error Rate (estimated) | Quality of Context7 Docs |
|-----------|------------------------------|--------------------------|-------------------------|
| **React + Next.js** | Highest (millions of repos) | Low (~5-10% error rate) | Excellent |
| **Vue + Nuxt** | High (hundreds of thousands) | Low-Medium (~10-15%) | Good |
| **Svelte + SvelteKit** | Medium (tens of thousands) | Medium (~15-20%) | Good |
| **Angular** | High | Low-Medium (~10-15%) | Good |
| **Astro** | Lower (newer framework) | Medium (~15-25%) | Good |
| **Hono** | Lower (niche) | Medium-High (~20-30%) | Fair |

**Practical impact:** When an AI agent generates Next.js code, it can typically produce working code on the first attempt for common patterns (routing, data fetching, form handling). For SvelteKit, the agent may need one or two correction cycles for less common patterns (form actions, hooks, stores). For Hono, the agent may hallucinate APIs from Express or Fastify.

### 12.3 Code Generation Quality: Simpler APIs Produce Fewer Errors

| API Surface | AI Error Pattern | Mitigation |
|-------------|-----------------|------------|
| **Tailwind classes** | Very reliable (deterministic mapping) | None needed |
| **Drizzle queries** | Reliable (SQL-like, predictable) | Validate against schema types |
| **Prisma queries** | Reliable (well-known patterns) | Requires `prisma generate` step |
| **Server Actions** | Reliable (simple function pattern) | Validate with Zod schemas |
| **tRPC procedures** | Reliable (type inference catches errors) | TypeScript compiler validates |
| **REST route handlers** | Moderate (request/response boilerplate) | Zod validation on all inputs |
| **GraphQL resolvers** | More errors (complex type system, N+1 queries) | Schema-first validation |
| **Cloudflare Workers API** | More errors (non-standard runtime APIs) | Test against Worker runtime |

### 12.4 Type Safety Reduces AI Hallucination

TypeScript provides a second line of defense against AI-generated errors:

1. **Schema-inferred types (Drizzle).** The TypeScript compiler catches type mismatches between database schema and application code. If the AI generates a query that references a non-existent column, the type error is caught immediately.

2. **End-to-end type safety (tRPC).** The client knows the exact shape of every server procedure's input and output. If the AI generates a client call with wrong parameters, TypeScript catches it.

3. **Component prop validation.** TypeScript interfaces on React components catch incorrect prop usage in AI-generated JSX.

4. **Zod runtime validation.** Even if types pass, runtime validation catches data that does not match the schema (e.g., a string that should be an email, a number that should be positive).

**The type safety chain:**
```
Drizzle schema (database) -> Zod schemas (validation) -> tRPC types (API) -> TypeScript (components)
```

Each link in this chain catches errors the previous one might miss. For AI-generated code, this multi-layer validation is essential because it catches hallucinated field names, incorrect types, and invalid data shapes before they reach production.

### 12.5 Context7 Documentation Coverage

Context7 allows AI agents to look up framework documentation without pasting large docs into the context window. Coverage quality directly affects the Stack Scout's recommendation:

| Library | Context7 Status | Implication for VibeOS |
|---------|----------------|----------------------|
| **Next.js** | Comprehensive | Stack Scout can resolve most questions via Context7 |
| **React** | Comprehensive | Same |
| **Tailwind CSS** | Comprehensive | Same |
| **Supabase** | Good | Most APIs covered; some edge cases may need docs pasting |
| **Drizzle ORM** | Good | Core queries covered; advanced features may need supplementation |
| **Prisma** | Comprehensive | Extensive coverage |
| **Stripe** | Good | Payment flows covered; complex billing scenarios may need docs |
| **shadcn/ui** | Good | Component APIs covered; customization patterns may vary |
| **Zod** | Good | Schema patterns well covered |
| **tRPC** | Fair-Good | Basic patterns covered; advanced adapters may need docs |

---

## 13. Recommended Default Stack for VibeOS

### 13.1 The VibeOS Default Stack

```
Framework:      Next.js 15 (App Router, Server Components, Server Actions, PPR)
Language:       TypeScript (strict mode)
Styling:        Tailwind CSS v4 (CSS-first config, @theme directive)
Components:     shadcn/ui (Radix-based, accessible, copy-paste model)
Database:       Supabase (PostgreSQL) with Row Level Security
ORM:            Drizzle ORM (TypeScript-native, edge-compatible)
Auth:           Supabase Auth (integrated, zero additional setup)
Payments:       Stripe (Checkout + Billing Portal + Webhooks)
Validation:     Zod (shared client/server schemas)
API Layer:      Server Actions (mutations) + Server Components (queries) + tRPC (complex)
State:          React Server Components (server state) + Zustand (client, if needed)
Forms:          React Hook Form + Zod resolver (or Server Actions for simple forms)
Icons:          Lucide React
Fonts:          next/font (self-hosted, zero layout shift)
Testing:        Vitest (unit) + Playwright (E2E + accessibility via axe-core)
Linting:        ESLint + eslint-plugin-jsx-a11y + Prettier
Deployment:     Vercel (primary) or Cloudflare Pages (secondary)
Analytics:      Vercel Analytics or Plausible (privacy-friendly)
Email:          Resend (developer-friendly API, React Email templates)
Rate Limiting:  Upstash Redis (@upstash/ratelimit)
PWA:            Serwist (service worker, optional)
```

### 13.2 Why This Stack Wins for AI-Generated Code

| Factor | Score | Reasoning |
|--------|-------|-----------|
| **Token efficiency** | 8/10 | Server Actions eliminate API boilerplate; shadcn/ui is concise; Drizzle queries are terse |
| **AI reliability** | 9/10 | Next.js + React have the largest training corpus; fewest hallucinations |
| **Context7 coverage** | 9/10 | Excellent coverage for Next.js, Supabase, Drizzle, shadcn/ui, Stripe |
| **Simplicity** | 8/10 | Supabase consolidates DB + Auth + Storage; Stripe handles all payments |
| **Accessibility** | 9/10 | shadcn/ui (Radix) provides WCAG AA out of the box; automated testing with axe-core |
| **Performance** | 9/10 | RSC reduces client JS; PPR optimizes TTFB; images auto-optimized; next/font eliminates CLS |
| **Security** | 8/10 | Supabase RLS, Zod validation, CSP headers, managed auth, parameterized queries |
| **Cost (solo dev)** | 8/10 | Supabase free tier + Vercel free tier = $0 until paying users |
| **Scalability** | 8/10 | Supabase scales Postgres; Vercel scales serverless; Stripe scales payments |
| **Overall** | **8.4/10** | Best balance of AI compatibility, developer experience, and production readiness |

### 13.3 Stack Alternatives Table

The Stack Scout TDR should present alternatives when the user's requirements do not fit the default:

| Component | Default | Alternative 1 | Alternative 2 | When to Switch |
|-----------|---------|---------------|---------------|----------------|
| Framework | Next.js 15 | SvelteKit 2 | Nuxt 4 | Smaller bundles (Svelte), Vue preference (Nuxt) |
| Database | Supabase (Postgres) | Neon (Postgres) | Turso (libSQL) | No Supabase extras needed (Neon), edge-first (Turso) |
| ORM | Drizzle | Prisma | Kysely | Prisma's migration tooling preferred, raw SQL preference (Kysely) |
| Auth | Supabase Auth | Clerk | Auth.js v5 | Not using Supabase (Clerk), zero vendor lock-in (Auth.js) |
| Payments | Stripe | Lemon Squeezy | Paddle | Zero tax handling (Lemon Squeezy/Paddle) |
| Components | shadcn/ui | Radix Primitives | React Aria | Custom design only (Radix), maximum a11y (React Aria) |
| Deployment | Vercel | Cloudflare Pages | Railway | Cost-sensitive (Cloudflare), full containers (Railway) |
| Email | Resend | Postmark | AWS SES | Transactional email focus (Postmark), high volume (SES) |
| State | Zustand | Jotai | TanStack Query | Atomic state (Jotai), server state cache (TanStack Query) |
| API | Server Actions + tRPC | REST Route Handlers | GraphQL | Public API needed (REST), complex client needs (GraphQL) |

### 13.4 Stack Scout TDR Evaluation Criteria

When the Stack Scout agent evaluates a tech stack for a new project, it should score each option on these weighted criteria:

| Criterion | Weight | Description |
|-----------|--------|-------------|
| **AI Generation Reliability** | 25% | How reliably can Claude generate correct code for this technology? (Based on training corpus size, documentation quality, API simplicity) |
| **Context7 Coverage** | 15% | How well does Context7 cover this technology's documentation? (Reduces need to paste docs into context) |
| **Token Efficiency** | 15% | How many tokens does a typical feature require? (Less boilerplate = more features per session) |
| **Solo Developer Suitability** | 15% | How appropriate is this for a single developer? (Setup complexity, operational burden, learning curve) |
| **Production Readiness** | 10% | Security, performance, accessibility, scalability out of the box |
| **Ecosystem Maturity** | 10% | Community size, npm downloads, Stack Overflow answers, third-party integrations |
| **Cost at Zero Revenue** | 5% | Can the developer build and launch without paying anything? (Free tier availability) |
| **Migration Path** | 5% | How hard is it to switch away if the technology becomes unsupported? (Vendor lock-in risk) |

**Scoring scale:** Each criterion is scored 1-10. The weighted sum produces a TDR score. The Stack Scout should present the top 2-3 options with scores, explicitly state the trade-offs, and recommend a default. The user can override any decision.

**TDR output format (example):**

```markdown
## Technology Decision Record: Database

### Evaluated Options

| Option | AI Reliability | Context7 | Token Eff. | Solo Dev | Production | Ecosystem | Cost | Migration | **Score** |
|--------|---------------|----------|-----------|----------|-----------|-----------|------|-----------|-----------|
| Supabase + Drizzle | 8 | 8 | 8 | 9 | 9 | 8 | 9 | 7 | **8.25** |
| Neon + Drizzle | 7 | 7 | 8 | 7 | 8 | 7 | 8 | 8 | **7.40** |
| Turso + Drizzle | 6 | 6 | 9 | 7 | 7 | 6 | 9 | 7 | **6.95** |
| Supabase + Prisma | 8 | 9 | 7 | 8 | 8 | 9 | 9 | 7 | **8.10** |

### Recommendation
**Supabase + Drizzle ORM** (score: 8.25)

### Reasoning
- Supabase provides auth + storage + realtime in addition to Postgres, reducing operational complexity
- Drizzle's TypeScript-native schema and edge-compatible runtime align with the project's serverless deployment
- Row Level Security provides database-level authorization beyond application-level checks

### Trade-offs
- Supabase creates moderate vendor lock-in (mitigated: standard Postgres underneath)
- Drizzle has less documentation than Prisma (mitigated: growing rapidly, SQL-like syntax is intuitive)
```

---

## 14. Sources

The following sources informed this research. Web search and web fetch tools were unavailable during this session; content is based on established documentation and best practices through early 2025, with known trends projected to 2026. Verify version-specific claims against current release notes.

### Framework Documentation
- Next.js 15 documentation: https://nextjs.org/docs
- Next.js App Router: https://nextjs.org/docs/app
- React Server Components: https://react.dev/reference/rsc/server-components
- Remix / React Router v7: https://reactrouter.com/
- SvelteKit 2: https://svelte.dev/docs/kit
- Svelte 5 (runes): https://svelte.dev/docs/svelte
- Nuxt 4: https://nuxt.com/docs
- Astro: https://docs.astro.build

### Styling and Components
- Tailwind CSS v4: https://tailwindcss.com/docs
- shadcn/ui: https://ui.shadcn.com
- Radix UI: https://www.radix-ui.com/primitives
- Vanilla Extract: https://vanilla-extract.style
- React Aria (Adobe): https://react-spectrum.adobe.com/react-aria/

### Backend and API
- tRPC: https://trpc.io/docs
- Hono: https://hono.dev/docs
- Vercel Functions: https://vercel.com/docs/functions
- Cloudflare Workers: https://developers.cloudflare.com/workers/

### Database and ORM
- Supabase documentation: https://supabase.com/docs
- Neon documentation: https://neon.tech/docs
- Turso documentation: https://docs.turso.tech
- PlanetScale: https://planetscale.com/docs
- Drizzle ORM: https://orm.drizzle.team/docs/overview
- Prisma: https://www.prisma.io/docs
- Dexie.js: https://dexie.org/docs

### Authentication
- Auth.js (NextAuth v5): https://authjs.dev
- Clerk: https://clerk.com/docs
- Supabase Auth: https://supabase.com/docs/guides/auth
- Better Auth: https://www.better-auth.com/docs
- Lucia Auth (archived): https://lucia-auth.com

### Payments
- Stripe Billing: https://stripe.com/docs/billing
- Stripe Checkout: https://stripe.com/docs/payments/checkout
- Stripe Webhooks: https://stripe.com/docs/webhooks
- Lemon Squeezy: https://docs.lemonsqueezy.com
- Paddle: https://developer.paddle.com/docs

### Accessibility
- WCAG 2.2: https://www.w3.org/TR/WCAG22/
- WCAG 2.2 Quick Reference: https://www.w3.org/WAI/WCAG22/quickref/
- axe-core: https://github.com/dequelabs/axe-core
- @axe-core/playwright: https://github.com/dequelabs/axe-core-npm/tree/develop/packages/playwright
- pa11y: https://pa11y.org
- eslint-plugin-jsx-a11y: https://github.com/jsx-eslint/eslint-plugin-jsx-a11y
- Radix UI accessibility: https://www.radix-ui.com/primitives/docs/overview/accessibility

### Performance
- Web Vitals: https://web.dev/vitals/
- Interaction to Next Paint (INP): https://web.dev/articles/inp
- Largest Contentful Paint (LCP): https://web.dev/articles/lcp
- Cumulative Layout Shift (CLS): https://web.dev/articles/cls
- Next.js Image Optimization: https://nextjs.org/docs/app/building-your-application/optimizing/images
- next/font: https://nextjs.org/docs/app/building-your-application/optimizing/fonts
- Serwist (PWA): https://serwist.pages.dev
- @next/bundle-analyzer: https://www.npmjs.com/package/@next/bundle-analyzer

### Security
- OWASP Top 10 (2021): https://owasp.org/www-project-top-ten/
- Content Security Policy (MDN): https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
- Upstash Rate Limiting: https://upstash.com/docs/redis/sdks/ratelimit-ts/overview
- Zod: https://zod.dev
- Socket.dev: https://socket.dev
- DOMPurify: https://github.com/cure53/DOMPurify

### Deployment
- Vercel documentation: https://vercel.com/docs
- Cloudflare Pages: https://developers.cloudflare.com/pages/
- OpenNext (Cloudflare adapter): https://opennext.js.org
- Railway: https://docs.railway.app
- Fly.io: https://fly.io/docs

### Industry Surveys and Data
- State of JS 2024 Survey: https://2024.stateofjs.com
- Stack Overflow Developer Survey 2024: https://survey.stackoverflow.co/2024/
- npm download statistics: https://www.npmjs.com
- HTTP Archive Web Almanac: https://almanac.httparchive.org
