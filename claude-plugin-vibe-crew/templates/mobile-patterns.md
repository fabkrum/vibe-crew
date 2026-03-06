# Mobile & Touch Pattern Reference

Agent-facing reference for mobile-first, touch-friendly interface design. The Builder reads this during the Design Phase; the Code Reviewer checks compliance during review.
**Principle:** Thumb zone first. Every interactive element must be reachable with one hand, sized for finger taps (not mouse clicks), and respect device safe areas. Gestures must always have non-gesture alternatives. CSS environment variables and dynamic viewport units replace hardcoded values.

## 1. Touch Targets & Ergonomics

### Thumb Zone Design
- **When:** Any mobile screen with interactive elements — decide where to place primary actions.
- **What:** Bottom third = primary actions (CTAs, inputs, nav). Top = information display. Middle = secondary actions. Pad bottom with `env(safe-area-inset-bottom)`.
- **A11y:** Bottom placement benefits motor-impaired users with limited reach. Don't place at extreme edges where screen magnification users can't see.
- **Anti-pattern:** Never place primary actions in the top-right corner on mobile. Never require two-handed operation for core flows.

### Touch Target Sizing
- **When:** Every interactive element on mobile — buttons, links, checkboxes, radio buttons, icons.
- **What:** Minimum 48x48dp (Material Design) / 44x44px (WCAG 2.5.8). Expand small icons with `::after` pseudo-element: `position: absolute; inset: -8px`. Never rely on visual size alone.
- **A11y:** WCAG 2.5.8 requires 24x24px minimum with 24px spacing. WCAG 2.5.5 (AAA) requires 44x44px. Use the larger target.
- **Anti-pattern:** Never use icon-only buttons smaller than 44px without expanded hit area. Never pack interactive elements without 8px non-interactive gaps.

### Large Tap Areas
- **When:** Cards, list items, rows with links or actions.
- **What:** Entire card/row is tappable via `display: block` on the anchor. Multiple actions: primary link wraps card, secondary actions use `position: relative` + `z-index`.
- **A11y:** Tappable element must be a semantic `<a>` or `<button>`. Avoid `<div onClick>`.
- **Anti-pattern:** Never make only the text/icon inside a card tappable while the rest is dead space.

### Minimum Spacing Between Targets
- **When:** Dense layouts — toolbars, button groups, list actions.
- **What:** 8px non-interactive gap between adjacent touch targets. Use `gap: 8px` in flex/grid containers.
- **A11y:** WCAG 2.5.8 allows undersized targets if they have 24px spacing. Generous spacing is the simplest compliance path.
- **Anti-pattern:** Never place interactive elements edge-to-edge without gaps.

### FAB Placement
- **When:** Single promoted primary action (compose, add, create). One per screen max.
- **What:** `position: fixed`, `bottom: calc(16px + env(safe-area-inset-bottom))`, `right: 16px`. 56px diameter. Above tab bar. z-index below modals.
- **A11y:** `aria-label="Create new item"`. Should not obscure content — add scroll padding. Consider hiding on scroll-down.
- **Anti-pattern:** Never use multiple FABs. Never place FAB over the tab bar or bottom sheet.

### Input Field Sizing
- **When:** All text inputs, selects, and textareas on mobile.
- **What:** `min-height: 48px; font-size: 16px`. The 16px rule prevents iOS Safari auto-zoom on focus. This is the only correct fix — never use `user-scalable=no`.
- **A11y:** WCAG 1.4.4 requires content to be zoomable to 200%. Disabling zoom via meta tags violates this.
- **Anti-pattern:** Never use `font-size` below 16px on inputs. Never add `maximum-scale=1` or `user-scalable=no` to the viewport meta tag.

## 2. Mobile Navigation

### Bottom Tab Bar
- **When:** Primary app navigation with 3-5 top-level sections.
- **What:** Fixed bottom, `padding-bottom: env(safe-area-inset-bottom)`. Icon + text label stacked vertically. Active tab: color + filled icon variant.
- **A11y:** `<nav aria-label="Main navigation">`. Each tab: `role="tab"`, `aria-selected`, `aria-current="page"`. Labels mandatory — icon-only tabs fail WCAG 1.1.1.
- **Anti-pattern:** Never use more than 5 tabs. Never omit text labels.

