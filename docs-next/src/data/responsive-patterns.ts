export interface ResponsivePattern {
  name: string;
  category: 'strategy' | 'breakpoints' | 'typography' | 'images' | 'layout' | 'navigation';
  description: string;
  implementation: string;
  a11y: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<ResponsivePattern['category'], string> = {
  strategy: 'Mobile-First Strategy',
  breakpoints: 'Breakpoints & Container Queries',
  typography: 'Fluid Typography',
  images: 'Responsive Images',
  layout: 'Responsive Layout Patterns',
  navigation: 'Responsive Navigation',
};

export const categoryOrder: ResponsivePattern['category'][] = [
  'strategy', 'breakpoints', 'typography', 'images', 'layout', 'navigation',
];

export const responsivePatterns: ResponsivePattern[] = [
  // --- Mobile-First Strategy ---
  {
    name: 'Mobile-First CSS',
    category: 'strategy',
    description: 'Write base CSS for the smallest screen, then add @media (min-width) queries to enhance for larger viewports. Mobile-first forces content prioritization — you start with what matters most and add enhancements, rather than hiding content on mobile.',
    implementation: 'Base styles target mobile (no media query). Add `@media (min-width: 768px)` for tablet, `@media (min-width: 1024px)` for desktop. Each query adds complexity, never removes it. Use the design system breakpoint tokens.',
    a11y: 'Mobile-first ensures core content is accessible on all devices. Content hidden via `display: none` at certain breakpoints must not contain focusable elements — use `visibility: hidden` or remove from DOM instead.',
    docsUrl: null,
  },
  {
    name: 'Content-Driven Breakpoints',
    category: 'strategy',
    description: 'Add breakpoints where the design breaks, not at arbitrary device widths. If a layout looks wrong at 620px, add a breakpoint at 620px. Device-based breakpoints (iPhone, iPad) become outdated as new devices launch.',
    implementation: 'Test layouts by slowly resizing the browser. Where content overflows, line lengths become unreadable, or layouts collapse — add a breakpoint there. Standard breakpoints (768px, 1024px) are starting points, not rules.',
    a11y: 'Content-driven breakpoints ensure readability at every viewport width. Target 45-75 characters per line for body text — add breakpoints or adjust font size when lines get too long or too short.',
    docsUrl: null,
  },
  {
    name: 'Progressive Enhancement',
    category: 'strategy',
    description: 'Start with a functional baseline that works everywhere (semantic HTML + core CSS), then layer on enhancements (Grid, animations, WebGL) for capable browsers. Every user gets a working experience; modern browsers get a richer one.',
    implementation: 'Use `@supports` to test for CSS feature support before applying advanced layouts. Use `@media (hover: hover)` to add hover effects only on devices with pointer input. Use `@media (prefers-reduced-motion: no-preference)` to gate animations.',
    a11y: 'Progressive enhancement is inherently accessible — the baseline works with assistive technology. Enhanced features should never break the accessible baseline.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Glossary/Progressive_Enhancement',
  },

  // --- Breakpoints & Container Queries ---
  {
    name: 'Standard Breakpoints',
    category: 'breakpoints',
    description: 'Four standard viewport breakpoints cover the vast majority of devices: 360px (small mobile minimum), 768px (tablet/large phone landscape), 1024px (desktop), and 1440px (large desktop/content max-width). Use these as starting points, then adjust based on content needs.',
    implementation: 'Define as CSS custom properties (for documentation) and `@media` queries. `--breakpoint-sm: 640px`, `--breakpoint-md: 768px`, `--breakpoint-lg: 1024px`, `--breakpoint-xl: 1280px`. Note: CSS custom properties cannot be used directly in media queries.',
    a11y: 'Breakpoints should never hide essential content. If content is visible at one breakpoint, its functionality should be reachable at all breakpoints — even if the presentation changes.',
    docsUrl: null,
  },
  {
    name: 'Container Queries',
    category: 'breakpoints',
    description: 'Component behavior depends on its container width, not the viewport. A card component adapts differently in a sidebar (300px) vs main content (800px) using the same code. Container queries make components truly reusable across layout contexts.',
    implementation: 'Set `container-type: inline-size` on the parent wrapper. Use `@container (min-width: 400px) { ... }` to style children based on container width. Name containers with `container-name` for specificity. 95%+ browser support (2024+).',
    a11y: 'No specific accessibility impact beyond standard responsive concerns. Container queries improve component reusability which indirectly improves consistency for assistive technology users.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_containment/Container_queries',
  },
  {
    name: 'Pointer & Hover Detection',
    category: 'breakpoints',
    description: 'Use `@media (pointer: fine)` to detect mouse/stylus input and `@media (hover: hover)` to detect hover capability. This lets you add hover effects only on devices that support them, and adjust target sizes based on input precision.',
    implementation: '`@media (pointer: coarse)` for touch devices — increase touch targets to 48px+. `@media (hover: hover)` — add hover states only here. `@media (pointer: fine)` — allow smaller interactive elements (24px minimum).',
    a11y: 'Never rely on hover as the only way to access information — `@media (hover: hover)` adds hover effects, but the content must be accessible via click/tap/keyboard too. Hover-only interactions fail for keyboard and touch users.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/CSS/@media/pointer',
  },

  // --- Fluid Typography ---
  {
    name: 'Clamp-Based Font Sizing',
    category: 'typography',
    description: 'Use `clamp(min, preferred, max)` for font sizes that scale smoothly between breakpoints without media queries. The preferred value uses a `rem + vw` formula to create fluid scaling. Eliminates jarring font-size jumps at breakpoints.',
    implementation: '`h1 { font-size: clamp(1.75rem, 1.2rem + 2vw, 3rem); }`. Body: `clamp(0.9rem, 0.85rem + 0.25vw, 1.1rem)`. Use a fluid type scale generator to calculate values. Always use `rem` for the min to ensure zoom works.',
    a11y: 'WCAG 1.4.4 (Resize Text) requires text to be zoomable to 200%. `clamp()` respects browser zoom when the min value uses `rem`. Never use `vw` alone — it ignores zoom and becomes unreadable at extremes.',
    docsUrl: 'https://utopia.fyi/type/calculator/',
  },
  {
    name: 'Fluid Spacing',
    category: 'typography',
    description: 'Apply the same `clamp()` approach to spacing (margins, padding, gaps) so layouts breathe proportionally to viewport width. Tight spacing on mobile, generous spacing on desktop — without media query jumps.',
    implementation: '`gap: clamp(0.75rem, 0.5rem + 1vw, 2rem)`. Apply to grid gaps, section padding, and content margins. Match fluid spacing scale to fluid type scale for visual consistency.',
    a11y: 'Fluid spacing benefits users who zoom — spacing scales proportionally rather than staying fixed. Ensure minimum spacing never goes below 4px to maintain visual separation.',
    docsUrl: 'https://utopia.fyi/space/calculator/',
  },
  {
    name: 'Line Length Control',
    category: 'typography',
    description: 'Optimal line length is 45-75 characters for body text (66ch ideal per typographic research). Lines too long reduce reading comprehension; lines too short cause excessive eye movement. Use `max-width` in `ch` units to constrain.',
    implementation: '`max-width: 65ch` on text containers. For wider layouts, use multi-column with `column-width: 25ch; column-count: auto`. `ch` unit is based on the width of the "0" character in the current font.',
    a11y: 'WCAG 1.4.8 (Visual Presentation, AAA) recommends max 80 characters per line. Using `ch` units naturally adapts when users change font size or zoom.',
    docsUrl: null,
  },

  // --- Responsive Images ---
  {
    name: 'srcset and sizes',
    category: 'images',
    description: 'Provide multiple image resolutions and let the browser choose the best one based on viewport width and device pixel ratio. The `srcset` attribute lists available widths; `sizes` tells the browser how wide the image renders at each breakpoint.',
    implementation: '`<img srcset="photo-400.jpg 400w, photo-800.jpg 800w, photo-1200.jpg 1200w" sizes="(max-width: 768px) 100vw, (max-width: 1024px) 50vw, 33vw" src="photo-800.jpg" alt="Description" loading="lazy">`. Cap at 2x — human eyes can\'t distinguish 2x from 3x.',
    a11y: 'Always include `alt` attribute. The responsive image mechanism is transparent to assistive technology — `alt` text applies regardless of which source is loaded.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/HTML/Responsive_images',
  },
  {
    name: 'Art Direction with Picture',
    category: 'images',
    description: 'The `<picture>` element lets you serve different image crops or formats per breakpoint (art direction). A wide panoramic hero on desktop can become a square crop on mobile — different compositions optimized for each viewport.',
    implementation: '`<picture><source media="(min-width: 1024px)" srcset="hero-wide.webp" type="image/webp" /><source media="(min-width: 768px)" srcset="hero-medium.webp" /><img src="hero-mobile.jpg" alt="Hero" /></picture>`. List sources from largest to smallest.',
    a11y: 'The `alt` attribute goes on the `<img>` fallback element, not on `<source>`. All art-directed crops should convey the same essential content — don\'t change the semantic meaning between breakpoints.',
    docsUrl: null,
  },
  {
    name: 'Aspect Ratio Preservation',
    category: 'images',
    description: 'Always set `aspect-ratio` or explicit `width`/`height` on images and videos to prevent Cumulative Layout Shift (CLS). Without dimensions, the browser can\'t reserve space before the image loads, causing content to jump.',
    implementation: '`img { aspect-ratio: 16/9; object-fit: cover; width: 100%; height: auto; }`. Or use explicit HTML attributes: `<img width="800" height="450">`. Framework image components (Next.js Image, Astro Image) handle this automatically.',
    a11y: 'Layout shift is disorienting for all users, especially those using screen magnification or with cognitive disabilities. Stable layouts reduce cognitive load.',
    docsUrl: null,
  },
  {
    name: 'Lazy Loading Strategy',
    category: 'images',
    description: 'Below-fold images use `loading="lazy"` to defer loading until they\'re near the viewport. Above-fold and LCP (Largest Contentful Paint) images must NEVER be lazy-loaded — this delays the critical rendering path and causes visible pop-in.',
    implementation: 'Hero/LCP image: `loading="eager" fetchpriority="high"` (exactly one per page). All other images: `loading="lazy"`. If the LCP image is CSS-rendered, add `<link rel="preload" as="image" fetchpriority="high">`.',
    a11y: 'Lazy loading has no direct accessibility impact, but faster page loads benefit users on assistive technology who may experience compounded delays.',
    docsUrl: null,
  },

  // --- Responsive Layout Patterns ---
  {
    name: 'Auto-Fill Grid',
    category: 'layout',
    description: 'A CSS Grid that automatically adjusts column count based on available space — no media queries needed. Cards flow into as many columns as fit, with a minimum card width. The simplest responsive card layout.',
    implementation: '`display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: var(--spacing-4)`. Use `auto-fill` (empty tracks) vs `auto-fit` (collapsed tracks) based on whether you want items to stretch to fill.',
    a11y: 'Grid items maintain DOM order which matches visual order. Never use CSS Grid to reorder items in a way that contradicts the logical reading order.',
    docsUrl: null,
  },
  {
    name: 'Flex Wrap Layout',
    category: 'layout',
    description: 'A flexbox layout where items wrap to the next line when they don\'t fit. Best for 1D collections of varying-width items like tags, buttons, or navigation items. Items maintain their natural width.',
    implementation: '`display: flex; flex-wrap: wrap; gap: var(--spacing-2)`. Use `flex: 1 1 200px` on children for equal-width wrapping. Use `flex: 0 0 auto` for natural-width items.',
    a11y: 'Wrapped flex items maintain DOM order. Use `gap` instead of margins for consistent spacing. Avoid `order` property which creates a mismatch between visual and DOM order.',
    docsUrl: null,
  },
  {
    name: 'Logical Properties',
    category: 'layout',
    description: 'Use `margin-inline`, `padding-block`, `border-inline-start` instead of physical properties like `margin-left`, `padding-top`. Logical properties automatically adapt to RTL (`dir="rtl"`) and vertical writing modes without additional CSS.',
    implementation: '`margin-left` → `margin-inline-start`. `padding-top` → `padding-block-start`. `width` → `inline-size`. `text-align: left` → `text-align: start`. Apply to all new CSS — no performance or size cost.',
    a11y: 'Logical properties make RTL support automatic, benefiting Arabic, Hebrew, Farsi, and other RTL language users. Combined with `lang` and `dir` attributes, layouts adapt without any extra CSS.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_logical_properties_and_values',
  },
  {
    name: 'Sidebar Layout',
    category: 'layout',
    description: 'A main content area with a sidebar that collapses below the content on mobile. Uses CSS Grid or Flexbox with a breakpoint to switch from side-by-side to stacked layout.',
    implementation: 'CSS Grid: `grid-template-columns: 1fr` (mobile), then `@media (min-width: 1024px) { grid-template-columns: 260px 1fr }`. Or use "Every Layout" sidebar pattern: `flex-wrap: wrap` with `flex-basis` on sidebar and `flex-grow: 999` on main.',
    a11y: 'Sidebar should be `<aside aria-label="Sidebar">`. On mobile, sidebar content appears after main content in DOM order. Use skip links to navigate between sections.',
    docsUrl: null,
  },
  {
    name: 'Stack-to-Row Pattern',
    category: 'layout',
    description: 'Elements stack vertically on mobile and arrange horizontally on wider viewports. The most common responsive layout shift — used for header layouts, form fields, card content, and action button groups.',
    implementation: '`display: flex; flex-direction: column; gap: var(--spacing-2)` then `@media (min-width: 768px) { flex-direction: row; align-items: center }`. Use `flex-wrap: wrap` as a safety net on intermediate widths.',
    a11y: 'Maintain logical reading order regardless of layout direction. Stacked (mobile) and inline (desktop) should read in the same sequence. Focus order must match visual order.',
    docsUrl: null,
  },

  // --- Responsive Navigation ---
  {
    name: 'Responsive Nav Pattern',
    category: 'navigation',
    description: 'Navigation adapts across three breakpoints: horizontal top bar on desktop (1024px+), condensed top bar or collapsible sidebar on tablet (768px-1023px), and bottom tab bar or hamburger drawer on mobile (<768px). Bottom tab bar is preferred for primary actions — it\'s in the thumb zone.',
    implementation: 'Desktop: `<nav>` with horizontal `<ul>`. Tablet: priority+ pattern (show top items, overflow into "More" menu). Mobile: bottom tab bar for 3-5 items, hamburger drawer for 5+ items. Use `@media` to switch.',
    a11y: '`<nav aria-label="Main navigation">` at all breakpoints. Hamburger button: `aria-expanded`, `aria-controls`. Tab bar: `role="tablist"` with `aria-selected`. All items keyboard-navigable.',
    docsUrl: null,
  },
  {
    name: 'Priority+ Navigation',
    category: 'navigation',
    description: 'Show as many nav items as fit in the available space; overflow the rest into a "More" dropdown. The nav adapts dynamically to any width without needing specific breakpoints. Used by Google and many responsive web apps.',
    implementation: 'Use `ResizeObserver` on the nav container. Calculate which items fit based on their widths. Move overflow items to a "More" dropdown. Recalculate on resize. Libraries: `react-priority-navigation`.',
    a11y: '"More" button: `aria-expanded`, `aria-haspopup="true"`. Overflow menu: `role="menu"`. Items in "More" must be keyboard-navigable with arrow keys. Focus returns to "More" button on close.',
    docsUrl: null,
  },
  {
    name: 'Off-Canvas Navigation',
    category: 'navigation',
    description: 'A navigation panel that slides in from the side of the viewport, overlaying or pushing the main content. The standard mobile navigation pattern for apps with many sections. Triggered by a hamburger icon.',
    implementation: 'Width: `min(80vw, 360px)`. Transform: `translateX(-100%)` → `translateX(0)` over 250ms ease-out. Close: X button + backdrop click + swipe + Escape. `overscroll-behavior: contain` to prevent body scroll bleed.',
    a11y: 'Focus trap when open. `role="dialog"`, `aria-modal="true"`, `aria-label="Site navigation"`. Close on Escape. Return focus to hamburger trigger on close. Hamburger: `aria-expanded` + `aria-controls`.',
    docsUrl: null,
  },
  {
    name: 'Responsive Table',
    category: 'navigation',
    description: 'Tables are inherently wide and overflow on mobile. Three adaptation strategies: horizontal scroll (simplest), card transformation (each row becomes a card), or column prioritization (hide low-priority columns). Choose based on data density.',
    implementation: 'Scroll: wrap in `<div style="overflow-x: auto">` with `-webkit-overflow-scrolling: touch`. Cards: `@media (max-width: 768px)` — set `display: block` on rows, use `data-label` attributes for headers. Column priority: `display: none` on low-priority columns.',
    a11y: 'Scrollable tables: add `tabindex="0"` and `role="region"` with `aria-label` on the scroll container. Card view: use `aria-label` on each card. Never remove columns that contain essential data without providing an alternative view.',
    docsUrl: null,
  },
];
