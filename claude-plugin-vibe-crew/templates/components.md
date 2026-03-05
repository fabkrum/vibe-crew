# UI Component & Pattern Reference

Agent-facing reference for component selection, interaction patterns, and keyboard navigation.
The Builder and Orchestrator read this file during design and implementation phases.
**Principle:** Agents use precise component vocabulary internally, plain language with users.

## 1. Collecting User Input

### Button
- **Aliases:** action, CTA, submit button | **shadcn:** `button` — `npx shadcn@latest add button -y`
- **Plain language:** "A clickable button that triggers an action"
- **When to use:** Primary actions, form submissions, confirmations, toggles
- **Keyboard:** Enter/Space activates. Focus ring visible. Use `disabled` (removes from tab order) or `aria-disabled` (keeps focusable for tooltip).
- **A11y:** `role="button"` implicit. `aria-label` for icon-only. Loading: `aria-busy` + `aria-disabled`.
- **Anti-patterns:** Never `<div onClick>`. Never remove focus outline without replacement.

### Checkbox
- **Aliases:** tick box, multi-select option | **shadcn:** `checkbox` — `npx shadcn@latest add checkbox -y`
- **Plain language:** "A box you tick to turn an option on or off"
- **When to use:** Multiple selections, boolean toggles, terms acceptance
- **Keyboard:** Space toggles. Tab between checkboxes.
- **A11y:** `role="checkbox"`, `aria-checked`. Group: `role="group"` + `aria-labelledby`.
- **Anti-patterns:** Don't use for mutually exclusive (use Radio Group) or instant actions (use Switch).

### Combobox
- **Aliases:** autocomplete, type-ahead, searchable dropdown | **shadcn:** `command` + `popover` — `npx shadcn@latest add command popover -y`
- **Plain language:** "A search box that filters and suggests options as you type"
- **When to use:** Large lists (10+ items): country pickers, tag inputs, user search
- **Keyboard:** Type to filter. Arrows navigate suggestions. Enter selects. Escape closes. `aria-activedescendant` for virtual focus.
- **A11y:** `role="combobox"`, `aria-expanded`, `aria-autocomplete`.
- **Anti-patterns:** Never plain `<select>` for 10+ items. Use Select for <5 items.

### Date Picker
- **Aliases:** calendar input, date selector | **shadcn:** `calendar` + `popover` — `npx shadcn@latest add calendar popover -y`
- **Plain language:** "A calendar popup for picking dates"
- **When to use:** Date selection, date range filtering, scheduling
- **Keyboard:** Arrows navigate days. Enter selects. Escape closes. PageUp/Down for months. Focus trap in popover.
- **A11y:** Grid pattern: `role="grid"`, `aria-selected` on chosen date.
- **Anti-patterns:** Always allow typing dates directly. Don't use for time-only.

### Form
- **Aliases:** input form, data entry | **shadcn:** `form` — `npx shadcn@latest add form -y`
- **Plain language:** "A group of fields the user fills in and submits"
- **When to use:** Any structured data collection: registration, settings, checkout
- **Keyboard:** Tab between fields. Enter submits single-line inputs. Errors as live regions.
- **A11y:** `<form>` with `aria-labelledby`. Labels via `htmlFor`/`id`. Errors via `aria-describedby`.
- **Anti-patterns:** Don't clear form on validation error. Always show a submit button.

### Input
- **Aliases:** text field, text box | **shadcn:** `input` — `npx shadcn@latest add input -y`
- **Plain language:** "A text field where users type information"
- **When to use:** Short text: names, emails, URLs, search queries
- **Keyboard:** Standard text input. Appropriate `inputmode` for mobile.
- **A11y:** Always pair with `<label>`. `aria-describedby` for help. `aria-invalid` + `aria-errormessage` for errors.
- **Anti-patterns:** Don't use for multi-line (use Textarea). Don't use placeholder as only label.

### Input OTP
- **Aliases:** verification code, PIN input | **shadcn:** `input-otp` — `npx shadcn@latest add input-otp -y`
- **Plain language:** "Separate boxes for entering a verification code"
- **When to use:** 2FA codes, email/phone verification
- **Keyboard:** Auto-advance on digit. Backspace to previous. Paste fills all. Arrows between boxes.
- **A11y:** `role="group"` with `aria-label="Verification code"`.
- **Anti-patterns:** Always support paste. Never require manual tab between boxes.

