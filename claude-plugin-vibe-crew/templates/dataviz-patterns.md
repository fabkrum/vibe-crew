# Data Visualization Pattern Reference

Agent-facing reference for data visualization, chart selection, and dashboard composition decisions. The Builder reads this during the Design Phase; the Code Reviewer checks compliance during review.
**Principle:** Every chart must tell a story, provide a data table alternative for accessibility, and never rely on color alone to convey meaning.

## 1. Chart Types

### Line Chart
- **When:** Showing trends over continuous intervals (time series). X-axis is ordered (dates, sequential steps).
- **What:** Use LineChart with Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend. For multiple series, use distinct stroke colors from design tokens.
- **A11y:** Data table alternative via toggle. `aria-label` on container describing the trend. Add point markers or dashed/solid line styles per series — never color alone.

### Bar Chart
- **When:** Comparing discrete categories. The easiest chart type for users to interpret (NN/G).
- **What:** Vertical for categories, horizontal when labels exceed 8 characters. Add value labels on bars for small datasets (<10 bars).
- **A11y:** Each bar focusable with `aria-label` including category and value. Data table alternative. Minimum bar color contrast 3:1 against background.

### Area Chart
- **When:** Emphasizing volume or cumulative totals over time. Stacked areas show part-to-whole.
- **What:** Use gradient fills (opacity 0.3 to 0) for depth. Limit to 4 stacked series for readability.
- **A11y:** Stacked areas are hard for colorblind users — provide toggle to un-stack. Data table alternative. Label each area with visible legend.

### Pie & Donut Chart
- **When:** Part-to-whole relationships. Limit to 5-6 slices — users struggle comparing similar angles. Always sort by size.
- **What:** Place primary KPI in donut center. Group small slices (<5%) into "Other". Use direct labels not just legend.
- **A11y:** Data table alternative (pie charts are hardest for screen readers). Use patterns (stripes, dots) in addition to color.
- **Anti-pattern:** Never use more than 6 slices. Never rely on legend-only labeling.

### Scatter Plot
- **When:** Exploring relationships between two quantitative variables. Reveals correlations, clusters, outliers.
- **What:** Add reference lines for averages. Use color for a third dimension. ZAxis for bubble size.
- **A11y:** Announce data count and visible pattern ("120 points, positive correlation"). Each point focusable with tooltip. Tabular alternative.

### Heatmap
- **When:** Showing magnitude across two categorical dimensions (time-of-day activity, correlation matrices).
- **What:** CSS Grid of colored cells or D3.js. Sequential color scale (white to blue). Show value on hover. Color legend with min/max.
- **A11y:** Show values on hover and in data table. `aria-label` per cell: "Monday 9am: 42 requests". High-contrast mode with pattern fills.
- **Anti-pattern:** Never rely on color alone without visible values on interaction.

### Sparkline
- **When:** Tiny inline trend context in table cells, KPI cards, or text. Shows direction, not precise values.
- **What:** LineChart with no axes, grid, or tooltip. Height 24-32px. Color final point green/red for trend direction.
- **A11y:** `aria-label` describing trend: "Revenue: up 12% over 7 days". Actual value must be available as text nearby.

### Gauge / Radial Chart
- **When:** Single value against a known min/max (CPU usage, goal progress). Limit to one per card.
- **What:** RadialBarChart or custom SVG arc. Numeric value in center. Color zones: green (good), yellow (warning), red (critical).
- **A11y:** Numeric value as visible text — arc is supplementary. `aria-label="CPU usage: 73%"`. Add text labels ("Good", "Warning") not just color.

### Funnel Chart
- **When:** Progressive reduction through sequential stages (conversion funnels, sales pipelines).
- **What:** Show both count and percentage drop-off per stage. Color dark to light. Connector labels for stage-to-stage conversion.
- **A11y:** Label each stage with name, count, and conversion rate. Table alternative. `aria-label` on container summarizing the funnel.

### Treemap
- **When:** Hierarchical part-to-whole (file usage, budget allocation, portfolios).
- **What:** Label rectangles directly — legends fail with many categories. Use color for secondary dimension. D3.js for drill-down.
- **A11y:** `aria-label` per rectangle with category and value. Breadcrumb for drill-down. Flat table alternative. Minimum touch target 44x44px.

