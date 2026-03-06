export interface MobilePattern {
  name: string;
  category: 'touch' | 'navigation' | 'gestures' | 'layout' | 'feedback' | 'content' | 'utilities';
  description: string;
  implementation: string;
  a11y: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<MobilePattern['category'], string> = {
  touch: 'Touch Targets & Ergonomics',
  navigation: 'Mobile Navigation',
  gestures: 'Gestures & Interactions',
  layout: 'Mobile Layout & Safe Areas',
  feedback: 'Mobile Feedback',
  content: 'Content Patterns',
  utilities: 'Utility Components',
};

export const categoryOrder: MobilePattern['category'][] = [
  'touch', 'navigation', 'gestures', 'layout', 'feedback', 'content', 'utilities',
];

export const mobilePatterns: MobilePattern[] = [
  // --- Touch Targets & Ergonomics ---
  {
    name: 'Thumb Zone Design',
    category: 'touch',
    description: 'Place primary actions in the bottom third of the screen where thumbs naturally rest. The top of the screen is the stretch zone — reserve it for less-frequent actions or information display. The "thumb zone" principle applies to all one-handed mobile usage.',
    implementation: 'Position CTAs, navigation, and primary inputs at the bottom. Use `env(safe-area-inset-bottom)` to pad above the home indicator. Test by holding the phone with one hand — if you can\'t reach a primary button, move it down.',
    a11y: 'Bottom placement benefits motor-impaired users who may have limited reach. Ensure actions remain visible to screen magnification users by not placing them at the extreme edge.',
    docsUrl: null,
  },
  {
    name: 'Touch Target Sizing',
    category: 'touch',
    description: 'Minimum 48x48dp (Material Design) or 44x44px (WCAG 2.5.8). Small targets cause mis-taps, especially for users with motor impairments. The most common mobile usability failure.',
    implementation: 'Set `min-width: 48px; min-height: 48px` on interactive elements. For small icons, expand the hit area using a `::after` pseudo-element with `position: absolute; inset: -8px`. Never rely on visual size alone.',
    a11y: 'WCAG 2.5.8 (Target Size Minimum) requires 24x24px minimum with no adjacent targets within 24px. WCAG 2.5.5 (Target Size Enhanced, AAA) requires 44x44px. Use the larger target.',
    docsUrl: 'https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html',
  },
  {
    name: 'Large Tap Areas',
    category: 'touch',
    description: 'Make entire rows, cards, and list items tappable — not just the text or icon inside them. Users expect the full surface to be interactive. Tapping dead space next to a link and getting no response frustrates users.',
    implementation: 'Use `display: block` on anchor elements wrapping cards. For list items, apply `cursor: pointer` and click handler to the `<li>`, not a nested element. Ensure the entire visual container responds to touch.',
    a11y: 'The tappable element must be a semantic link (`<a>`) or button. If the card has multiple actions, use one primary link wrapping the card and `position: relative` + `z-index` for secondary actions.',
    docsUrl: null,
  },
  {
    name: 'Minimum Spacing Between Targets',
    category: 'touch',
    description: 'Maintain at least 8px of non-interactive space between adjacent touch targets. Without spacing, users accidentally trigger the wrong action — the "ghost touch zone" problem, especially common in dense lists and toolbars.',
    implementation: 'Use `gap: 8px` in flex/grid containers with interactive elements. For inline buttons, add `margin-inline: 4px`. Test with large-finger simulation (Chrome DevTools touch emulation at 2x DPR).',
    a11y: 'WCAG 2.5.8 allows undersized targets if they have 24px spacing. Generous spacing is the simplest way to meet target size requirements on constrained interfaces.',
    docsUrl: null,
  },
  {
    name: 'FAB Placement',
    category: 'touch',
    description: 'Floating Action Button — a circular primary action button fixed at the bottom-right corner. Use for a single promoted action (compose, add, create). Limit to one per screen.',
    implementation: 'Fixed position, `bottom: calc(16px + env(safe-area-inset-bottom))`, `right: 16px`. Size: 56px diameter. Place above the tab bar if present. Use `z-index` above content but below modals.',
    a11y: 'Must have an accessible label (`aria-label="Create new item"`). Should not obscure content — add scroll padding at the bottom. Consider hiding on scroll-down, showing on scroll-up.',
    docsUrl: 'https://m3.material.io/components/floating-action-button/overview',
  },
  {
    name: 'Input Field Sizing',
    category: 'touch',
    description: 'Text inputs need 48px minimum height and `font-size: 16px` to prevent iOS Safari from auto-zooming. iOS zooms the viewport when focused inputs have font-size below 16px, breaking layout.',
    implementation: 'Set `min-height: 48px; font-size: 16px` on all `<input>`, `<textarea>`, and `<select>` elements. The 16px rule specifically prevents iOS zoom — use it even if your design system prefers smaller text.',
    a11y: 'Larger inputs benefit users with motor impairments. Clear visual focus styles (2px+ border change) required. Pair with visible labels above (not placeholder-only).',
    docsUrl: null,
  },

  // --- Mobile Navigation ---
  {
    name: 'Bottom Tab Bar',
    category: 'navigation',
    description: 'A fixed bar at the bottom of the screen with 3-5 navigation tabs, each showing an icon and label. The dominant mobile navigation pattern — used by every major app. More than 5 tabs becomes cramped.',
    implementation: 'Fixed position at bottom with `padding-bottom: env(safe-area-inset-bottom)`. Each tab: icon + text label stacked vertically. Active tab highlighted with color and/or filled icon variant. Use `<nav>` with `role="tablist"`.',
    a11y: 'Use `<nav aria-label="Main navigation">`. Each tab: `role="tab"`, `aria-selected="true|false"`, `aria-current="page"` for active. Labels are mandatory — icon-only tabs fail WCAG 1.1.1.',
    docsUrl: 'https://m3.material.io/components/navigation-bar/overview',
  },
  {
    name: 'Drawer Navigation',
    category: 'navigation',
    description: 'A side panel (typically 80vw wide) that slides in from the left or right, containing navigation links. Best for apps with 5+ sections or deep hierarchies. Always closeable via X button, backdrop tap, and swipe.',
    implementation: 'Width: `min(80vw, 360px)`. Close triggers: X button (top-right), backdrop click, swipe in closing direction. Transition: 250ms ease-out. Use `overscroll-behavior: contain` to prevent body scroll.',
    a11y: 'Focus trap inside open drawer. Close on Escape. Return focus to hamburger trigger on close. Drawer: `role="dialog"`, `aria-modal="true"`, `aria-label="Site navigation"`.',
    docsUrl: null,
  },
  {
    name: 'Back Navigation',
    category: 'navigation',
    description: 'A left-pointing chevron or arrow in the top-left corner that navigates to the previous screen. The universal mobile "go back" gesture. Must align with both Android back button and iOS swipe-back expectations.',
    implementation: 'Top-left position, min 44x44px touch target. Use `history.back()` or explicit route. On iOS, support swipe-from-left-edge with `touch-action: pan-x` on the first 20px of viewport.',
    a11y: 'Label: `aria-label="Go back"` or `aria-label="Back to [previous page]"`. The button itself must be a `<button>` or `<a>`, not a div with click handler.',
    docsUrl: null,
  },
  {
    name: 'Collapsing Header',
    category: 'navigation',
    description: 'A header that shrinks from a tall layout (56px with title/subtitle) to a compact bar (44px with title only) as the user scrolls down, maximizing content space. Restores when scrolling back up.',
    implementation: 'Use `IntersectionObserver` on a sentinel element or `scroll` event (throttled) to toggle a `.collapsed` class. Transition: `height 200ms ease`. Hide subtitle with `opacity: 0` and `overflow: hidden`.',
    a11y: 'Content must remain accessible in both states. Never hide navigation controls during collapse. Use `prefers-reduced-motion` to disable the animation and snap between states.',
    docsUrl: null,
  },
  {
    name: 'Bottom Sheet',
    category: 'navigation',
    description: 'A panel that slides up from the bottom to 40-60% of the screen height, with a drag handle for resize and swipe-down dismiss. Used for contextual options, filters, and secondary content without full navigation.',
    implementation: 'Snap points at 40%, 60%, and 100% height. Drag handle: 32x4px rounded bar centered at top. Dismiss: swipe below 20% threshold. Always include visible close button — many users don\'t discover swipe dismissal.',
    a11y: 'Trap focus when covering >50% of viewport. `role="dialog"`, `aria-modal="true"`. Close button + Escape key. Announce opening: `aria-live="polite"`. Drag handle: `role="separator"` with `aria-label`.',
    docsUrl: 'https://www.nngroup.com/articles/bottom-sheet/',
  },

  // --- Gestures & Interactions ---
  {
    name: 'Swipe Left / Right',
    category: 'gestures',
    description: 'Swipe horizontally on a list item to reveal actions — swipe left for destructive actions (delete, archive) in red, swipe right for affirmative actions (complete, favorite) in green. An 80px threshold prevents accidental triggers.',
    implementation: 'Track `touchstart`/`touchmove`/`touchend`. Set `touch-action: pan-y` to allow vertical scroll while capturing horizontal swipe. Threshold: 80px horizontal displacement. Snap back if below threshold.',
    a11y: 'Always provide non-swipe alternatives (context menu, long-press, or visible buttons). Swipe is undiscoverable — include a tutorial on first use. Keyboard: Delete key or context menu.',
    docsUrl: null,
  },
  {
    name: 'Pull to Refresh',
    category: 'gestures',
    description: 'Drag down from the top of a scrolled-to-top list to trigger a content refresh. Show a spinner animation pulled below the header. 64px pull threshold. The most recognized mobile gesture after tap and scroll.',
    implementation: 'Detect `touchmove` when `scrollTop === 0`. Set `overscroll-behavior-y: contain` to prevent browser-native PTR. Show spinner when pulled past 64px. CSS: translate the content container down. Release triggers refresh.',
    a11y: 'Provide a "Refresh" button as alternative. Announce refresh state via `aria-live="polite"`: "Refreshing..." then "Content updated, N new items". Never use as the only way to get fresh content.',
    docsUrl: null,
  },
  {
    name: 'Long Press Context Menu',
    category: 'gestures',
    description: 'A 500ms press-and-hold reveals a context menu of actions for the touched element. On mobile, render as a bottom sheet rather than a positioned dropdown to keep options in the thumb zone.',
    implementation: 'Start timer on `touchstart`, cancel on `touchmove` (>10px displacement) or `touchend` before 500ms. Use `navigator.vibrate(10)` for haptic confirmation. Show bottom sheet with action list and Cancel button.',
    a11y: 'Long press is undiscoverable — always provide a visible menu trigger (kebab icon) as alternative. Context menu items must be keyboard-accessible. Announce menu opening via aria-live.',
    docsUrl: null,
  },
  {
    name: 'Pinch to Zoom',
    category: 'gestures',
    description: 'Two-finger pinch gesture to zoom into images, maps, or charts. Intuitive for visual content exploration. Always provide +/- button alternatives for single-finger and keyboard users.',
    implementation: 'Use `touch-action: manipulation` on zoomable elements. Track two-touch distance changes. Apply CSS `transform: scale()`. Clamp zoom range (1x-5x). Double-tap to toggle between 1x and 2x.',
    a11y: 'Never disable `user-scalable=no` on the viewport — it prevents assistive technology zoom. Provide visible +/- buttons with aria-labels. Support keyboard zoom with + and - keys.',
    docsUrl: null,
  },
  {
    name: 'Swipe to Dismiss',
    category: 'gestures',
    description: 'Swipe a toast, notification, or card horizontally to dismiss it. Uses velocity-based calculation — fast flicks dismiss even with small displacement. The standard dismissal gesture for transient UI.',
    implementation: 'Track touch velocity (`distance / time`). Dismiss if velocity > 0.5px/ms OR displacement > 50% of element width. Animate out with `transform: translateX(100%)` + `opacity: 0`. Duration: 200ms.',
    a11y: 'Always include a visible close button (X) as alternative. Toasts must have `role="status"` or `role="alert"`. Auto-dismiss timer should be pausable on hover/focus (WCAG 2.2.1).',
    docsUrl: null,
  },
  {
    name: 'Haptic Feedback',
    category: 'gestures',
    description: 'Vibration feedback confirming touch interactions — 10ms for success/selection, 100-50-100ms pattern for error/warning. Enhances perceived responsiveness. Must be opt-out respecting user settings.',
    implementation: '`navigator.vibrate(10)` for tap confirmation. `navigator.vibrate([100, 50, 100])` for error pattern. Check `"vibrate" in navigator` before use. Respect `prefers-reduced-motion` — disable all haptics.',
    a11y: 'Haptics must supplement, never replace, visual and auditory feedback. Users with sensory disabilities may not perceive vibration. Always provide multi-modal feedback (visual + haptic + optional audio).',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/API/Vibration_API',
  },

  // --- Mobile Layout & Safe Areas ---
  {
    name: 'Safe Area Insets',
    category: 'layout',
    description: 'CSS environment variables that account for hardware obstructions — the iPhone notch, Dynamic Island, Android camera cutouts, and home indicator bar. Without these, UI gets hidden behind device chrome.',
    implementation: 'Add `<meta name="viewport" content="viewport-fit=cover">` to enable edge-to-edge. Then pad with `env(safe-area-inset-top)`, `env(safe-area-inset-bottom)`, `env(safe-area-inset-left)`, `env(safe-area-inset-right)`. Apply to fixed headers and bottom bars.',
    a11y: 'Ensures interactive elements are not obscured by device hardware. Critical for switch-access users who need to reach all interactive elements. Test on devices with notches and rounded corners.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/CSS/env',
  },
  {
    name: 'Dynamic Viewport Height',
    category: 'layout',
    description: 'Use `100dvh` instead of `100vh` for full-screen layouts. On mobile browsers, `100vh` includes the space behind the URL bar, causing content to overflow. `dvh` adjusts dynamically as the URL bar shows/hides.',
    implementation: '`height: 100dvh` for hero sections, modals, and full-screen interfaces. Fallback: `height: 100vh; height: 100dvh` for browsers without `dvh` support. Also available: `svh` (small) and `lvh` (large).',
    a11y: 'Prevents content from being hidden behind the mobile browser chrome, which particularly affects screen magnification users. Stable layout reduces cognitive load for all users.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/CSS/length#dynamic',
  },
  {
    name: 'One-Handed Reachability',
    category: 'layout',
    description: 'Arrange screen content in a reverse pyramid: critical interactive elements at the bottom (easy to reach), informational content at the top (readable but rarely tapped). Optimizes for one-handed phone use on larger screens.',
    implementation: 'Place primary CTA buttons, input fields, and tab bars at the bottom. Move titles, descriptions, and status information to the top. Use `flex-direction: column-reverse` for action-first mobile layouts.',
    a11y: 'Benefits users with limited hand mobility. Ensure the visual order still makes logical reading sense — DOM order must match reading order even when visually rearranged. Use `order` CSS property cautiously.',
    docsUrl: null,
  },
  {
    name: 'Prevent Zoom on Input Focus',
    category: 'layout',
    description: 'iOS Safari auto-zooms the viewport when a focused input has `font-size` below 16px. This breaks layout and disorients users. The fix is CSS, not meta tags — never use `user-scalable=no`.',
    implementation: 'Set `font-size: 16px` (or larger) on all `<input>`, `<select>`, and `<textarea>` elements. This is the only correct fix. Do NOT use `maximum-scale=1` or `user-scalable=no` in the viewport meta tag.',
    a11y: 'WCAG 1.4.4 (Resize Text) requires content to be zoomable to 200%. Disabling zoom via meta tags violates this. The 16px font-size approach prevents unwanted zoom while preserving intentional zoom capability.',
    docsUrl: null,
  },

  // --- Mobile Feedback ---
  {
    name: 'Stories Format',
    category: 'feedback',
    description: 'Full-screen vertical cards that auto-advance every 5-7 seconds. Tap right side to advance, left to go back, hold to pause. Progress indicators at the top show position. The dominant format for ephemeral mobile content.',
    implementation: 'Full viewport height (`100dvh`). Progress bar: segmented `<div>`s with CSS animation (`width: 0 → 100%` over 5-7s). Pause on `touchstart`, resume on `touchend`. Preload next card\'s media for instant transitions.',
    a11y: '`prefers-reduced-motion`: disable auto-advance, require manual tap. Provide pause/play button. Each card: `role="group"`, `aria-label="Story 3 of 8"`. Progress: `role="progressbar"`, `aria-valuenow`.',
    docsUrl: null,
  },
  {
    name: 'Pull-Down Banner',
    category: 'feedback',
    description: 'A transient notification banner that slides down from the top of the screen, mimicking native push notification styling. Auto-dismisses after 4 seconds. Tappable to navigate to related content.',
    implementation: 'Fixed position, `top: env(safe-area-inset-top)`. Animate in: `translateY(-100%) → translateY(0)` over 300ms. Auto-dismiss timer: 4s. Swipe up to dismiss manually. Queue multiple banners.',
    a11y: '`role="status"` for informational, `role="alert"` for urgent. `aria-live="polite"`. Auto-dismiss must be pausable on hover/focus (WCAG 2.2.1). Provide dismiss button.',
    docsUrl: null,
  },
  {
    name: 'Mobile Skeleton Loading',
    category: 'feedback',
    description: 'Placeholder shapes matching the real content layout, animated with a shimmer effect while loading. Heights must match actual content to prevent layout shift. More effective than spinners for perceived performance.',
    implementation: 'Match skeleton dimensions to actual content using `aspect-ratio` to lock heights. CSS shimmer: `linear-gradient` animated with `@keyframes`. Max 3 shimmer cycles, then static gray. Use `<div aria-hidden="true">`.',
    a11y: 'Skeleton is `aria-hidden="true"`. Announce loading state separately: `<div role="status" aria-live="polite">Loading content...</div>`. Respect `prefers-reduced-motion` — show static gray, no shimmer.',
    docsUrl: null,
  },

  // --- Content Patterns ---
  {
    name: 'Timeline / Activity Feed',
    category: 'content',
    description: 'A vertical sequence of timestamped events connected by a visual line, showing chronological activity (user actions, order updates, project milestones). Each entry has a node marker, timestamp, title, and optional detail.',
    implementation: 'CSS vertical line via `::before` pseudo-element on the container (2px wide, centered). Node markers: 12px circles positioned over the line. Each entry: `<article>` with `<time datetime="...">`. Alternate left/right on desktop, stack on mobile.',
    a11y: 'Use `<ol>` or `<ul>` for the event list. `<time datetime="">` for machine-readable timestamps. `aria-label="Activity timeline"` on container. New events: `aria-live="polite"` region.',
    docsUrl: null,
  },
  {
    name: 'Star Rating',
    category: 'content',
    description: 'A 1-5 star rating input or display. For input: tap a star to set rating (tapping the same star toggles it off). Each star must be an individually tappable 44px+ target. Display ratings with filled/half/empty stars.',
    implementation: 'Input: `role="radiogroup"` container with 5 `role="radio"` buttons. Use SVG star shapes. Display: `aria-label="Rated 4 out of 5 stars"`. Half-stars via SVG `clipPath`. Touch: min 44x44px per star.',
    a11y: 'Input: `role="radiogroup"` with `aria-label="Rating"`. Each star: `role="radio"`, `aria-checked`, `aria-label="1 star"` through `aria-label="5 stars"`. Arrow keys navigate. Display: `aria-label` with text value.',
    docsUrl: 'https://www.w3.org/WAI/ARIA/apg/patterns/radio/',
  },
  {
    name: 'Stepper / Wizard',
    category: 'content',
    description: 'A multi-step process with a visual progress indicator showing completed, current, and upcoming steps. On mobile, the full stepper collapses to a compact "Step 2 of 5" label to save horizontal space.',
    implementation: 'Desktop: horizontal step indicators with connecting lines. Mobile: `<span>Step 2 of 5</span>` with a thin progress bar. Each step: `<li>` in an `<ol>`. Completed steps are tappable to go back.',
    a11y: '`<nav aria-label="Progress">` containing `<ol>`. Current step: `aria-current="step"`. Completed steps: links. Future steps: `aria-disabled="true"`. Announce step changes via `aria-live`.',
    docsUrl: null,
  },
  {
    name: 'Dark Mode Toggle',
    category: 'content',
    description: 'A three-state toggle (System / Light / Dark) that respects `prefers-color-scheme` by default and saves user overrides to localStorage. System option follows OS preference and updates live.',
    implementation: 'Check `prefers-color-scheme` media query for default. Save override to localStorage. Apply via `data-theme` attribute on `<html>`. Use CSS custom properties for all colors. Transition: 200ms on `background-color` and `color`.',
    a11y: 'Use `role="radiogroup"` for three-state toggle. Each option: `role="radio"`, `aria-checked`. Ensure all color combinations meet WCAG contrast in both modes. Never rely on color alone for information.',
    docsUrl: 'https://web.dev/articles/prefers-color-scheme',
  },
  {
    name: 'Back to Top Button',
    category: 'content',
    description: 'A button that appears after scrolling 400-600px, smoothly scrolling to the top of the page when tapped. Essential for long-scrolling mobile pages where reaching the header requires excessive thumb effort.',
    implementation: 'Show/hide with `IntersectionObserver` on a sentinel element at 400-600px from top. `window.scrollTo({ top: 0, behavior: "smooth" })`. Position: bottom-right, above FAB if present. `prefers-reduced-motion`: use `behavior: "instant"`.',
    a11y: '`aria-label="Back to top"`. Move focus to the top of the page (e.g., skip-nav target or `<main>`) after scrolling. Hidden when at top: `aria-hidden="true"` or `display: none` to remove from tab order.',
    docsUrl: null,
  },

  // --- Utility Components ---
  {
    name: 'Share Sheet / Action Sheet',
    category: 'utilities',
    description: 'A bottom-mounted list of share targets or actions triggered by a share button. Uses the native Web Share API when available for OS-level sharing, with a custom fallback bottom sheet listing copy-link, email, and social options.',
    implementation: 'Check `navigator.share` support. If available: `navigator.share({ title, text, url })`. Fallback: custom bottom sheet with share options. Always include "Copy link" as first option. Cancel button at the bottom.',
    a11y: 'Share trigger: `aria-label="Share this [item]"`. Bottom sheet: `role="dialog"`, `aria-modal="true"`, `aria-label="Share options"`. Focus trap. Each option: `role="button"` or `<button>`. Cancel returns focus.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/API/Web_Share_API',
  },
  {
    name: 'Swipeable Card Stack',
    category: 'utilities',
    description: 'A deck of cards where the top card can be swiped left (reject) or right (accept) — the Tinder-style interaction pattern. Cards behind are slightly scaled down to create depth. Used for decision-making interfaces.',
    implementation: 'Stack with `position: absolute`. Top card tracks touch with `transform: translateX() rotate()`. Rotation: `angle = displacement * 0.1deg`. Behind cards: `scale(0.95)`, `translateY(10px)`. Animate exit: fly off screen 300ms.',
    a11y: 'Provide arrow buttons (left/right) below the stack as keyboard alternatives. Arrow keys for navigation. Each card: `role="group"`, `aria-label`. Announce card content when it becomes the top card.',
    docsUrl: null,
  },
  {
    name: 'Horizontal Scroll with Snap',
    category: 'utilities',
    description: 'A horizontally scrolling container where items snap to alignment points, creating a carousel-like experience without complex JavaScript. Used for image galleries, product rows, and category browsing.',
    implementation: '`scroll-snap-type: x mandatory` on container. `scroll-snap-align: start` on children. `overflow-x: auto; -webkit-overflow-scrolling: touch`. Hide scrollbar: `scrollbar-width: none`. Add gradient edge fades for affordance.',
    a11y: '`role="region"` with `aria-label` and `tabindex="0"` for keyboard scrollability. Arrow keys scroll. Provide visible prev/next buttons. Ensure all items are reachable — do not use `overflow: hidden` which hides content.',
    docsUrl: null,
  },
];
