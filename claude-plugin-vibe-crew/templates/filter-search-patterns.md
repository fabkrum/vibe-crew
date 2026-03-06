# Filter & Search Pattern Reference

Agent-facing reference for search, filter, and sort design decisions. The Builder reads this during the Design Phase; the Code Reviewer checks compliance during review.
**Principle:** Search and filter interfaces must be fast, accessible, and preserve user context — never lose state on back-navigation.

## 1. Search Patterns

### Search Bar
- **When:** Site has substantial content users need to find by keyword.
- **What:** Visible text input with search icon in a sticky header. Wrap in `<search>` or `<form role="search">`.
- **A11y:** `<search>` landmark or `role="search"`. `<label>` or `aria-label` on input. Unique `aria-label` if multiple search regions.

### Instant Search
- **When:** Datasets small enough for sub-200ms responses or backed by a fast search API.
- **What:** Results update as user types without form submission. Use Command (cmdk) with CommandInput/CommandList. Debounce 150-300ms.
- **A11y:** `aria-live="polite"` on results region. `aria-live="assertive"` only for zero-result states.
- **Anti-pattern:** Never fire on every keystroke without debounce.

### Search Suggestions
- **When:** Any search input where predictable results exist. Selected 23% of the time on e-commerce (NN/G).
- **What:** Combobox dropdown with query completions, popular matches, scoped suggestions, or rich suggestions with thumbnails.
- **A11y:** `role="combobox"` with `aria-autocomplete="list"`, `aria-expanded`, `aria-controls`, `aria-activedescendant`. Down Arrow opens, Escape closes, Enter selects.

### Search Results Page
- **When:** Search returning more than a handful of results.
- **What:** Card per result. Show total count prominently. Query echo. Combine with filter sidebar and sort controls.
- **A11y:** Announce result count in `aria-live="polite"`. Semantic `<ol>` for results. Skip links past filters to results.

### Faceted Search
- **When:** E-commerce product discovery or any structured content with filterable attributes.
- **What:** Input (search) + Accordion (filter groups) with Checkbox lists. Show result counts per facet value. Popover on mobile.
- **A11y:** Each facet group needs visible heading or `aria-label`. Checkboxes use `role="checkbox"` with `aria-checked`. Announce filtered count via `aria-live`.

### Full-Text Search
- **When:** Users need to find content by terms anywhere in body text.
- **What:** Client-side: Pagefind, Lunr.js, Fuse.js. Server-side: Elasticsearch, Meilisearch, Algolia. Highlight matches with `<mark>`.
- **A11y:** `<mark>` for highlighted terms. `aria-live` for result counts.

### Fuzzy Matching
- **When:** Preventing zero-result dead ends from typos.
- **What:** Client: Fuse.js with configurable threshold. Server: Meilisearch/Algolia built-in typo tolerance. Show "Did you mean X?" or auto-correct with escape hatch.
- **A11y:** If auto-correcting, announce correction in `aria-live="polite"`.

### Recent Searches
- **When:** Search input receives focus while empty.
- **What:** Show 3-5 past queries (mobile) or up to 10 (desktop). Store in localStorage or user account. Clock icon + "Clear history" action.
- **A11y:** Label group with heading. Each item keyboard-navigable. Clear mechanism keyboard-accessible.

### Saved Searches
- **When:** Power users with repeated search criteria (job boards, marketplaces).
- **What:** "Save search" button stores named entry with serialized query + filter state. Optional notifications for new matches.
- **A11y:** Save button needs accessible label. Saved search list navigable with arrow keys.

### Search Scoping
- **When:** Multi-section sites where search can be restricted to a content type.
- **What:** Select or ToggleGroup adjacent to search input. Default to "All". On results page, state active scope and offer one-click expansion.
- **A11y:** `aria-label="Search scope"` on selector. Announce scope changes.
- **Anti-pattern:** Never default to a narrow scope — users expect full-site search (NN/G).

## 2. Filter Patterns

### Sidebar Filters
- **When:** Desktop content-heavy sites with many filter categories.
- **What:** Accordion in `<aside>` with per-category AccordionItems. Expand 3-5 most important by default; collapse the rest.
- **A11y:** `<aside aria-label="Filters">`. Each accordion trigger is a button. Preserve expanded/collapsed state across changes.

### Horizontal Filter Bar
- **When:** Fewer than 5-7 filter categories.
- **What:** Row of Popover triggers above results showing category name + active count. Checkbox/RadioGroup inside. "Apply" button on mobile.
- **A11y:** Trigger includes category name and active count in accessible name (e.g., "Brand, 2 selected"). Focus-trap popover content.

### Filter Chips
- **When:** Any filtered view — show active filters as removable pills above results.
- **What:** Badge with close button (X) in flex-wrap container. Include "Clear all" at the end.
- **A11y:** Each chip: `aria-label="Remove filter: [Category] - [Value]"`. Keyboard removal with Delete/Backspace. Announce removal via `aria-live`.

### Multi-Select Filters
- **When:** Filter groups where users select multiple values (e.g., multiple brands).
- **What:** Checkbox inside Accordion or Popover content. Show result count per option. Truncate 10+ items with "Show more".
- **A11y:** `role="group"` with `aria-labelledby` on category heading. Native `<input type="checkbox">` preferred.