### Label
- **Aliases:** field label | **shadcn:** `label` — `npx shadcn@latest add label -y`
- **Plain language:** "Text that describes what a field is for"
- **When to use:** Every form input — no exceptions.
- **Anti-patterns:** Never use placeholder as sole label.

### Radio Group
- **Aliases:** single select, option picker | **shadcn:** `radio-group` — `npx shadcn@latest add radio-group -y`
- **Plain language:** "A set of options where you pick exactly one"
- **When to use:** Mutually exclusive choices, 2-5 visible options
- **Keyboard:** Arrows move between options (roving tabindex). Tab enters/exits group. Space selects.
- **A11y:** `role="radiogroup"` + `aria-labelledby`. Each: `role="radio"` + `aria-checked`.
- **Anti-patterns:** 6+ options → Select or Combobox. Multiple selections → Checkbox.

### Select
- **Aliases:** dropdown, picker, select box | **shadcn:** `select` — `npx shadcn@latest add select -y`
- **Plain language:** "A dropdown list for picking one option"
- **When to use:** Single selection, 3-10 options, limited space
- **Keyboard:** Enter/Space opens. Arrows navigate. Enter selects. Escape closes. Type-ahead jumps.
- **Anti-patterns:** 10+ items → Combobox. Navigation → Navigation Menu.

### Slider
- **Aliases:** range slider, range input | **shadcn:** `slider` — `npx shadcn@latest add slider -y`
- **Plain language:** "A draggable handle for picking a value within a range"
- **When to use:** Numeric ranges: price, volume, rating, filters
- **Keyboard:** Arrows adjust. Home/End for min/max.
- **A11y:** `role="slider"`, `aria-valuenow`, `aria-valuemin`, `aria-valuemax`, `aria-valuetext`.
- **Anti-patterns:** Exact numbers → Input type="number". Always show current value.

### Switch
- **Aliases:** toggle, on/off switch | **shadcn:** `switch` — `npx shadcn@latest add switch -y`
- **Plain language:** "An on/off toggle that takes effect immediately"
- **When to use:** Binary settings that apply instantly: dark mode, notifications, feature flags
- **Keyboard:** Space toggles.
- **A11y:** `role="switch"`, `aria-checked`. Label describes setting, not state.
- **Anti-patterns:** Needs submit → Checkbox. Effect not immediate → Checkbox.

### Textarea
- **Aliases:** text area, message box | **shadcn:** `textarea` — `npx shadcn@latest add textarea -y`
- **Plain language:** "A larger text box for longer content"
- **When to use:** Multi-line: descriptions, comments, messages, bios
- **Anti-patterns:** Single-line → Input. Consider auto-resize.

### Toggle
- **Aliases:** toggle button, pressed button | **shadcn:** `toggle` — `npx shadcn@latest add toggle -y`
- **Plain language:** "A button that stays pressed or released"
- **When to use:** Formatting tools (bold/italic), view mode switching
- **Keyboard:** Enter/Space toggles. | **A11y:** `aria-pressed`. `aria-label` for icon-only.

### Toggle Group
- **Aliases:** button group, segmented control | **shadcn:** `toggle-group` — `npx shadcn@latest add toggle-group -y`
- **Plain language:** "A row of buttons where you pick one (or multiple)"
- **When to use:** View switchers (grid/list), filter groups. Max 5 options.
- **Keyboard:** Roving tabindex — Tab enters/exits, arrows within.

### File Upload
- **Aliases:** file picker, drag and drop | **shadcn:** Custom (Input type="file" + drag zone)
- **Plain language:** "A button or drop zone for uploading files"
- **When to use:** Document, image, CSV uploads
- **Keyboard:** Enter/Space opens file dialog. Drop zone not keyboard-accessible — always provide button.
- **A11y:** `<input type="file">` with label. `aria-describedby` for formats/limits. Progress via live region.
- **Anti-patterns:** Never drag-and-drop only. Show accepted types and size limits.

## 2. Displaying Data

### Avatar
- **Aliases:** profile picture, user icon | **shadcn:** `avatar` — `npx shadcn@latest add avatar -y`
- **Plain language:** "A small circular image showing a user's photo or initials"
- **When to use:** Profiles, comment authors, team members, activity feeds

