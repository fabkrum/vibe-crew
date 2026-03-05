export interface AnimationPattern {
  name: string;
  category: 'foundations' | 'entrance-exit' | 'micro' | 'loading' | 'scroll' | 'overlay';
  description: string;
  implementation: string;
  reducedMotion: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<AnimationPattern['category'], string> = {
  foundations: 'Motion Foundations',
  'entrance-exit': 'Entrance & Exit',
  micro: 'Micro-Interactions',
  loading: 'Loading States',
  scroll: 'Scroll-Driven',
  overlay: 'Notification & Overlay',
};

export const categoryOrder: AnimationPattern['category'][] = [
  'foundations', 'entrance-exit', 'micro', 'loading', 'scroll', 'overlay',
];

export const animationPatterns: AnimationPattern[] = [
  // --- Motion Foundations ---
  {
    name: 'Reduced Motion',
    category: 'foundations',
    description: 'Gate every animation behind prefers-reduced-motion. The design system zeros all duration tokens automatically; complex animations (parallax, stagger) need explicit @media overrides.',
    implementation: 'Design system tokens (--duration-*) zero out via the prefers-reduced-motion block. For custom animations, wrap in @media (prefers-reduced-motion: no-preference) { }.',
    reducedMotion: 'All motion disabled. Essential state transitions use instant crossfade.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion',
  },
  {
    name: 'GPU-Safe Animation',
    category: 'foundations',
    description: 'Only animate transform and opacity — the two GPU-composited properties. Animating width, height, top, left, margin, or padding triggers layout recalculation and causes jank.',
    implementation: 'Use transform: translate(), scale(), rotate() for position/size changes. Use opacity for visibility. Use will-change: transform sparingly on known animated elements.',
    reducedMotion: 'N/A — this is a performance rule, not a motion preference.',
    docsUrl: 'https://web.dev/articles/animations-guide',
  },

  // --- Entrance & Exit ---
  {
    name: 'Fade',
    category: 'entrance-exit',
    description: 'The simplest entrance/exit — opacity transition from 0 to 1. Use for content reveals, page transitions, and image loading.',
    implementation: 'opacity: 0 → 1 with --duration-normal + --ease-out (enter) or --ease-in (exit). Combine with translateY for a subtle slide-fade.',
    reducedMotion: 'Instant show/hide — no fade animation.',
    docsUrl: null,
  },
  {
    name: 'Slide',
    category: 'entrance-exit',
    description: 'Content enters from a screen edge via translateX/Y. Use for panels, drawers, sheets, and mobile navigation.',
    implementation: 'transform: translateX(100%) → translateX(0) with --duration-normal + --ease-out. Vary direction based on context (left for nav, bottom for sheets).',
    reducedMotion: 'Instant position change or crossfade — no sliding motion.',
    docsUrl: null,
  },
  {
    name: 'Scale',
    category: 'entrance-exit',
    description: 'Element appears by scaling from 0.95 to 1 with an opacity fade. Use for modals, dialogs, popovers, and tooltips.',
    implementation: 'transform: scale(0.95) → scale(1) + opacity: 0 → 1 with --duration-fast + --ease-out. Never scale from 0 — too dramatic.',
    reducedMotion: 'Instant appear — opacity only, no scale transform.',
    docsUrl: null,
  },
  {
    name: 'Collapse',
    category: 'entrance-exit',
    description: 'Expand or collapse a section without animating height (layout-safe). Use for accordions, collapsible panels, and expandable rows.',
    implementation: 'grid-template-rows: 0fr → 1fr on parent, overflow: hidden on child. Uses --duration-normal + --ease-in-out.',
    reducedMotion: 'Instant expand/collapse — no animation.',
    docsUrl: null,
  },

  // --- Micro-Interactions ---
  {
    name: 'Hover Feedback',
    category: 'micro',
    description: 'Subtle scale or lift on hover for buttons, cards, and interactive elements. Creates a sense of direct manipulation.',
    implementation: 'transform: scale(1.02) or translateY(-1px) + shadow increase on :hover. Use --duration-fast + --ease-spring.',
    reducedMotion: 'No transform; color/shadow change only.',
    docsUrl: null,
  },
  {
    name: 'Press Feedback',
    category: 'micro',
    description: 'Scale-down effect on :active state for buttons. Provides tactile confirmation of interaction.',
    implementation: 'transform: scale(0.97) on :active. Use --duration-instant + --ease-default.',
    reducedMotion: 'No transform; opacity change only.',
    docsUrl: null,
  },
  {
    name: 'Validation Shake',
    category: 'micro',
    description: 'Horizontal shake animation for form fields with invalid input. Always pair with aria-invalid and visible error text — never shake as the only error indicator.',
    implementation: '@keyframes shake: translateX(-4px/4px) for 2-3 cycles over --duration-normal. Apply on submit validation failure.',
    reducedMotion: 'No shake — rely on red border + error message only.',
    docsUrl: null,
  },

  // --- Loading States ---
  {
    name: 'Shimmer Loading',
    category: 'loading',
    description: 'Gradient sweep animation over skeleton placeholders while data loads. Communicates that content is on its way.',
    implementation: 'Animated background-position on a linear-gradient. Container gets aria-busy="true", skeletons get aria-hidden="true".',
    reducedMotion: 'Static gray skeleton — no sweep animation.',
    docsUrl: 'https://ui.shadcn.com/docs/components/skeleton',
  },

  // --- Scroll-Driven ---
  {
    name: 'Scroll Reveal',
    category: 'scroll',
    description: 'Content fades and slides into view as the user scrolls. Use IntersectionObserver with threshold: 0.1 for efficient detection.',
    implementation: 'IntersectionObserver triggers opacity: 0 → 1 + translateY(20px) → 0 with --duration-normal + --ease-out.',
    reducedMotion: 'Content visible immediately — no scroll animation.',
    docsUrl: null,
  },
  {
    name: 'Staggered List',
    category: 'scroll',
    description: 'List items enter sequentially with increasing delays. Creates a cascade effect for card grids, search results, and feeds.',
    implementation: 'Each item gets transition-delay: calc(var(--index) * 50ms). Cap total delay at 500ms (10 items max stagger).',
    reducedMotion: 'All items appear simultaneously — no stagger delay.',
    docsUrl: null,
  },
];
