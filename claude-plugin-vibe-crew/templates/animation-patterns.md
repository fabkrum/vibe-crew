# Animation & Motion Pattern Reference

Agent-facing reference for animation decisions, motion tokens, and reduced-motion compliance.
The Builder reads this during the Design Phase; the Code Reviewer checks compliance during review.
**Principle:** Every animation must have a purpose, use design-system tokens, and respect `prefers-reduced-motion`.

## 1. Motion Foundations

### Reduced Motion
- **When:** Always — every animation must be wrapped or gated.
- **What:** Use `@media (prefers-reduced-motion: reduce)` to disable or replace motion. Crossfade or instant-swap for essential transitions.
- **Token:** `--duration-*` tokens zero out automatically via the design system's `prefers-reduced-motion` block.
- **Test:** Toggle "Reduce motion" in OS accessibility settings; verify no animation plays.

### GPU-Safe Animation
- **When:** Always — only animate `transform` and `opacity`.
- **What:** Never animate `width`, `height`, `top`, `left`, `margin`, or `padding` — these trigger layout recalculation. Use `transform: translate/scale/rotate` and `opacity` exclusively.
- **Why:** Layout-triggering properties cause jank on 60fps displays. Composited properties (`transform`, `opacity`) are GPU-accelerated.

### Duration Scale
- **When:** Selecting animation timing.
- **Tokens:** `--duration-instant` (100ms) for micro-feedback, `--duration-fast` (150ms) for hover/press, `--duration-normal` (250ms) for enter/exit, `--duration-slow` (400ms) for complex transitions, `--duration-slower` (600ms) for page-level.
- **Rule:** Never exceed 600ms for UI animation. Content animations (scroll-driven) may be longer.

### Easing Selection
- **Enter animations:** `--ease-out` (fast start, gentle stop — feels responsive).
- **Exit animations:** `--ease-in` (gentle start, fast end — gets out of the way).
- **Symmetric transitions:** `--ease-in-out` (toggles, state changes).
- **Micro-interactions:** `--ease-spring` (playful bounce for hover, press, toggle).
- **Default fallback:** `--ease-default` when uncertain.

## 2. Entrance & Exit Patterns

### Fade
- **When:** Showing/hiding content, page transitions, image reveals.
- **What:** `opacity: 0 → 1` (enter), `opacity: 1 → 0` (exit).
- **Token:** `--duration-normal` + `--ease-out` (enter), `--ease-in` (exit).
- **Reduced motion:** Instant show/hide (no fade).

### Slide
- **When:** Panels, drawers, sheets, mobile navigation, content entering from edge.
- **What:** `transform: translateX(100%) → translateX(0)` (slide from right). Vary axis and direction for context.
- **Token:** `--duration-normal` + `--ease-out`.
- **Reduced motion:** Instant position change or crossfade.

### Scale
- **When:** Modals, dialogs, popovers, tooltips appearing.
- **What:** `transform: scale(0.95) → scale(1)` + `opacity: 0 → 1`. Subtle — never scale from 0.
- **Token:** `--duration-fast` + `--ease-out`.
- **Reduced motion:** Instant appear (opacity only, no scale).

### Collapse / Expand
- **When:** Accordion sections, collapsible panels, expandable rows.
- **What:** `grid-template-rows: 0fr → 1fr` with `overflow: hidden` on the child. Avoids animating `height` (layout-safe).
- **Token:** `--duration-normal` + `--ease-in-out`.
- **Reduced motion:** Instant expand/collapse.

## 3. Micro-Interaction Patterns

### Hover Feedback
- **When:** Buttons, cards, interactive list items, links with visual weight.
- **What:** `transform: scale(1.02)` or subtle `translateY(-1px)` + shadow increase.
- **Token:** `--duration-fast` + `--ease-spring`.
- **Reduced motion:** No transform; allow color/shadow change only.

### Press Feedback
- **When:** Buttons on `:active` state.
- **What:** `transform: scale(0.97)`.
- **Token:** `--duration-instant` + `--ease-default`.
- **Reduced motion:** No transform; allow opacity change.

### Toggle State
- **When:** Switch, checkbox, toggle button state change.
- **What:** Translate the toggle handle, transition background color.
- **Token:** `--duration-fast` + `--ease-spring`.
- **Reduced motion:** Instant state change.

### Validation Shake
- **When:** Form field with invalid input on submit attempt.
- **What:** `@keyframes shake { 0%, 100% { transform: translateX(0) } 25% { transform: translateX(-4px) } 75% { transform: translateX(4px) } }` — 2-3 cycles over `--duration-normal`.
- **Token:** `--duration-normal`.
- **Reduced motion:** No shake; rely on red border + error message only.
- **A11y:** Never shake as the only error indicator — always pair with `aria-invalid` + visible text.

## 4. Loading State Patterns