### Range Filters
- **When:** Numeric or date range selection (price, date).
- **What:** Dual-thumb Slider + two Input fields for min/max, synced bidirectionally. DatePicker range variant for dates.
- **A11y:** Slider needs `role="slider"` with `aria-valuemin/max/now` and `aria-label`. Text input fallback mandatory for keyboard users.

### Toggle Filters
- **When:** Binary yes/no attributes ("In stock only", "Free shipping").
- **What:** Toggle or Switch placed prominently above results or at top of filter sidebar.
- **A11y:** `role="switch"` with `aria-checked`. Visible label required. Announce state change.

### Cascading Filters
- **When:** Selections in one filter constrain options in another (prevents impossible combos).
- **What:** Manage dependency graph in state. Update child options on parent change. Show disabled options with tooltip explanation.
- **A11y:** Disabled options need `aria-disabled="true"` with tooltip. Announce option changes via `aria-live` on parent update.

### Filter Presets
- **When:** Common user intents can be pre-configured ("Budget picks", "Top rated", "New arrivals").
- **What:** ToggleGroup or Button row as pills. Each preset applies known filter set. Allow combining with manual filters.
- **A11y:** `role="radiogroup"` if mutually exclusive, `role="group"` if combinable. Descriptive label per preset.

### Saved Filters
- **When:** Power users in SaaS dashboards or job boards with repeated filter combos.
- **What:** Serialize filter state to JSON, store per-user. Dialog for save form, DropdownMenu for load picker.
- **A11y:** Save dialog needs proper focus management. Saved filter list keyboard-navigable.

### Search Within Filters
- **When:** A filter category has 15+ values (e.g., 200 brands).
- **What:** Text input at top of filter group. Filter visible options client-side. Show top 10 with "Show all" link.
- **A11y:** Input needs `aria-label="Search [category name]"`. Results in `aria-live` region.

## 3. Sort Patterns

### Sort Dropdown
- **When:** Any list/grid needing user-controlled sort order.
- **What:** Select with predefined options including criterion + direction (e.g., "Price: Low to High"). Place right-aligned in results header next to count.
- **A11y:** `aria-label="Sort by"`. Arrow keys navigate, Enter selects.

### Column Sort
- **When:** Data tables with sortable columns.
- **What:** Clickable column headers with arrow icons. Shift+click for secondary sort. Use DataTable (TanStack Table).
- **A11y:** Headers need `aria-sort="ascending"`, `"descending"`, or `"none"`. Use `<button>` inside `<th>`. Announce sort changes.

### Default Sort Order
- **When:** Setting initial result order before user interaction.
- **What:** Relevance for search results, recency for feeds, popularity/recommended for browsing. Show active sort in dropdown.
- **A11y:** Current sort indicated via `aria-sort` or `aria-current` on active option.
- **Anti-pattern:** Avoid alphabetical as default sort (NN/G).

### Sort Direction Indicators
- **When:** Any sortable column or active sort control.
- **What:** ChevronUp/ChevronDown for active sort, ChevronsUpDown for unsorted. Apply to DataTable headers.
- **A11y:** Icons are decorative (`aria-hidden="true"`); state conveyed by `aria-sort` on `<th>`.

## 4. Combined Patterns

### Search + Filter + Sort Layout
- **When:** Any list/grid with 20+ items.
- **What:** Search (left/top), filters (below or sidebar), sort dropdown (right in header), result count (left in header). Collapse filters behind button on mobile.
- **A11y:** Landmarks: `<search>`, `<aside>` for filters, `<main>` for results. Skip links: "Skip to results", "Skip to filters".

### URL-Synced Filters
- **When:** Any filtered view that should be bookmarkable/shareable.
- **What:** Sync query, filters, sort, pagination to URL params via `useSearchParams`. Use `router.replace()` not `push` to avoid history bloat.
- **A11y:** Browser back button must undo filter changes. Announce results update from URL-driven state changes.
- **Anti-pattern:** Never lose filter state on back-navigation.

### Filter Counts
- **When:** Any filter with discrete options.
- **What:** Show matching result count next to each option (e.g., "Nike (42)"). Gray out zero-count options. Update dynamically.
- **A11y:** Include count in accessible name (e.g., "Nike, 42 results"). Do not rely on color alone for zero-count.

### Active Filter Summary
- **When:** Any view with active filters — show removable chips between controls and results.
- **What:** Flex-wrap Badge components with close buttons. "Clear all" ghost Button. Show total result count.
- **A11y:** `aria-label="Active filters"` on region. Announce removal and "clear all" via `aria-live`. Each chip: `aria-label="Remove filter: [value]"`.

### Apply Button with Count
- **When:** Mobile filter panels or batch filtering workflows.
- **What:** Button showing expected result count (e.g., "Show 247 results"). Do not update results until pressed. Dim results while pending.
- **A11y:** Button label programmatically updates with count. Announce "Filters applied, showing N results" after activation.

## 5. Performance