### Badge
- **Aliases:** tag, chip, pill, status indicator | **shadcn:** `badge` — `npx shadcn@latest add badge -y`
- **Plain language:** "A small colored label showing status or category"
- **When to use:** Status indicators, counts, tags. Don't rely on color alone.

### Calendar
- **Aliases:** month view, date grid | **shadcn:** `calendar` — `npx shadcn@latest add calendar -y`
- **Plain language:** "A month grid showing dates you can select"
- **Keyboard:** Arrows navigate days. PageUp/Down months. Enter selects. Home/End first/last of week.
- **A11y:** `role="grid"`, `aria-selected` on chosen date.

### Card
- **Aliases:** content card, tile, panel | **shadcn:** `card` — `npx shadcn@latest add card -y`
- **Plain language:** "A bordered box containing related information"
- **When to use:** Product displays, content previews, dashboard widgets
- **Anti-patterns:** Clickable cards: use single `<a>` or pseudo-content trick. Don't nest interactive elements deeply.

### Carousel
- **Aliases:** image slider, slideshow, gallery | **shadcn:** `carousel` — `npx shadcn@latest add carousel -y`
- **Plain language:** "A sliding gallery showing one item at a time"
- **Keyboard:** Arrows navigate slides. Tab reaches prev/next buttons. Pause auto-play on focus/hover.
- **A11y:** `aria-roledescription="carousel"`. Each slide: `aria-label="N of M"`. Auto-play must have pause.
- **Anti-patterns:** Don't auto-play without pause. Don't hide essential content in later slides.

### Chart
- **Aliases:** graph, visualization | **shadcn:** `chart` (Recharts) — `npx shadcn@latest add chart -y`
- **Plain language:** "A visual graph showing data trends and comparisons"
- **When to use:** Analytics, trends, comparisons. Always provide table alternative.
- **Anti-patterns:** Don't load eagerly — use Import on Visibility. Don't rely on color alone.

### Data Table
- **Aliases:** sortable table, data grid | **shadcn:** `table` + `@tanstack/react-table` — `npx shadcn@latest add table -y`
- **Plain language:** "A table with sorting, filtering, and pagination"
- **When to use:** Structured data, 5+ columns: user lists, orders, inventory, logs
- **Keyboard:** Tab to table, arrows between cells. Sort headers: Enter/Space. `aria-sort` on headers.
- **Anti-patterns:** Simple key-value → definition list. 100+ rows → add List Virtualization.

### Table
- **Aliases:** static table, simple table | **shadcn:** `table` — `npx shadcn@latest add table -y`
- **Plain language:** "A simple table for displaying rows of data"
- **A11y:** Semantic `<table>`, proper `<th>` with `scope`. Don't use `<div>` grids.

### Progress
- **Aliases:** progress bar, loading bar | **shadcn:** `progress` — `npx shadcn@latest add progress -y`
- **Plain language:** "A bar showing how far along a task is"
- **A11y:** `role="progressbar"`, `aria-valuenow/min/max`, `aria-label`.

### Skeleton
- **Aliases:** placeholder, shimmer, loading skeleton | **shadcn:** `skeleton` — `npx shadcn@latest add skeleton -y`
- **Plain language:** "A placeholder shape showing where content will appear while loading"
- **When to use:** Any data-loading page/section — replaces spinners. Match shapes to actual layout.
- **A11y:** `aria-hidden="true"` on skeletons. Container: `aria-busy="true"`.

### Spinner
- **Aliases:** loading spinner, loader | **shadcn:** Custom (CSS animation)
- **Plain language:** "A spinning icon that means something is loading"
- **When to use:** Button loading, inline loading. Prefer Skeleton for page-level.
- **A11y:** `role="status"`, `aria-label="Loading"`.

## 3. Navigation

### Breadcrumb
- **Aliases:** path, trail | **shadcn:** `breadcrumb` — `npx shadcn@latest add breadcrumb -y`
- **Plain language:** "A trail showing where you are in the site hierarchy"
- **A11y:** `<nav aria-label="Breadcrumb">`. Current page: `aria-current="page"` (not a link).

### Command
- **Aliases:** command palette, spotlight, Cmd+K | **shadcn:** `command` — `npx shadcn@latest add command -y`
- **Plain language:** "A keyboard-triggered search box for finding actions quickly"
- **Keyboard:** Cmd+K opens. Type to filter. Arrows navigate. Enter activates. Escape closes. Focus trapped.

