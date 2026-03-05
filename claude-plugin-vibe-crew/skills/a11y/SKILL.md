---
name: a11y
description: WCAG 2.1 AA accessibility audit — axe-core scan, keyboard navigation, ARIA validation
disable-model-invocation: false
args: target_url
category: action
---

# /a11y

WCAG 2.1 AA accessibility audit. Runs an axe-core scan via Playwright, checks keyboard navigation patterns, validates ARIA usage, and reports violations by severity. Saves a structured report for Vibe Score tracking.

---

## Pre-flight Check

Verify that VibeCrew is initialized:

```bash
test -d ".vibecrew" && echo "initialized" || echo "missing"
```

If `.vibecrew/` does not exist, output EXACTLY this and stop:

```
VibeCrew not initialized. Run /setup first.
```

Create the a11y reports directory:

```bash
mkdir -p .vibecrew/a11y
```

### Check dependencies

Verify Playwright and axe-core are available:

```bash
jq -r '.devDependencies["@playwright/test"] // .dependencies["@playwright/test"] // empty' package.json 2>/dev/null
jq -r '.devDependencies["@axe-core/playwright"] // .dependencies["@axe-core/playwright"] // empty' package.json 2>/dev/null
```

If `@axe-core/playwright` is not installed, prompt:

```
@axe-core/playwright is required for accessibility scanning.
Install it? (yes/no)
```

If yes:

```bash
npm install -D @axe-core/playwright
```

If Playwright itself is not installed, also install it (see /e2e for setup).

### Determine target URL

Parse from `$ARGUMENTS` or ask:

```
What URL should be scanned for accessibility?
  Example: http://localhost:3000
  Default: http://localhost:3000
```

Verify the target is reachable:

```bash
curl -s -o /dev/null -w "%{http_code}" "{target_url}" 2>/dev/null || echo "unreachable"
```

If unreachable, warn:

```
Warning: {target_url} is not reachable. Make sure your dev server is running.
Start it with: npm run dev
```

---

## Step 1: axe-core Scan

### 1.1 Run the scan

Execute the VibeCrew a11y scan script:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/run-a11y-scan.sh" "{target_url}"
```

Parse the JSON output. If the scan failed, report the error and suggest troubleshooting.

### 1.2 Alternative: use existing axe config

If the project has the VibeCrew axe config template installed:

```bash
ls src/test-utils/axe-config.ts tests/axe-config.ts e2e/axe-config.ts 2>/dev/null || echo "no axe config"
```

Use the existing config for consistency with the project's a11y test setup.

---

## Step 2: Keyboard Navigation Checklist

Perform a keyboard navigation audit on the target page. Check for:

### Focus management
- [ ] All interactive elements are reachable via Tab key
- [ ] Focus order follows visual layout (logical tab sequence)
- [ ] Focus is visible (focus ring/outline on focused elements)
- [ ] No keyboard traps (can always Tab/Escape out of any element)

### Interaction patterns
- [ ] Buttons activate with Enter and Space
- [ ] Links activate with Enter
- [ ] Dropdowns/menus open with Enter/Space, navigate with Arrow keys, close with Escape
- [ ] Modals trap focus inside and return focus on close
- [ ] Form submission works with Enter key

### Skip navigation
- [ ] Skip-to-content link exists (or first focusable element is main content)

If the Playwright MCP is available, use it to interactively test keyboard navigation. Otherwise, generate a checklist for manual testing.

Report:

```
Keyboard Navigation
====================
  Checked:   {N} patterns
  Issues:    {N} found
  {list any keyboard issues}
```

---

## Step 3: ARIA Validation

Scan source files for ARIA usage patterns:

```bash
# Find ARIA attributes in source files
grep -rn 'aria-' --include='*.tsx' --include='*.jsx' --include='*.vue' --include='*.html' --include='*.svelte' 2>/dev/null | head -30
```

### Check for common ARIA issues

1. **Missing ARIA labels** — Interactive elements without accessible names
2. **Redundant ARIA** — ARIA attributes that duplicate native semantics (e.g., `role="button"` on `<button>`)
3. **Invalid ARIA** — Incorrect role/property combinations
4. **Missing landmark roles** — Page without `<main>`, `<nav>`, `<header>`, `<footer>` landmarks
5. **Dynamic content** — AJAX-loaded content without `aria-live` regions

Report:

```
ARIA Validation
================
  Attributes found: {N}
  Issues:           {N}
  {list any ARIA issues}
```

---

## Step 4: Report

### 4.1 Display violations by severity

```
Accessibility Audit: {target_url}
====================================

--- Critical ({N}) ---
{violations that prevent users from accessing content}

1. [{rule_id}] {description}
   Impact:  critical
   Help:    {help_url}
   Elements: {N} affected
     - {html_snippet}

--- Serious ({N}) ---
{violations that seriously impair usability}

1. [{rule_id}] {description}
   Impact:  serious
   Elements: {N} affected

--- Moderate ({N}) ---
{violations that degrade experience}

1. [{rule_id}] {description}
   Elements: {N} affected

--- Minor ({N}) ---
{violations that are cosmetic or edge-case}

Summary: {total_violations} violations ({critical} critical, {serious} serious, {moderate} moderate, {minor} minor)
Passes:  {passes_count} rules passed
```

### 4.2 Save report

The scan script already saves to `.vibecrew/a11y/audit-{timestamp}.json`. Verify the file exists:

```bash
ls -1t .vibecrew/a11y/audit-*.json 2>/dev/null | head -1
```

If the keyboard and ARIA checks found additional issues, append them to the report:

```bash
LATEST_REPORT=$(ls -1t .vibecrew/a11y/audit-*.json 2>/dev/null | head -1)
if [[ -n "$LATEST_REPORT" ]]; then
  jq --argjson keyboard '{...}' --argjson aria '{...}' \
    '. + {keyboard_audit: $keyboard, aria_audit: $aria}' \
    "$LATEST_REPORT" > "${LATEST_REPORT}.tmp" && mv "${LATEST_REPORT}.tmp" "$LATEST_REPORT"
fi
```

### 4.3 Recommendations

Based on the violations:

**If zero violations:**

```
Excellent! No accessibility violations detected. Your page meets WCAG 2.1 AA standards.
```

**If violations exist:**

```
Recommended fixes (priority order):
1. [critical] {fix_description} — affects {N} users
2. [serious]  {fix_description}
3. ...

Resources:
- WCAG 2.1 Quick Reference: https://www.w3.org/WAI/WCAG21/quickref/
- axe Rules: https://dequeuniversity.com/rules/axe/
```

---

## Rules

- Use `${CLAUDE_PLUGIN_ROOT}` for all plugin-relative paths.
- **WCAG 2.1 AA is the target standard.** Do not audit against AAA unless the user explicitly requests it.
- **axe-core is the primary scanner.** The keyboard and ARIA checks supplement automated scanning with manual verification patterns.
- **Never modify source code** during the audit. Report violations and let the developer fix them.
- **Save every report.** Even clean audits are tracked for Vibe Score bonuses.
- **Severity comes from axe-core.** Use axe's impact levels (critical, serious, moderate, minor) directly. Do not reclassify.
- If the dev server is not running, help the user start it or accept a different URL.
- If the Playwright MCP server is available, use it for interactive accessibility exploration alongside the automated scan.
- Maximum 5 pages per audit. If the user wants to scan more pages, run /a11y multiple times with different URLs.
- The a11y audit earns a +2 Vibe Score bonus when the report exists and shows zero critical/serious violations.