### Sankey Diagram
- **When:** Flow distribution from source to destination (user journeys, budget flows). Reveals leakage and dominant paths.
- **What:** Nodes in columns, curved path links. Color links by source/destination. Limit to 15-20 nodes.
- **A11y:** Flow table alternative: Source, Destination, Quantity. Each link focusable. `aria-label` summarizing flow.

### KPI Card
- **When:** Showing a single critical metric with trend. The most common dashboard element. Place 3-5 at dashboard top.
- **What:** Large number + label + delta (absolute or %) + trend arrow + optional sparkline.
- **A11y:** Heading + value structure. Trend via text ("up 12%") not just arrow color. `aria-live="polite"` if real-time.

## 2. Dashboard Composition

### Dashboard Grid Layout
- **When:** Arranging charts and KPIs on a dashboard.
- **What:** 12-column CSS Grid. Most important metrics top-left (F-pattern). Full-width charts on top, smaller cards in 2-3 column rows. Gap 1rem. Limit to 5-9 visible widgets.
- **A11y:** Landmark `<main>` for dashboard, headings per section. Tab order matches visual layout. Skip links to major sections.
- **Anti-pattern:** Never exceed 9 widgets visible without scrolling.

### Dashboard Header with Global Filters
- **When:** Multiple charts share date range and filter controls.
- **What:** Sticky bar with DatePickerWithRange + Select/Combobox. Store filter state in URL params. Show "Last updated" timestamp.
- **A11y:** `<nav aria-label="Dashboard filters">`. Announce filter changes with `aria-live`. Keyboard-accessible date picker.

### Chart Card with Header
- **When:** Every chart on a dashboard.
- **What:** Card > CardHeader (title + description + action buttons) > CardContent (chart). DropdownMenu for per-chart actions (export, expand, refresh).
- **A11y:** Title in appropriate heading level. Chart container `role="img"` with `aria-label` summarizing data. Action buttons have descriptive labels.

### Tabbed Dashboard Views
- **When:** Dashboard has multiple logical sections (Overview, Revenue, Users, Performance).
- **What:** Tabs with lazy-loaded chart data per tab. Overview shows top 5-7 KPIs; detail tabs show full charts. Persist active tab in URL.
- **A11y:** Standard tab pattern: `role="tablist"`, `role="tab"` with `aria-selected`, `role="tabpanel"` with `aria-labelledby`. Arrow keys between tabs.

### Comparison Layout
- **When:** Comparing two periods, segments, or scenarios side-by-side.
- **What:** Overlay on same axes when scales match (solid vs dashed); side-by-side when scales differ.
- **A11y:** Legend must clearly distinguish series. Line styles differ (solid vs dashed) — not just color. `aria-label` states comparison.

### Empty Dashboard State
- **When:** No data available (new user, empty date range, disconnected source).
- **What:** Illustration + message + CTA. For new users, show sample data with "This is sample data" banner. Never show blank charts.
- **A11y:** Message in chart region for screen readers. `role="status"` for dynamic empty states when filters produce no data.
- **Anti-pattern:** Never show empty chart containers with no explanation.

## 3. Chart Interaction

### Tooltip on Hover
- **When:** Users need precise values from chart data points.
- **What:** Floating card with formatted values and units. Shared tooltip for line/area charts (all series at hovered x-position).
- **A11y:** Must appear on keyboard focus, not just hover. `aria-describedby` linking data points to tooltip. Tooltip must not obscure data.

### Crosshair
- **When:** Multi-series line charts where tracking position across series matters.
- **What:** Vertical reference line following cursor, snapping to nearest data point. Dot on each line at intersection.
- **A11y:** Visual enhancement only — underlying tooltip provides value info via keyboard.

### Brush / Range Selection
- **When:** Large time series where users need to zoom into a sub-range.
- **What:** Draggable range selector below main chart with mini area chart for context. Reset button for full range.
- **A11y:** Handles keyboard-operable (arrow keys to move, Shift+Arrow to resize). Announce selected range. Date inputs as alternative.