### Dropdown Menu
- **Aliases:** action menu, kebab menu, three-dot menu | **shadcn:** `dropdown-menu` — `npx shadcn@latest add dropdown-menu -y`
- **Plain language:** "A menu showing actions when you click a button"
- **Keyboard:** Enter/Space opens. Arrows navigate. Enter activates. Escape closes. Focus trapped; restores on close.
- **Anti-patterns:** Navigation → Navigation Menu. Max 1 nesting level.

### Menubar
- **Aliases:** top menu, application menu | **shadcn:** `menubar` — `npx shadcn@latest add menubar -y`
- **Plain language:** "A horizontal bar of menus like File, Edit, View"
- **Keyboard:** Left/Right between menu titles. Up/Down opens/navigates items.
- **Anti-patterns:** Simple navigation → Navigation Menu. Don't use on mobile.

### Navigation Menu
- **Aliases:** nav bar, site nav, mega menu | **shadcn:** `navigation-menu` — `npx shadcn@latest add navigation-menu -y`
- **Plain language:** "The main site navigation bar with links and dropdown sections"
- **A11y:** `<nav aria-label="Main">`. `aria-current="page"` on active link.

### Pagination
- **Aliases:** page numbers, pager | **shadcn:** `pagination` — `npx shadcn@latest add pagination -y`
- **Plain language:** "Page numbers for navigating between pages of a list"
- **When to use:** Long lists, search results. Default choice over infinite scroll.
- **A11y:** `<nav aria-label="Pagination">`. Current: `aria-current="page"`.

### Sidebar
- **Aliases:** side nav, navigation drawer | **shadcn:** `sidebar` — `npx shadcn@latest add sidebar -y`
- **Plain language:** "A navigation panel on the left side"
- **When to use:** Dashboards, admin panels, multi-section apps
- **Keyboard:** On mobile: treat as overlay with focus trap. Collapse button: `aria-expanded`.

### Tabs
- **Aliases:** tab bar, tabbed interface | **shadcn:** `tabs` — `npx shadcn@latest add tabs -y`
- **Plain language:** "Tabs that switch between content sections"
- **Keyboard:** Tab focuses active tab. Arrows between tabs. Enter/Space activates. Tab to panel.
- **A11y:** `role="tablist"/"tab"/"tabpanel"`. `aria-selected`, `aria-controls`.
- **Anti-patterns:** Sequential steps → Stepper. Primary nav → use actual navigation.

## 4. Feedback & Status

### Alert
- **Aliases:** banner, notice, warning | **shadcn:** `alert` — `npx shadcn@latest add alert -y`
- **Plain language:** "A colored banner showing an important message"
- **A11y:** `role="alert"` (urgent) or `role="status"` (info). Icon + color, not color alone.

### Alert Dialog
- **Aliases:** confirmation dialog, are-you-sure | **shadcn:** `alert-dialog` — `npx shadcn@latest add alert-dialog -y`
- **Plain language:** "A popup asking you to confirm before a significant action"
- **When to use:** Destructive/irreversible actions only.
- **Keyboard:** Focus trapped. Escape does NOT close — user must choose. Tab cycles buttons.
- **A11y:** `role="alertdialog"`, `aria-describedby`.

### Sonner (Toast)
- **Aliases:** toast, snackbar, notification popup | **shadcn:** `sonner` — `npx shadcn@latest add sonner -y`
- **Plain language:** "A small popup message that appears briefly then disappears"
- **When to use:** Action confirmations, non-critical errors. Pauses on hover/focus.
- **A11y:** `role="status"` + `aria-live="polite"`. Critical: `role="alert"`.
- **Anti-patterns:** Errors needing action → Alert/Dialog. Max 3 stacked.

### Empty State
- **Aliases:** zero state, no data, blank state | **shadcn:** Custom (Card + illustration + Button)
- **Plain language:** "A friendly message when there's no data, with a clear next step"
- **Anti-patterns:** Never show blank page. Always provide action to populate.

## 5. Overlays & Modals