### Drawer Navigation
- **When:** Apps with 5+ sections or deep navigation hierarchies.
- **What:** `min(80vw, 360px)` width. Close via: X button, backdrop tap, swipe. `overscroll-behavior: contain`.
- **A11y:** Focus trap when open. Close on Escape. Return focus to hamburger trigger. `role="dialog"`, `aria-modal="true"`.
- **Anti-pattern:** Never rely only on swipe-to-close — always include visible close button.

### Back Navigation
- **When:** Every sub-page or detail view on mobile.
- **What:** Top-left chevron, min 44x44px. `history.back()` or explicit route. Support iOS swipe-from-left-edge.
- **A11y:** `aria-label="Go back"` or `aria-label="Back to [previous page]"`. Must be `<button>` or `<a>`, not `<div>`.
- **Anti-pattern:** Never use a div with click handler for navigation.

### Collapsing Header
- **When:** Long-scrolling pages where header space is valuable.
- **What:** Shrinks 56px → 44px on scroll-down. Restores on scroll-up. Use `IntersectionObserver` or throttled scroll handler.
- **A11y:** Never hide navigation controls during collapse. `prefers-reduced-motion`: snap between states, no animation.
- **Anti-pattern:** Never hide the back button or primary navigation when collapsed.

### Bottom Sheet
- **When:** Contextual options, filters, secondary content — anything that doesn't need full navigation.
- **What:** Snap points at 40%, 60%, 100% height. Drag handle: 32x4px rounded bar. Swipe-down dismiss below 20%. Always include visible close button.
- **A11y:** Trap focus when covering >50% viewport. `role="dialog"`, `aria-modal="true"`. Close button + Escape key.
- **Anti-pattern:** Never rely only on swipe dismissal. Many users don't discover it.

## 3. Gestures & Interactions

### Swipe Left / Right
- **When:** List items with contextual actions (delete, archive, complete, favorite).
- **What:** Left = destructive (red). Right = affirmative (green). 80px threshold. `touch-action: pan-y`.
- **A11y:** Always provide non-swipe alternatives (context menu, long-press, visible buttons). Swipe is undiscoverable.
- **Anti-pattern:** Never use swipe as the only way to access an action.

### Pull to Refresh
- **When:** Lists and feeds where content updates frequently.
- **What:** Detect `touchmove` when `scrollTop === 0`. `overscroll-behavior-y: contain`. 64px threshold. Show spinner.
- **A11y:** Provide "Refresh" button alternative. Announce via `aria-live="polite"`: "Refreshing..." then "Content updated."
- **Anti-pattern:** Never use as the only way to refresh. Never use browser-native PTR without custom styling.

### Long Press Context Menu
- **When:** Items that need contextual actions beyond swipe.
- **What:** 500ms hold. Cancel on `touchmove` >10px. Bottom sheet on mobile (not positioned dropdown). `navigator.vibrate(10)`.
- **A11y:** Always provide visible menu trigger (kebab icon) as alternative. Long press is undiscoverable.
- **Anti-pattern:** Never hide essential actions behind long press only.

### Pinch to Zoom
- **When:** Images, maps, charts, diagrams — visual content exploration.
- **What:** `touch-action: manipulation`. Track two-touch distance. CSS `transform: scale()`. Clamp 1x-5x. Double-tap toggles 1x/2x.
- **A11y:** Never use `user-scalable=no`. Provide visible +/- buttons. Support keyboard zoom with +/- keys.
- **Anti-pattern:** Never disable viewport zoom to "fix" pinch zoom.

### Swipe to Dismiss
- **When:** Toasts, notifications, transient cards.
- **What:** Velocity-based: dismiss if >0.5px/ms OR >50% element width. Animate: `translateX(100%) + opacity: 0` in 200ms.
- **A11y:** Always include visible close button (X). Auto-dismiss must be pausable on hover/focus (WCAG 2.2.1).
- **Anti-pattern:** Never auto-dismiss without a pause mechanism.

