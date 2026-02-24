#!/usr/bin/env bash
# scripts/run-a11y-scan.sh
# Runs an axe-core accessibility scan via Playwright against a target URL/page.
# Saves report to .vibecrew/a11y/audit-{timestamp}.json
# Usage: run-a11y-scan.sh [url] [project_root]
# Output: JSON report to stdout

set -euo pipefail

TARGET_URL="${1:-http://localhost:3000}"
PROJECT_ROOT="${2:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
TIMESTAMP=$(date -u +%Y%m%d-%H%M%S)
REPORT_DIR="$PROJECT_ROOT/.vibecrew/a11y"
REPORT_FILE="$REPORT_DIR/audit-${TIMESTAMP}.json"

mkdir -p "$REPORT_DIR"

# Check if Playwright and axe-core are available
if ! npx --yes @axe-core/playwright --version &>/dev/null 2>&1; then
  echo '{"error": "axe-core/playwright not available", "violations": [], "scan_completed": false}' | tee "$REPORT_FILE"
  exit 0
fi

# Create a temporary Playwright script for the axe scan
SCAN_SCRIPT=$(mktemp /tmp/a11y-scan-XXXXXX.mjs)
cat > "$SCAN_SCRIPT" << 'SCAN_EOF'
import { chromium } from 'playwright';
import AxeBuilder from '@axe-core/playwright';

const url = process.argv[2] || 'http://localhost:3000';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  try {
    await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
  } catch (e) {
    console.log(JSON.stringify({
      error: `Failed to load ${url}: ${e.message}`,
      violations: [],
      scan_completed: false
    }));
    await browser.close();
    process.exit(0);
  }

  const results = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21aa', 'best-practice'])
    .analyze();

  const report = {
    url: url,
    timestamp: new Date().toISOString(),
    scan_completed: true,
    violations_count: results.violations.length,
    violations: results.violations.map(v => ({
      id: v.id,
      impact: v.impact,
      description: v.description,
      help: v.help,
      helpUrl: v.helpUrl,
      nodes_count: v.nodes.length,
      nodes: v.nodes.slice(0, 5).map(n => ({
        html: n.html.substring(0, 200),
        target: n.target,
        failureSummary: n.failureSummary
      }))
    })),
    passes_count: results.passes.length,
    incomplete_count: results.incomplete.length,
    summary: {
      critical: results.violations.filter(v => v.impact === 'critical').length,
      serious: results.violations.filter(v => v.impact === 'serious').length,
      moderate: results.violations.filter(v => v.impact === 'moderate').length,
      minor: results.violations.filter(v => v.impact === 'minor').length
    }
  };

  console.log(JSON.stringify(report, null, 2));
  await browser.close();
})();
SCAN_EOF

# Run the scan
SCAN_OUTPUT=$(node "$SCAN_SCRIPT" "$TARGET_URL" 2>/dev/null || echo '{"error": "scan execution failed", "violations": [], "scan_completed": false}')

# Save report
echo "$SCAN_OUTPUT" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "$REPORT_FILE"

# Clean up temp script
rm -f "$SCAN_SCRIPT"

# Output to stdout
echo "$SCAN_OUTPUT"