### Debounced Search Input
- **When:** Any search-as-you-type implementation.
- **What:** Delay API calls until user stops typing. 150ms for fast APIs, 300ms for slower endpoints. Cancel pending on new input.
- **A11y:** Visual spinner feedback during pending search.

### Server-Side vs Client-Side Filtering
- **When:** Choosing filtering strategy.
- **What:** Client-side for under ~1000 items (TanStack Table filtering). Server-side for larger datasets (filter params as URL query, React Query/SWR caching). Hybrid: server for initial, client for refinement.
- **A11y:** Announce loading states for server-side filtering.

### Filter Result Caching
- **When:** Revisiting previous filter combinations should be instant.
- **What:** React Query/TanStack Query with keys from filter state. Set staleTime 30s-5min. Client-side: `useMemo` for filtered arrays.

### Search Indexing
- **When:** Full-text search needs sub-millisecond performance.
- **What:** Client: Pagefind (static, build-time), Lunr.js, Fuse.js. Server: Elasticsearch, Meilisearch, Algolia. Rebuild on content changes.

## 6. Accessibility

### Search Landmark
- **When:** Every page with a search UI.
- **What:** Wrap in `<search>` or `<form role="search">`. Add `aria-label` if multiple search regions on page.
- **A11y:** WCAG required for discoverability. Multiple landmarks each need unique `aria-label`.

### Live Result Count
- **When:** Search or filter results change.
- **What:** `aria-live="polite"` element with "N results found." `aria-live="assertive"` only for zero results.
- **Anti-pattern:** Never announce on every keystroke — wait for debounce.

### Filter Keyboard Navigation
- **When:** All filter controls.
- **What:** Native HTML form elements for built-in keyboard support. Tab order: search > filters top-to-bottom > sort > results.
- **A11y:** WCAG 2.1.1 (Keyboard). Visible focus indicators with 3:1 contrast (WCAG 2.4.7). Never trap focus in filter panels unless modal.

### Filter Group Labeling
- **When:** Every filter group.
- **What:** `<fieldset>` + `<legend>` per group, or `role="group"` with `aria-labelledby` pointing to heading.
- **A11y:** WCAG 1.3.1 (Info and Relationships). Every checkbox/radio associated with both own label and group label.

## 7. Mobile Patterns

### Bottom Sheet Filters
- **When:** Mobile filter UI needs thumb-reachable controls.
- **What:** Drawer (Vaul) sliding up from bottom. Include close button (X) + swipe-to-dismiss. "Apply" button with result count at bottom.
- **A11y:** Focus trap when modal. Close button keyboard-accessible. Announce open/close. Return focus to trigger. Min touch target: 48x48px.
- **Anti-pattern:** Never rely on swipe-to-dismiss alone — many users don't discover it (NN/G).

### Collapsible Filter Panel
- **When:** Mobile views needing to conserve vertical space.
- **What:** Accordion (`type="multiple"`). Expand 1-2 most important categories by default. "Filter" button in header reveals panel.
- **A11y:** Triggers are buttons with `aria-expanded`. Content uses `aria-hidden` when collapsed. Maintain focus on trigger after toggle.

### Full-Screen Filter Overlay
- **When:** Complex filter interface on mobile.
- **What:** Full-screen Dialog or Drawer snapped to full height. Category nav on left or tabs at top. "Show N results" button at bottom.
- **A11y:** Full focus trap. Escape closes. Return focus to trigger. Announce "Filter dialog opened, N categories available."

### Horizontal Scroll Chips
- **When:** 5-12 high-priority filter options on mobile.
- **What:** Horizontally scrollable container (`overflow-x: auto`, `flex-nowrap`) of Toggle/ToggleGroup. Gradient scroll indicators on edges.
- **A11y:** Container: `role="toolbar"` or `role="group"` with `aria-label`. Arrow keys navigate. Each chip: `aria-pressed`. Scroll indicators must not obscure text.

### Sort & Filter Button
- **When:** Constrained mobile space needs a single entry point for both sort and filter.
- **What:** Button with filter icon + "Sort & Filter" label opening Drawer. Two sections: "Sort" (RadioGroup) and "Filter" (Accordion + Checkboxes). Badge with active count.
- **A11y:** Button label includes count: "Sort and Filter, 3 active." Panel follows modal/drawer a11y patterns.

## Builder Agent Key Principles

1. **Debounce all search inputs** — 150-300ms prevents excessive requests.
2. **URL-sync filter state** — bookmarkable, shareable, back-button works.
3. **Never lose state on back-navigation** — use `router.replace()` for filter changes.
4. **Show filter counts** — prevents zero-result dead ends.
5. **Active filter summary with "Clear all"** — users must see and remove active filters.
6. **Landmarks and skip links** — `<search>`, `<aside>` for filters, skip links to results.
7. **`aria-live` for result counts** — polite for updates, assertive only for zero results.
8. **Mobile: bottom sheet or full-screen overlay** — never sidebar filters on small screens.
9. **Default sort matches intent** — relevance for search, recency for feeds, never alphabetical.
10. **Every filter group has a programmatic label** — `<fieldset>`+`<legend>` or `role="group"`+`aria-labelledby`.
