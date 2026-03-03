export interface UIPattern {
  name: string;
  aliases: string[];
  category: 'input' | 'data' | 'navigation' | 'feedback' | 'overlay' | 'layout' | 'interaction' | 'keyboard';
  description: string;
  shadcn: string | null;
  docsUrl: string | null;
}

export const categoryLabels: Record<UIPattern['category'], string> = {
  input: 'Collecting User Input',
  data: 'Displaying Data',
  navigation: 'Navigation',
  feedback: 'Feedback & Status',
  overlay: 'Overlays & Modals',
  layout: 'Layout',
  interaction: 'Interaction & Performance Patterns',
  keyboard: 'Keyboard & Focus Patterns',
};

export const categoryOrder: UIPattern['category'][] = [
  'input', 'data', 'navigation', 'feedback', 'overlay', 'layout', 'interaction', 'keyboard',
];

export const uiPatterns: UIPattern[] = [
  // --- Collecting User Input ---
  { name: 'Button', aliases: ['action', 'CTA', 'submit button'], category: 'input', description: 'A clickable element that triggers an action. Use for primary actions, form submissions, and confirmations.', shadcn: 'button', docsUrl: 'https://ui.shadcn.com/docs/components/button' },
  { name: 'Checkbox', aliases: ['tick box', 'multi-select option'], category: 'input', description: 'A box you tick to turn an option on or off. Use for multiple selections from a list or boolean toggles.', shadcn: 'checkbox', docsUrl: 'https://ui.shadcn.com/docs/components/checkbox' },
  { name: 'Combobox', aliases: ['autocomplete', 'type-ahead', 'searchable dropdown'], category: 'input', description: 'A search box that filters and suggests options as you type. Use for selecting from large lists (10+ items) like countries or tags.', shadcn: 'command + popover', docsUrl: 'https://ui.shadcn.com/docs/components/combobox' },
  { name: 'Date Picker', aliases: ['calendar input', 'date selector'], category: 'input', description: 'A calendar popup for picking dates. Use for date selection, date ranges, and scheduling.', shadcn: 'calendar + popover', docsUrl: 'https://ui.shadcn.com/docs/components/date-picker' },
  { name: 'Form', aliases: ['input form', 'data entry'], category: 'input', description: 'A group of fields the user fills in and submits. The foundation for any structured data collection.', shadcn: 'form', docsUrl: 'https://ui.shadcn.com/docs/components/form' },
  { name: 'Input', aliases: ['text field', 'text box'], category: 'input', description: 'A text field where users type short text like names, emails, or search queries.', shadcn: 'input', docsUrl: 'https://ui.shadcn.com/docs/components/input' },
  { name: 'Input OTP', aliases: ['verification code', 'PIN input'], category: 'input', description: 'Separate boxes for entering a verification code. Auto-advances on digit entry and supports paste.', shadcn: 'input-otp', docsUrl: 'https://ui.shadcn.com/docs/components/input-otp' },
  { name: 'Label', aliases: ['field label', 'input label'], category: 'input', description: 'Text that describes what a form field is for. Every input must have one.', shadcn: 'label', docsUrl: 'https://ui.shadcn.com/docs/components/label' },
  { name: 'Radio Group', aliases: ['single select', 'option picker'], category: 'input', description: 'A set of options where you pick exactly one. Use for mutually exclusive choices with 2\u20135 visible options.', shadcn: 'radio-group', docsUrl: 'https://ui.shadcn.com/docs/components/radio-group' },
  { name: 'Select', aliases: ['dropdown', 'picker', 'select box'], category: 'input', description: 'A dropdown list for picking one option from 3\u201310 choices where space is limited.', shadcn: 'select', docsUrl: 'https://ui.shadcn.com/docs/components/select' },
  { name: 'Slider', aliases: ['range slider', 'range input'], category: 'input', description: 'A draggable handle for picking a value within a range, like price or volume.', shadcn: 'slider', docsUrl: 'https://ui.shadcn.com/docs/components/slider' },
  { name: 'Switch', aliases: ['toggle', 'on/off switch'], category: 'input', description: 'An on/off toggle that takes effect immediately. Use for settings like dark mode or notifications.', shadcn: 'switch', docsUrl: 'https://ui.shadcn.com/docs/components/switch' },
  { name: 'Textarea', aliases: ['text area', 'message box'], category: 'input', description: 'A larger text box for writing longer content like descriptions, comments, or messages.', shadcn: 'textarea', docsUrl: 'https://ui.shadcn.com/docs/components/textarea' },
  { name: 'Toggle', aliases: ['toggle button', 'pressed button'], category: 'input', description: 'A button that stays pressed or released. Use for formatting tools like bold/italic or view mode switching.', shadcn: 'toggle', docsUrl: 'https://ui.shadcn.com/docs/components/toggle' },
  { name: 'Toggle Group', aliases: ['button group', 'segmented control'], category: 'input', description: 'A row of buttons where you pick one (or multiple). Use for view switchers or filter groups.', shadcn: 'toggle-group', docsUrl: 'https://ui.shadcn.com/docs/components/toggle-group' },
  { name: 'File Upload', aliases: ['file picker', 'drag and drop'], category: 'input', description: 'A button or drop zone for uploading files. Always provide a button alternative alongside drag-and-drop.', shadcn: null, docsUrl: null },

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
];
