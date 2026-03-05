# Responsive Design Pattern Reference

Agent-facing reference for responsive design decisions, breakpoint strategy, and mobile-first implementation.
The Builder reads this during the Design Phase; the Code Reviewer checks compliance during review.
**Principle:** Design for mobile first, enhance progressively, use content-driven breakpoints.

## 1. Mobile-First Strategy

- **Rule:** Write base CSS for the smallest screen, then add `@media (min-width)` queries to enhance.
- **Why:** Mobile-first forces content prioritization. Desktop-first leads to hiding content on mobile.
- **Implementation:**
  ```css
  /* Base: mobile */
  .grid { display: flex; flex-direction: column; gap: var(--spacing-4); }
  /* Tablet: 768px+ */
  @media (min-width: 768px) { .grid { flex-direction: row; } }
  /* Desktop: 1024px+ */
  @media (min-width: 1024px) { .grid { gap: var(--spacing-8); } }
  ```
- **Anti-pattern:** Never use `max-width` media queries as the primary breakpoint strategy.
- **Content-driven breakpoints:** If the design breaks at 620px, add a breakpoint at 620px. Don't force content into arbitrary breakpoints.

## 2. Breakpoints & Container Queries

### Standard Breakpoints
- `360px` — Small mobile (minimum viable)
- `768px` — Tablet / large phone landscape
- `1024px` — Desktop
- `1440px` — Large desktop / content max-width

### Container Queries
- **When:** Component behavior should depend on its container, not the viewport. Cards in a sidebar vs main content. Widgets in a dashboard grid.
- **What:** `@container (min-width: 400px) { ... }` on the parent, `container-type: inline-size` on the wrapper.
- **Why:** Viewport queries break when a component is reused in different layout contexts.
- **Fallback:** Container queries have 95%+ browser support (2024+). For older browsers, use viewport queries as fallback.

## 3. Fluid Typography

- **Rule:** Use `clamp()` for font sizes that scale smoothly between breakpoints.
- **Formula:** `clamp(min, preferred, max)` where preferred uses `rem + vw`.
- **Examples:**
  ```css
  h1 { font-size: clamp(1.75rem, 1.2rem + 2vw, 3rem); }
  body { font-size: clamp(0.9rem, 0.85rem + 0.25vw, 1.1rem); }
  ```
- **Anti-pattern:** Never use `vw` alone for font-size — becomes unreadable at extremes. Always clamp.
- **A11y:** Text must remain legible when zoomed to 200%. `clamp()` respects zoom if the min uses `rem`.

## 4. Touch Targets

- **Minimum size:** 44x44px (WCAG 2.5.8 Level AAA, 24x24px Level AA minimum).
- **Minimum gap:** 8px between adjacent touch targets.
- **Implementation:**
  ```css
  .touch-target {
    min-width: 44px;
    min-height: 44px;
    padding: var(--spacing-2);
  }
  ```
- **Common violations:** Icon buttons without padding, inline links in dense text, close buttons in corners.
- **Desktop exception:** On pointer devices, targets can be smaller (24px+). Use `@media (pointer: fine)` to detect.

## 5. Responsive Images

### srcset and sizes
- **When:** Any content image that appears at different sizes across breakpoints.
- **What:**
  ```html
  <img
    src="photo-800.jpg"
    srcset="photo-400.jpg 400w, photo-800.jpg 800w, photo-1200.jpg 1200w"
    sizes="(max-width: 768px) 100vw, (max-width: 1024px) 50vw, 33vw"
    loading="lazy"
    alt="Description"
  />
  ```

### Picture element
- **When:** Different image crops or formats per breakpoint (art direction).
- **What:**
  ```html
  <picture>
    <source media="(min-width: 1024px)" srcset="hero-wide.webp" type="image/webp" />
    <source media="(min-width: 768px)" srcset="hero-medium.webp" type="image/webp" />
    <img src="hero-mobile.jpg" alt="Hero" loading="lazy" />
  </picture>
  ```

### Lazy loading
- **Rule:** All below-fold images get `loading="lazy"`. Hero/LCP images get `loading="eager"` + `fetchpriority="high"`.

### Aspect ratio
- **Rule:** Always set `aspect-ratio` or explicit `width`/`height` on images to prevent layout shift (CLS).
  ```css
  img { aspect-ratio: 16/9; object-fit: cover; width: 100%; height: auto; }
  ```

## 6. Responsive Layout Patterns

### Grid + Flex
- **Grid:** Use for 2D layouts (card grids, page templates, dashboard panels).
  ```css
  .card-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: var(--spacing-4);
  }
  ```
- **Flex:** Use for 1D layouts (nav bars, button groups, inline elements).
- **Anti-pattern:** Don't use `float` for layout. Don't use `position: absolute` for responsive layout.

### Logical Properties
- **Rule:** Use `margin-inline`, `padding-block`, `border-inline-start` instead of `margin-left`, `padding-top`, `border-left`.
- **Why:** Logical properties automatically adapt to RTL (`dir="rtl"`) and vertical writing modes.
- **Key mappings:**
  - `left` → `inline-start`
  - `right` → `inline-end`
  - `top` → `block-start`
  - `bottom` → `block-end`
  - `width` → `inline-size`
  - `height` → `block-size`

### Responsive Navigation
- **Desktop (1024px+):** Horizontal top bar or persistent sidebar. All items visible.
- **Tablet (768px-1023px):** Collapsible sidebar or condensed top bar.
- **Mobile (<768px):** Bottom tab bar (3-5 items) or hamburger menu. Bottom tab bar is preferred for primary actions — thumb-reachable.
- **Rule:** Never hide-only with hamburger on desktop. Never show full sidebar on mobile.

## Builder Agent Key Principle

1. **Mobile-first CSS** — base styles target mobile, `min-width` queries enhance for larger screens.
2. **Touch targets 44x44px minimum** — verify every interactive element, especially icon buttons.
3. **Fluid typography with `clamp()`** — never raw `vw` units for text.
4. **Logical properties over physical** — `inline-start` not `left`, enables RTL for free.
5. **`aspect-ratio` on all images** — prevents layout shift.
6. **Container queries for reusable components** — viewport queries for page-level layout.