### Dialog
- **Aliases:** modal, popup, lightbox | **shadcn:** `dialog` — `npx shadcn@latest add dialog -y`
- **Plain language:** "A popup window on top of the page"
- **Keyboard:** Focus trapped. First focusable gets focus on open. Escape closes. Focus restores on close.
- **A11y:** `role="dialog"`, `aria-labelledby`, `aria-describedby`. Background: `inert`.
- **Anti-patterns:** Don't nest dialogs. Simple confirmations → Alert Dialog.

### Drawer
- **Aliases:** bottom sheet, slide-out | **shadcn:** `drawer` — `npx shadcn@latest add drawer -y`
- **Plain language:** "A panel sliding in from the bottom or side"
- **Keyboard:** Same as Dialog: focus trap, Escape to close, focus restore.

### Popover
- **Aliases:** popup, floating panel, bubble | **shadcn:** `popover` — `npx shadcn@latest add popover -y`
- **Plain language:** "A small floating panel next to a button"
- **Keyboard:** Focus moves in on open. Escape closes. Focus restores.
- **Anti-patterns:** Complex forms → Dialog.

### Sheet
- **Aliases:** side panel, slide-over | **shadcn:** `sheet` — `npx shadcn@latest add sheet -y`
- **Plain language:** "A panel sliding in from the side"
- **When to use:** Settings, detail views, carts, notifications
- **Keyboard:** Same as Dialog: focus trap, Escape to close, focus restore.

### Tooltip
- **Aliases:** hint, hover tip, info bubble | **shadcn:** `tooltip` — `npx shadcn@latest add tooltip -y`
- **Plain language:** "A small label on hover or focus"
- **Keyboard:** Appears on focus (not just hover). Escape dismisses. Not interactive.
- **A11y:** `role="tooltip"`, linked via `aria-describedby`.
- **Anti-patterns:** Essential info → visible text. Interactive content → Popover.

### Context Menu
- **Aliases:** right-click menu | **shadcn:** `context-menu` — `npx shadcn@latest add context-menu -y`
- **Plain language:** "A menu on right-click"
- **Keyboard:** Shift+F10 opens. Arrows navigate. Always provide alternative access.

### Hover Card
- **Aliases:** preview card, link preview | **shadcn:** `hover-card` — `npx shadcn@latest add hover-card -y`
- **Plain language:** "A preview card on hover over a link"
- **Anti-patterns:** Don't put critical actions in hover cards.

## 6. Layout

### Accordion
- **Aliases:** collapsible section, FAQ | **shadcn:** `accordion` — `npx shadcn@latest add accordion -y`
- **Plain language:** "Sections that expand/collapse when you click headings"
- **Keyboard:** Enter/Space toggles. Tab between headers.
- **A11y:** Trigger: `<button>` + `aria-expanded` + `aria-controls`. Panel: `role="region"`.

### Aspect Ratio
- **Aliases:** responsive container | **shadcn:** `aspect-ratio` — `npx shadcn@latest add aspect-ratio -y`
- **Plain language:** "A container keeping images/videos at correct proportions"

### Collapsible
- **Aliases:** disclosure, show/hide | **shadcn:** `collapsible` — `npx shadcn@latest add collapsible -y`
- **Plain language:** "A section you expand or collapse with a toggle"
- **Anti-patterns:** Multiple sections → Accordion.

### Resizable
- **Aliases:** split pane, draggable divider | **shadcn:** `resizable` — `npx shadcn@latest add resizable -y`
- **Plain language:** "A draggable divider between panels"
- **Keyboard:** Arrows resize when handle focused. `role="separator"`.

### Scroll Area
- **Aliases:** scrollable container, custom scrollbar | **shadcn:** `scroll-area` — `npx shadcn@latest add scroll-area -y`
- **Plain language:** "A container with custom scrollbars for overflowing content"

### Separator
- **Aliases:** divider, horizontal rule | **shadcn:** `separator` — `npx shadcn@latest add separator -y`
- **Plain language:** "A visual line separating content sections"
- **A11y:** `role="separator"`. Decorative: `aria-hidden="true"`.

## 7. Interaction & Performance Patterns