### Haptic Feedback
- **When:** Confirming touch interactions — taps, toggles, errors.
- **What:** `navigator.vibrate(10)` for success. `navigator.vibrate([100, 50, 100])` for error. Feature-detect first. Respect `prefers-reduced-motion`.
- **A11y:** Haptics must supplement, never replace, visual feedback. Must be opt-out.
- **Anti-pattern:** Never use haptics as the sole feedback mechanism.

## 4. Mobile Layout & Safe Areas

### Safe Area Insets
- **When:** Any fixed-position element (headers, tab bars, FABs, bottom sheets) on notch/Dynamic Island devices.
- **What:** `<meta name="viewport" content="viewport-fit=cover">`. Pad with `env(safe-area-inset-top)`, `env(safe-area-inset-bottom)`, `env(safe-area-inset-left)`, `env(safe-area-inset-right)`.
- **A11y:** Ensures interactive elements aren't obscured by device hardware. Critical for switch-access users.
- **Anti-pattern:** Never omit safe-area padding on fixed elements. Never assume all phones have symmetric insets.

### Dynamic Viewport Height
- **When:** Full-screen layouts, heroes, modals, splash screens.
- **What:** `height: 100dvh` (dynamic). Fallback: `height: 100vh; height: 100dvh`. Also: `svh` (small), `lvh` (large).
- **A11y:** Prevents content from being hidden behind mobile browser chrome.
- **Anti-pattern:** Never use `100vh` for full-screen mobile layouts — it overflows behind the URL bar.

### One-Handed Reachability
- **When:** Any mobile screen layout — deciding vertical content arrangement.
- **What:** Reverse pyramid: CTAs and inputs at bottom, information at top. `flex-direction: column-reverse` for action-first layouts.
- **A11y:** DOM order must match reading order even when visually rearranged. Use CSS `order` cautiously.
- **Anti-pattern:** Never place primary CTAs at the top of mobile screens.

### Prevent Zoom on Input Focus
- **When:** All forms on iOS Safari.
- **What:** `font-size: 16px` on all inputs, selects, textareas. This is the ONLY correct fix.
- **A11y:** Never use `maximum-scale=1` or `user-scalable=no` — violates WCAG 1.4.4.
- **Anti-pattern:** Never disable viewport zoom. Never use font-size below 16px on form elements.

## 5. Mobile Feedback

### Stories Format
- **When:** Ephemeral content, onboarding sequences, feature tours, product showcases.
- **What:** Full viewport (`100dvh`). Segmented progress bars. Auto-advance 5-7s. Tap right=next, left=back, hold=pause. Preload next card.
- **A11y:** `prefers-reduced-motion`: disable auto-advance, require manual tap. Pause/play button. `role="group"`, `aria-label="Story 3 of 8"`.
- **Anti-pattern:** Never auto-advance without a pause mechanism. Never use without progress indicators.

### Pull-Down Banner
- **When:** Transient notifications mimicking native push notification styling.
- **What:** Fixed position, `top: env(safe-area-inset-top)`. Slide in 300ms. Auto-dismiss 4s. Swipe up to dismiss. Queue multiple.
- **A11y:** `role="status"` or `role="alert"`. `aria-live="polite"`. Auto-dismiss pausable on hover/focus (WCAG 2.2.1).
- **Anti-pattern:** Never auto-dismiss without a pause mechanism.

### Mobile Skeleton Loading
- **When:** Any content that takes >200ms to load on mobile.
- **What:** Placeholder shapes matching real content dimensions. `aspect-ratio` to lock heights. CSS shimmer gradient. Max 3 shimmer cycles, then static gray.
- **A11y:** Skeleton: `aria-hidden="true"`. Separate `<div role="status" aria-live="polite">Loading...</div>`. `prefers-reduced-motion`: static gray, no shimmer.
- **Anti-pattern:** Never use mismatched skeleton dimensions — causes layout shift (CLS).

