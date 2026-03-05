---
name: audit
description: OWASP Top 10 security review — scan codebase, check dependencies, detect secrets
disable-model-invocation: false
category: analysis
---

# /audit

Run an OWASP Top 10 security audit on the current project. Scans for vulnerabilities across all ten OWASP categories, checks dependencies for known CVEs, and detects hardcoded secrets. Produces a structured audit report saved to `.vibecrew/audits/`.

---

## Step 1: Pre-flight Check

Verify that VibeCrew is initialized:

```bash
test -f ".vibecrew/state.json" && echo "exists" || echo "missing"
```

If `.vibecrew/state.json` does not exist, output EXACTLY this and stop:

```
VibeCrew not initialized. Run /setup first.
```

Do NOT output anything else. Do NOT create the file. Do NOT offer alternatives.

---

## Step 2: Detect Project Language

Scan the project root to determine the primary language and ecosystem.

Check for the following files in order of priority:

| File | Language |
|---|---|
| `package.json` | Node.js (JavaScript/TypeScript) |
| `pyproject.toml` | Python |
| `requirements.txt` | Python |
| `Gemfile` | Ruby |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `composer.json` | PHP |
| `pom.xml` | Java (Maven) |
| `build.gradle` | Java (Gradle) |

```bash
for f in package.json pyproject.toml requirements.txt Gemfile go.mod Cargo.toml composer.json pom.xml build.gradle; do
  test -f "$f" && echo "FOUND: $f"
done
```

If multiple files are found, note all detected languages. Use the first match as the primary language for reporting purposes.

If no project files are found, report:

```
No recognized project manifest found. The audit will run generic pattern scans only.
```

Continue with the audit regardless — generic security scans (secrets, OWASP code patterns) apply to any language.

---

## Step 3: Run Dependency Audit

Execute the multi-language dependency vulnerability scanner:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/scan-dependencies.sh"
```

Capture the JSON output. Parse the `results` object and note:

- Which languages were scanned successfully (`"status": "scanned"`)
- Which tools are missing (`"status": "tool_not_installed"`)
- Which lockfiles are absent (`"status": "no_lockfile"`)
- Total vulnerability counts per language

If all results are `"no_lockfile"`, note this but continue — the OWASP code scan is still valuable.

If a tool is not installed, note it for the final report as an informational finding.

---

## Step 4: Run Secret Detection

Execute the secret detection scanner:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect-secrets.sh"
```

Capture the JSON output. Note:

- Total count of secrets found
- Types of secrets detected (AWS keys, API keys, JWTs, etc.)
- Files containing secrets

Each detected secret will be included in the final audit report under the A02 (Cryptographic Failures) category.

---

## Step 5: Invoke Security Auditor Agent

Launch the `security-auditor` agent for the deep OWASP Top 10 scan:

The security-auditor agent will:
1. Scan all ten OWASP categories (A01-A10)
2. Use the dependency scan and secret detection results from Steps 3-4
3. Produce a structured findings JSON written to `.vibecrew/audits/audit-<timestamp>.json`

Wait for the agent to complete and read the audit report file.

If the agent report has `"status": "incomplete"`, inform the user:

```
The security audit was partially completed. Some OWASP categories may not have been fully scanned. Review the report for details.
```

---

## Step 6: Format Results

Read the audit report from `.vibecrew/audits/` and display findings grouped by severity.

Present the results in this format:

```
Security Audit Results
======================
Project:  <project name>
Language: <detected language>
Scanned:  <timestamp>

Critical: N findings
  - [A01] <file>:<line> — <description>
  - [A03] <file>:<line> — <description>

High: N findings
  - [A07] <file>:<line> — <description>

Medium: N findings
  - [A05] <file>:<line> — <description>

Low: N findings
  - [A09] <file>:<line> — <description>

Info: N findings
  - [A06] pip-audit not installed — install with: pip install pip-audit

----------------------
Summary: X critical, Y high, Z medium, W low, V info
Report:  .vibecrew/audits/audit-<timestamp>.json
```

If there are no findings for a severity level, omit that section entirely.

If there are zero total findings:

```
Security Audit Results
======================
Project:  <project name>
Language: <detected language>
Scanned:  <timestamp>

No security findings detected. Good job!

----------------------
Summary: 0 findings
Report:  .vibecrew/audits/audit-<timestamp>.json
```

---

## Step 7: GitHub Issues (Optional)

Check whether automatic GitHub issue creation is enabled:

```bash
jq -r '.audit.auto_github_issues // false' .vibecrew/config.json 2>/dev/null
```

**If `auto_github_issues` is `true`:**

1. Filter findings to only `critical` and `high` severity.
2. If there are critical/high findings, ask the user:
   > Found **N** critical/high findings. Create GitHub issues for them? (y/n)
3. **If the user confirms:**
   - For each critical/high finding, create a GitHub issue:
     ```bash
     gh issue create \
       --title "[Security] A0X: <short description>" \
       --body "## Security Finding\n\n**OWASP Category:** <category>\n**Severity:** <severity>\n**File:** <file>:<line>\n**CWE:** <cwe_id>\n\n### Description\n<description>\n\n### Remediation\n<remediation>\n\n---\n_Generated by VibeCrew /audit_" \
       --label "security"
     ```
   - Report the created issue URLs.
4. **If the user declines**, skip issue creation.

**If `auto_github_issues` is `false` or not set:**

Skip this step entirely. Do not mention GitHub issues.

---

## Step 8: Save Report

The audit report should already be saved by the security-auditor agent in Step 5. Verify the file exists:

```bash
ls -la .vibecrew/audits/audit-*.json 2>/dev/null | tail -1
```

If the report file exists, confirm:

```
Full report saved to: .vibecrew/audits/audit-<timestamp>.json
```

If the report file does not exist (agent did not write it), write a summary report using the temp-file-then-mv pattern:

```bash
mkdir -p .vibecrew/audits
AUDIT_TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
cat > ".vibecrew/audits/audit-${AUDIT_TIMESTAMP}.json.tmp" << 'EOF'
{ ... compiled findings JSON ... }
EOF
mv ".vibecrew/audits/audit-${AUDIT_TIMESTAMP}.json.tmp" ".vibecrew/audits/audit-${AUDIT_TIMESTAMP}.json"
```

---

## Rules

- **NEVER** auto-fix findings. The audit is read-only. Report findings and let the developer decide what to fix.
- **NEVER** create GitHub issues without asking the user first, even if `auto_github_issues` is `true`.
- **Always** report findings before offering to create issues.
- **Always** save the full report to `.vibecrew/audits/` before exiting.
- Use `${CLAUDE_PLUGIN_ROOT}` for all plugin-relative paths (scripts, agents, templates).
- Keep the summary output concise. The full JSON report has all the details; the terminal output is for quick orientation.
- If the dependency scan or secret scan fails, continue with the remaining steps. Do not abort the entire audit because one scanner had an issue.
- If there are more than 20 findings in a single severity group, show the first 10 and note `... and N more (see full report)`.