| Pattern | Plain language | When to suggest | Implementation |
|---|---|---|---|
| Optimistic UI | "Updates instantly, retries silently on failure" | Any mutation: like, toggle, delete, form submit | Update local state immediately. Server request in background. Rollback + error toast on failure. |
| Skeleton Loading | "Shows page shape while content loads" | Any page/section fetching data on load | Skeleton components matching layout shape. `aria-busy="true"` on container. |
| Import on Interaction | "Heavy components load only on click" | Date pickers, rich editors, charts, maps, modals with heavy content | `React.lazy()` + dynamic `import()` on user action. |
| Import on Visibility | "Below-fold content loads on scroll" | Carousels, comments, maps, analytics charts | Intersection Observer triggers `import()`. Show Skeleton until loaded. |
| List Virtualization | "Only renders visible rows, handles thousands" | Tables/lists with 100+ rows | `@tanstack/react-virtual` or `react-window`. |
| Prefetch on Hover | "Starts loading next page on hover" | Nav links, pagination, card grids | `<Link prefetch="intent">` or `onMouseEnter` prefetch. |
| Progressive Disclosure | "Simple view first, details on demand" | Complex forms, settings, onboarding | Collapsible sections, tabs, or stepped forms. |
| Stale-While-Revalidate | "Shows cached data, refreshes in background" | Dashboards, feeds, analytics | `useSWR`, `@tanstack/react-query`, or Next.js ISR. |
| Debounced Search | "Waits until you stop typing to search" | Search inputs, filter inputs, autocomplete | 300ms debounce. Cancel pending requests on new input. |
| Infinite Scroll vs Pagination | "Paginated by default; infinite only if chosen" | Long lists, feeds, search results | Default: Pagination. Infinite scroll: feed-type content only. |
| Route-Based Splitting | "Each page loads only its own code" | Multi-page apps (automatic in Next.js/Remix/SvelteKit) | Framework default — no extra work needed. |
| Page Transitions | "Smooth animations between pages" | Content sites, portfolios, onboarding | View Transitions API or Framer Motion. Respect `prefers-reduced-motion`. |

## 8. Keyboard Navigation & Focus Management

| Pattern | Plain language | When to enforce | Enforcement |
|---|---|---|---|
| Focus Trapping | "Tab stays inside popup until closed" | Every modal, dialog, drawer, sheet, alert dialog | shadcn/Radix handles automatically. Verify custom overlays. |
| Focus Restoration | "Focus returns to trigger on close" | Every overlay triggered by user action | shadcn/Radix handles automatically. Verify custom implementations. |
| Arrow Key Navigation | "Arrows move between items in list/menu" | Menus, radio groups, tabs, tree views, listboxes, grids | Check W3C APG spec for the component type. |
| Roving Tabindex | "Tab enters group, arrows within, Tab leaves" | Tab lists, toolbars, radio groups, menu bars | Active item: `tabindex="0"`. Others: `tabindex="-1"`. |
| Skip Link | "Hidden link jumps to main content" | Every page — first focusable element | `<a href="#main" class="sr-only focus:not-sr-only">Skip to content</a>` |
| Visible Focus Ring | "Clear outline on focused element" | Every interactive element | Never `outline: none` without `:focus-visible` replacement. Min 2px, contrasting. |
| Escape to Close | "Escape closes any overlay" | Every popover, dialog, drawer, dropdown, tooltip | shadcn handles. Exception: Alert Dialog does NOT close on Escape. |
| Enter/Space to Activate | "Both keys trigger buttons and links" | Every clickable element | Native `<button>`/`<a>` handle this. Verify custom `<div>`/`<span>` components. |
| Disabled vs Aria-Disabled | "Choose between can't-focus and explained-disabled" | Forms with conditional requirements | `disabled` removes from tab order. `aria-disabled` keeps focusable. |
| Live Regions | "Screen readers announce changes without focus" | Toasts, form errors, loading states, search counts | `aria-live="polite"` (status) or `"assertive"` (errors). `aria-busy` for loading. |
| Keyboard Shortcuts | "Power users trigger actions without clicking" | Optional — repeated actions | Cmd+K (palette), Cmd+S (save). Never override browser defaults. |

## 9. Conversion & Trust Patterns

Cross-reference with `business-patterns.md` for full rationale. This section
maps business patterns to specific component implementations.