### Drill-Down
- **When:** Chart element leads to a detailed breakdown (click bar for sub-categories, time period to zoom).
- **What:** onClick on chart elements. Breadcrumb for back navigation. Animate transition. Overview first, details on demand (Shneiderman's mantra).
- **A11y:** Clickable elements need `role="button"` or actual `<button>`. Announce drill-down context. Keyboard-accessible breadcrumb.

### Chart Legend
- **When:** Multi-series charts need a labeled key mapping colors/patterns to series.
- **What:** Interactive legend toggling series visibility. Hidden series grayed-out. Below chart on mobile, right on desktop.
- **A11y:** Items keyboard-focusable, toggle via Enter/Space. Announce "series hidden/shown". Use patterns + color, not color alone.

### Chart Annotations
- **When:** Notable events need context on the chart (launches, outages, promotions).
- **What:** ReferenceLine, ReferenceArea, ReferenceDot with labels at relevant coordinates. Distinct annotation color. Detail on hover.
- **A11y:** Text label accessible to screen readers. `aria-label` on markers. Include annotations in data table alternative.

### Chart Export
- **When:** Users need raw data or chart images for their own analysis.
- **What:** DropdownMenu in chart card header: "Download CSV", "Download PNG". CSV from data array; PNG via html2canvas or svg-to-image.
- **A11y:** `aria-label="Export chart data"`. Announce "Download started" via `aria-live`.

## 4. Accessibility

### Data Table Alternative
- **When:** Every chart, without exception.
- **What:** "View as table" toggle above each chart. Proper `<table>` with `<thead>`, `<th>`, `<td>`. Sortable via DataTable.
- **A11y:** `<caption>` describing data. `scope="col"` and `scope="row"` on headers. Table must contain all chart information including annotation notes.
- **Anti-pattern:** Never ship a chart without a table alternative.

### Color-Blind Safe Palettes
- **When:** Every chart using color to distinguish series or categories.
- **What:** Vetted palette: blue, orange, teal, purple, pink (avoid pure red+green). Add line patterns (solid, dashed, dotted) and point shapes (circle, square, triangle).
- **A11y:** WCAG 1.4.1: color is not the sole means of conveying information. Every color-coded element needs a secondary differentiator. Test with Sim Daltonism.
- **Anti-pattern:** Never use red/green as the only distinction between series.

### Chart Container ARIA
- **When:** Every chart wrapper.
- **What:** `<figure role="img" aria-label="[chart type] showing [metric] from [range], [key insight]">` with `<figcaption>`.
- **A11y:** Include chart type, what is measured, time range, and key insight. Under 150 characters. Long descriptions in `aria-describedby` linked to `<details>`.

### Keyboard-Navigable Data Points
- **When:** Charts with interactive data points.
- **What:** `tabIndex` on data point SVG elements. Arrow keys between points. Tooltip on focus (same as hover).
- **A11y:** Each point: `aria-label` with series name, category, and value. Escape exits chart navigation.

### High Contrast Mode
- **When:** Supporting low-vision users.
- **What:** Detect `prefers-contrast: more`. Increase stroke-width (1.5 to 3), font-size, pattern fills via SVG `<defs>`. Support `forced-colors` for Windows High Contrast.
- **A11y:** WCAG 1.4.11: non-text contrast 3:1 minimum; high-contrast mode 4.5:1. Axis labels and tick marks must remain visible.

### Sonification
- **When:** Providing audio alternative for blind users to perceive trends and outliers.
- **What:** Web Audio API: y-values map to pitch, x-axis to time. Play/pause/speed controls. "Listen to chart" button.
- **A11y:** Announce start/end of playback. Supplements but does not replace the data table.

## 5. Real-Time & Streaming

### Live-Updating Chart
- **When:** Monitoring dashboards (server metrics, stock prices, IoT sensors).
- **What:** WebSocket or EventSource. Append new points, remove oldest for fixed window. requestAnimationFrame for animation. Limit to 1-2 Hz updates.
- **A11y:** Announce only threshold crossings, not every update. Provide "Pause updates" button.
- **Anti-pattern:** Never update faster than 2 Hz visually — causes jank and overwhelms screen readers.

### Threshold Alerts
- **When:** Values have warning and critical boundaries on monitoring charts.
- **What:** ReferenceLine at y-threshold with label. ReferenceArea for zone coloring. Change element color on breach. Pulse animation.
- **A11y:** `aria-live="assertive"` for threshold crossings. Threshold lines labeled with text, not just color.

### Auto-Refresh with Indicator
- **When:** Dashboard data refreshes on a timer (30s, 1m, 5m).
- **What:** "Updated 30s ago" with countdown. Refresh button. Store preference in localStorage. Toggle for auto-refresh.
- **A11y:** Minimum 30s refresh interval to avoid disrupting screen readers. "Last updated" in `aria-live="polite"`. Pause option.

### Streaming Data Buffer
- **When:** High-frequency data (100 Hz) needs batching for smooth rendering.
- **What:** Collect events in array, flush to chart at 500ms intervals or per animation frame. Web Worker for heavy aggregation. Pulsing "live" indicator.
- **A11y:** "Live" indicator needs `aria-label="Receiving live data"`.

### Time Window Selector
- **When:** Time-series dashboards need quick range switching.
- **What:** ToggleGroup: "1h", "6h", "24h", "7d", "30d", "Custom". Custom opens DatePickerWithRange. Store in URL params. Place in dashboard header.
- **A11y:** `role="radiogroup"` with `aria-label="Time range"`. Each option `role="radio"` with `aria-checked`. Announce selection.

### Sparkline in Table Cell
- **When:** Inline trend visualization inside data table rows.
- **What:** Minimal LineChart (no axes/tooltip) at 80x24px in `<td>`. Green for uptrend, red for downtrend. Pair with numeric value in adjacent cell.
- **A11y:** Sparkline is decorative: `aria-hidden="true"`. Trend direction in cell `aria-label` if meaningful.

## 6. Responsive & Mobile

### Responsive Chart Container
- **When:** Every chart.
- **What:** ResponsiveContainer (width="100%" height={300}). CSS aspect-ratio for preservation. Debounce resize events. Never fixed pixel widths.
- **A11y:** Labels and legends readable at all sizes. If chart becomes too small, show data table instead.
- **Anti-pattern:** Never use fixed pixel widths on charts.

### Axis Label Rotation
- **When:** X-axis labels overlap at smaller widths.
- **What:** Rotate 45 or 90 degrees only when overlap detected. Alternative: truncate with ellipsis, full label in tooltip. Prefer horizontal when space permits.
- **A11y:** Minimum font size 11px even when rotated. Full label text in DOM regardless of visual rotation.

### Mobile Chart Simplification
- **When:** Charts displayed on mobile screens.
- **What:** Downsample data (weekly instead of daily). Hide secondary axes. Increase tick spacing. Top 5 bars only. Horizontal scroll with snap for dense charts.
- **A11y:** Touch targets minimum 44x44px. Tooltip triggered by tap. Swipe must not conflict with page scrolling.

### Chart Skeleton Loading
- **When:** Chart data is loading.
- **What:** Placeholder SVG/div matching chart dimensions with animated pulse. Fade transition to real chart.
- **A11y:** `aria-busy="true"` while loading. `aria-label="Loading chart data"`. Remove `aria-busy` on load. No `aria-live` for loading state.
- **Anti-pattern:** Never show a blank space or generic spinner — use a chart-shaped skeleton.

### Stacked-to-Scrollable Layout
- **When:** Multiple charts on one page across screen sizes.
- **What:** CSS Grid with `auto-fill, minmax(320px, 1fr)`. Below 320px per chart, single column. Swipeable tab panels on mobile. Scroll snap for carousels.
- **A11y:** Scroll containers need `role="region"` with `aria-label`. Visual scroll indicators. All charts reachable via keyboard.

### Print-Optimized Charts
- **When:** Users print dashboards for meetings and reports.
- **What:** `@media print`: white background, increased stroke contrast, visible data labels, expanded legends, removed hover-only elements. SVG for crisp printing.
- **A11y:** Print output includes all interactive information (annotations as inline labels, tooltips as visible labels). Titles and legends visible.

## Builder Agent Key Principles

1. **Every chart gets a data table** — toggle between chart and table view, no exceptions.
2. **Never color alone** — use patterns, shapes, or line styles as secondary differentiators.
3. **Chart container ARIA** — `role="img"` with `aria-label` stating chart type, metric, range, and insight.
4. **5-9 widgets max** — limit visible dashboard widgets to prevent cognitive overload.
5. **KPIs at the top** — place 3-5 KPI cards in the F-pattern scanning zone (top-left).
6. **Responsive containers only** — never fixed pixel widths, always ResponsiveContainer.
7. **Tooltips on focus** — not just hover; keyboard users need the same data access.
8. **Threshold alerts are assertive** — use `aria-live="assertive"` only for threshold crossings, not routine updates.
