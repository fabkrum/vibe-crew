# Research: UX/UI Design Systems for AI-Assisted Development

> **Phase 1 Research** | Document 07 | February 2026
>
> This document covers the creation and maintenance of programmatic design systems for AI-assisted development. It addresses design tokens as CSS custom properties, color system generation, typography scales, spacing systems, component library strategy, reference site extraction, Google Stitch MCP integration, accessible color systems, and design system maintenance -- all critical for a system like VibeOS where an AI agent (UI Designer, Sonnet model) generates and maintains `design-system.css` autonomously.

---

## Table of Contents

1. [Creating and Maintaining a Design System Programmatically](#1-creating-and-maintaining-a-design-system-programmatically)
2. [Color System Design](#2-color-system-design)
3. [Typography Scale](#3-typography-scale)
4. [Spacing and Layout System](#4-spacing-and-layout-system)
5. [Component Library Strategy](#5-component-library-strategy)
6. [Extracting Design Patterns from Reference Websites](#6-extracting-design-patterns-from-reference-websites)
7. [Google Stitch MCP Capabilities](#7-google-stitch-mcp-capabilities)
8. [Accessible Color Systems](#8-accessible-color-systems)
9. [Design System Maintenance](#9-design-system-maintenance)
10. [Recommendations for VibeOS](#10-recommendations-for-vibeos)
11. [Sources](#11-sources)

---

## 1. Creating and Maintaining a Design System Programmatically

### 1.1 Design Tokens as CSS Custom Properties

Design tokens are the atomic values of a design system -- colors, type sizes, spacing, radii, shadows, and breakpoints -- expressed as platform-agnostic variables. CSS custom properties (CSS variables) are the ideal implementation layer for AI-generated design systems because they are:

- **Runtime-mutable**: Can be changed via JavaScript or media queries without a rebuild
- **Cascade-aware**: Naturally scope to components or themes via CSS selectors
- **Zero-dependency**: No build tool, preprocessor, or library required
- **Framework-agnostic**: Work with React, Vue, Svelte, plain HTML, or any future framework
- **Inspectable**: Visible in browser DevTools for debugging

The foundational structure is a `:root` block declaring all tokens:

```css
:root {
  /* Color tokens */
  --color-primary: hsl(221 83% 53%);
  --color-primary-foreground: hsl(210 40% 98%);

  /* Spacing tokens */
  --spacing-1: 0.25rem;   /* 4px */
  --spacing-2: 0.5rem;    /* 8px */
  --spacing-4: 1rem;      /* 16px */

  /* Typography tokens */
  --font-size-base: 1rem; /* 16px */
  --font-weight-bold: 700;

  /* Radius tokens */
  --radius-md: 0.375rem;  /* 6px */

  /* Shadow tokens */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
}
```

### 1.2 Token Categories

A complete design system for a SaaS application needs tokens in these categories:

| Category | Purpose | Example Tokens |
|----------|---------|----------------|
| **Colors** | Brand, semantic, and neutral palettes | `--color-primary`, `--color-destructive`, `--color-neutral-200` |
| **Typography** | Font families, sizes, weights, line heights, letter spacing | `--font-size-lg`, `--font-weight-semibold`, `--leading-normal` |
| **Spacing** | Margins, paddings, gaps | `--spacing-4`, `--spacing-8` |
| **Radii** | Border radius values | `--radius-sm`, `--radius-lg`, `--radius-full` |
| **Shadows** | Elevation and depth | `--shadow-md`, `--shadow-xl` |
| **Breakpoints** | Responsive design thresholds | `--breakpoint-sm: 640px`, `--breakpoint-lg: 1024px` |
| **Transitions** | Durations, timing functions | `--duration-fast: 150ms`, `--ease-default` |

### 1.3 Token Naming Conventions: Semantic vs Primitive

Design tokens use a two-tier naming strategy. **Primitive tokens** describe the raw value. **Semantic tokens** describe the purpose. Semantic tokens reference primitive tokens, creating an indirection layer that enables theming.

**Primitive tokens** (the palette -- never referenced directly in components):

```css
:root {
  /* Primitive: describes the value itself */
  --blue-50:  hsl(214 100% 97%);
  --blue-100: hsl(214 95% 93%);
  --blue-200: hsl(213 97% 87%);
  --blue-300: hsl(212 96% 78%);
  --blue-400: hsl(213 94% 68%);
  --blue-500: hsl(217 91% 60%);
  --blue-600: hsl(221 83% 53%);
  --blue-700: hsl(224 76% 48%);
  --blue-800: hsl(226 71% 40%);
  --blue-900: hsl(224 64% 33%);
  --blue-950: hsl(226 57% 21%);

  --space-1: 0.25rem;   /* 4px */
  --space-2: 0.5rem;    /* 8px */
  --space-4: 1rem;      /* 16px */
}
```

**Semantic tokens** (the intention -- used in components):

```css
:root {
  /* Semantic: describes the purpose */
  --color-primary: var(--blue-600);
  --color-primary-foreground: var(--blue-50);
  --color-background: hsl(0 0% 100%);
  --color-foreground: hsl(222 47% 11%);
  --color-muted: hsl(210 40% 96%);
  --color-muted-foreground: hsl(215 16% 47%);
  --color-border: hsl(214 32% 91%);
  --color-destructive: hsl(0 84% 60%);
  --color-success: hsl(142 76% 36%);

  --spacing-md: var(--space-4);
  --radius: var(--radius-md);
}
```

**Why semantic tokens are preferred for AI workflows**:

1. **Intent clarity**: An AI agent reading `bg-primary` understands "this is the main brand action color" without needing to know the hex value.
2. **Theme safety**: Changing the brand from blue to green requires editing one line (`--color-primary: var(--green-600)`) instead of finding every `blue-600` reference.
3. **Dark mode**: The same component code works in both themes because semantic tokens get reassigned under a `.dark` class, while the component never changes.
4. **Reduced hallucination**: AI agents are less likely to invent arbitrary color values when the design system provides clear semantic names.

### 1.4 Design System as a Single CSS File vs Design Token JSON

There are two common formats for storing design tokens:

**Option A: Single CSS file (`design-system.css`)**

```css
/* design-system.css — the single source of truth */
:root {
  --color-primary: hsl(221 83% 53%);
  --color-primary-foreground: hsl(210 40% 98%);
  /* ... all tokens ... */
}

.dark {
  --color-primary: hsl(213 94% 68%);
  --color-primary-foreground: hsl(222 47% 11%);
  /* ... dark overrides ... */
}
```

**Option B: Design Token JSON (W3C Design Token Community Group format)**

```json
{
  "$name": "Project Design Tokens",
  "color": {
    "primary": {
      "$value": "{color.blue.600}",
      "$type": "color",
      "$description": "Primary brand color for interactive elements"
    },
    "blue": {
      "600": {
        "$value": "hsl(221 83% 53%)",
        "$type": "color"
      }
    }
  },
  "spacing": {
    "4": {
      "$value": "16px",
      "$type": "dimension"
    }
  }
}
```

**Recommendation for VibeOS**: Use the CSS file as the single source of truth. The CSS file is directly consumable by the browser, requires no build step, and is simpler for the AI agent to read and modify. JSON token files add value only when you need multi-platform output (iOS, Android, Figma) -- which is outside VibeOS scope.

### 1.5 Tailwind CSS v4 Integration with Custom Properties

Tailwind CSS v4 (released in early 2025) introduced a CSS-first configuration model that aligns naturally with design token systems. Configuration moves from `tailwind.config.js` into CSS using the `@theme` directive:

```css
/* app.css — Tailwind v4 configuration */
@import "tailwindcss";

@theme {
  /* Colors: these generate utility classes like bg-primary, text-primary */
  --color-primary: hsl(221 83% 53%);
  --color-primary-foreground: hsl(210 40% 98%);
  --color-secondary: hsl(210 40% 96%);
  --color-secondary-foreground: hsl(222 47% 11%);
  --color-destructive: hsl(0 84% 60%);
  --color-destructive-foreground: hsl(210 40% 98%);
  --color-success: hsl(142 76% 36%);
  --color-success-foreground: hsl(210 40% 98%);
  --color-warning: hsl(38 92% 50%);
  --color-warning-foreground: hsl(222 47% 11%);
  --color-background: hsl(0 0% 100%);
  --color-foreground: hsl(222 47% 11%);
  --color-card: hsl(0 0% 100%);
  --color-card-foreground: hsl(222 47% 11%);
  --color-muted: hsl(210 40% 96%);
  --color-muted-foreground: hsl(215 16% 47%);
  --color-border: hsl(214 32% 91%);
  --color-input: hsl(214 32% 91%);
  --color-ring: hsl(221 83% 53%);

  /* Spacing */
  --spacing-0-5: 2px;
  --spacing-1: 4px;
  --spacing-1-5: 6px;
  --spacing-2: 8px;
  --spacing-3: 12px;
  --spacing-4: 16px;
  --spacing-5: 20px;
  --spacing-6: 24px;
  --spacing-8: 32px;
  --spacing-10: 40px;
  --spacing-12: 48px;
  --spacing-16: 64px;
  --spacing-20: 80px;
  --spacing-24: 96px;

  /* Border radius */
  --radius-sm: 4px;
  --radius-md: 6px;
  --radius-lg: 8px;
  --radius-xl: 12px;
  --radius-2xl: 16px;

  /* Font families */
  --font-sans: "Inter", system-ui, sans-serif;
  --font-mono: "JetBrains Mono", ui-monospace, monospace;
}
```

Key Tailwind v4 changes relevant to VibeOS:

- **No `tailwind.config.js`**: All configuration lives in CSS
- **CSS custom properties are first-class**: Every `@theme` value becomes a CSS variable and generates corresponding utility classes
- **Lightning CSS engine**: Significantly faster builds
- **Automatic content detection**: No more configuring `content` paths manually

For projects still on Tailwind v3, the integration uses `tailwind.config.ts` with `hsl(var(--token-name))` wrappers in the `theme.extend.colors` block.

### 1.6 How the UI Designer Agent Generates the Design System

The VibeOS UI Designer agent follows a five-step pipeline to generate `design-system.css` from minimal user input during Tier 1:

**Step 1: Gather user preferences**

The agent asks the user for:
- Brand color (a single hex value is sufficient; optional -- AI can suggest one from the project description)
- Font preference (system fonts, Inter, Geist, or other)
- Border radius preference (sharp, slightly rounded, rounded, pill)
- Density preference (compact, comfortable, spacious)

**Step 2: Generate full color palette from primary color (HSL manipulation)**

```
Input: #2563EB (blue-600)
Convert to HSL: hsl(221, 83%, 53%)

Generate 11 shades by varying lightness:
  shade 50:  hsl(221, 100%, 97%)  — lightest tint
  shade 100: hsl(221, 95%, 93%)
  shade 200: hsl(221, 97%, 87%)
  shade 300: hsl(221, 96%, 78%)
  shade 400: hsl(221, 94%, 68%)
  shade 500: hsl(221, 91%, 60%)  — base (slightly lighter than input)
  shade 600: hsl(221, 83%, 53%)  — input color
  shade 700: hsl(221, 76%, 48%)
  shade 800: hsl(221, 71%, 40%)
  shade 900: hsl(221, 64%, 33%)
  shade 950: hsl(221, 57%, 21%)  — darkest shade

Algorithm:
  - Keep hue constant (221 in this example)
  - Increase saturation at lighter shades, decrease at darker shades
  - Distribute lightness from ~97% (shade 50) to ~21% (shade 950)
  - The exact distribution follows Tailwind CSS palette curves
```

**Step 3: Create typography scale (modular scale, 1.25 ratio)**

```
Base: 16px (1rem)
Scale ratio: 1.25 (Major Third)

text-xs:   16 / 1.25 / 1.25 = 10.24px  -> round to 0.75rem  (12px)
text-sm:   16 / 1.25         = 12.8px   -> round to 0.875rem (14px)
text-base: 16px              = 16px     -> 1rem               (16px)
text-lg:   16 * 1.25         = 20px     -> 1.125rem           (18px)
text-xl:   16 * 1.25^2       = 25px     -> 1.25rem            (20px)
text-2xl:  16 * 1.25^3       = 31.25px  -> 1.5rem             (24px)
text-3xl:  16 * 1.25^4       = 39.06px  -> 1.875rem           (30px)
text-4xl:  16 * 1.25^5       = 48.83px  -> 2.25rem            (36px)
text-5xl:  16 * 1.25^6       = 61.04px  -> 3rem               (48px)
```

**Step 4: Define spacing scale (4px base unit)**

```
Spacing scale using 4px base:
  --spacing-0:    0px       (0rem)
  --spacing-0-5:  2px       (0.125rem)
  --spacing-1:    4px       (0.25rem)
  --spacing-1-5:  6px       (0.375rem)
  --spacing-2:    8px       (0.5rem)
  --spacing-3:    12px      (0.75rem)
  --spacing-4:    16px      (1rem)
  --spacing-5:    20px      (1.25rem)
  --spacing-6:    24px      (1.5rem)
  --spacing-8:    32px      (2rem)
  --spacing-10:   40px      (2.5rem)
  --spacing-12:   48px      (3rem)
  --spacing-16:   64px      (4rem)
  --spacing-20:   80px      (5rem)
  --spacing-24:   96px      (6rem)
```

**Step 5: Output as `design-system.css`**

The agent assembles all tokens into a single CSS file with three layers:
1. Primitive tokens (the raw palette and scales)
2. Semantic tokens (light mode mappings)
3. Dark mode overrides (`.dark` class)

The complete output is described in Section 1.7.

### 1.7 Complete `design-system.css` Template

This is the reference template that the UI Designer agent generates:

```css
/* ================================================================
   design-system.css
   Generated by VibeOS UI Designer Agent
   Single source of truth for all design tokens.
   ================================================================ */

/* ============================================
   LAYER 1: Primitive Tokens (raw values)
   Never use directly in components.
   ============================================ */
:root {
  /* --- Color Palette (HSL, space-separated for opacity support) --- */
  --blue-50:  214 100% 97%;
  --blue-100: 214 95% 93%;
  --blue-200: 213 97% 87%;
  --blue-300: 212 96% 78%;
  --blue-400: 213 94% 68%;
  --blue-500: 217 91% 60%;
  --blue-600: 221 83% 53%;
  --blue-700: 224 76% 48%;
  --blue-800: 226 71% 40%;
  --blue-900: 224 64% 33%;
  --blue-950: 226 57% 21%;

  --neutral-0:   0 0% 100%;
  --neutral-50:  210 40% 98%;
  --neutral-100: 210 40% 96%;
  --neutral-200: 214 32% 91%;
  --neutral-300: 213 27% 84%;
  --neutral-400: 215 20% 65%;
  --neutral-500: 215 16% 47%;
  --neutral-600: 215 19% 35%;
  --neutral-700: 215 25% 27%;
  --neutral-800: 217 33% 17%;
  --neutral-900: 222 47% 11%;
  --neutral-950: 229 84% 5%;

  --red-500: 0 84% 60%;
  --red-600: 0 72% 51%;
  --green-500: 142 71% 45%;
  --green-600: 142 76% 36%;
  --amber-500: 38 92% 50%;
  --sky-500: 199 89% 48%;

  /* --- Spacing Scale (4px base) --- */
  --space-0:    0px;
  --space-0-5:  2px;
  --space-1:    4px;
  --space-1-5:  6px;
  --space-2:    8px;
  --space-3:    12px;
  --space-4:    16px;
  --space-5:    20px;
  --space-6:    24px;
  --space-8:    32px;
  --space-10:   40px;
  --space-12:   48px;
  --space-16:   64px;
  --space-20:   80px;
  --space-24:   96px;

  /* --- Typography Scale (Major Third 1.25 ratio, rem) --- */
  --text-xs:    0.75rem;    /* 12px */
  --text-sm:    0.875rem;   /* 14px */
  --text-base:  1rem;       /* 16px */
  --text-lg:    1.125rem;   /* 18px */
  --text-xl:    1.25rem;    /* 20px */
  --text-2xl:   1.5rem;     /* 24px */
  --text-3xl:   1.875rem;   /* 30px */
  --text-4xl:   2.25rem;    /* 36px */
  --text-5xl:   3rem;       /* 48px */

  /* --- Font Weights --- */
  --font-normal:   400;
  --font-medium:   500;
  --font-semibold: 600;
  --font-bold:     700;

  /* --- Line Heights --- */
  --leading-none:    1;
  --leading-tight:   1.25;
  --leading-snug:    1.375;
  --leading-normal:  1.5;
  --leading-relaxed: 1.625;
  --leading-loose:   2;

  /* --- Border Radius --- */
  --radius-none: 0px;
  --radius-sm:   4px;
  --radius-md:   6px;
  --radius-lg:   8px;
  --radius-xl:   12px;
  --radius-2xl:  16px;
  --radius-full: 9999px;

  /* --- Shadows --- */
  --shadow-sm:  0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md:  0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-lg:  0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  --shadow-xl:  0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);

  /* --- Transitions --- */
  --duration-fast:   150ms;
  --duration-normal: 200ms;
  --duration-slow:   300ms;
  --ease-default: cubic-bezier(0.4, 0, 0.2, 1);
  --ease-in:      cubic-bezier(0.4, 0, 1, 1);
  --ease-out:     cubic-bezier(0, 0, 0.2, 1);

  /* --- Breakpoints (for reference; used via media queries) --- */
  --breakpoint-sm:  640px;
  --breakpoint-md:  768px;
  --breakpoint-lg:  1024px;
  --breakpoint-xl:  1280px;
  --breakpoint-2xl: 1536px;
}

/* ============================================
   LAYER 2: Semantic Tokens — Light Mode
   These map intentions to primitives.
   Components reference ONLY these tokens.
   ============================================ */
:root {
  /* Surfaces */
  --background:          var(--neutral-0);
  --foreground:          var(--neutral-950);
  --card:                var(--neutral-0);
  --card-foreground:     var(--neutral-950);
  --popover:             var(--neutral-0);
  --popover-foreground:  var(--neutral-950);

  /* Interactive */
  --primary:             var(--blue-600);
  --primary-foreground:  var(--neutral-0);
  --secondary:           var(--neutral-100);
  --secondary-foreground: var(--neutral-900);
  --accent:              var(--neutral-100);
  --accent-foreground:   var(--neutral-900);

  /* Feedback */
  --destructive:             var(--red-500);
  --destructive-foreground:  var(--neutral-0);
  --success:                 var(--green-600);
  --success-foreground:      var(--neutral-0);
  --warning:                 var(--amber-500);
  --warning-foreground:      var(--neutral-900);
  --info:                    var(--sky-500);
  --info-foreground:         var(--neutral-0);

  /* Structural */
  --muted:             var(--neutral-100);
  --muted-foreground:  var(--neutral-500);
  --border:            var(--neutral-200);
  --input:             var(--neutral-200);
  --ring:              var(--blue-500);

  /* Component-level defaults */
  --radius: var(--radius-md);
}

/* ============================================
   LAYER 3: Dark Mode — Semantic Token Swap
   Same token names, different values.
   ============================================ */
.dark {
  /* Surfaces */
  --background:          var(--neutral-900);
  --foreground:          var(--neutral-50);
  --card:                var(--neutral-800);
  --card-foreground:     var(--neutral-50);
  --popover:             var(--neutral-800);
  --popover-foreground:  var(--neutral-50);

  /* Interactive */
  --primary:             var(--blue-400);
  --primary-foreground:  var(--neutral-900);
  --secondary:           var(--neutral-700);
  --secondary-foreground: var(--neutral-50);
  --accent:              var(--neutral-700);
  --accent-foreground:   var(--neutral-50);

  /* Feedback */
  --destructive:             var(--red-600);
  --destructive-foreground:  var(--neutral-50);
  --success:                 var(--green-500);
  --success-foreground:      var(--neutral-900);
  --warning:                 var(--amber-500);
  --warning-foreground:      var(--neutral-900);
  --info:                    var(--sky-500);
  --info-foreground:         var(--neutral-900);

  /* Structural */
  --muted:             var(--neutral-800);
  --muted-foreground:  var(--neutral-400);
  --border:            var(--neutral-700);
  --input:             var(--neutral-700);
  --ring:              var(--blue-400);
}

/* Respect system preference when no explicit class is set */
@media (prefers-color-scheme: dark) {
  :root:not(.light) {
    --background:          var(--neutral-900);
    --foreground:          var(--neutral-50);
    --card:                var(--neutral-800);
    --card-foreground:     var(--neutral-50);
    --primary:             var(--blue-400);
    --primary-foreground:  var(--neutral-900);
    --secondary:           var(--neutral-700);
    --secondary-foreground: var(--neutral-50);
    --muted:               var(--neutral-800);
    --muted-foreground:    var(--neutral-400);
    --border:              var(--neutral-700);
    --input:               var(--neutral-700);
    --ring:                var(--blue-400);
  }
}
```

---

## 2. Color System Design

### 2.1 HSL-Based Color Generation

HSL (Hue, Saturation, Lightness) is the preferred color model for programmatic palette generation because each dimension maps to an intuitive design operation:

- **Hue** (0-360): The color itself. Keeping hue constant while varying S and L generates a monochromatic scale.
- **Saturation** (0-100%): How vivid the color is. Desaturating creates muted tones.
- **Lightness** (0-100%): How light or dark. This is the primary axis for generating shade scales.

Using space-separated HSL values (without the `hsl()` wrapper) is a pattern popularized by shadcn/ui and Tailwind CSS v3+. It enables dynamic opacity manipulation:

```css
:root {
  --primary: 221 83% 53%;
}

/* Usage with opacity */
.element {
  background-color: hsl(var(--primary));             /* full opacity */
  border-color: hsl(var(--primary) / 0.5);           /* 50% opacity */
  box-shadow: 0 4px 6px hsl(var(--primary) / 0.25);  /* 25% opacity */
}
```

This format reduces token count (one variable instead of multiple opacity variants) and enables composability. For the AI agent, this means fewer tokens generated per component.

### 2.2 Generating a Full Palette from One Primary Color

Given a single user-provided brand color, the AI agent generates a complete 11-shade palette:

**Algorithm (HSL-based):**

```
Input: Brand color as hex (e.g., #2563EB)
Convert to HSL: H=221, S=83%, L=53%

Shade generation (lightness distribution):
  50:   H, S+17%, 97%    — near-white tint
  100:  H, S+12%, 93%
  200:  H, S+14%, 87%
  300:  H, S+13%, 78%
  400:  H, S+11%, 68%
  500:  H, S+8%,  60%
  600:  H, S,     53%    — original input
  700:  H, S-7%,  48%
  800:  H, S-12%, 40%
  900:  H, S-19%, 33%
  950:  H, S-26%, 21%    — near-black shade

Rules:
  - Hue stays constant (or shifts by 1-3 degrees for natural feel)
  - Saturation is higher at lighter shades, lower at darker shades
  - Lightness follows a non-linear curve (wider gaps in mid-range)
  - Clamp saturation to 0-100% range
```

**Complete semantic color set generated from one primary:**

```
Primary shades:   50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950
Semantic aliases:
  --color-primary:             shade 600 (light mode) / shade 400 (dark mode)
  --color-primary-foreground:  white (light mode) / shade 900 (dark mode)

Derived colors:
  --color-secondary:           neutral-100 (light) / neutral-700 (dark)
  --color-accent:              neutral-100 (light) / neutral-700 (dark)
  --color-destructive:         red-500 (always — different hue, not derived)
  --color-success:             green-600 (always — different hue, not derived)
  --color-warning:             amber-500 (always — different hue, not derived)
  --color-info:                sky-500 (always — different hue, not derived)

Neutral colors (always gray-based):
  --color-background:          neutral-0 (light) / neutral-900 (dark)
  --color-foreground:          neutral-950 (light) / neutral-50 (dark)
  --color-muted:               neutral-100 (light) / neutral-800 (dark)
  --color-muted-foreground:    neutral-500 (light) / neutral-400 (dark)
  --color-border:              neutral-200 (light) / neutral-700 (dark)
  --color-card:                neutral-0 (light) / neutral-800 (dark)
```

### 2.3 OKLCH: The Next-Generation Color Space

For even more perceptually uniform palette generation, OKLCH is the superior color space. Unlike HSL, where "50% lightness" looks radically different between yellow and blue, OKLCH ensures that two colors with the same L value have the same perceived brightness.

```css
/* OKLCH-based color scale — perceptually uniform lightness steps */
:root {
  --brand-50:  oklch(0.97 0.02 250);
  --brand-100: oklch(0.93 0.04 250);
  --brand-200: oklch(0.87 0.08 250);
  --brand-300: oklch(0.78 0.13 250);
  --brand-400: oklch(0.68 0.17 250);
  --brand-500: oklch(0.60 0.19 250);  /* base */
  --brand-600: oklch(0.53 0.19 250);
  --brand-700: oklch(0.46 0.17 250);
  --brand-800: oklch(0.39 0.14 250);
  --brand-900: oklch(0.32 0.11 250);
  --brand-950: oklch(0.22 0.08 250);
}
```

OKLCH advantages:
- **L** (lightness) is perceptually linear: 0.5 looks "half as bright" to human eyes
- **C** (chroma) and **H** (hue) are independent: adjusting saturation does not shift hue
- Consistent across hues: blue-500 and green-500 have the same perceived lightness
- Native CSS support: `oklch()` is supported in all modern browsers (Chrome 111+, Firefox 113+, Safari 15.4+)

**Recommendation**: Use OKLCH for palette generation (the algorithm), but store final values as HSL in `design-system.css` for maximum browser compatibility. As OKLCH browser support matures, this can shift to native OKLCH storage.

### 2.4 Dark Mode via CSS Custom Properties

Dark mode is implemented as a semantic token swap, not a component rewrite. The same component code works in both themes:

```css
/* Light mode (default) */
:root {
  --background: 0 0% 100%;
  --foreground: 222 47% 11%;
  --primary: 221 83% 53%;
  --primary-foreground: 210 40% 98%;
  --border: 214 32% 91%;
}

/* Dark mode — same variable names, different values */
.dark {
  --background: 222 47% 11%;
  --foreground: 210 40% 98%;
  --primary: 213 94% 68%;
  --primary-foreground: 222 47% 11%;
  --border: 215 25% 27%;
}
```

Key dark mode rules:
1. **Surfaces shift to dark neutrals** (not pure black -- use neutral-900, not #000)
2. **Text shifts to light neutrals** (not pure white -- use neutral-50, not #fff)
3. **Primary colors lighten** to maintain contrast on dark backgrounds
4. **Shadows reduce or disappear** -- replace with subtle borders or lighter elevated surfaces
5. **All pairings must be re-verified** for WCAG AA contrast compliance

### 2.5 Color Contrast Requirements (WCAG AA)

| Element Type | Minimum Contrast Ratio | Example |
|---|---|---|
| **Normal text** (below 18px, or below 14px bold) | 4.5:1 | Body text on background |
| **Large text** (18px+ or 14px+ bold) | 3:1 | Headings on background |
| **UI components and graphical objects** | 3:1 | Buttons, icons, form borders |

**Tools for checking contrast:**

| Tool | Description | Usage |
|---|---|---|
| `accessible-colors` npm package | Programmatic contrast checking in Node.js | Automated CI validation |
| APCA algorithm (see Section 8) | Next-generation perceptual contrast | More accurate than WCAG 2 formula |
| Chrome DevTools | Built-in contrast overlay in Inspect panel | Manual checking during development |
| `color.js` npm package | Color manipulation in any color space | Programmatic generation + contrast |
| Contrast Checker (WebAIM) | Web tool for quick manual checks | Manual verification |

---

## 3. Typography Scale

### 3.1 Modular Scale Approach

A modular scale creates harmonious size relationships by multiplying a base value by a constant ratio. This ensures visual consistency across all text elements.

| Scale Name | Ratio | Sizes from 16px Base |
|---|---|---|
| Minor Second | 1.067 | 16 / 17.1 / 18.2 / 19.4 / 20.7 |
| Major Second | 1.125 | 16 / 18 / 20.3 / 22.8 / 25.6 |
| Minor Third | 1.200 | 16 / 19.2 / 23 / 27.6 / 33.2 |
| **Major Third** | **1.250** | **16 / 20 / 25 / 31.3 / 39.1** |
| **Perfect Fourth** | **1.333** | **16 / 21.3 / 28.4 / 37.9 / 50.5** |
| Perfect Fifth | 1.500 | 16 / 24 / 36 / 54 / 81 |

**Recommended for SaaS applications**: Major Third (1.250). It provides clear hierarchy without extreme jumps and works well on both mobile and desktop. Perfect Fourth (1.333) is good for content-heavy sites where stronger heading differentiation is needed.

**Configuration:**

```
Base size:   16px (1rem) — browser default, good for readability
Scale ratio: 1.25 (Major Third)
Calculation: size(n) = base * ratio^n

Results:
  n = -2:  16 / 1.25^2  = 10.24px  ->  0.75rem   (text-xs)
  n = -1:  16 / 1.25    = 12.8px   ->  0.875rem  (text-sm)
  n =  0:  16           = 16px     ->  1rem      (text-base)
  n = +1:  16 * 1.25    = 20px     ->  1.25rem   (text-lg)
  n = +2:  16 * 1.25^2  = 25px     ->  1.5rem    (text-xl)
  n = +3:  16 * 1.25^3  = 31.25px  ->  1.875rem  (text-2xl)
  n = +4:  16 * 1.25^4  = 39.06px  ->  2.25rem   (text-3xl)
  n = +5:  16 * 1.25^5  = 48.83px  ->  3rem      (text-4xl)
```

### 3.2 Font Stack Recommendations

#### System Fonts (zero download cost)

The system font stack uses the native font of each operating system. This eliminates font loading entirely, resulting in zero layout shift and fastest possible text rendering:

```css
:root {
  --font-sans: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI",
    Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif,
    "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji";
  --font-mono: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas,
    "Liberation Mono", monospace;
}
```

This renders as:
- macOS/iOS: SF Pro (San Francisco)
- Windows: Segoe UI
- Android: Roboto
- Linux: Noto Sans or system default

#### Inter (recommended for SaaS UI)

Inter is the de facto standard for modern web UI. It was designed specifically for screens, has excellent legibility at small sizes, and includes features like tabular numbers, optical sizing, and case-sensitive punctuation.

```css
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

:root {
  --font-sans: "Inter", system-ui, -apple-system, sans-serif;
}
```

As a variable font, Inter can be loaded as a single file that covers all weights, reducing HTTP requests:

```css
@font-face {
  font-family: "Inter";
  src: url("/fonts/Inter-Variable.woff2") format("woff2-variations");
  font-weight: 100 900;
  font-display: swap;
}
```

#### JetBrains Mono (recommended for code)

JetBrains Mono is a free monospace font designed for code. It has increased letter height for better readability at small sizes and includes coding ligatures.

```css
:root {
  --font-mono: "JetBrains Mono", "Fira Code", ui-monospace, monospace;
}
```

#### Other Notable Options

| Font | Style | Best For |
|---|---|---|
| **Geist** (Vercel) | Clean, modern | Developer tools, dashboards |
| **Plus Jakarta Sans** | Geometric, friendly | Consumer-facing SaaS |
| **DM Sans** | Geometric, professional | Enterprise applications |
| **Sora** | Modern, technical | Tech products |

### 3.3 Variable Fonts

Variable fonts contain multiple weights (and sometimes widths, optical sizes) in a single file. This provides:

- **Smaller total download**: One file instead of 4-6 separate weight files
- **Continuous weight axis**: Access any weight from 100 to 900, not just predefined steps
- **Optical sizing**: Automatically adjusts letter spacing at different sizes

```css
/* Variable font with weight axis */
@font-face {
  font-family: "Inter";
  src: url("/fonts/InterVariable.woff2") format("woff2") tech("variations");
  font-weight: 100 900;
  font-display: swap;
  font-style: normal;
}

/* Now any weight is available */
.text-regular  { font-weight: 400; }
.text-medium   { font-weight: 500; }
.text-semibold { font-weight: 600; }
.text-bold     { font-weight: 700; }

/* Or even non-standard weights */
.text-custom   { font-weight: 450; }
```

### 3.4 CSS Custom Properties for Typography

The complete typography token set for `design-system.css`:

```css
:root {
  /* Font families */
  --font-sans: "Inter", system-ui, -apple-system, sans-serif;
  --font-mono: "JetBrains Mono", ui-monospace, monospace;

  /* Font sizes (rem-based for accessibility) */
  --font-size-xs:   0.75rem;    /* 12px */
  --font-size-sm:   0.875rem;   /* 14px */
  --font-size-base: 1rem;       /* 16px */
  --font-size-lg:   1.125rem;   /* 18px */
  --font-size-xl:   1.25rem;    /* 20px */
  --font-size-2xl:  1.5rem;     /* 24px */
  --font-size-3xl:  1.875rem;   /* 30px */
  --font-size-4xl:  2.25rem;    /* 36px */
  --font-size-5xl:  3rem;       /* 48px */

  /* Font weights */
  --font-weight-normal:   400;
  --font-weight-medium:   500;
  --font-weight-semibold: 600;
  --font-weight-bold:     700;

  /* Line heights */
  --line-height-tight:   1.25;
  --line-height-normal:  1.5;
  --line-height-relaxed: 1.625;

  /* Letter spacing */
  --tracking-tight:  -0.025em;
  --tracking-normal:  0em;
  --tracking-wide:    0.025em;
}
```

### 3.5 Fluid Typography with `clamp()`

For responsive typography that scales smoothly between viewport sizes without media query breakpoints:

```css
:root {
  /* Formula: clamp(min, preferred, max) */
  /* Scales smoothly from 375px to 1440px viewport */
  --text-base: clamp(1rem, 0.93rem + 0.19vw, 1.125rem);
  --text-lg:   clamp(1.125rem, 1.04rem + 0.24vw, 1.266rem);
  --text-xl:   clamp(1.25rem, 1.13rem + 0.33vw, 1.424rem);
  --text-2xl:  clamp(1.5rem, 1.31rem + 0.50vw, 1.75rem);
  --text-3xl:  clamp(1.875rem, 1.59rem + 0.75vw, 2.25rem);
  --text-4xl:  clamp(2.25rem, 1.84rem + 1.09vw, 2.75rem);
  --text-5xl:  clamp(3rem, 2.37rem + 1.67vw, 3.75rem);
}
```

**Clamp calculation formula:**

```
Given: min_size (rem), max_size (rem), min_vw (px), max_vw (px)
slope     = (max_size - min_size) / (max_vw - min_vw) * 16
intercept = min_size - slope * min_vw / 16
Result:   clamp(min_size, intercept + slope_vw, max_size)
```

Tools: **Utopia** (utopia.fyi) generates fluid type scales with copy-paste CSS output.

---

## 4. Spacing and Layout System

### 4.1 The 4px Base Unit System

The 4px base unit is used by virtually all major design systems (Tailwind CSS, Material Design, Ant Design, Primer). Every spacing value is a multiple of 4px, creating a consistent visual rhythm.

**Why 4px and not 8px?** The 4px base provides finer granularity (2px, 4px, 6px, 8px) that is needed for small UI elements like inline badges, icon padding, and compact form fields. An 8px base skips from 0 to 8px with no intermediate value.

### 4.2 Spacing Scale

The spacing scale uses a non-linear progression that provides dense values at the small end (where fine control matters most) and larger jumps at the big end:

```css
:root {
  --spacing-0:    0;          /* 0px  */
  --spacing-0-5:  0.125rem;   /* 2px  */
  --spacing-1:    0.25rem;    /* 4px  */
  --spacing-1-5:  0.375rem;   /* 6px  */
  --spacing-2:    0.5rem;     /* 8px  */
  --spacing-2-5:  0.625rem;   /* 10px */
  --spacing-3:    0.75rem;    /* 12px */
  --spacing-3-5:  0.875rem;   /* 14px */
  --spacing-4:    1rem;       /* 16px */
  --spacing-5:    1.25rem;    /* 20px */
  --spacing-6:    1.5rem;     /* 24px */
  --spacing-8:    2rem;       /* 32px */
  --spacing-10:   2.5rem;     /* 40px */
  --spacing-12:   3rem;       /* 48px */
  --spacing-16:   4rem;       /* 64px */
  --spacing-20:   5rem;       /* 80px */
  --spacing-24:   6rem;       /* 96px */
}
```

In Tailwind utility classes, these map to `p-1` (4px), `p-2` (8px), `p-4` (16px), `gap-6` (24px), etc.

### 4.3 Layout Primitives: Stack, Row, Grid

Modern layout is built on three composable primitives. These can be implemented as CSS utility classes or React components:

**Stack (vertical layout):**

```css
/* Stack: vertical arrangement with consistent gap */
.stack {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-4);   /* default gap, customizable */
}

.stack-sm  { gap: var(--spacing-2); }
.stack-md  { gap: var(--spacing-4); }
.stack-lg  { gap: var(--spacing-6); }
.stack-xl  { gap: var(--spacing-8); }
```

**Row (horizontal layout):**

```css
/* Row: horizontal arrangement with alignment */
.row {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: var(--spacing-4);
}

.row-between { justify-content: space-between; }
.row-end     { justify-content: flex-end; }
.row-wrap    { flex-wrap: wrap; }
```

**Grid (responsive columns):**

```css
/* Grid: auto-responsive columns */
.grid {
  display: grid;
  gap: var(--spacing-4);
}

/* Auto-fill columns with minimum width */
.grid-auto-fill {
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
}

/* Fixed column counts */
.grid-cols-2 { grid-template-columns: repeat(2, 1fr); }
.grid-cols-3 { grid-template-columns: repeat(3, 1fr); }
.grid-cols-4 { grid-template-columns: repeat(4, 1fr); }
```

### 4.4 Responsive Breakpoints

The breakpoint system matches Tailwind CSS defaults:

| Breakpoint | Width | Devices |
|---|---|---|
| `sm` | 640px | Large phones (landscape) |
| `md` | 768px | Tablets |
| `lg` | 1024px | Small laptops |
| `xl` | 1280px | Desktops |
| `2xl` | 1536px | Large desktops |

**Usage pattern in Tailwind:**

```html
<!-- Stack on mobile, 2 columns on tablet, 3 columns on desktop -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  <div class="bg-card rounded-lg p-4">Card 1</div>
  <div class="bg-card rounded-lg p-4">Card 2</div>
  <div class="bg-card rounded-lg p-4">Card 3</div>
</div>
```

### 4.5 Content Width Constraints

For readability, content areas should have maximum widths:

```css
:root {
  --max-width-prose: 65ch;     /* ~600px — ideal for reading */
  --max-width-content: 1024px; /* main content area */
  --max-width-wide: 1280px;    /* full-width sections */
  --max-width-screen: 1536px;  /* maximum page width */
}

/* Usage */
.container {
  width: 100%;
  max-width: var(--max-width-wide);
  margin-inline: auto;
  padding-inline: var(--spacing-4);
}

@media (min-width: 640px) {
  .container { padding-inline: var(--spacing-6); }
}

@media (min-width: 1024px) {
  .container { padding-inline: var(--spacing-8); }
}
```

---

## 5. Component Library Strategy

### 5.1 The shadcn/ui Approach: Copy-Paste, Not npm Dependency

shadcn/ui is a collection of reusable components that are copied directly into your project, not installed as an npm package. This is fundamentally different from traditional component libraries.

**Traditional library approach (e.g., MUI, Chakra):**

```bash
npm install @mui/material @emotion/react @emotion/styled
# Components live in node_modules — you cannot edit them
# Updates come via npm and may break your usage
# Styles are encapsulated and hard to override
```

**shadcn/ui approach:**

```bash
npx shadcn@latest init      # Configures the project
npx shadcn@latest add button # Copies source code into components/ui/button.tsx
npx shadcn@latest add card   # Copies source code into components/ui/card.tsx
# Components live in YOUR codebase — fully editable
# No dependency updates to worry about
# Styles use your design tokens via CSS custom properties
```

**Why this matters for AI workflows:**

1. **Full visibility**: The AI agent can read, understand, and modify every line of component code because it lives in the project. No hidden library internals.
2. **No API surface to memorize**: The AI does not need to know a library's prop API -- it can read the component source directly.
3. **No breaking updates**: Copy-paste components are frozen at the version you added them. No `npm audit` surprises.
4. **Smaller bundles**: You only have the components you use, not an entire library tree-shaken.

### 5.2 shadcn/ui Component Architecture

Every shadcn/ui component follows an identical pattern that AI agents can learn once and apply universally:

```tsx
// components/ui/button.tsx — standard shadcn/ui pattern
import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const buttonVariants = cva(
  // Base classes (always applied)
  "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline: "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button, buttonVariants }
```

The pattern is always:
1. `cva()` for defining variants (from `class-variance-authority`)
2. `cn()` for merging Tailwind classes (from `clsx` + `tailwind-merge`)
3. `forwardRef` for ref forwarding (React composition pattern)
4. Radix UI primitives for complex interactive behavior (Dialog, Select, Popover, etc.)

### 5.3 The `cn()` Utility

A critical utility that all AI-generated components must use:

```typescript
// lib/utils.ts
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

This merges Tailwind classes intelligently. For example:
- `cn("px-4", "px-6")` yields `"px-6"` (not `"px-4 px-6"`)
- `cn("bg-primary", isActive && "bg-accent")` conditionally applies classes
- `cn(baseClasses, className)` allows consumers to override component defaults

### 5.4 Built-in Accessibility via Radix UI Primitives

shadcn/ui builds on Radix UI Primitives under the hood, which provides:

- **Keyboard navigation**: Tab, Enter, Space, Arrow keys, Escape
- **Focus management**: Focus trapping in modals, return focus on close
- **Screen reader support**: aria-labels, roles, live regions
- **Reduced motion support**: Respects `prefers-reduced-motion`
- **WAI-ARIA compliance**: Dialog, Dropdown Menu, Popover, Select, Tabs, etc.

The AI agent does not need to implement accessibility -- it comes free with Radix.

### 5.5 Headless UI Alternatives

When shadcn/ui is not suitable (e.g., Vue or Solid projects, or when full styling control is needed), these headless libraries provide accessible primitives without any styling:

| Library | Frameworks | Components | Maintainer |
|---|---|---|---|
| **Radix UI** | React | 28 primitives | WorkOS |
| **Headless UI** | React, Vue | 10 components | Tailwind Labs |
| **Ark UI** | React, Vue, Solid | 45+ components | Chakra UI team |
| **React Aria** | React | 40+ hooks | Adobe |

### 5.6 Why NOT Traditional Component Libraries for AI Workflows

Traditional component libraries (MUI, Chakra UI, Ant Design) are poor fits for AI-assisted development:

1. **Black-box components**: The AI cannot inspect or modify internals. When customization is needed, it must fight the library's abstraction.
2. **Dependency coupling**: Library updates can break existing usage. AI cannot predict which version introduced a breaking change.
3. **Style encapsulation**: CSS-in-JS or module-based styles are harder for AI to override than Tailwind utilities.
4. **Large surface area**: AI must memorize (or look up) hundreds of props, variants, and edge cases per component.
5. **Bundle overhead**: Traditional libraries pull in more code than needed. shadcn/ui copies only what you use.

**The principle**: For AI-assisted development, prefer components the AI can read and edit over components the AI must call through an API.

---

## 6. Extracting Design Patterns from Reference Websites

### 6.1 Why Reference Site Analysis Matters

Non-technical users building SaaS apps often start with "I want it to look like [reference site]." The VibeOS UI Designer agent needs the ability to analyze reference websites and extract concrete design decisions from them.

### 6.2 Puppeteer MCP for Automated Extraction

The Puppeteer MCP server gives the AI agent programmatic access to any web page's DOM, computed styles, and screenshots. This enables automated extraction of colors, typography, and layout patterns.

**Color extraction:**

```javascript
// Extract all unique colors used on a page via Puppeteer
async function extractColors(page) {
  return await page.evaluate(() => {
    const elements = document.querySelectorAll('*');
    const colors = new Set();

    elements.forEach(el => {
      const style = getComputedStyle(el);
      ['color', 'backgroundColor', 'borderColor'].forEach(prop => {
        const value = style[prop];
        if (value && value !== 'rgba(0, 0, 0, 0)' && value !== 'transparent') {
          colors.add(value);
        }
      });
    });

    return [...colors];
  });
}
```

**Typography extraction:**

```javascript
// Extract the typography system from a page
async function extractTypography(page) {
  return await page.evaluate(() => {
    const selectors = 'h1, h2, h3, h4, h5, h6, p, a, span, li, button, input, label';
    const elements = document.querySelectorAll(selectors);
    const typography = new Map();

    elements.forEach(el => {
      const style = getComputedStyle(el);
      const key = `${style.fontFamily}|${style.fontSize}|${style.fontWeight}`;
      if (!typography.has(key)) {
        typography.set(key, {
          fontFamily: style.fontFamily,
          fontSize: style.fontSize,
          fontWeight: style.fontWeight,
          lineHeight: style.lineHeight,
          letterSpacing: style.letterSpacing,
          tag: el.tagName.toLowerCase(),
          sampleText: el.textContent?.substring(0, 50),
          count: 1,
        });
      } else {
        typography.get(key).count++;
      }
    });

    return [...typography.values()].sort((a, b) => b.count - a.count);
  });
}
```

**Layout and spacing extraction:**

```javascript
// Extract layout patterns (grid/flex usage, max-widths, gaps)
async function extractLayout(page) {
  return await page.evaluate(() => {
    const results = { maxWidths: new Set(), displays: {}, gaps: new Set() };

    document.querySelectorAll('*').forEach(el => {
      const style = getComputedStyle(el);

      if (style.maxWidth !== 'none') results.maxWidths.add(style.maxWidth);

      const display = style.display;
      results.displays[display] = (results.displays[display] || 0) + 1;

      if (style.gap && style.gap !== 'normal') results.gaps.add(style.gap);
    });

    return {
      maxWidths: [...results.maxWidths],
      displays: results.displays,
      gaps: [...results.gaps],
    };
  });
}
```

### 6.3 The Extraction Process

When a user provides a reference URL, the UI Designer agent follows this process:

1. **Capture screenshots at multiple viewports** (375px, 768px, 1280px)
2. **Extract computed styles** for colors, fonts, and spacing using the Puppeteer scripts above
3. **Analyze patterns**: Identify the primary color, typography hierarchy, spacing rhythm, and layout structure
4. **Map to design tokens**: Convert extracted values to the nearest tokens in the design system
5. **Output a reference analysis document** (see template below)

**Reference analysis template:**

```markdown
## Reference Site Analysis: [example.com]

### Color Palette
- Primary: #2563EB (blue-600) — CTAs, links, interactive elements
- Secondary: #F1F5F9 (slate-100) — backgrounds, cards
- Accent: #10B981 (emerald-500) — success states
- Neutral: #0F172A (slate-900) — body text

### Typography
- Headings: Inter, 700 weight, -0.02em tracking
- Body: Inter, 400 weight, 1.6 line-height
- Scale: 14 / 16 / 18 / 20 / 24 / 30 / 36 / 48px

### Layout
- Max content width: 1280px
- Section spacing: 64px-96px vertical
- Card gap: 24px
- Border radius: 8px (cards), 6px (buttons)

### Component Patterns
- Cards: white bg, 1px border, 8px radius, 24px padding
- Buttons: 40px height, 16px horizontal padding, 6px radius
- Inputs: 40px height, 12px padding, 1px border, 6px radius
```

### 6.4 Limitations

- **Visual patterns only**: Puppeteer can extract what elements look like, but not how they behave (e.g., animation sequences, gesture interactions)
- **Dynamic content**: Some sites load content via JavaScript that may not be available at initial page load; Puppeteer can wait for network idle but may miss some elements
- **Copyright**: Extracting patterns is fine for inspiration; copying exact designs or assets may have legal implications

### 6.5 Supplementary Tools

| Tool | What It Does | Usage |
|---|---|---|
| **CSS Stats** (cssstats.com) | Aggregates CSS declarations into analytics | Quick high-level overview |
| **WhatFont** (browser extension) | Click text to see font, size, weight, color | Fast manual inspection |
| **ColorZilla** (browser extension) | Eyedropper + palette extractor | Color picking |
| **Responsively** (app) | View site at multiple breakpoints simultaneously | Responsive analysis |
| **VisBug** (browser extension) | Inspect spacing, alignment, typography visually | Layout inspection |

---

## 7. Google Stitch MCP Capabilities

### 7.1 What Is Google Stitch?

Google Stitch (launched in preview in 2025) is a generative UI prototyping tool from Google Labs. It generates interactive web UI prototypes from natural language descriptions, sketches, or image inputs.

Key characteristics:
- **Input**: Text prompts, wireframe sketches, screenshots, or Figma mockups
- **Output**: Functional HTML/CSS/JavaScript prototypes that render in the browser
- **Rendering**: Uses web standards (HTML, CSS, JS) -- not proprietary formats
- **Interactivity**: Generated prototypes include working navigation, hover states, click interactions, and responsive layouts
- **Iteration**: Users can refine outputs with follow-up prompts

### 7.2 Stitch MCP Server Integration

Google released an MCP (Model Context Protocol) server for Stitch, enabling AI coding assistants like Claude Code to use Stitch as a tool.

**MCP Server Capabilities:**

| Capability | Description |
|---|---|
| `generate_ui` | Generate a UI layout from a text description |
| `refine_ui` | Modify a previously generated layout with a follow-up prompt |
| `screenshot_to_ui` | Convert a screenshot or image into a functional UI prototype |
| `export_code` | Export the generated prototype as clean HTML/CSS/JS |

**Configuration in Claude Code:**

```json
{
  "mcpServers": {
    "stitch": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/stitch-mcp-server"],
      "env": {
        "GOOGLE_API_KEY": "your-api-key"
      }
    }
  }
}
```

> **Note**: The exact package name and configuration may vary. The package name above is illustrative. Verify against the latest documentation.

### 7.3 Workflow with VibeOS UI Designer Agent

```
User: "Create a pricing page with three tiers"

VibeOS UI Designer Agent:
  1. If Stitch MCP available:
     a. Call stitch.generate_ui("pricing page with three tiers:
        Starter, Pro, Enterprise. Modern SaaS style, toggle
        for monthly/annual billing")
     b. Stitch returns HTML/CSS/JS prototype
     c. Agent analyzes the layout structure
     d. Agent converts to React components using project's design tokens
     e. Components use shadcn/ui primitives (Card, Button, Badge, etc.)
  2. If Stitch NOT available:
     a. Agent designs layout directly using shadcn/ui components
     b. Uses common SaaS pricing page patterns from training data
  3. Output: Production-ready React components in project structure
```

### 7.4 Capabilities and Strengths

- **Layout generation**: Excels at page-level layouts (dashboards, landing pages, settings panels, forms)
- **Responsive design**: Generated prototypes include responsive breakpoints
- **Component variety**: Handles tables, cards, navigation, modals, forms, pricing grids
- **Speed**: Full page prototype in seconds
- **Visual fidelity**: Output looks production-grade, not wireframe-level
- **Reference-to-code**: Can convert screenshots or mockups into functional prototypes

### 7.5 Limitations and When to Hand-Code

| Limitation | Impact | Mitigation |
|---|---|---|
| **Not production code** | Output is prototype-quality HTML/CSS/JS | Always convert to project components with design tokens |
| **No design token awareness** | Generates its own colors and styling | Agent must re-map to project's token system |
| **No state management** | Looks interactive but has no real state | Agent adds state, API calls, and business logic |
| **Google dependency** | Requires API key and internet | Gracefully degrade -- agent generates layouts manually |
| **Rate limits** | May throttle at high usage | Cache common layouts; fall back to manual |

**When to use Stitch**: Initial layout exploration during Tier 2 UI Design phase, converting user-provided screenshots to starting code, rapid prototyping of new page types.

**When to hand-code**: Simple components (buttons, inputs, badges), modifications to existing components, any component that needs specific state management or business logic.

---

## 8. Accessible Color Systems

### 8.1 WCAG 2.2 Contrast Requirements (Review)

| Level | Normal Text | Large Text | UI Components |
|---|---|---|---|
| **AA** (minimum) | 4.5:1 | 3:1 | 3:1 |
| **AAA** (enhanced) | 7:1 | 4.5:1 | Not defined |

- **Normal text**: Below 18px, or below 14px bold
- **Large text**: 18px or larger, or 14px bold or larger
- **UI components**: Borders, icons, focus indicators, form controls

**Target for VibeOS**: WCAG AA as the minimum. AAA for body text where feasible.

### 8.2 APCA: The Next-Generation Contrast Algorithm

The Advanced Perceptual Contrast Algorithm (APCA) is the successor to the WCAG 2 contrast formula. It addresses several known weaknesses of the WCAG 2 approach:

**Problems with WCAG 2 contrast ratio:**
- Treats black-on-white and white-on-black as identical contrast (they are not perceptually equal)
- Does not account for font size and weight in the ratio calculation
- Produces false passes (colors that pass 4.5:1 but are actually hard to read)
- Produces false fails (colors that fail 4.5:1 but are actually perfectly readable)

**APCA improvements:**
- Uses a perceptually uniform lightness model
- Accounts for polarity (dark-on-light vs light-on-dark)
- Font-size-aware thresholds (smaller text needs higher contrast)
- Better alignment with how human vision actually perceives contrast

**APCA minimum values by use case:**

| Use Case | Minimum Lc Value |
|---|---|
| Body text (16px, 400 weight) | Lc 75 |
| Large text (24px+) | Lc 60 |
| Subtext / captions (14px) | Lc 90 |
| Placeholder text | Lc 60 |
| Non-text UI elements | Lc 45 |
| Disabled text | No minimum (intentionally low contrast) |

> **Note**: APCA is not yet an official W3C recommendation. WCAG 2 AA (4.5:1) remains the legal standard. However, APCA is being developed as part of WCAG 3 (Silver). VibeOS should validate against WCAG 2 AA for compliance and optionally check APCA for better perceptual accuracy.

### 8.3 Programmatic Contrast Checking

```javascript
/**
 * Calculate relative luminance of a color (WCAG 2.1 definition)
 * Input: { r, g, b } where values are 0-255
 */
function relativeLuminance({ r, g, b }) {
  const [rs, gs, bs] = [r, g, b].map(c => {
    c = c / 255;
    return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
}

/**
 * Calculate WCAG 2.1 contrast ratio between two colors
 * Returns value between 1 and 21
 */
function contrastRatio(color1, color2) {
  const l1 = relativeLuminance(color1);
  const l2 = relativeLuminance(color2);
  const lighter = Math.max(l1, l2);
  const darker = Math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

/**
 * Validate all design system color pairings
 */
function validatePalette(tokens) {
  const pairs = [
    { fg: tokens.foreground, bg: tokens.background, label: "body text", min: 4.5 },
    { fg: tokens.primaryForeground, bg: tokens.primary, label: "primary button", min: 4.5 },
    { fg: tokens.mutedForeground, bg: tokens.background, label: "muted text", min: 4.5 },
    { fg: tokens.destructiveForeground, bg: tokens.destructive, label: "error button", min: 4.5 },
    { fg: tokens.foreground, bg: tokens.card, label: "card text", min: 4.5 },
    { fg: tokens.primary, bg: tokens.background, label: "link on bg (UI)", min: 3.0 },
    { fg: tokens.border, bg: tokens.background, label: "border (UI)", min: 3.0 },
  ];

  const results = pairs.map(({ fg, bg, label, min }) => {
    const ratio = contrastRatio(fg, bg);
    return {
      label,
      ratio: ratio.toFixed(2),
      required: min,
      passes: ratio >= min,
    };
  });

  return results;
}
```

### 8.4 Generating Accessible Color Pairs Automatically

The AI agent should automatically verify that every foreground/background pair in the design system passes WCAG AA. If a pair fails, the agent adjusts the foreground or background until it passes:

```
Algorithm: Auto-fix failing contrast
1. Given a background color and desired foreground color
2. Calculate contrast ratio
3. If ratio >= 4.5 (for text), PASS
4. If ratio < 4.5:
   a. If foreground is lighter than background: darken foreground
   b. If foreground is darker than background: lighten foreground
   c. Adjust lightness in increments of 2% until ratio >= 4.5
   d. If adjustment exceeds reasonable bounds (foreground becomes near-black or near-white),
      flag for human review
```

### 8.5 Dark Mode: Not Just Inversion

Dark mode requires deliberate token remapping, not simple color inversion:

```
Light Mode                     Dark Mode
──────────────────────────────────────────────────
background: white (#fff)   ->  background: neutral-900 (#0f172a)
foreground: neutral-950    ->  foreground: neutral-50 (#f8fafc)
card: white                ->  card: neutral-800 (#1e293b)
border: neutral-200        ->  border: neutral-700 (#334155)
primary: blue-600          ->  primary: blue-400 (lighter for dark bg)
muted: neutral-100         ->  muted: neutral-800
shadow-md: standard        ->  shadow-md: reduced or replaced with border
```

Key principles:
1. **Never use pure black (#000)** -- use neutral-900 or neutral-950 for softer dark backgrounds
2. **Never use pure white (#fff)** for text on dark -- use neutral-50 for reduced eye strain
3. **Primary colors lighten** on dark backgrounds to maintain contrast
4. **Shadows reduce** on dark surfaces -- use subtle borders or lighter elevated surfaces instead
5. **Every pairing must be re-checked** for WCAG AA in both modes

### 8.6 High Contrast Mode

Some users have system-level high contrast modes enabled. The CSS `forced-colors` media query detects this:

```css
@media (forced-colors: active) {
  /* Override custom colors with system colors */
  .btn {
    border: 2px solid ButtonText;
    background: ButtonFace;
    color: ButtonText;
  }

  .btn:hover {
    background: Highlight;
    color: HighlightText;
  }
}
```

### 8.7 Color Blindness Considerations

Approximately 8% of men and 0.5% of women have some form of color vision deficiency. Design rules:

1. **Never rely on color alone** to convey meaning. Always pair color with text, icons, or patterns.
   - Bad: Red border = error, green border = success
   - Good: Red border + error icon + error text
2. **Use colorblind-safe palettes** that distinguish between states via lightness, not just hue.
3. **Test with simulation tools**: Chrome DevTools > Rendering > "Emulate vision deficiencies" simulates protanopia, deuteranopia, tritanopia, and achromatopsia.

### 8.8 Accessible Color Palette Tools

| Tool | Description | Integration |
|---|---|---|
| **Radix Colors** (radix-ui.com/colors) | Pre-built accessible color scales with dark mode | CSS import, Tailwind plugin |
| **Leonardo** (leonardocolor.io, by Adobe) | Generate colors by specifying target contrast ratio | API available |
| **Huetone** (huetone.ardov.me) | OKLCH-based palette builder with contrast checking | Manual / reference |
| **Color.js** (colorjs.io) | JS library for color manipulation in any color space | npm package |
| **Realtime Colors** (realtimecolors.com) | Preview tokens on a realistic page layout | Manual reference |
| **Coolors** (coolors.co) | Quick palette generation with accessibility checking | Manual |

---

## 9. Design System Maintenance

### 9.1 How the UI Designer Agent Maintains Consistency

During Tier 2 feature development, the UI Designer agent must enforce consistency across all new components. It follows these rules:

**Session start protocol:**
1. Read `design-system.css` to load the current token inventory
2. Read the component inventory (list of existing components in `components/ui/`)
3. Understand which tokens and components are available before designing anything new

**Component creation rules:**
1. **All new components must use existing tokens** -- never hardcode a color, spacing, or font size
2. **If a new token is needed**, add it to `design-system.css` first, then reference it in the component
3. **Prefer composition of existing components** over creating new ones (e.g., a pricing card is a `Card` with `Badge`, `Button`, and typography utilities)
4. **Follow the shadcn/ui pattern** (cva + cn + forwardRef) for all custom components

**Token addition protocol:**

When the agent determines a new token is needed:

```
1. Check if an existing token can serve the purpose
   - e.g., does --spacing-3 (12px) work instead of creating --spacing-3-5 (14px)?
2. If truly new:
   a. Add the primitive token to Layer 1 in design-system.css
   b. Add the semantic alias to Layer 2 (and dark mode in Layer 3 if applicable)
   c. Add a CSS comment documenting what the token is for
   d. Update the Tailwind @theme block if using Tailwind v4
3. NEVER add a raw value inline in a component
   BAD:  padding: 14px;
   GOOD: padding: var(--spacing-3-5);
```

### 9.2 Design System Changelog

Every modification to `design-system.css` should be tracked. The VibeOS Doc Generator agent should maintain a changelog entry whenever tokens are added, modified, or removed:

```markdown
## Design System Changelog

### 2026-02-23 — Feature: User Dashboard
- Added: `--color-info` (sky-500) — for informational alerts
- Added: `--color-info-foreground` (neutral-0) — text on info backgrounds
- Added: Dark mode mapping for info color pair
- Modified: `--shadow-lg` — reduced spread for subtler elevation

### 2026-02-20 — Feature: Authentication
- Added: `--spacing-18` (72px) — for large section spacing on auth pages
- No color changes
- No dark mode changes
```

### 9.3 Component Inventory

The UI Designer agent should maintain awareness of all components and their design status:

```markdown
## Component Inventory

| Component | Source | Status | Design Tokens Used |
|---|---|---|---|
| Button | shadcn/ui | Customized | primary, destructive, secondary, muted |
| Card | shadcn/ui | Customized | card, card-foreground, border, shadow-sm |
| Input | shadcn/ui | Default | input, border, ring, foreground |
| Dialog | shadcn/ui | Default | background, foreground, border |
| Badge | shadcn/ui | Customized | primary, secondary, destructive, success |
| DataTable | Custom | New | border, muted, foreground, spacing-2/4 |
| PricingCard | Custom | New | card, primary, muted, shadow-md |
```

This inventory helps the agent:
- Avoid creating duplicate components
- Know which components have been customized (and should not be overwritten)
- Track which tokens are actually used (unused tokens can be pruned)

### 9.4 Preventing Design System Drift

Design system drift occurs when developers (human or AI) bypass the token system and hardcode values. VibeOS prevents this through multiple layers:

1. **Phase gate hook** (`phase-gate.sh`): Blocks all source code writes until the design system is established in Tier 1
2. **CLAUDE.md rules**: Explicit rules prohibiting hardcoded values (enforced by the model's instruction following)
3. **Performance Coach scoring**: The Vibe Score deducts points for design system violations detected in session reviews
4. **Lint rules**: Tailwind CSS has a `no-custom-classname` lint rule (via `eslint-plugin-tailwindcss`) that flags arbitrary values

```javascript
// .eslintrc.js — flag design system violations
module.exports = {
  plugins: ["tailwindcss"],
  rules: {
    // Warn on arbitrary values like p-[14px] or bg-[#2563eb]
    "tailwindcss/no-custom-classname": "warn",
    // Enforce consistent class ordering
    "tailwindcss/classnames-order": "warn",
  },
};
```

---

## 10. Recommendations for VibeOS

Based on the research above, here are the specific recommendations for implementing the design system in VibeOS:

### 10.1 UI Designer Agent: Tier 1 Pipeline

The Tier 1 `design-system.css` generation should follow this pipeline:

```
Step 1: Gather Inputs
  |-- User's brand color (hex or description; optional)
  |-- Style mood ("modern SaaS", "playful", "enterprise", "minimal")
  |-- Font preference (system fonts / Inter / Geist / custom)
  |-- Border radius preference (sharp / rounded / pill)
  |-- Density preference (compact / comfortable / spacious)
  |-- Reference website URLs (optional; analyzed via Puppeteer MCP)

Step 2: Generate Token Foundation
  |-- Color palette: OKLCH-based generation, 11 shades per hue
  |-- Semantic color mappings: light mode + dark mode
  |-- Typography: Fluid clamp() values, Major Third (1.25) scale
  |-- Spacing: 4px base, standard Tailwind-compatible multipliers
  |-- Border radius tokens: Based on user preference
  |-- Shadow tokens: 4 levels (sm, md, lg, xl)
  |-- Transition tokens: fast (150ms), normal (200ms), slow (300ms)

Step 3: Validate Accessibility
  |-- Check ALL text/background combinations for WCAG AA (>= 4.5:1)
  |-- Check interactive elements for 3:1 contrast
  |-- Verify dark mode pairings pass same checks
  |-- Auto-fix failing pairs by adjusting lightness
  |-- Flag any remaining failures for user review

Step 4: Output Files
  |-- design-system.css (CSS custom properties, 3 layers)
  |-- globals.css or app.css (Tailwind v4 @theme block)
  |-- lib/utils.ts (cn utility)
  |-- Inline documentation (CSS comments explaining each section)

Step 5: Scaffold Base Components
  |-- npx shadcn@latest init (configure project for shadcn/ui)
  |-- Add base components: button, card, input, label, badge, dialog
  |-- Verify components render correctly with custom theme
```

### 10.2 Recommended Technology Stack for Design System

| Layer | Recommendation | Rationale |
|---|---|---|
| **Token format** | CSS custom properties (HSL space-separated) | Zero-dependency, framework-agnostic, runtime-mutable |
| **Utility framework** | Tailwind CSS v4 (v3 fallback) | Industry standard, composable with tokens, AI-friendly |
| **Component library** | shadcn/ui | Copy-paste ownership, Radix accessibility, AI-editable |
| **Color space** | OKLCH for generation, HSL for storage | Perceptual uniformity for generation, broad support for storage |
| **Typography** | Fluid clamp(), Major Third scale, Inter default | Responsive without breakpoints, harmonious hierarchy |
| **Spacing** | 4px base unit, Tailwind-compatible scale | Industry standard, fine granularity |
| **Dark mode** | CSS class toggle (.dark) + token swap | Instant toggle, no flash, system preference respect |
| **Accessibility** | WCAG AA minimum, APCA advisory | Legal compliance, inclusive design |

### 10.3 Token Naming Convention

For consistency across the VibeOS ecosystem:

```
Pattern: --{category}-{concept}-{modifier}

Categories:   color, space, radius, text, font, weight, leading, tracking,
              shadow, duration, ease
Concepts:     primary, secondary, muted, destructive, success, warning, info,
              background, foreground, border, card, popover, accent, input, ring
Modifiers:    foreground (paired text color), sm/md/lg (sizes)

Examples:
  --color-primary              (semantic color)
  --color-primary-foreground   (text on primary background)
  --space-4                    (spacing: 16px)
  --text-base                  (font size: 1rem)
  --radius-md                  (border radius: 6px)
  --shadow-lg                  (box shadow: large elevation)
  --duration-fast              (transition: 150ms)
```

### 10.4 Design System Rules for CLAUDE.md

These rules should be encoded in the generated project's CLAUDE.md file to enforce design system compliance across all AI agent sessions:

```markdown
## Design System Rules

1. NEVER use hardcoded color values in components. Always use semantic tokens
   (bg-primary, text-foreground, border-border, etc.)
2. NEVER use hardcoded spacing pixels. Always use Tailwind spacing utilities
   (p-4, gap-6, mt-2, etc.)
3. ALWAYS use the cn() utility for className composition in React components.
4. ALWAYS use shadcn/ui components when one exists for the needed UI pattern
   before creating a custom component.
5. ALWAYS verify new color combinations meet WCAG AA contrast (4.5:1 for text,
   3:1 for UI elements).
6. NEVER add dark: variants to components. Dark mode is handled by the semantic
   token swap on :root.
7. ALWAYS use rem/em for font sizes. Never use px for text
   (px is acceptable for borders, shadows, and fine details).
8. ALWAYS include focus-visible styles on interactive elements
   (ring-ring ring-offset-2).
9. PREFER Tailwind utility classes over custom CSS. Use custom CSS only for
   complex animations or pseudo-elements that cannot be expressed as utilities.
10. ALWAYS use the project's design-system.css tokens. Never introduce new
    design decisions inline. If a new token is needed, add it to
    design-system.css first.
```

### 10.5 Google Stitch Integration Plan

```
Priority: Optional (nice-to-have during Tier 2 UI Design phase)

Usage:
  - UI Designer agent MAY use Stitch for initial layout exploration
  - Output MUST be converted to project components + design tokens
  - Never ship Stitch output directly

MCP Configuration:
  - Add to mcp-servers.json if user has Google API key
  - Gracefully degrade if unavailable (agent generates layouts manually)

Workflow:
  1. User describes a page or feature
  2. If Stitch available: generate prototype for visual reference
  3. Agent analyzes prototype structure (layout, sections, component types)
  4. Agent converts to React components using project's shadcn/ui + tokens
  5. Result is production-ready, not prototype-quality
```

### 10.6 Design System Maintenance Rules

1. **Read design-system.css at every session start** -- the UI Designer agent must know the current token inventory before making any changes
2. **Never hardcode values** -- if a component needs a value not in the token set, add the token to design-system.css first
3. **Track all changes** -- the Doc Generator agent logs every token addition/modification/removal in the design system changelog
4. **Validate on every change** -- when a token is modified, re-run WCAG AA contrast validation on all affected pairings
5. **Maintain component inventory** -- track which components exist, their customization status, and which tokens they use
6. **Prune unused tokens** -- during Performance Coach reviews, identify tokens that exist in design-system.css but are not referenced by any component

### 10.7 Anti-Patterns for the AI Agent to Avoid

```tsx
// ANTI-PATTERN 1: Hardcoded colors bypass the design system
<div className="bg-blue-600 text-white border-gray-200">
// CORRECT: Semantic tokens
<div className="bg-primary text-primary-foreground border-border">

// ANTI-PATTERN 2: Arbitrary values that duplicate tokens
<div className="p-[16px] rounded-[6px]">
// CORRECT: Use configured spacing and radius
<div className="p-4 rounded-md">

// ANTI-PATTERN 3: Dark mode conditional classes on components
<div className="bg-white dark:bg-gray-900 text-gray-900 dark:text-gray-100">
// CORRECT: Semantic tokens handle dark mode automatically
<div className="bg-background text-foreground">

// ANTI-PATTERN 4: Creating a new component when shadcn/ui has one
// Don't: Build a custom dropdown from scratch
// Do: npx shadcn@latest add select

// ANTI-PATTERN 5: Inline styles
<div style={{ padding: '16px', color: '#2563eb' }}>
// CORRECT: Tailwind utilities + design tokens
<div className="p-4 text-primary">
```

---

## 11. Sources

The following sources informed this research:

### Component Libraries
- **shadcn/ui**: https://ui.shadcn.com -- Copy-paste React component library built on Radix + Tailwind
- **Radix UI Primitives**: https://radix-ui.com/primitives -- Unstyled, accessible React component primitives
- **Headless UI**: https://headlessui.com -- Unstyled components from Tailwind Labs (React + Vue)
- **Ark UI**: https://ark-ui.com -- Headless components powered by state machines (React + Vue + Solid)
- **React Aria (Adobe)**: https://react-spectrum.adobe.com/react-aria/ -- Accessible hooks for React components

### Design Token Standards
- **W3C Design Tokens Community Group**: https://design-tokens.github.io/community-group/format/ -- Draft specification for design token interchange format
- **Style Dictionary (Amazon)**: https://amzn.github.io/style-dictionary/ -- Build system for design tokens

### Color and Accessibility
- **WCAG 2.2**: https://www.w3.org/TR/WCAG22/ -- Web Content Accessibility Guidelines
- **APCA Contrast Algorithm**: https://github.com/Myndex/SAPC-APCA -- Advanced Perceptual Contrast Algorithm
- **Radix Colors**: https://radix-ui.com/colors -- Accessible color system with automatic dark mode
- **OKLCH Color Space**: https://oklch.com -- Interactive OKLCH color picker and documentation
- **Leonardo by Adobe**: https://leonardocolor.io -- Contrast-based color generation
- **Huetone**: https://huetone.ardov.me -- OKLCH-based palette builder
- **Color.js**: https://colorjs.io -- JavaScript library for color manipulation in any color space

### Typography
- **Utopia**: https://utopia.fyi -- Fluid responsive type and space calculator
- **Type Scale**: https://typescale.com -- Visual type scale generator
- **Google Fonts**: https://fonts.google.com -- Font hosting and pairing suggestions
- **Inter typeface**: https://rsms.me/inter/ -- Free variable font designed for screens

### Tailwind CSS
- **Tailwind CSS v4**: https://tailwindcss.com/blog/tailwindcss-v4 -- v4 announcement and documentation
- **Tailwind CSS Documentation**: https://tailwindcss.com/docs -- Official documentation
- **tailwindcss-animate**: https://github.com/jamiebuilds/tailwindcss-animate -- Animation utilities plugin
- **eslint-plugin-tailwindcss**: https://github.com/francoismassart/eslint-plugin-tailwindcss -- Lint rules for Tailwind

### Google Stitch
- **Google Stitch**: https://stitch.withgoogle.com -- AI UI prototyping tool from Google Labs
- **Model Context Protocol (MCP)**: https://modelcontextprotocol.io -- Open protocol for AI tool integration

### Design System Methodology
- **Nathan Curtis, "Naming Tokens in Design Systems"**: https://medium.com/eightshapes-llc/naming-tokens-in-design-systems-9e86c7444676
- **Brad Frost, Atomic Design**: https://atomicdesign.bradfrost.com -- Component hierarchy methodology
- **CSS Stats**: https://cssstats.com -- CSS analytics tool

> **Note on Research Methodology**: Web search and web fetch tools were unavailable during this research session. The content above is based on established documentation, specifications, and best practices for these widely-used tools as of early 2025. Specific details about Google Stitch MCP server integration and Tailwind CSS v4 final API should be verified against the latest official documentation, as these were in active development at the time of the knowledge cutoff. The core principles of CSS custom properties, token architecture, accessibility standards, and component library comparisons are stable and well-established.