| Pattern | Components | Implementation |
|---------|-----------|----------------|
| CTA Hierarchy | Button (primary/secondary/ghost variants) | One primary per view. Secondary for alternatives. Ghost for low-priority. |
| Social Proof Bar | Avatar + Badge + custom | Logo row, testimonial cards, or "X users" counter near CTAs. |
| Trust Placement | Card + Badge + Tooltip | Security/guarantee badges in Card footer adjacent to action buttons. |
| Empty State Onboarding | Card + Button + illustration | Explain value, show sample, guide first action. Never blank. |
| Success Celebration | Sonner + custom animation | Toast for minor actions. Full-screen moment for milestones. |
| Progressive Disclosure | Accordion + Collapsible + Tabs | Simple first, details on demand. Reduce cognitive load per Hick's Law. |
| Inline Validation | Form + Input + Label | Validate on blur, not on type. Show errors via `aria-describedby`. |
| Pricing Comparison | Table + Card + Badge + Toggle | 3 tiers, center highlighted (Von Restorff), annual/monthly toggle. |

## 10. Animation & Motion Patterns

Cross-reference with `animation-patterns.md` for full token reference and reduced-motion requirements.

| Pattern | When to apply | Token | Reduced Motion |
|---------|---------------|-------|----------------|
| Fade (enter/exit) | Content reveal, page transitions, image loading | `--duration-normal` + `--ease-out` (enter), `--ease-in` (exit) | Instant show/hide |
| Slide | Drawers, sheets, mobile nav, panels from edge | `--duration-normal` + `--ease-out` | Instant position or crossfade |
| Scale | Modals, dialogs, popovers, tooltips appearing | `--duration-fast` + `--ease-out` | Opacity only, no scale |
| Collapse/Expand | Accordions, collapsible sections | `--duration-normal` + `--ease-in-out` via `grid-template-rows: 0fr/1fr` | Instant toggle |
| Hover Feedback | Buttons, cards, interactive items | `--duration-fast` + `--ease-spring`, `scale(1.02)` | Color/shadow only |
| Press Feedback | Buttons on `:active` | `--duration-instant`, `scale(0.97)` | Opacity change only |
| Shimmer/Skeleton | Data loading states | Continuous gradient sweep, `aria-busy="true"` | Static gray placeholder |
| Scroll Reveal | Sections entering viewport | `--duration-normal` + `--ease-out` via IntersectionObserver | Content visible immediately |
| Staggered List | List items entering viewport | `delay: index * 50ms`, cap 500ms | All items appear at once |
| Toast Slide-In | Toast notifications | `--duration-normal` + `--ease-out` | Instant appear/disappear |

**Rules:** Only animate `transform` + `opacity` (GPU-safe). Cap at 600ms. `ease-out` for enter, `ease-in` for exit, `spring` for micro-interactions.

## 11. Responsive Design Patterns

Cross-reference with `responsive-patterns.md` for full implementation guidance.

| Pattern | When to apply | Implementation |
|---------|---------------|----------------|
| Mobile-First | Always — base CSS targets mobile | `min-width` media queries to enhance for larger screens |
| Breakpoints | Standard: 360/768/1024/1440px | Content-driven breakpoints when design breaks at non-standard widths |
| Container Queries | Reusable components in different layouts | `container-type: inline-size` on wrapper, `@container (min-width)` |
| Fluid Typography | All heading and body text | `clamp(min, preferred, max)` with `rem + vw`. Never raw `vw` alone |
| Touch Targets | Every interactive element on touch devices | 44×44px minimum, 8px gap. Use `@media (pointer: fine)` for desktop exception |
| Responsive Images | Content images at different sizes | `srcset` + `sizes`, `<picture>` for art direction, `loading="lazy"`, `aspect-ratio` |
| Logical Properties | All spacing and alignment | `margin-inline`, `padding-block`, `border-inline-start` — auto-adapts to RTL |
| Responsive Navigation | App navigation across breakpoints | Desktop: top bar/sidebar. Mobile: bottom tab bar (preferred) or hamburger |

**Rules:** Mobile-first CSS. Touch targets 44px minimum. `clamp()` for fluid text. Logical properties over physical. `aspect-ratio` on all images.

## Builder Agent Key Principle

shadcn/ui (Radix UI) handles most keyboard patterns automatically. The agent ensures:
1. **Custom components** follow W3C APG keyboard specs for their type
2. **Page-level focus** moves correctly after navigation and overlay close
3. **Focus order matches visual order** — no CSS tricks breaking tab sequence
4. **No keyboard traps** — user can always Tab/Escape out
