export interface UIPattern {
  name: string;
  aliases: string[];
  category: 'data' | 'navigation' | 'feedback' | 'overlay' | 'layout' | 'interaction' | 'keyboard' | 'responsive' | 'error';
  description: string;
  shadcn: string | null;
  docsUrl: string | null;
}

export const categoryLabels: Record<UIPattern['category'], string> = {
  data: 'Displaying Data',
  navigation: 'Navigation',
  feedback: 'Feedback & Status',
  overlay: 'Overlays & Modals',
  layout: 'Layout',
  interaction: 'Interaction & Performance Patterns',
  keyboard: 'Keyboard & Focus Patterns',
  responsive: 'Responsive Design',
  error: 'Error Handling',
};

export const categoryOrder: UIPattern['category'][] = [
  'data', 'navigation', 'feedback', 'overlay', 'layout', 'interaction', 'keyboard', 'responsive', 'error',
];

export const uiPatterns: UIPattern[] = [
  // --- Displaying Data ---
  { name: 'Avatar', aliases: ['profile picture', 'user icon'], category: 'data', description: 'A small circular image showing a user\'s photo or initials.', shadcn: 'avatar', docsUrl: 'https://ui.shadcn.com/docs/components/avatar' },
  { name: 'Badge', aliases: ['tag', 'chip', 'pill', 'status indicator'], category: 'data', description: 'A small colored label showing status or category. Use for status indicators, counts, or tags.', shadcn: 'badge', docsUrl: 'https://ui.shadcn.com/docs/components/badge' },
  { name: 'Calendar', aliases: ['month view', 'date grid'], category: 'data', description: 'A month grid showing dates. Use for inline date selection or scheduling displays.', shadcn: 'calendar', docsUrl: 'https://ui.shadcn.com/docs/components/calendar' },
  { name: 'Card', aliases: ['content card', 'tile', 'panel'], category: 'data', description: 'A bordered box containing related information. Use for product displays, content previews, or dashboard widgets.', shadcn: 'card', docsUrl: 'https://ui.shadcn.com/docs/components/card' },
  { name: 'Carousel', aliases: ['image slider', 'slideshow', 'gallery'], category: 'data', description: 'A sliding gallery showing one item at a time with navigation arrows. Use sparingly.', shadcn: 'carousel', docsUrl: 'https://ui.shadcn.com/docs/components/carousel' },
  { name: 'Chart', aliases: ['graph', 'visualization', 'data chart'], category: 'data', description: 'A visual graph showing data trends and comparisons. Always provide a table alternative for accessibility.', shadcn: 'chart', docsUrl: 'https://ui.shadcn.com/docs/components/chart' },
  { name: 'Data Table', aliases: ['sortable table', 'data grid'], category: 'data', description: 'A table with sorting, filtering, and pagination. Use for structured data with 5+ columns.', shadcn: 'table', docsUrl: 'https://ui.shadcn.com/docs/components/data-table' },
  { name: 'Table', aliases: ['static table', 'simple table'], category: 'data', description: 'A simple table for displaying rows of data. Use for static displays, comparison tables, or pricing.', shadcn: 'table', docsUrl: 'https://ui.shadcn.com/docs/components/table' },
  { name: 'Progress', aliases: ['progress bar', 'loading bar'], category: 'data', description: 'A bar showing how far along a task is. Use for file uploads, multi-step processes, or loading.', shadcn: 'progress', docsUrl: 'https://ui.shadcn.com/docs/components/progress' },
  { name: 'Skeleton', aliases: ['placeholder', 'shimmer', 'loading skeleton'], category: 'data', description: 'A placeholder shape that shows where content will appear while loading. Replaces spinners for layout-aware loading.', shadcn: 'skeleton', docsUrl: 'https://ui.shadcn.com/docs/components/skeleton' },

  // --- Navigation ---
  { name: 'Breadcrumb', aliases: ['path', 'trail', 'page path'], category: 'navigation', description: 'A trail showing where you are in the site hierarchy.', shadcn: 'breadcrumb', docsUrl: 'https://ui.shadcn.com/docs/components/breadcrumb' },
  { name: 'Command', aliases: ['command palette', 'spotlight', 'Cmd+K'], category: 'navigation', description: 'A keyboard-triggered search box for finding actions and content quickly (Ctrl/Cmd+K).', shadcn: 'command', docsUrl: 'https://ui.shadcn.com/docs/components/command' },
  { name: 'Dropdown Menu', aliases: ['action menu', 'kebab menu', 'three-dot menu'], category: 'navigation', description: 'A menu that appears when you click a button, showing a list of actions.', shadcn: 'dropdown-menu', docsUrl: 'https://ui.shadcn.com/docs/components/dropdown-menu' },
  { name: 'Menubar', aliases: ['top menu', 'application menu'], category: 'navigation', description: 'A horizontal bar of menus like File, Edit, View \u2014 for complex desktop-style applications.', shadcn: 'menubar', docsUrl: 'https://ui.shadcn.com/docs/components/menubar' },
  { name: 'Navigation Menu', aliases: ['nav bar', 'site nav', 'mega menu'], category: 'navigation', description: 'The main site navigation with links and optional dropdown sections.', shadcn: 'navigation-menu', docsUrl: 'https://ui.shadcn.com/docs/components/navigation-menu' },
  { name: 'Pagination', aliases: ['page numbers', 'pager'], category: 'navigation', description: 'Page numbers for navigating between pages of a long list. Default choice over infinite scroll.', shadcn: 'pagination', docsUrl: 'https://ui.shadcn.com/docs/components/pagination' },
  { name: 'Sidebar', aliases: ['side nav', 'navigation drawer', 'left panel'], category: 'navigation', description: 'A navigation panel on the left side of the screen. Use for dashboard apps and admin panels.', shadcn: 'sidebar', docsUrl: 'https://ui.shadcn.com/docs/components/sidebar' },
  { name: 'Tabs', aliases: ['tab bar', 'tabbed interface'], category: 'navigation', description: 'Tabs along the top that switch between different content sections.', shadcn: 'tabs', docsUrl: 'https://ui.shadcn.com/docs/components/tabs' },

  // --- Feedback & Status ---
  { name: 'Alert', aliases: ['banner', 'notice', 'warning'], category: 'feedback', description: 'A colored banner showing an important inline message \u2014 warnings, success, errors, or info.', shadcn: 'alert', docsUrl: 'https://ui.shadcn.com/docs/components/alert' },
  { name: 'Alert Dialog', aliases: ['confirmation dialog', 'are-you-sure'], category: 'feedback', description: 'A popup asking you to confirm a significant action before it happens. Use for destructive or irreversible operations.', shadcn: 'alert-dialog', docsUrl: 'https://ui.shadcn.com/docs/components/alert-dialog' },
  { name: 'Sonner (Toast)', aliases: ['toast', 'snackbar', 'notification popup'], category: 'feedback', description: 'A small popup message that appears briefly and disappears. Use for action confirmations and non-critical errors.', shadcn: 'sonner', docsUrl: 'https://ui.shadcn.com/docs/components/sonner' },
  { name: 'Empty State', aliases: ['zero state', 'no data', 'blank state'], category: 'feedback', description: 'A friendly message shown when there\'s no data yet, with a clear next step. Never show a blank page.', shadcn: null, docsUrl: null },

  // --- Overlays & Modals ---
  { name: 'Dialog', aliases: ['modal', 'popup', 'lightbox'], category: 'overlay', description: 'A popup window that appears on top of the page with a backdrop. Focus is trapped inside until closed.', shadcn: 'dialog', docsUrl: 'https://ui.shadcn.com/docs/components/dialog' },
  { name: 'Drawer', aliases: ['bottom sheet', 'slide-out panel'], category: 'overlay', description: 'A panel that slides in from the bottom or side. Great for mobile-friendly detail views and filters.', shadcn: 'drawer', docsUrl: 'https://ui.shadcn.com/docs/components/drawer' },
  { name: 'Popover', aliases: ['popup', 'floating panel', 'bubble'], category: 'overlay', description: 'A small floating panel next to a button. Use for rich tooltips, mini-forms, or extra controls.', shadcn: 'popover', docsUrl: 'https://ui.shadcn.com/docs/components/popover' },
  { name: 'Sheet', aliases: ['side panel', 'slide-over', 'off-canvas'], category: 'overlay', description: 'A panel that slides in from the side. Use for settings, detail views, or shopping carts.', shadcn: 'sheet', docsUrl: 'https://ui.shadcn.com/docs/components/sheet' },
  { name: 'Tooltip', aliases: ['hint', 'hover tip', 'info bubble'], category: 'overlay', description: 'A small label that appears on hover or focus. Use for icon-only buttons or additional context.', shadcn: 'tooltip', docsUrl: 'https://ui.shadcn.com/docs/components/tooltip' },
  { name: 'Context Menu', aliases: ['right-click menu'], category: 'overlay', description: 'A menu that appears on right-click. Use for desktop app-like interfaces. Always provide alternative access.', shadcn: 'context-menu', docsUrl: 'https://ui.shadcn.com/docs/components/context-menu' },
  { name: 'Hover Card', aliases: ['preview card', 'link preview'], category: 'overlay', description: 'A preview card that appears when you hover over a link. Use for user profiles or entity summaries.', shadcn: 'hover-card', docsUrl: 'https://ui.shadcn.com/docs/components/hover-card' },

  // --- Layout ---
  { name: 'Accordion', aliases: ['collapsible section', 'expandable', 'FAQ'], category: 'layout', description: 'Sections that expand and collapse when you click their headings. Use for FAQs or grouped settings.', shadcn: 'accordion', docsUrl: 'https://ui.shadcn.com/docs/components/accordion' },
  { name: 'Aspect Ratio', aliases: ['responsive container', 'fixed ratio box'], category: 'layout', description: 'A container that keeps images or videos at the right proportions regardless of screen size.', shadcn: 'aspect-ratio', docsUrl: 'https://ui.shadcn.com/docs/components/aspect-ratio' },
  { name: 'Collapsible', aliases: ['disclosure', 'show/hide', 'toggle section'], category: 'layout', description: 'A section you can expand or collapse with a single toggle. Use for optional details or advanced options.', shadcn: 'collapsible', docsUrl: 'https://ui.shadcn.com/docs/components/collapsible' },
  { name: 'Resizable', aliases: ['split pane', 'draggable divider'], category: 'layout', description: 'A divider between panels you can drag to resize. Use for code editors or comparison views.', shadcn: 'resizable', docsUrl: 'https://ui.shadcn.com/docs/components/resizable' },
  { name: 'Scroll Area', aliases: ['scrollable container', 'custom scrollbar'], category: 'layout', description: 'A container with custom scrollbars for overflowing content like chat windows or code blocks.', shadcn: 'scroll-area', docsUrl: 'https://ui.shadcn.com/docs/components/scroll-area' },
  { name: 'Separator', aliases: ['divider', 'horizontal rule'], category: 'layout', description: 'A visual line separating sections of content. Use between content groups or menu sections.', shadcn: 'separator', docsUrl: 'https://ui.shadcn.com/docs/components/separator' },

  // --- Interaction & Performance Patterns ---
  { name: 'Optimistic UI', aliases: ['instant update', 'optimistic update'], category: 'interaction', description: 'Updates the interface instantly when you perform an action. If something goes wrong on the server, it quietly retries or rolls back.', shadcn: null, docsUrl: 'https://simonhearne.com/2021/optimistic-ui-patterns/' },
  { name: 'Skeleton Loading', aliases: ['placeholder loading', 'shimmer'], category: 'interaction', description: 'Shows the page shape while content loads, so the layout doesn\'t jump around when data arrives.', shadcn: null, docsUrl: 'https://ui.shadcn.com/docs/components/skeleton' },
  { name: 'Import on Interaction', aliases: ['lazy load on click', 'deferred import'], category: 'interaction', description: 'Heavy components like date pickers or rich text editors load only when you click on them.', shadcn: null, docsUrl: 'https://www.patterns.dev/vanilla/import-on-interaction' },
  { name: 'Import on Visibility', aliases: ['lazy load on scroll', 'below-fold loading'], category: 'interaction', description: 'Content below the fold loads as you scroll to it, keeping the initial page load fast.', shadcn: null, docsUrl: 'https://www.patterns.dev/vanilla/import-on-visibility' },
  { name: 'List Virtualization', aliases: ['virtual scroll', 'windowed list'], category: 'interaction', description: 'Only renders the rows you can see \u2014 handles thousands of items smoothly without slowing down.', shadcn: null, docsUrl: 'https://www.patterns.dev/vanilla/virtual-lists' },
  { name: 'Prefetch on Hover', aliases: ['link prefetch', 'predictive loading'], category: 'interaction', description: 'Starts loading the next page when you hover a link, so navigation feels instant.', shadcn: null, docsUrl: 'https://instant.page/' },
  { name: 'Progressive Disclosure', aliases: ['show more', 'advanced options'], category: 'interaction', description: 'Shows simple view first, details on demand. Keeps interfaces approachable without hiding power.', shadcn: null, docsUrl: 'https://www.nngroup.com/articles/progressive-disclosure/' },
  { name: 'Stale-While-Revalidate', aliases: ['SWR', 'background refresh', 'cache-first'], category: 'interaction', description: 'Shows cached data immediately, refreshes in the background. Dashboards and feeds feel instant.', shadcn: null, docsUrl: 'https://swr.vercel.app/' },
  { name: 'Debounced Search', aliases: ['throttled input', 'delayed search'], category: 'interaction', description: 'Waits until you stop typing before searching. Prevents unnecessary requests while you compose your query.', shadcn: null, docsUrl: null },
  { name: 'Infinite Scroll vs Pagination', aliases: ['load more', 'endless scroll'], category: 'interaction', description: 'Paginated by default (better for SEO and accessibility). Infinite scroll only when explicitly chosen for feed-type content.', shadcn: null, docsUrl: null },
  { name: 'Route-Based Splitting', aliases: ['code splitting', 'page-level splitting'], category: 'interaction', description: 'Each page only loads the code it needs. Automatic in Next.js, Remix, and SvelteKit.', shadcn: null, docsUrl: 'https://www.patterns.dev/vanilla/route-based-splitting' },
  { name: 'Page Transitions', aliases: ['route animation', 'view transition'], category: 'interaction', description: 'Smooth animations between page navigations. Respects user\'s reduced-motion preference.', shadcn: null, docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/API/View_Transitions_API' },

  // --- Keyboard & Focus Patterns ---
  { name: 'Focus Trapping', aliases: ['modal focus', 'focus lock'], category: 'keyboard', description: 'Tab stays inside the popup until you close it. Every modal, dialog, drawer, and sheet must trap focus.', shadcn: null, docsUrl: 'https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/' },
  { name: 'Focus Restoration', aliases: ['return focus', 'focus return'], category: 'keyboard', description: 'When a popup closes, focus returns to the button that opened it. Maintains keyboard user\'s place on the page.', shadcn: null, docsUrl: 'https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/' },
  { name: 'Arrow Key Navigation', aliases: ['arrow keys', 'directional navigation'], category: 'keyboard', description: 'Arrow keys move between items in a list, menu, or grid. The standard keyboard pattern for grouped elements.', shadcn: null, docsUrl: 'https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/' },
  { name: 'Roving Tabindex', aliases: ['managed focus', 'single tab stop'], category: 'keyboard', description: 'Tab enters a group of items, arrow keys move within it, Tab leaves. Prevents excessive tab stops.', shadcn: null, docsUrl: 'https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/#kbd_roving_tabindex' },
  { name: 'Skip Link', aliases: ['skip navigation', 'skip to content'], category: 'keyboard', description: 'A hidden link that lets keyboard users jump past navigation to the main content. Must be the first focusable element.', shadcn: null, docsUrl: 'https://www.w3.org/WAI/WCAG21/Understanding/bypass-blocks.html' },
  { name: 'Visible Focus Ring', aliases: ['focus indicator', 'focus outline'], category: 'keyboard', description: 'A clear outline shows which element is currently focused. Never remove focus styles without providing a visible replacement.', shadcn: null, docsUrl: 'https://www.w3.org/WAI/WCAG21/Understanding/focus-visible.html' },
  { name: 'Escape to Close', aliases: ['dismiss on escape', 'escape key'], category: 'keyboard', description: 'Pressing Escape closes any overlay \u2014 popovers, dialogs, drawers, dropdowns, and tooltips.', shadcn: null, docsUrl: 'https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/' },
  { name: 'Enter/Space to Activate', aliases: ['keyboard activation'], category: 'keyboard', description: 'Enter or Space triggers buttons and links. Every clickable element must respond to both keys.', shadcn: null, docsUrl: 'https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/' },
  { name: 'Live Regions', aliases: ['ARIA live', 'dynamic announcements'], category: 'keyboard', description: 'Screen readers announce dynamic changes \u2014 toast notifications, form errors, loading states \u2014 without moving focus.', shadcn: null, docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/ARIA_Live_Regions' },

  // --- Responsive Design ---
  { name: 'Mobile-First Layout', aliases: ['mobile first', 'progressive enhancement'], category: 'responsive', description: 'Write base CSS for mobile, then add min-width media queries to enhance for larger screens. Forces content prioritization.', shadcn: null, docsUrl: null },
  { name: 'Breakpoint System', aliases: ['media queries', 'responsive breakpoints'], category: 'responsive', description: 'Standard breakpoints at 360/768/1024/1440px. Use content-driven breakpoints when the design breaks at non-standard widths.', shadcn: null, docsUrl: null },
  { name: 'Container Query', aliases: ['container query', '@container'], category: 'responsive', description: 'Component adapts to its container width instead of the viewport. Essential for reusable components in different layout contexts.', shadcn: null, docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_containment/Container_queries' },
  { name: 'Fluid Typography', aliases: ['responsive text', 'clamp font'], category: 'responsive', description: 'Font sizes scale smoothly between breakpoints using clamp(min, preferred, max). Never use raw vw units alone for text.', shadcn: null, docsUrl: null },
  { name: 'Touch Target Sizing', aliases: ['tap target', 'touch area'], category: 'responsive', description: 'All interactive elements must be at least 44\u00d744px with 8px gaps between adjacent targets (WCAG 2.5.8).', shadcn: null, docsUrl: 'https://www.w3.org/WAI/WCAG21/Understanding/target-size.html' },
  { name: 'Responsive Images', aliases: ['srcset', 'picture element', 'lazy images'], category: 'responsive', description: 'Use srcset + sizes for resolution switching, <picture> for art direction, loading="lazy" for below-fold, and aspect-ratio to prevent layout shift.', shadcn: null, docsUrl: 'https://developer.mozilla.org/en-US/docs/Learn/HTML/Multimedia_and_embedding/Responsive_images' },
  { name: 'Responsive Navigation', aliases: ['mobile nav', 'bottom tab bar'], category: 'responsive', description: 'Desktop: persistent top bar or sidebar. Mobile: bottom tab bar (3\u20145 items) or hamburger menu. Never hide-only on desktop.', shadcn: null, docsUrl: null },
  { name: 'Logical Properties', aliases: ['inline-start', 'block-end', 'RTL support'], category: 'responsive', description: 'Use margin-inline, padding-block, border-inline-start instead of physical directions. Automatically adapts to RTL and vertical writing modes.', shadcn: null, docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_logical_properties_and_values' },

  // --- Error Handling ---
  { name: 'Error Boundary', aliases: ['error catching', 'fallback UI'], category: 'error', description: 'Component-level error catching with fallback UI, error logging, and reset/retry actions. Prevents a single broken component from crashing the page.', shadcn: null, docsUrl: 'https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary' },
  { name: 'Retry Pattern', aliases: ['exponential backoff', 'auto-retry'], category: 'error', description: 'Retry failed network requests with exponential backoff (1s \u2192 2s \u2192 4s). Show a retry button after max attempts. Never retry indefinitely.', shadcn: null, docsUrl: null },
  { name: 'Offline Indicator', aliases: ['connectivity status', 'offline banner'], category: 'error', description: 'Detect offline status and show a persistent banner. Serve cached content via service worker. Queue mutations for sync-on-reconnect.', shadcn: null, docsUrl: null },
  { name: 'Custom 404', aliases: ['not found page', 'missing page'], category: 'error', description: 'Friendly 404 page with search bar, popular links, and a clear path home. Never show a raw server error page.', shadcn: null, docsUrl: null },
  { name: 'Custom 500', aliases: ['server error page', 'internal error'], category: 'error', description: 'Apologetic 500 page with retry button and status page link. Log the error server-side. Show a reference ID for support.', shadcn: null, docsUrl: null },
  { name: 'Empty State \u2014 First Use', aliases: ['first run empty', 'welcome state'], category: 'error', description: 'When there is no data yet: show an illustration, explain what will appear here, and provide a primary CTA to create the first item.', shadcn: null, docsUrl: null },
  { name: 'Empty State \u2014 No Results', aliases: ['no matches', 'search empty'], category: 'error', description: 'When a search or filter returns nothing: show the query, suggest alternatives, and offer a way to clear filters.', shadcn: null, docsUrl: null },
  { name: 'Network Error Toast', aliases: ['API error notification', 'connection error'], category: 'error', description: 'Non-blocking toast for transient network errors with a retry action. For persistent failures, escalate to a full-page error state.', shadcn: null, docsUrl: null },
];