### Shimmer / Skeleton
- **When:** Data fetching, page load, lazy-loaded sections.
- **What:** Gradient sweep animation over skeleton placeholders. `background: linear-gradient(90deg, var(--color-muted) 25%, var(--color-muted-foreground, 0.05) 50%, var(--color-muted) 75%)`. Animate `background-position`.
- **Token:** Continuous animation — exempt from duration scale.
- **A11y:** `aria-busy="true"` on container, `aria-hidden="true"` on skeleton elements.
- **Reduced motion:** Static skeleton (no sweep animation). Gray placeholder only.

### Spinner
- **When:** Button loading, inline loading where skeleton doesn't fit.
- **What:** Rotating circle or arc. `animation: spin 1s linear infinite`.
- **A11y:** `role="status"`, `aria-label="Loading"`.
- **Reduced motion:** Replace with static "Loading..." text or pulsing dot.

### Progress Bar
- **When:** File uploads, multi-step processes, determinate loading.
- **What:** Width transition from 0% to N%. Use `transform: scaleX()` for GPU compositing.
- **Token:** `--duration-slow` + `--ease-out` for smooth updates.
- **A11y:** `role="progressbar"`, `aria-valuenow`, `aria-valuemin`, `aria-valuemax`.

### Skeleton-to-Content Fade
- **When:** Data arrives for a skeleton-loaded section.
- **What:** Crossfade from skeleton to real content. `opacity` transition.
- **Token:** `--duration-fast` + `--ease-out`.
- **Reduced motion:** Instant swap (no fade).

## 5. Scroll-Driven Patterns

### Scroll Reveal
- **When:** Content entering viewport on scroll — sections, cards, images.
- **What:** IntersectionObserver triggers `opacity: 0 → 1` + `translateY(20px) → 0`. Use `threshold: 0.1`.
- **Token:** `--duration-normal` + `--ease-out`.
- **Reduced motion:** Content visible immediately (no animation on scroll).

### Parallax
- **When:** Hero sections, background images, decorative elements.
- **What:** `transform: translateY(calc(var(--scroll-offset) * 0.3))`. Use CSS `scroll-timeline` or IntersectionObserver.
- **Reduced motion:** Disable entirely — static positioning.

### Scroll Progress Indicator
- **When:** Long-form content pages (articles, documentation).
- **What:** Fixed bar at top showing read progress. `transform: scaleX()` driven by scroll position.
- **Reduced motion:** Still allowed — not disorienting. But remove animation, use instant updates.

### Staggered List
- **When:** List items entering viewport — card grids, search results, feeds.
- **What:** Each item gets `transition-delay: calc(var(--index) * 50ms)`. Cap total delay at 500ms (10 items max stagger).
- **Token:** `--duration-normal` + `--ease-out` per item.
- **Reduced motion:** All items appear simultaneously (no stagger).

## 6. Notification & Overlay Patterns

### Toast Slide-In
- **When:** Toast notifications appearing.
- **What:** `translateY(100%) → translateY(0)` (bottom) or `translateX(100%) → translateX(0)` (right). Auto-dismiss with progress indicator.
- **Token:** `--duration-normal` + `--ease-out` (enter), `--ease-in` (exit).
- **Reduced motion:** Instant appear/disappear.

### Modal Animation
- **When:** Dialog, alert dialog opening.
- **What:** Backdrop: `opacity: 0 → 1` (var(--duration-normal)). Content: `scale(0.95) → scale(1)` + `opacity` (var(--duration-fast)).
- **Token:** Backdrop `--duration-normal` + `--ease-out`. Content `--duration-fast` + `--ease-out`.
- **Reduced motion:** Instant appear (no scale or fade).

### Tooltip Animation
- **When:** Tooltip appearing on hover/focus.
- **What:** `opacity: 0 → 1` + slight `translateY(-4px) → 0`. Include 200ms delay before show (avoid flicker on mouse pass-through).
- **Token:** `--duration-fast` + `--ease-out`.
- **Reduced motion:** Instant appear (no animation, keep delay for flicker prevention).

### Drawer / Sheet
- **When:** Side panel or bottom sheet opening.
- **What:** `translateX(100%) → 0` (side) or `translateY(100%) → 0` (bottom). Backdrop fade simultaneously.
- **Token:** `--duration-normal` + `--ease-out` (open), `--ease-in` (close).
- **Reduced motion:** Instant appear/disappear.

## Builder Agent Key Principle

1. **Every animation uses a design-system token** — never hardcode `300ms` or `ease-in-out`.
2. **Every animation respects `prefers-reduced-motion`** — the design system zeros durations automatically, but complex animations (parallax, stagger) need explicit `@media` overrides.
3. **Only animate `transform` and `opacity`** — everything else triggers layout.
4. **Easing direction matters** — `ease-out` for enter, `ease-in` for exit, `spring` for micro-interactions.
5. **Cap animation duration at 600ms** — longer animations feel sluggish in UI contexts.