## 6. Content Patterns

### Timeline / Activity Feed
- **When:** Chronological events — order updates, project milestones, activity logs.
- **What:** Vertical line via `::before` (2px). Node markers (12px circles). `<time datetime="">`. Alternate on desktop, stack on mobile.
- **A11y:** `<ol>` or `<ul>` for event list. `<time datetime="">` for timestamps. `aria-label="Activity timeline"`. New events: `aria-live="polite"`.
- **Anti-pattern:** Never use purely visual timelines without semantic list structure.

### Star Rating
- **When:** User reviews, product ratings, feedback collection.
- **What:** Input: `role="radiogroup"` + 5 `role="radio"` buttons. SVG stars. 44px+ per star. Display: `aria-label="Rated 4 out of 5"`.
- **A11y:** Arrow keys navigate stars. `aria-checked` per star. Half-stars via SVG `clipPath`.
- **Anti-pattern:** Never use star ratings without keyboard navigation. Never use hover-only interaction on mobile.

### Stepper / Wizard
- **When:** Multi-step processes (checkout, onboarding, form wizards).
- **What:** Desktop: horizontal steps with connecting lines. Mobile: compact "Step 2 of 5" + progress bar. `<ol>` for steps. Completed steps tappable.
- **A11y:** `<nav aria-label="Progress">`, `<ol>`. `aria-current="step"` on active. `aria-disabled="true"` on future steps.
- **Anti-pattern:** Never show full horizontal stepper on mobile — it's too wide. Collapse to compact format.

### Dark Mode Toggle
- **When:** Any app offering theme customization.
- **What:** Three states: System / Light / Dark. `prefers-color-scheme` default. localStorage override. `data-theme` on `<html>`. CSS custom properties for all colors.
- **A11y:** `role="radiogroup"` for three-state toggle. Ensure all colors meet WCAG contrast in both modes.
- **Anti-pattern:** Never offer only Light/Dark without a System option. Never rely on color alone for information.

### Back to Top Button
- **When:** Long-scrolling mobile pages.
- **What:** Show after 400-600px scroll via `IntersectionObserver`. `window.scrollTo({ top: 0, behavior: "smooth" })`. `prefers-reduced-motion`: `behavior: "instant"`.
- **A11y:** `aria-label="Back to top"`. Move focus to top of page after scroll. Hidden when at top: remove from tab order.
- **Anti-pattern:** Never show back-to-top when already at top. Never forget to hide from tab order when invisible.

## 7. Utility Components

### Share Sheet / Action Sheet
- **When:** Sharing content, choosing from a list of actions.
- **What:** `navigator.share()` when available. Fallback: bottom sheet with Copy Link (first), Email, social options. Cancel at bottom.
- **A11y:** `role="dialog"`, `aria-modal="true"`, `aria-label="Share options"`. Focus trap. Cancel returns focus.
- **Anti-pattern:** Never omit "Copy link" from share options. Never skip the native Web Share API when available.

### Swipeable Card Stack
- **When:** Decision-making interfaces (matching, curation, triage).
- **What:** Stack with `position: absolute`. Top card tracks touch with `transform: translateX() rotate()`. Behind cards: `scale(0.95)`. Exit animation: 300ms.
- **A11y:** Arrow buttons below stack as keyboard alternative. Arrow keys for navigation. Each card: `role="group"`, `aria-label`.
- **Anti-pattern:** Never use swipe cards without visible button alternatives.

### Horizontal Scroll with Snap
- **When:** Image galleries, product rows, category browsing, carousels.
- **What:** `scroll-snap-type: x mandatory`. `scroll-snap-align: start`. `overflow-x: auto`. Hide scrollbar. Gradient edge fades for affordance.
- **A11y:** `role="region"`, `aria-label`, `tabindex="0"` for keyboard scroll. Visible prev/next buttons. Never use `overflow: hidden`.
- **Anti-pattern:** Never hide content with `overflow: hidden` — it's inaccessible. Always provide buttons for non-touch users.
