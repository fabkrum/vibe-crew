# Safety Design

> **Architecture Document 2.4 (Revised)** | VibeOS Plugin Safety Model
>
> This document defines the complete safety architecture for VibeOS. Every mechanism described here is enforced deterministically by bash scripts and declarative configuration -- never by relying on the model to "remember" safety rules. The target user is non-technical and may not understand the implications of risky operations. Safety is the non-negotiable foundation layer: without it, a single bad command can destroy data, leak credentials, or corrupt the repository.
>
> **v1.0 Revision Notes.** This revision updates the safety model for the consolidated 5-agent topology (Session Startup, Workflow Orchestrator, Stack Scout, Builder, Verifier), resolves the Orchestrator write permission contradiction from v0.9, adds cost guardrails for unattended execution, adds CLAUDE.md size management to prevent rule bloat, and updates rollback strategies for worktree-based isolation.

---

## Table of Contents

1. [Three-Tier Trust Model](#1-three-tier-trust-model)
2. [File System Restrictions](#2-file-system-restrictions)
3. [Blocked Operations](#3-blocked-operations)
4. [Dual Enforcement Strategy](#4-dual-enforcement-strategy)
5. [Phase Gate Implementation](#5-phase-gate-implementation)
6. [Notification System (Interrupt Protocol)](#6-notification-system-interrupt-protocol)
7. [Rollback Strategies](#7-rollback-strategies)
8. [Context Window Safety](#8-context-window-safety)
9. [Cost Guardrails](#9-cost-guardrails)
10. [CLAUDE.md Size Management](#10-claudemd-size-management)
11. [Security of Generated Code](#11-security-of-generated-code)
12. [Testing the Safety System](#12-testing-the-safety-system)

---

## 1. Three-Tier Trust Model

All operations that VibeOS agents can perform are classified into one of three trust tiers. The tier determines whether the operation proceeds silently, requires a one-time confirmation, or always blocks for explicit user approval. The default posture is conservative: when in doubt, escalate.

### 1.1 Tier 1 -- Autonomous (Always Proceed)

Operations that are read-only or produce trivially reversible side effects. These run without any user interaction and without consuming a permission prompt.

| Operation | Tool(s) | Justification |
|-----------|---------|---------------|
| Read any project file | `Read` | Read-only, no side effects |
| Search with Glob/Grep | `Glob`, `Grep` | Read-only |
| Web search and documentation lookup | `WebSearch`, `WebFetch`, Context7 MCP | Read-only external data |
| Run test suite | `Bash(npm test)`, `Bash(npx vitest *)` | Isolated, read-only output |
| Run linter | `Bash(eslint *)`, `Bash(prettier --check)` | Read-only output |
| Run build | `Bash(npm run build)` | Produces artifacts in known directories |
| Run type checker | `Bash(npx tsc --noEmit)` | Read-only analysis |
| Auto-format written files | PostToolUse `format-code.sh` | Modifies only files the agent just wrote |
| Git queries | `Bash(git status)`, `Bash(git log *)`, `Bash(git diff *)`, `Bash(git branch)` | Read-only git state |
| Create feature branches | `Bash(git checkout -b feat/*)`, `Bash(git checkout -b fix/*)` | Non-destructive, reversible |
| Conventional commits on feature branches | `Bash(git add *)`, `Bash(git commit -m *)` | Versioned and reversible |
| Modify `.vibeos/` state files via scripts | `Bash(jq ... .vibeos/state.json)` | Plugin state, easily reset |
| Write to planning artifacts | `Write`, `Edit` to `docs/`, `CLAUDE.md`, `VISION.md`, `design-system.css` | Non-code, reversible |

**Rationale.** These operations either cannot cause harm (reads) or produce changes that git can trivially undo (commits on feature branches). Requiring approval for these would destroy autonomous workflow fluency.

### 1.2 Tier 2 -- Supervised (Confirm Once Per Session)

Operations that modify the project in standard ways but are part of normal development workflow. The user approves the first invocation of each operation type; subsequent invocations of the same type are auto-approved for the remainder of the session.

| Operation | Tool(s) | Approval Token | Notes |
|-----------|---------|----------------|-------|
| Write source code | `Write`, `Edit` to `src/`, `app/`, `lib/`, `components/` | `source-write` | Auto-approved after foundation is complete |
| Install project dependencies | `Bash(npm install <package>)` | `npm-install` | Modifies lockfile |
| Push to feature branch | `Bash(git push origin feat/*)` | `git-push-feature` | Affects remote state |
| Create pull request | `Bash(gh pr create *)` | `pr-create` | Affects collaboration workflow |
| Delete files within project | `Bash(rm src/old-component.tsx)` | `file-delete` | Data loss potential |
| Create new files in source directories | `Write` to new path in `src/` | `file-create` | First time only |
| Run dev server | `Bash(npm run dev)` | `dev-server` | Binds a port |

**Session-scoped approval tracking.** Approvals are recorded in `.vibeos/state.json` (see `architecture/schemas.md` Section 3 for the canonical schema) so hook scripts can check whether an operation type has already been approved this session.

When a PreToolUse hook encounters a Tier 2 operation, it checks this file. If the approval token exists, the operation proceeds. If not, the hook blocks the operation (exit code 2) and the model presents the approval request to the user.

### 1.3 Tier 3 -- Manual (Always Require Explicit Approval)

Operations that are destructive, irreversible, or security-sensitive. These always require explicit user approval, regardless of prior approvals. There is no "approve once" shortcut for Tier 3.

| Operation | Tool(s) | Why Always Ask |
|-----------|---------|----------------|
| Force push | `Bash(git push --force *)` | Destroys remote history |
| Delete branches | `Bash(git branch -D *)` | Data loss for collaborators |
| Modify `.env` files | `Write`, `Edit` to `.env*` | Credential exposure risk |
| Run database migrations | `Bash(npx prisma migrate deploy)` | Modifies persistent data schema |
| Deploy or publish | `Bash(npm publish)`, `Bash(vercel deploy)` | Production impact |
| Merge to main/master | `Bash(git merge *)` into main | Affects all collaborators |
| Reset or rebase shared branches | `Bash(git reset *)`, `Bash(git rebase *)` on main | History rewrite |
| System modifications | `sudo`, global installs, shell profile edits | OS stability |
| CLAUDE.md rule mutations | Verifier proposals (v1.1: Performance Coach) | Changes project rules permanently |
| Access credential files | `Read` or `Bash(cat)` on `.env`, `.ssh/`, `.aws/` | Security |
| Network requests with data | `Bash(curl -X POST *)` | Potential exfiltration |

**Implementation.** Tier 3 operations are enforced by two mechanisms working together: (1) `settings.json` `deniedTools` entries that unconditionally block the most dangerous patterns, and (2) PreToolUse hook scripts that block operations with detailed error messages and suggest safer alternatives.

### 1.4 Trust Tier Summary Diagram

```
TIER 1 (Autonomous)          TIER 2 (Supervised)           TIER 3 (Manual)
Auto-approved, silent        Approve once per session       Always ask, every time

  Read files                   Write source code             Force push
  Search/Grep                  Install dependencies          Delete branches
  Run tests                    Git push (feature)            Modify .env files
  Run linter/build             Create PRs                    Database migrations
  Git queries                  Delete files (project)        Deploy/publish
  Feature branch commits       Run dev server                Merge to main
  .vibeos/ state via scripts                                 System modifications
  Context7 lookups                                           CLAUDE.md mutations
  Format code                                                Credential access
```

---

## 2. File System Restrictions

### 2.1 Project Root Confinement

All file write operations are confined to the project root directory. The project root is determined by `git rev-parse --show-toplevel` (falling back to `pwd` if not in a git repository). Every Write and Edit operation passes through a PreToolUse hook that validates the target path against the project root.

### 2.2 The `sandbox.sh` Module

All hook scripts that need path validation source a shared `sandbox.sh` module. This creates a single point of truth for path safety logic and prevents inconsistencies between scripts.

```bash
#!/bin/bash
# scripts/sandbox.sh
# Source this from other hook scripts: source "${CLAUDE_PLUGIN_ROOT}/scripts/sandbox.sh"

SANDBOX_PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SANDBOX_PROJECT_ROOT=$(realpath "$SANDBOX_PROJECT_ROOT")

# --- Path Canonicalization ---
# Resolves symlinks, relative paths, and ~/ references to absolute canonical paths.
# This is the critical defense against path traversal attacks.

sandbox_canonicalize() {
  local path="$1"
  # Expand ~ to $HOME
  path="${path/#\~/$HOME}"
  # Make relative paths absolute
  [[ "$path" != /* ]] && path="$SANDBOX_PROJECT_ROOT/$path"
  # Resolve to canonical path
  if [[ -e "$path" ]]; then
    realpath "$path"
  else
    local parent=$(dirname "$path")
    local name=$(basename "$path")
    if [[ -d "$parent" ]]; then
      echo "$(realpath "$parent")/$name"
    else
      realpath -m "$path" 2>/dev/null || echo "$path"
    fi
  fi
}

# --- Project Root Check ---
# Returns 0 if the path resolves inside the project root, 1 otherwise.

sandbox_check_path() {
  local path="$1"
  local canonical=$(sandbox_canonicalize "$path")

  # Path must start with the project root
  if [[ "$canonical" != "$SANDBOX_PROJECT_ROOT"* ]]; then
    return 1
  fi

  # Walk up the path chain checking for symlinks that escape the project
  local current="$canonical"
  while [[ "$current" != "$SANDBOX_PROJECT_ROOT" && "$current" != "/" ]]; do
    if [[ -L "$current" ]]; then
      local target=$(readlink -f "$current")
      if [[ "$target" != "$SANDBOX_PROJECT_ROOT"* ]]; then
        return 1
      fi
    fi
    current=$(dirname "$current")
  done

  return 0
}

# --- Sensitive File Check ---
# Returns 0 if the file is NOT sensitive, 1 if it IS sensitive and must be blocked.

sandbox_check_sensitive_file() {
  local path="$1"
  local canonical=$(sandbox_canonicalize "$path")
  local basename=$(basename "$canonical")

  local sensitive_patterns=(
    ".env" ".env.local" ".env.production" ".env.staging" ".env.development"
    "credentials.json" "service-account.json"
    "id_rsa" "id_ed25519" "id_ecdsa"
    ".npmrc" ".pypirc"
  )

  for pattern in "${sensitive_patterns[@]}"; do
    if [[ "$basename" == "$pattern" ]]; then
      return 1
    fi
  done

  # Block writes inside .git/ directory
  if [[ "$canonical" == *"/.git/"* || "$canonical" == *"/.git" ]]; then
    return 1
  fi

  # Block writes to .ssh/ and .aws/ directories
  if [[ "$canonical" == *"/.ssh/"* || "$canonical" == *"/.aws/"* ]]; then
    return 1
  fi

  return 0
}

# --- Combined Validation ---
# Returns 0 if the write is safe, 1 with a descriptive message if blocked.

sandbox_validate_write() {
  local path="$1"

  if ! sandbox_check_path "$path"; then
    echo "SANDBOX VIOLATION: Write target outside project root"
    echo "  Path: $path"
    echo "  Resolved: $(sandbox_canonicalize "$path")"
    echo "  Project: $SANDBOX_PROJECT_ROOT"
    return 1
  fi

  if ! sandbox_check_sensitive_file "$path"; then
    echo "SANDBOX VIOLATION: Write target is a sensitive file"
    echo "  Path: $path"
    echo "  Sensitive files (.env, .ssh/, .aws/, .git/) cannot be modified by agents."
    echo "  If you need to modify this file, do it manually."
    return 1
  fi

  return 0
}
```

### 2.3 Path Traversal Detection

Path traversal is the primary escape vector for sandbox confinement. A path like `src/../../etc/passwd` appears to be inside the project but resolves outside it. The `sandbox.sh` module defends against all known traversal patterns:

| Pattern | Example | Defense |
|---------|---------|---------|
| `../` sequences | `src/../../../etc/passwd` | `realpath` canonicalization resolves to absolute path |
| Absolute paths outside project | `/etc/hosts` | Canonical path comparison against project root |
| Home directory references | `~/`, `$HOME/` | Tilde expansion before canonicalization |
| Symlink targets | `src/link -> /etc/` | `readlink -f` resolves symlink chain, validates target |
| Null bytes | `file%00.txt` | bash and `realpath` handle these safely |
| Double encoding | `..%252f..%252f` | `realpath` operates on the decoded filesystem path |

**Critical implementation note.** String-based path comparison (checking if a path string starts with the project root) is trivially bypassed. All path checks must use `realpath` canonicalization first, then compare the resolved absolute path.

### 2.4 Explicit Deny List

Even if a path resolves within the project root, certain files and directories are unconditionally blocked:

| Target | Reason |
|--------|--------|
| `.env`, `.env.local`, `.env.production`, `.env.staging`, `.env.development` | Contains secrets and credentials |
| `.git/` | Repository internals, corruption risk |
| `.ssh/` | SSH keys, authentication credentials |
| `.aws/` | AWS access keys and configuration |
| `credentials.json`, `service-account.json` | Cloud provider service credentials |
| `id_rsa`, `id_ed25519`, `id_ecdsa` | Private cryptographic keys |
| `.npmrc`, `.pypirc` | Package registry authentication tokens |

The deny list is configurable per project via `.vibeos/config.json` (see `architecture/schemas.md` Section 2 for the canonical schema):

```json
{
  "sandbox": {
    "additional_sensitive_files": [
      ".gcloud/",
      "firebase-config.json",
      "stripe-secret.key"
    ]
  }
}
```

### 2.5 Restrict-Paths Hook Script

The `restrict-paths.sh` script is the PreToolUse hook that enforces file system restrictions on every Write and Edit operation:

```bash
#!/bin/bash
# scripts/restrict-paths.sh
# PreToolUse hook for Write|Edit -- blocks writes outside project root
# and to sensitive files.

set -euo pipefail

source "${CLAUDE_PLUGIN_ROOT}/scripts/sandbox.sh"

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only apply to Write and Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# Validate the write target
if ! sandbox_validate_write "$FILE_PATH"; then
  # sandbox_validate_write already printed the error message
  exit 2
fi

# All checks passed
exit 0
```

---

## 3. Blocked Operations

The `protect-data.sh` PreToolUse hook script inspects the `command` field of every Bash tool invocation and blocks dangerous patterns. Commands are organized into eight categories totaling 51 blocked patterns.

### 3.1 Category 1: Destructive File Operations

| # | Pattern | Regex | Risk |
|---|---------|-------|------|
| 1 | `rm -rf /` | `rm\s+(-[a-zA-Z]*r[a-zA-Z]*f\|--recursive).*\s+/[^a-zA-Z]` | Critical |
| 2 | `rm -rf ~` | `rm\s+(-[a-zA-Z]*r[a-zA-Z]*f\|--recursive).*(\s+~\|\$HOME)` | Critical |
| 3 | `rm -rf` outside project | `rm\s+(-[a-zA-Z]*r[a-zA-Z]*f\|--recursive)` (path verified) | High |
| 4 | `mkfs` | `mkfs\b` | Critical |
| 5 | `dd if=` | `dd\s+if=` | Critical |
| 6 | `> /dev/sda` | `>\s*/dev/(sd\|hd\|nvme)` | Critical |
| 7 | `truncate` | `truncate\s+` | High |

### 3.2 Category 2: Privilege Escalation

| # | Pattern | Regex | Risk |
|---|---------|-------|------|
| 8 | `sudo` | `\bsudo\b` | Critical |
| 9 | `su -` | `\bsu\s+-` | Critical |
| 10 | `doas` | `\bdoas\b` | Critical |
| 11 | `pkexec` | `\bpkexec\b` | Critical |
| 12 | `chmod 777` | `chmod\s+777` | High |
| 13 | `chmod -R 777` | `chmod\s+(-[a-zA-Z]*R).*777` | Critical |
| 14 | `chown` | `\bchown\b` | High |
| 15 | `setuid` | `chmod\s+[u+]*s` | Critical |

### 3.3 Category 3: Git Danger Zone

| # | Pattern | Regex | Risk |
|---|---------|-------|------|
| 16 | `git push --force` | `git\s+push\s+.*--force` | Critical |
| 17 | `git push -f` | `git\s+push\s+.*-f\b` | Critical |
| 18 | `git reset --hard` | `git\s+reset\s+--hard` | High |
| 19 | `git clean -f` | `git\s+clean\s+.*-[a-zA-Z]*f` | High |
| 20 | `git rebase main/master` | `git\s+rebase\s+.*(main\|master)` | High |
| 21 | `git branch -D main/master` | `git\s+branch\s+-D\s+(main\|master)` | Critical |
| 22 | `git checkout .` (discard all) | `git\s+checkout\s+\.\s*$` | Medium |
| 23 | `git stash drop` | `git\s+stash\s+drop` | Medium |
| 24 | `git push` to main/master | `git\s+push\s+.*\s+(main\|master)\b` | High |

### 3.4 Category 4: Database Destruction

| # | Pattern | Regex (case-insensitive) | Risk |
|---|---------|--------------------------|------|
| 25 | `DROP TABLE` | `DROP\s+TABLE` | Critical |
| 26 | `DROP DATABASE` | `DROP\s+DATABASE` | Critical |
| 27 | `DROP SCHEMA` | `DROP\s+SCHEMA` | Critical |
| 28 | `TRUNCATE TABLE` | `TRUNCATE\s+TABLE` | Critical |
| 29 | `DELETE FROM` without WHERE | `DELETE\s+FROM\s+\w+\s*;` | High |

### 3.5 Category 5: Credential and Secret Exposure

| # | Pattern | Regex | Risk |
|---|---------|-------|------|
| 30 | Read `.env` files | `cat\s+.*\.env\b` | High |
| 31 | Read SSH keys | `cat\s+.*\.ssh/` | Critical |
| 32 | Read AWS credentials | `cat\s+.*\.aws/(credentials\|config)` | Critical |
| 33 | `curl` with credentials | `curl\s+.*(-u\|--user)` | High |
| 34 | Print all environment vars | `\bprintenv\b\|env\s*$\|\bset\s*$` | Medium |

### 3.6 Category 6: System Modification

| # | Pattern | Regex | Risk |
|---|---------|-------|------|
| 35 | `npm install -g` | `npm\s+install\s+(-g\|--global)` | High |
| 36 | `brew install` | `\bbrew\s+install\b` | Medium |
| 37 | `apt install` | `\bapt(-get)?\s+install\b` | High |
| 38 | Modify shell profiles | `>>?\s+.*\.(bashrc\|zshrc\|profile\|bash_profile)` | High |
| 39 | `launchctl` | `\blaunchctl\b` | High |
| 40 | `systemctl` | `\bsystemctl\b` | High |
| 41 | `crontab` | `\bcrontab\b` | High |
| 42 | `defaults write` | `\bdefaults\s+write\b` | High |

### 3.7 Category 7: Network Exfiltration

| # | Pattern | Regex | Risk |
|---|---------|-------|------|
| 43 | `curl` POST with data | `curl\s+.*(-X\s+POST\|-d\|--data)` | Medium |
| 44 | `nc` (netcat) | `\bnc\b\|\bncat\b\|\bnetcat\b` | High |
| 45 | `scp` | `\bscp\b` | High |
| 46 | `rsync` to remote | `rsync\s+.*:` | High |
| 47 | `wget` to pipe | `wget\s+.*-O\s*-\s*\|` | Medium |

### 3.8 Category 8: Resource Exhaustion

| # | Pattern | Regex | Risk |
|---|---------|-------|------|
| 48 | Fork bomb | `:\(\)\{.*:\|.*\}\s*;` | Critical |
| 49 | `yes \|` | `\byes\s*\|` | Medium |
| 50 | `while true` (no break) | `while\s+true\s*;.*do` | Medium |
| 51 | `kill -9` | `\bkill\s+(-9\|-SIGKILL)\b` | High |

### 3.9 Block Response Messages

When `protect-data.sh` blocks a command, it prints a descriptive message that the model receives. The message includes: (1) what was blocked, (2) why it is dangerous, and (3) a safer alternative when one exists.

```
BLOCKED: git reset --hard discards all uncommitted changes permanently.
Safer alternative: git stash (preserves changes) or git reset --soft (keeps staging).
```

```
BLOCKED: Global npm install detected.
Command: npm install -g typescript
Use local project dependencies instead: npm install typescript (without -g).
```

### 3.10 Known Limitation

Regex-based command blocking is a necessary but imperfect defense. A sufficiently creative command can bypass string matching through base64 encoding, variable expansion, `eval`, or heredocs. This is unlikely in a model-generated context but is documented as a residual risk. The mitigation is defense-in-depth: even if command blocking is bypassed, file system restrictions (Section 2) and worktree-based rollback (Section 7) provide additional safety layers.

---

## 4. Dual Enforcement Strategy

Safety is enforced by two independent layers that complement each other. Neither layer alone is sufficient.

### 4.1 Layer 1: `settings.json` Deny Rules

The `settings.json` file provides declarative, zero-token permission control. It determines whether a tool runs without prompting (allowedTools), triggers a permission prompt (default), or is unconditionally blocked (deniedTools).

**Strengths:** Zero-cost enforcement. Simple glob pattern matching. Cannot be bypassed by the model. Evaluated before hooks.

**Limitations:** Cannot inspect command content or file paths. Cannot apply conditional logic (e.g., "allow git push only on feature branches"). Cannot provide custom error messages.

```json
{
  "permissions": {
    "allowedTools": [
      "Read",
      "Write",
      "Edit",
      "Glob",
      "Grep",
      "Bash(npm test)",
      "Bash(npm run test:*)",
      "Bash(npm run lint)",
      "Bash(npm run lint:*)",
      "Bash(npm run build)",
      "Bash(npm run dev)",
      "Bash(npm run format)",
      "Bash(npx prettier *)",
      "Bash(npx eslint *)",
      "Bash(npx vitest *)",
      "Bash(npx tsc *)",
      "Bash(npx playwright *)",
      "Bash(git status)",
      "Bash(git log *)",
      "Bash(git diff *)",
      "Bash(git add *)",
      "Bash(git commit -m *)",
      "Bash(git checkout -b feat/*)",
      "Bash(git checkout -b fix/*)",
      "Bash(git checkout -b docs/*)",
      "Bash(git checkout feat/*)",
      "Bash(git checkout fix/*)",
      "Bash(git push origin feat/*)",
      "Bash(git push origin fix/*)",
      "Bash(git push -u origin feat/*)",
      "Bash(git push -u origin fix/*)",
      "Bash(git branch)",
      "Bash(git branch -a)",
      "Bash(git worktree *)",
      "Bash(gh pr create *)",
      "Bash(gh pr list *)",
      "Bash(gh pr view *)",
      "Bash(jq *)",
      "Bash(cat .vibeos/*)",
      "Bash(ls *)",
      "Bash(wc *)",
      "Bash(sort *)",
      "Bash(head *)",
      "Bash(tail *)",
      "Bash(mkdir *)",
      "Bash(cp *)",
      "Bash(mv *)"
    ],
    "deniedTools": [
      "Bash(sudo *)",
      "Bash(su *)",
      "Bash(doas *)",
      "Bash(pkexec *)",
      "Bash(git push --force *)",
      "Bash(git push -f *)",
      "Bash(git reset --hard *)",
      "Bash(git clean -f *)",
      "Bash(git clean -fd *)",
      "Bash(rm -rf /)",
      "Bash(rm -rf ~)",
      "Bash(rm -rf $HOME)",
      "Bash(chmod 777 *)",
      "Bash(chmod -R 777 *)",
      "Bash(npm install -g *)",
      "Bash(kill -9 *)",
      "Bash(kill -SIGKILL *)",
      "Bash(launchctl *)",
      "Bash(defaults write *)",
      "Bash(systemctl *)",
      "Bash(crontab *)",
      "Bash(mkfs *)",
      "Bash(dd if=*)"
    ]
  }
}
```

### 4.2 Layer 2: PreToolUse Command Hooks

Hook scripts provide complex validation logic that `settings.json` cannot express. They receive the full tool invocation as JSON via stdin and can inspect command content, file paths, and conditional state.

**Strengths:** Can inspect command arguments and file paths. Can apply conditional logic. Can provide custom error messages with safer alternatives. Can check project state (e.g., phase gate status).

**Limitations:** Consumes script execution time (though not model tokens). Regex matching can be bypassed by obfuscation. Must be kept in sync with `settings.json` rules.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/protect-data.sh",
            "timeout": 10
          }
        ]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/restrict-paths.sh",
            "timeout": 10
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/phase-gate.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

### 4.3 How the Two Layers Interact

```
Agent invokes a tool (e.g., Bash with "git push --force origin main")
    |
    v
Layer 1: settings.json evaluation
    |
    +--> "Bash(git push --force *)" matches deniedTools
    +--> BLOCKED immediately (zero tokens, no hook invoked)
    |
    v (if not matched by deniedTools)
Layer 1: settings.json allowedTools check
    |
    +--> If matched: auto-approved (no permission prompt)
    +--> If not matched: permission prompt shown to user
    |
    v (if allowed to proceed)
Layer 2: PreToolUse hooks fire in sequence
    |
    +--> protect-data.sh inspects command content via regex
    |    Exit 0 = allowed, Exit 2 = blocked with message
    |
    +--> restrict-paths.sh validates file paths (Write/Edit only)
    |    Exit 0 = allowed, Exit 2 = blocked with message
    |
    +--> phase-gate.sh checks foundation status (Write/Edit only)
    |    Exit 0 = allowed, Exit 2 = blocked with message
    |
    v
Tool executes
```

**Key design principle.** `settings.json` is the coarse filter (simple pattern matching, fast, unconditional). Hooks are the fine filter (complex validation, conditional, with custom messages). Both must be configured. `settings.json` catches the obvious patterns that do not need explanation. Hooks catch the nuanced patterns that require contextual error messages.

### 4.4 Per-Agent Permission Scoping

Each VibeOS agent is launched with a tailored tool permission set defined in its agent `.md` file (see `architecture/agents.md` for full YAML frontmatter). Agents that do not need write access do not receive it.

**v1.0 Five-Agent Tool Permission Table:**

| Agent | Model | Allowed Tools | Disallowed Tools | Isolation |
|-------|-------|---------------|------------------|-----------|
| Session Startup | Haiku | `Read`, `Bash`, `Glob`, `Grep` | `Write`, `Edit`, `WebSearch`, `WebFetch`, Agent Teams, all MCP | Inline |
| Workflow Orchestrator | Opus | `Read`, `Bash`, `Glob`, `Grep`, `TeamCreate`, `TaskCreate`, `SendMessage` | `Write`, `Edit`, `WebSearch`, `WebFetch` | Inline |
| Stack Scout | Opus | `Read`, `Bash`, `Glob`, `Grep`, `WebSearch`, `WebFetch`, Context7 MCP, Puppeteer MCP | `Write`, `Edit`, `TeamCreate`, `TaskCreate`, `SendMessage` | Worktree |
| Builder | Opus | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep`, Context7 MCP | `WebSearch`, `WebFetch`, Puppeteer MCP, Agent Teams | Worktree |
| Verifier | Haiku | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep`, Context7 MCP | `WebSearch`, `WebFetch`, Puppeteer MCP, Agent Teams | Inline |

**Orchestrator write permission resolution.** The Orchestrator has `disallowedTools: Write, Edit` to prevent scope creep into source code writing. It needs to update `.vibeos/` state files (advancing feature phases, processing signals, updating backlog). This is resolved by using `Bash` to run shared scripts that modify `.vibeos/` state files. For example:

```bash
# Orchestrator advances a feature phase via Bash (NOT via Write tool)
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/complete-phase.sh feat-001 code")

# Orchestrator updates state via jq + Bash (NOT via Write tool)
Bash("jq '.foundation.complete = true' .vibeos/state.json > .vibeos/state.json.tmp && mv .vibeos/state.json.tmp .vibeos/state.json")

# Orchestrator processes a signal file via Bash (NOT via Write tool)
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/process-signal.sh builder-complete")
```

The scripts (`complete-phase.sh`, `claim-task.sh`, `update-backlog.sh`) are the same validated code paths used by all agents. This ensures consistent state mutations regardless of which agent triggers them, while maintaining the Orchestrator's `disallowedTools: Write, Edit` constraint.

**Principle of least privilege.** Stack Scout has no file write access. Session Startup has no file write access. The Orchestrator cannot write files directly -- only via shared Bash scripts that modify `.vibeos/` state. This limits the blast radius if any agent behaves unexpectedly.

---

## 5. Phase Gate Implementation

### 5.1 Purpose

The phase gate enforces the core VibeOS design principle: **research before code**. It blocks all source code writes until the Tier 1 foundation is complete. This prevents the most expensive mistake in AI-assisted development -- writing code against incorrect architectural decisions, the wrong design system, or an inappropriate technology stack.

### 5.2 What the Phase Gate Blocks

The phase gate intercepts all Write and Edit operations via a PreToolUse hook. If the target file is inside a source code directory and the foundation is incomplete, the operation is blocked.

**Blocked directories (source code -- requires foundation):**

| Directory | Description |
|-----------|-------------|
| `src/` | Application source code |
| `app/` | Next.js app directory |
| `pages/` | Next.js pages directory |
| `components/` | UI components |
| `lib/` | Library code |
| `utils/` | Utility functions |
| `hooks/` (React) | Custom React hooks |
| `api/` | API routes |
| `server/` | Server-side code |
| `features/` | Feature modules |

**Allowed files (planning artifacts -- always writeable):**

| File/Directory | Purpose |
|----------------|---------|
| `CLAUDE.md` | Project rules and conventions |
| `VISION.md` | Project goals and vision statement |
| `design-system.css` | Design tokens and component styles |
| `roadmap.md` | Feature roadmap with priorities |
| `tdr/`, `*.tdr.md` | Technology Decision Records |
| `.vibeos/` | VibeOS state and configuration |
| `docs/` | Documentation |
| `research/` | Research notes |
| `package.json` | Dependency manifest |
| `tsconfig.json` | TypeScript configuration |
| `.gitignore` | Git ignore rules |
| `.env.example` | Environment variable template (not `.env`) |
| `.prettierrc`, `.eslintrc` | Formatting and linting configuration |
| `commitlint.config.*` | Commit message conventions |

### 5.3 Foundation Completion Criteria

The phase gate reads `foundation.complete` (boolean) from `.vibeos/state.json` to determine whether the foundation is complete. All five Tier 1 artifacts must be present and approved before `foundation.complete` flips to `true`.

See `architecture/schemas.md` Section 3 for the canonical `state.json` schema, including the `foundation` object with per-artifact `status`, `file`, and `approved_at` fields.

The `foundation.complete` flag is set to `true` only when every artifact has `status: "complete"` and a non-null `approved_at` timestamp. This is the single boolean the phase gate hook checks for fast evaluation.

### 5.4 Phase Gate Script

```bash
#!/bin/bash
# scripts/phase-gate.sh
# PreToolUse hook for Write|Edit -- blocks source code writes before foundation

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibeos/state.json"

# --- Parse input ---
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only apply to Write and Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# --- Check foundation status ---
if [[ ! -f "$STATE_FILE" ]]; then
  # No state file -- allow writes to .vibeos/ itself (bootstrap)
  if [[ "$FILE_PATH" == *".vibeos/"* ]]; then
    exit 0
  fi
  # Output JSON hookSpecificOutput to deny
  cat <<HOOK_OUTPUT
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "reason": "VibeOS state not initialized. Run /setup first."
  }
}
HOOK_OUTPUT
  exit 2
fi

# Read foundation.complete from the canonical state.json schema
# (see architecture/schemas.md Section 3)
FOUNDATION_COMPLETE=$(jq -r '.foundation.complete // false' "$STATE_FILE" 2>/dev/null || echo "false")

# If foundation is complete, all writes are allowed
# (path validation is handled by restrict-paths.sh)
if [[ "$FOUNDATION_COMPLETE" == "true" ]]; then
  exit 0
fi

# --- Foundation is incomplete -- check if this is a planning artifact ---

RELATIVE_PATH="${FILE_PATH#$PROJECT_ROOT/}"
FILENAME=$(basename "$FILE_PATH")

# Always-allowed patterns during Tier 1
ALLOWED_PATTERNS=(
  "CLAUDE.md"
  "VISION.md"
  "design-system.css"
  "roadmap.md"
  ".vibeos/"
  "docs/"
  "tdr/"
  "research/"
  "package.json"
  "package-lock.json"
  "tsconfig.json"
  ".gitignore"
  ".env.example"
  ".prettierrc"
  ".eslintrc"
  "commitlint.config"
)

for pattern in "${ALLOWED_PATTERNS[@]}"; do
  if [[ "$RELATIVE_PATH" == "$pattern"* || "$FILENAME" == "$pattern"* ]]; then
    exit 0  # Planning artifact -- allow
  fi
done

# Check for TDR files by extension
if [[ "$FILENAME" == *.tdr.md ]]; then
  exit 0
fi

# --- This is a source code write during Tier 1 -- BLOCK ---

# Collect missing artifacts for the error message
MISSING=$(jq -r \
  '.foundation.artifacts | to_entries[] | select(.value.status != "complete") | "  - \(.value.file // "not created") (\(.key))"' \
  "$STATE_FILE" 2>/dev/null || echo "  (unable to read state)")

cat <<HOOK_OUTPUT
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "reason": "Cannot write source code before the project foundation is complete.\n\nFile: $FILE_PATH\n\nVibeOS requires these Tier 1 artifacts before any source code:\n  1. VISION.md -- Project goals and target users\n  2. design-system.css -- Design tokens and component styles\n  3. TDR -- Technology Decision Record\n  4. roadmap.md -- Feature roadmap with priorities\n  5. CLAUDE.md -- Project rules and conventions\n\nMissing artifacts:\n$MISSING\n\nComplete all foundation artifacts, then run /status to verify."
  }
}
HOOK_OUTPUT
exit 2
```

### 5.5 Lifting the Phase Gate

The phase gate is lifted when the Workflow Orchestrator (via `Bash` script) or the `/status` command detects that all five artifacts exist and have been approved. The `check-foundation.sh` script validates each artifact and sets `foundation.complete = true` in the canonical `state.json` schema (see `architecture/schemas.md` Section 3):

```bash
#!/bin/bash
# scripts/check-foundation.sh
# Validates Tier 1 artifacts and lifts the phase gate

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibeos/state.json"

REQUIRED_FILES=("VISION.md" "design-system.css" "CLAUDE.md")
ALL_PRESENT=true

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$PROJECT_ROOT/$file" ]]; then
    echo "MISSING: $file"
    ALL_PRESENT=false
  else
    echo "FOUND: $file"
  fi
done

# Check for TDR
TDR_FOUND=false
if ls "$PROJECT_ROOT"/tdr/*.tdr.md 2>/dev/null | head -1 > /dev/null; then
  TDR_FOUND=true
elif [[ -f "$PROJECT_ROOT/tdr/technology-decision-record.md" ]]; then
  TDR_FOUND=true
fi
[[ "$TDR_FOUND" == "false" ]] && { echo "MISSING: Technology Decision Record"; ALL_PRESENT=false; } || echo "FOUND: Technology Decision Record"

# Check for roadmap
[[ ! -f "$PROJECT_ROOT/roadmap.md" ]] && { echo "MISSING: roadmap.md"; ALL_PRESENT=false; } || echo "FOUND: roadmap.md"

# Update state (via jq + temp file -- same pattern used by Orchestrator)
if [[ "$ALL_PRESENT" == "true" ]]; then
  TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  jq --arg ts "$TIMESTAMP" \
     '.foundation.complete = true | .foundation.completed_at = $ts' \
     "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
  echo ""
  echo "Foundation COMPLETE. Phase gate lifted. Source code writes are now allowed."
else
  echo ""
  echo "Foundation INCOMPLETE. Complete the missing artifacts above."
fi
```

---

## 6. Notification System (Interrupt Protocol)

### 6.1 Design Principle

The system stays silent during normal operation and interrupts the user only when blocked, complete, or failed. This is the opposite of most notification systems, which default to noisy and require the user to silence them. VibeOS defaults to silent and notifies only on exception.

### 6.2 Three Notification Conditions

| Condition | Hook Event | Trigger | Sound | Priority |
|-----------|------------|---------|-------|----------|
| Permission stall | `Notification` / `permission_prompt` | Agent blocked, waiting for Y/N approval | Submarine | Critical |
| Task completion | `Notification` / `idle_prompt` | Agent finished its work, awaiting instructions | Glass | High |
| Critical failure | `PostToolUseFailure` | Tool execution failed, agent cannot self-recover | Basso | High |

**All other events are silent.** Normal tool executions, successful builds, passing tests, git commits -- none of these produce notifications. This preserves the user's Deep Work state.

### 6.3 Warp Terminal Deep-Linking

Warp Terminal exposes a `WARP_SESSION_ID` environment variable unique to each tab. Combined with the `warp://session/<id>` URI scheme, clicking a notification focuses the exact terminal tab where the agent is waiting:

```bash
if [[ -n "${WARP_SESSION_ID:-}" ]]; then
  DEEP_LINK="warp://session/${WARP_SESSION_ID}"
  terminal-notifier \
    -title "VibeOS: Approval Needed" \
    -message "Agent blocked. Click to focus the right tab." \
    -sound "Submarine" \
    -group "vibeos-${WARP_SESSION_ID}" \
    -execute "open '$DEEP_LINK'"
fi
```

### 6.4 Notification Fallback Chain

The notification system degrades gracefully when tools are unavailable:

```
Priority 1: terminal-notifier + Warp deep-link
    |         (native macOS banner, click focuses exact tab)
    v (no WARP_SESSION_ID)
Priority 2: terminal-notifier without deep-link
    |         (native macOS banner, no tab focus)
    v (no terminal-notifier installed)
Priority 3: osascript notification
    |         (macOS built-in, no click action)
    v (osascript fails)
Priority 4: OSC 777 escape sequence
    |         (terminal-native, works in Warp and some others)
    v (terminal does not support OSC 777)
Priority 5: Terminal bell (printf '\a')
    |         (dock bounce or badge on most terminals)
    v (all else fails)
Priority 6: Write to .vibeos/notifications.log
              (silent but auditable)
```

### 6.5 Notification Script

```bash
#!/bin/bash
# scripts/notify.sh
# Terminal-adaptive notification system for VibeOS
# Fires on: permission_prompt, idle_prompt, PostToolUseFailure
# Silent on: everything else (preserves Deep Work)

set -euo pipefail

# Ensure jq is available
if ! command -v jq &> /dev/null; then
  printf '\a'  # Terminal bell as absolute fallback
  exit 0  # Never block the agent due to notification failure
fi

# Read JSON payload from stdin
INPUT=$(cat)
TYPE=$(echo "$INPUT" | jq -r '.notification_type // empty')
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Attention required."')

# Check if called with "error" argument (PostToolUseFailure)
IS_ERROR=false
if [[ "${1:-}" == "error" ]]; then
  IS_ERROR=true
fi

# --- Determine notification content ---
if [[ "$IS_ERROR" == "true" ]]; then
  TITLE="VibeOS: Error"
  BODY="A critical tool execution failed. Human intervention required."
  SOUND="Basso"
else
  case "$TYPE" in
    "permission_prompt")
      TITLE="VibeOS: Approval Needed"
      BODY="Agent blocked. Needs your Y/N approval to proceed."
      SOUND="Submarine"
      ;;
    "idle_prompt")
      TITLE="VibeOS: Task Complete"
      BODY="Agent finished its task. Awaiting new instructions."
      SOUND="Glass"
      ;;
    *)
      # Non-critical event -- exit silently to preserve Deep Work
      exit 0
      ;;
  esac
fi

# --- Detect terminal and dispatch notification ---
detect_terminal() {
  if [[ -n "${WARP_SESSION_ID:-}" ]]; then echo "warp"
  elif [[ "${TERM_PROGRAM:-}" == "iTerm.app" ]]; then echo "iterm2"
  elif [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then echo "vscode"
  elif [[ "${TERM_PROGRAM:-}" == "Apple_Terminal" ]]; then echo "terminal_app"
  else echo "generic"
  fi
}

TERMINAL=$(detect_terminal)

# Attempt notification via fallback chain
if command -v terminal-notifier &> /dev/null; then
  case "$TERMINAL" in
    "warp")
      DEEP_LINK="warp://session/${WARP_SESSION_ID}"
      terminal-notifier \
        -title "$TITLE" \
        -message "$BODY" \
        -sound "$SOUND" \
        -group "vibeos-${WARP_SESSION_ID}" \
        -execute "open '$DEEP_LINK'" 2>/dev/null || true
      ;;
    "iterm2")
      printf '\e]9;%s\a' "$BODY"
      terminal-notifier \
        -title "$TITLE" \
        -message "$BODY" \
        -sound "$SOUND" \
        -group "vibeos-iterm" 2>/dev/null || true
      ;;
    *)
      terminal-notifier \
        -title "$TITLE" \
        -message "$BODY" \
        -sound "$SOUND" \
        -group "vibeos-generic" 2>/dev/null || true
      ;;
  esac
elif command -v osascript &> /dev/null; then
  osascript -e "display notification \"$BODY\" with title \"$TITLE\" sound name \"$SOUND\"" 2>/dev/null || true
else
  # OSC 777 escape sequence (Warp and advanced terminals)
  printf '\e]777;notify;%s;%s\a' "$TITLE" "$BODY" 2>/dev/null || true
  # Terminal bell as final fallback
  printf '\a'
fi

# Log every notification event to disk
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
LOG_DIR="$PROJECT_ROOT/.vibeos"
if [[ -d "$LOG_DIR" ]]; then
  echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"type\":\"${TYPE:-error}\",\"title\":\"$TITLE\",\"terminal\":\"$TERMINAL\"}" \
    >> "$LOG_DIR/notifications.log" 2>/dev/null || true
fi

# CRITICAL: Always exit 0. A notification failure must never block the agent.
exit 0
```

### 6.6 Hook Configuration for Notifications

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh"
          }
        ]
      },
      {
        "matcher": "idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh"
          }
        ]
      }
    ],
    "PostToolUseFailure": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh error"
          }
        ]
      }
    ]
  }
}
```

---

## 7. Rollback Strategies

### 7.1 Design Principle

AI agents can make mistakes at scale. Unlike human developers who make small, incremental changes, an agent might rewrite 20 files in one pass. Every change must be recoverable. Git is the safety net, but only if the agent commits early and often. Worktrees provide natural isolation boundaries -- if something goes wrong in a worktree, deleting it is a clean, complete rollback.

**Rule: no uncommitted work should persist for more than one phase of a Tier 2 cycle.**

### 7.2 Strategy 1: Worktree Isolation (Primary)

Worktrees are the primary safety boundary in VibeOS v1.0. Both the Builder and Stack Scout agents run in isolated git worktrees (`isolation: worktree`), meaning their entire filesystem is separate from the main working tree. This provides natural rollback at the granularity of an entire agent operation.

**How worktrees provide safety:**

```
Main Working Tree (Orchestrator, Verifier)
    |
    +-- .claude/worktrees/
    |       |
    |       +-- builder-feat-001/       <-- Builder worktree
    |       |   (complete copy of project on feat/user-auth branch)
    |       |
    |       +-- scout-tdr-001/          <-- Stack Scout worktree
    |           (read-only research workspace)
    |
    +-- src/                            <-- Untouched by Builder until merge
    +-- .vibeos/                        <-- Shared state (accessed via main tree)
```

**Safety properties of worktree isolation:**

| Property | Benefit |
|----------|---------|
| Filesystem isolation | Builder changes are invisible to the main tree until explicitly merged |
| Atomic rollback | If a Builder run goes wrong, `git worktree remove builder-feat-001` cleans up everything |
| No branch pollution | Failed worktrees can be removed without leaving orphaned branches |
| Parallel safety | Multiple Builder instances in separate worktrees cannot conflict with each other |
| Clean state guarantee | Each worktree starts from a known-good commit on its feature branch |

**Worktree lifecycle:**

```bash
# 1. Create worktree for a feature (done by Orchestrator or Agent Teams)
git worktree add .claude/worktrees/builder-feat-001 -b feat/user-auth

# 2. Builder works inside the worktree
#    All writes, commits, and builds happen in the worktree

# 3. On success: merge worktree changes back
cd /path/to/main/tree
git merge feat/user-auth  # Or via PR

# 4. Clean up the worktree
git worktree remove .claude/worktrees/builder-feat-001

# --- On failure: discard the entire worktree ---
git worktree remove --force .claude/worktrees/builder-feat-001
git branch -D feat/user-auth  # If the branch should also be removed
```

**Worktree cleanup script:**

```bash
#!/bin/bash
# scripts/cleanup-worktree.sh
# Removes a worktree and optionally its branch
# Usage: cleanup-worktree.sh <worktree-path> [--delete-branch]

set -euo pipefail

WORKTREE_PATH="$1"
DELETE_BRANCH="${2:-}"

if [[ ! -d "$WORKTREE_PATH" ]]; then
  echo "Worktree not found: $WORKTREE_PATH"
  exit 0
fi

# Get the branch name before removing
BRANCH=$(git -C "$WORKTREE_PATH" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# Remove the worktree
git worktree remove --force "$WORKTREE_PATH" 2>/dev/null || {
  # Fallback: manual cleanup if git worktree remove fails
  rm -rf "$WORKTREE_PATH"
  git worktree prune
}

echo "Removed worktree: $WORKTREE_PATH"

# Optionally delete the branch
if [[ "$DELETE_BRANCH" == "--delete-branch" && -n "$BRANCH" && "$BRANCH" != "main" && "$BRANCH" != "master" ]]; then
  git branch -D "$BRANCH" 2>/dev/null || true
  echo "Deleted branch: $BRANCH"
fi
```

### 7.3 Strategy 2: Checkpoint Commits

The secondary rollback mechanism within worktrees. Lightweight checkpoint commits are created before risky operations so that `git reset --soft` can undo them without destroying data.

```bash
#!/bin/bash
# scripts/checkpoint.sh
# Creates a checkpoint commit before risky agent operations

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REASON="${1:-agent-action}"
CHECKPOINT_MSG="checkpoint: pre-${REASON} ${TIMESTAMP}"

cd "$PROJECT_ROOT"
git add -A
git commit --allow-empty -m "$CHECKPOINT_MSG" 2>/dev/null || true

echo "$CHECKPOINT_MSG"
```

```bash
#!/bin/bash
# scripts/rollback.sh
# Rolls back to the most recent checkpoint (non-destructive)

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"

# Find the most recent checkpoint commit
CHECKPOINT=$(git log --oneline --grep="^checkpoint:" -1 --format="%H")

if [[ -z "$CHECKPOINT" ]]; then
  echo "No checkpoint found. Cannot rollback."
  exit 1
fi

# Soft reset -- preserves changes as unstaged modifications
git reset --soft "$CHECKPOINT"

echo "Rolled back to: $(git log --oneline -1 "$CHECKPOINT")"
echo "Changes from the agent's work are now unstaged."
echo "Run 'git checkout -- .' to discard them, or 'git stash' to save them."
```

**When checkpoints are created automatically:**

| Event | Checkpoint Reason |
|-------|-------------------|
| `/new-feature` start | `pre-feature-start` |
| Tier 2 phase transition (plan to code, code to test, etc.) | `pre-phase-<name>` |
| `/wrap` (session end) | `pre-wrap` |
| Before dependency installation | `pre-npm-install` |
| Before agent-initiated file deletion | `pre-file-delete` |

### 7.4 Strategy 3: Git Stash for Uncommitted Work

Git stash preserves the current working directory state and reverts to the last commit:

```bash
# Before a risky operation
git stash push --include-untracked -m "pre-agent-checkpoint: $(date +%Y%m%d-%H%M%S)"

# If the operation went wrong -- restore pre-agent state
git stash pop

# If the operation was successful -- discard the stash
git stash drop
```

The `--include-untracked` flag is mandatory for agent checkpoints. Without it, newly created files are not captured by the stash.

### 7.5 Strategy 4: WIP Commits for Session Recovery

The `/wrap` command creates WIP (work-in-progress) commits for incomplete features. These serve as recovery points when a session ends before work is complete:

```bash
# /wrap creates this
git add -A
git commit -m "wip(feature-name): plan + design + coding done"
```

The next session can find the latest WIP commit and resume from it:

```bash
git log --oneline --grep="^wip(" -5
```

### 7.6 Stale Lock Detection and Cleanup

When multiple agents share state files (`.vibeos/state.json`, `.vibeos/backlog.json`), advisory lock files prevent concurrent write conflicts. See `architecture/schemas.md` Section 8 for the canonical lock file schema. Locks can become stale if an agent crashes while holding one.

**Stale lock detection uses two mechanisms:**

1. **PID-based detection.** Each lock records the locking process's PID. If the process is no longer running (`kill -0 $PID` fails), the lock is stale.

2. **Timeout-based expiry.** Locks older than 30 minutes are considered stale and are automatically removed by any agent that encounters them.

```bash
#!/bin/bash
# scripts/cleanup-stale-locks.sh
# Removes all stale locks from the .vibeos/locks/ directory.
# Called by Session Startup agent at the beginning of every session.

set -euo pipefail

LOCKS_DIR=".vibeos/locks"
STALE_THRESHOLD=1800  # 30 minutes in seconds

if [[ ! -d "$LOCKS_DIR" ]]; then
  exit 0
fi

NOW=$(date "+%s")
CLEANED=0

for lock_dir in "$LOCKS_DIR"/*/; do
  [[ -d "$lock_dir" ]] || continue

  INFO_FILE="${lock_dir}info.json"
  if [[ ! -f "$INFO_FILE" ]]; then
    rm -rf "$lock_dir"
    CLEANED=$((CLEANED + 1))
    continue
  fi

  LOCK_PID=$(jq -r '.pid // empty' "$INFO_FILE")
  LOCK_TIME=$(jq -r '.locked_at // empty' "$INFO_FILE")
  LOCK_TARGET=$(jq -r '.target_file // "unknown"' "$INFO_FILE")

  # Check if locking process is still alive
  if [[ -n "$LOCK_PID" ]] && ! kill -0 "$LOCK_PID" 2>/dev/null; then
    echo "Removing lock for $LOCK_TARGET (PID $LOCK_PID is dead)."
    rm -rf "$lock_dir"
    CLEANED=$((CLEANED + 1))
    continue
  fi

  # Check if lock has exceeded the 30-minute timeout
  if [[ -n "$LOCK_TIME" ]]; then
    LOCK_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$LOCK_TIME" "+%s" 2>/dev/null || echo "0")
    AGE=$(( NOW - LOCK_EPOCH ))
    if [[ "$AGE" -gt "$STALE_THRESHOLD" ]]; then
      echo "Removing stale lock for $LOCK_TARGET (age: ${AGE}s)."
      rm -rf "$lock_dir"
      CLEANED=$((CLEANED + 1))
      continue
    fi
  fi
done

echo "Lock cleanup complete. Removed $CLEANED stale lock(s)."
```

### 7.7 Session State Preservation

All session state is persisted to disk in `.vibeos/`, never stored solely in the context window. This means:

- If the context window is exhausted or the session crashes, state survives.
- A new session can resume from exactly where the previous session left off.
- The Verifier can review past session data without it needing to be in the current context.

**State files** (see `architecture/schemas.md` for canonical schemas):

| File | Contents | Schema Reference |
|------|----------|------------------|
| `.vibeos/state.json` | Foundation status, active feature, current phase | schemas.md Section 3 |
| `.vibeos/backlog.json` | Feature backlog with specs and priorities | schemas.md Section 4 |
| `.vibeos/sessions/<id>.json` | Per-session logs (actions, duration, context usage) | schemas.md Section 5 |
| `.vibeos/scores/<id>.json` | Per-session Vibe Score breakdown | schemas.md Section 6 |
| `.vibeos/notifications.log` | Notification audit trail | Plain JSON lines |

### 7.8 Rollback Decision Matrix

| Scenario | Strategy | Command(s) |
|----------|----------|------------|
| Agent wrote bad code in worktree, not yet committed | Discard worktree changes | `git -C <worktree> checkout -- .` |
| Agent made one bad commit in worktree | Undo commit, keep changes | `git -C <worktree> reset --soft HEAD~1` |
| Agent made multiple bad commits in worktree | Undo to checkpoint | `git -C <worktree> reset --soft <checkpoint-hash>` |
| Entire worktree is thoroughly broken | Delete worktree and restart | `git worktree remove --force <worktree-path>` |
| Feature branch is unsalvageable | Delete worktree + branch, restart | `cleanup-worktree.sh <path> --delete-branch` |
| Need to pause and review agent work | Stash worktree state | `git -C <worktree> stash push --include-untracked` |
| Need to compare before and after | Diff against checkpoint | `git -C <worktree> diff <checkpoint>..HEAD` |
| Stack Scout research went wrong | Delete scout worktree | `git worktree remove --force <scout-worktree>` (no data loss -- research is read-only) |

**Non-destructive by default.** `git reset --soft` and `git stash` are preferred over `git reset --hard`. Worktree deletion is the "nuclear option" but is safe because the main working tree is always untouched. Destructive rollback on the main tree requires explicit user confirmation (Tier 3).

---

## 8. Context Window Safety

### 8.1 Why Context Exhaustion Is a Safety Issue

Context exhaustion is not merely a performance problem. When an agent operates near the limits of its context window:

1. **Safety rule amnesia** -- Safety instructions from CLAUDE.md may be pushed out of context.
2. **Instruction drift** -- The model may forget project-specific constraints.
3. **Degraded reasoning** -- Architectural decisions become inconsistent.
4. **Hallucinated context** -- The model may "remember" instructions that no longer exist in context.

For non-technical VibeOS users, this is especially dangerous because the output still looks correct. The agent continues producing plausible code that may silently violate safety rules.

### 8.2 Warning Thresholds

| Threshold | Level | Response |
|-----------|-------|----------|
| 60% | Soft warning | Log warning to `.vibeos/state.json`. Feedback message to model. |
| 80% | Hard warning | Native OS notification to user via `notify.sh`. Recommend `/wrap`. |
| 90% | Force stop | Agent should gracefully terminate. Create WIP commit. Start new session. |

### 8.3 Implementation via Stop Hook

The `check-context.sh` script fires after each agent turn (Stop hook) and reads context usage from the hook payload. It also performs cost monitoring (see Section 9) and CLAUDE.md size checking (see Section 10):

```bash
#!/bin/bash
# scripts/check-context.sh
# Stop hook -- monitors context window usage, cost, and CLAUDE.md size
# This is the central monitoring script that runs after every agent turn.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibeos/state.json"
CONFIG_FILE="$PROJECT_ROOT/.vibeos/config.json"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

INPUT=$(cat)

mkdir -p "$PROJECT_ROOT/.vibeos"

# =====================================================================
# PART 1: Context Window Monitoring
# =====================================================================

CONTEXT_PERCENT=$(echo "$INPUT" | jq -r '.context_window_percent // 0' 2>/dev/null || echo "0")

if (( $(echo "$CONTEXT_PERCENT >= 90" | bc -l 2>/dev/null || echo "0") )); then
  echo "DANGER: Context window is ${CONTEXT_PERCENT}% full."
  echo "Agent quality is severely degraded. Stop immediately."
  echo "Run /wrap to save all progress, then start a new session."
  jq '.force_stop = true' "$STATE_FILE" > "${STATE_FILE}.tmp" 2>/dev/null \
    && mv "${STATE_FILE}.tmp" "$STATE_FILE" || true
elif (( $(echo "$CONTEXT_PERCENT >= 80" | bc -l 2>/dev/null || echo "0") )); then
  echo "CRITICAL: Context window is ${CONTEXT_PERCENT}% full."
  echo "Run /wrap immediately to save progress."
  # Fire notification
  NOTIFY_SCRIPT="${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh"
  if [[ -x "$NOTIFY_SCRIPT" ]]; then
    echo '{"notification_type":"permission_prompt","message":"Context at '"$CONTEXT_PERCENT"'%. Wrap up now."}' \
      | bash "$NOTIFY_SCRIPT" 2>/dev/null || true
  fi
elif (( $(echo "$CONTEXT_PERCENT >= 60" | bc -l 2>/dev/null || echo "0") )); then
  echo "WARNING: Context window is ${CONTEXT_PERCENT}% full."
  echo "Consider wrapping up the current task."
fi

# =====================================================================
# PART 2: Cost Monitoring (see Section 9)
# =====================================================================

# Read token usage from the hook payload
INPUT_TOKENS=$(echo "$INPUT" | jq -r '.usage.input_tokens // 0' 2>/dev/null || echo "0")
CACHE_CREATION=$(echo "$INPUT" | jq -r '.usage.cache_creation_input_tokens // 0' 2>/dev/null || echo "0")
CACHE_READ=$(echo "$INPUT" | jq -r '.usage.cache_read_input_tokens // 0' 2>/dev/null || echo "0")
OUTPUT_TOKENS=$(echo "$INPUT" | jq -r '.usage.output_tokens // 0' 2>/dev/null || echo "0")

# Opus pricing (per million tokens) -- conservative estimate
# Input: $15.00, Cache write: $18.75, Cache read: $1.50, Output: $75.00
# Using Opus as the default since most agents run on Opus
COST_USD=$(echo "scale=4; ($INPUT_TOKENS * 15.00 + $CACHE_CREATION * 18.75 + $CACHE_READ * 1.50 + $OUTPUT_TOKENS * 75.00) / 1000000" \
  | bc -l 2>/dev/null || echo "0")

# Read cost limits from config.json (see architecture/schemas.md Section 2)
SESSION_WARN=$(jq -r '.cost_limits.session_warn_usd // 2.00' "$CONFIG_FILE" 2>/dev/null || echo "2.00")
SESSION_MAX=$(jq -r '.cost_limits.session_max_usd // 5.00' "$CONFIG_FILE" 2>/dev/null || echo "5.00")
DAILY_WARN=$(jq -r '.cost_limits.daily_warn_usd // 20.00' "$CONFIG_FILE" 2>/dev/null || echo "20.00")

# Accumulate session cost in state.json
CURRENT_SESSION_COST=$(jq -r '.session_cost_usd // 0' "$STATE_FILE" 2>/dev/null || echo "0")
NEW_SESSION_COST=$(echo "scale=4; $CURRENT_SESSION_COST + $COST_USD" | bc -l 2>/dev/null || echo "0")
jq --arg cost "$NEW_SESSION_COST" '.session_cost_usd = ($cost | tonumber)' \
  "$STATE_FILE" > "${STATE_FILE}.tmp" 2>/dev/null \
  && mv "${STATE_FILE}.tmp" "$STATE_FILE" || true

# Check session cost against hard limit
if (( $(echo "$NEW_SESSION_COST >= $SESSION_MAX" | bc -l 2>/dev/null || echo "0") )); then
  echo ""
  echo "COST HARD LIMIT: Session cost \$${NEW_SESSION_COST} exceeds maximum \$${SESSION_MAX}."
  echo "Agent MUST pause and ask the user before continuing."
  echo "Estimated cost breakdown: input=${INPUT_TOKENS} tokens, output=${OUTPUT_TOKENS} tokens."
  echo "To increase the limit, edit .vibeos/config.json cost_limits.session_max_usd."
  # Fire notification
  NOTIFY_SCRIPT="${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh"
  if [[ -x "$NOTIFY_SCRIPT" ]]; then
    echo '{"notification_type":"permission_prompt","message":"Session cost $'"$NEW_SESSION_COST"' exceeds limit $'"$SESSION_MAX"'. Approval needed to continue."}' \
      | bash "$NOTIFY_SCRIPT" 2>/dev/null || true
  fi
elif (( $(echo "$NEW_SESSION_COST >= $SESSION_WARN" | bc -l 2>/dev/null || echo "0") )); then
  echo ""
  echo "COST WARNING: Session cost is \$${NEW_SESSION_COST} (warning threshold: \$${SESSION_WARN})."
  echo "Consider wrapping up or reducing scope."
fi

# Check daily cost (aggregate from today's session logs)
TODAY=$(date -u +%Y-%m-%d)
DAILY_COST=$(find "$PROJECT_ROOT/.vibeos/sessions/" -name "session-${TODAY}-*.json" -exec jq -r '.tokens.estimated_cost_usd // 0' {} \; 2>/dev/null \
  | awk '{sum+=$1} END {printf "%.4f", sum+0}' || echo "0")
DAILY_TOTAL=$(echo "scale=4; $DAILY_COST + $NEW_SESSION_COST" | bc -l 2>/dev/null || echo "0")

if (( $(echo "$DAILY_TOTAL >= $DAILY_WARN" | bc -l 2>/dev/null || echo "0") )); then
  echo ""
  echo "DAILY COST WARNING: Today's total spend is \$${DAILY_TOTAL} (daily warning: \$${DAILY_WARN})."
  echo "Review whether current work justifies continued spending."
fi

# =====================================================================
# PART 3: CLAUDE.md Size Monitoring (see Section 10)
# =====================================================================

if [[ -f "$CLAUDE_MD" ]]; then
  CLAUDE_MD_LINES=$(wc -l < "$CLAUDE_MD" | tr -d ' ')

  if [[ "$CLAUDE_MD_LINES" -gt 600 ]]; then
    echo ""
    echo "CLAUDE.MD BLOCKED: CLAUDE.md is ${CLAUDE_MD_LINES} lines (hard limit: 600)."
    echo "No further mutations are allowed until pruning reduces it below 500 lines."
    echo "Run /wrap to have the Verifier propose stale rule removal."
    echo "Rules marked with <!-- pinned --> are protected from auto-pruning."
  elif [[ "$CLAUDE_MD_LINES" -gt 500 ]]; then
    echo ""
    echo "CLAUDE.MD WARNING: CLAUDE.md is ${CLAUDE_MD_LINES} lines (soft limit: 500)."
    echo "Consider pruning stale rules before adding new ones."
    echo "The Verifier (during /wrap) can propose removing rules not triggered in 5+ sessions."
  fi
fi

exit 0
```

### 8.4 Architectural Mitigations

Beyond the Stop hook, context safety is enforced architecturally:

| Mitigation | Mechanism |
|------------|-----------|
| Subagents for expensive work | Stack Scout runs research in its own worktree and context window, preventing documentation from consuming the main agent's context. |
| MCP servers instead of pasting | Context7 returns only the relevant documentation snippet, not entire library docs. |
| Compact diffs | Use `git diff --stat` first, then selectively view specific files. |
| State on disk | Session state, backlog, and scores are in `.vibeos/`, not in context. |
| Aggressive summarization | Agents summarize results before reporting back to the Orchestrator. |
| Worktree isolation | Builder and Stack Scout operate in separate context windows, preventing their work from consuming the Orchestrator's context. |

---

## 9. Cost Guardrails

### 9.1 The Problem

Unattended execution -- particularly via `/run-backlog` which processes multiple features sequentially -- can burn significant API credits without the user realizing it. A single `/run-backlog` session that processes 5 features might cost $10-25 in API credits. For non-technical users who may not understand token economics, this represents a real financial risk.

### 9.2 Three Cost Thresholds

| Threshold | Default | Level | Response |
|-----------|---------|-------|----------|
| Per-session warning | $2.00 USD | Soft | Log warning message. Agent continues but is aware of cost. |
| Per-session hard limit | $5.00 USD | Hard | Agent MUST pause and ask the user for approval before continuing. Notification fires. |
| Daily spend warning | $20.00 USD | Soft | Warning aggregated across all sessions today. Informational -- agent continues. |

### 9.3 Configuration

Cost thresholds are configured in `.vibeos/config.json` under the `cost_limits` field (see `architecture/schemas.md` Section 2 for the canonical schema):

```json
{
  "cost_limits": {
    "session_warn_usd": 2.00,
    "session_max_usd": 5.00,
    "daily_warn_usd": 20.00
  }
}
```

Users can adjust these thresholds to match their budget. Setting `session_max_usd` to `0` disables the hard limit (not recommended). Setting it to a high value like `50.00` effectively makes it a safety net for truly runaway sessions.

### 9.4 Cost Estimation Model

Cost is estimated from token usage in the hook payload using conservative Opus pricing (the model used by most agents):

| Token Type | Cost per Million | Notes |
|------------|-----------------|-------|
| Input tokens | $15.00 | Standard input processing |
| Cache creation tokens | $18.75 | First-time cache write |
| Cache read tokens | $1.50 | Subsequent reads from cache |
| Output tokens | $75.00 | Generated text |

**Important.** These are estimates. Actual costs depend on the model used (Haiku is cheaper than Opus), current Anthropic pricing, and whether prompt caching is active. The estimates are deliberately conservative (using Opus pricing for all agents) to err on the side of caution.

### 9.5 Implementation

Cost monitoring is implemented in `check-context.sh` (the Stop hook), which fires after every agent turn. See Section 8.3 for the complete script. The relevant cost monitoring logic:

1. **Read token usage** from the hook payload (`usage.input_tokens`, `usage.cache_creation_input_tokens`, `usage.cache_read_input_tokens`, `usage.output_tokens`)
2. **Calculate estimated cost** using the pricing model above
3. **Accumulate session cost** in `state.json` (`session_cost_usd` field)
4. **Compare against thresholds** from `config.json`
5. **Emit warnings or blocks** as appropriate

### 9.6 Per-Session Hard Limit Behavior

When the session cost exceeds `session_max_usd`:

1. The `check-context.sh` Stop hook emits a blocking message that the model receives
2. A notification fires via `notify.sh` (permission_prompt type) to alert the user
3. The agent is instructed to pause and ask the user whether to continue
4. The user can approve continuation (the session continues), or decline (the agent runs `/wrap`)

This is enforced by the Stop hook, which injects a message into the model's context after every turn. The agent cannot "forget" the cost warning because it is re-injected on each turn until the user responds.

### 9.7 Daily Cost Tracking

Daily cost is calculated by summing `tokens.estimated_cost_usd` from all session log files for the current date (see `architecture/schemas.md` Section 5 for the session log schema). This provides a running total across all sessions in a day, regardless of whether they are consecutive.

### 9.8 `/run-backlog` Specific Safeguards

The `/run-backlog` command processes multiple features unattended. Additional safeguards apply:

| Safeguard | Mechanism |
|-----------|-----------|
| Feature count limit | `/run-backlog` processes at most 3 features before pausing for user confirmation |
| Per-feature cost check | After each feature completes, check session cost against thresholds |
| Cumulative warning | After 2 features, report cumulative cost and estimated remaining cost |
| Early termination | If session cost exceeds hard limit during `/run-backlog`, stop processing the backlog and run `/wrap` |

---

## 10. CLAUDE.md Size Management

### 10.1 The Problem

CLAUDE.md is the model's primary instruction file. If it grows without bounds, it consumes an increasing share of the context window on every turn, crowds out actual work, and eventually degrades agent performance. Boris Cherny's own CLAUDE.md is approximately 2,500 tokens (~500 lines). VibeOS must prevent CLAUDE.md from bloating beyond this baseline.

The risk is compounded by the self-improving design: the Verifier (v1.0) and the future Performance Coach (v1.1) can propose CLAUDE.md rule mutations. Without size management, every session adds rules and none are ever removed.

### 10.2 Size Limits

| Threshold | Line Count | Approximate Tokens | Level | Response |
|-----------|------------|---------------------|-------|----------|
| Soft limit | 500 lines | ~2,500 tokens | Warning | Warn the user. Suggest pruning. |
| Hard limit | 600 lines | ~3,000 tokens | Block | Block all further CLAUDE.md mutations until pruning reduces it below 500 lines. |

### 10.3 Monitoring Implementation

CLAUDE.md size is monitored by `check-context.sh` (the Stop hook), the same script that monitors context usage and cost. See Section 8.3 for the complete script. The relevant CLAUDE.md monitoring logic:

1. **Count lines** in CLAUDE.md using `wc -l`
2. **Compare against thresholds** (500 soft, 600 hard)
3. **Emit warnings or blocks** as appropriate

When the hard limit (600 lines) is exceeded:
- The Stop hook emits a blocking message that the model receives
- The message instructs the agent that no further CLAUDE.md mutations are allowed
- The user is directed to run `/wrap` where the Verifier can propose pruning

### 10.4 Pruning Mechanism

During `/wrap`, the Verifier agent can propose removing stale rules from CLAUDE.md. The pruning process:

1. **Identify stale rules.** A rule is considered stale if it has not been triggered (referenced by an agent action or commit message) in the last 5 sessions. The Verifier checks this by scanning the last 5 session logs in `.vibeos/sessions/` for references to each CLAUDE.md rule.

2. **Respect pinned rules.** Rules marked with `<!-- pinned -->` as an HTML comment are never proposed for removal, regardless of how long they have been dormant. This allows users to protect critical rules that may not trigger frequently but are important safeguards.

   ```markdown
   ## Security Rules <!-- pinned -->

   - Never hardcode API keys in source code.
   - All user input must be validated with zod schemas on the server side.
   ```

3. **Propose, never auto-delete.** The Verifier presents a list of stale rules to the user with the recommendation to remove them. The user decides which rules to actually remove. This is a Tier 3 operation (always requires explicit approval).

4. **Pruning report format:**

   ```
   CLAUDE.md Pruning Report
   ========================
   Current size: 547 lines (soft limit: 500)

   Stale rules (not triggered in last 5 sessions):
     Line 142: "Always use React.memo for list item components"
       Last triggered: session-2026-02-15-002 (8 days ago, 6 sessions ago)
     Line 198: "Prefer date-fns over moment.js for date operations"
       Last triggered: never

   Pinned rules (protected from pruning):
     Line 12-25: "Security Rules" section (<!-- pinned -->)
     Line 89-95: "Testing Conventions" section (<!-- pinned -->)

   Recommendation: Remove 2 stale rules to save 8 lines.
   Approve? [Y/n]
   ```

### 10.5 Prevention Strategy

Beyond reactive pruning, VibeOS prevents CLAUDE.md bloat proactively:

| Strategy | Mechanism |
|----------|-----------|
| One-in-one-out | When adding a new rule near the soft limit, the Verifier must propose removing an equivalent stale rule |
| Consolidation over accumulation | When two rules cover similar ground, merge them into a single rule |
| Section budgets | The Verifier tracks rule counts per CLAUDE.md section and flags sections that grow disproportionately |
| Specificity decay | Rules that are too specific (referencing a single file or function) should be generalized or removed after the feature stabilizes |

### 10.6 CLAUDE.md Mutation Workflow (v1.0 vs v1.1)

| Capability | v1.0 (Verifier) | v1.1 (Performance Coach) |
|------------|------------------|--------------------------|
| Calculate Vibe Score | Yes | Yes |
| Coaching suggestions | Yes (in score file) | Yes (in score file + MEMORY.md) |
| Propose CLAUDE.md mutations | No | Yes |
| Auto-apply mutations | No | No (always Tier 3 approval) |
| Cross-session trend analysis | No | Yes (persistent memory) |
| Pruning proposals during `/wrap` | Yes (size management only) | Yes (size + staleness + trend) |

In v1.0, the Verifier handles CLAUDE.md size management (warning, blocking, pruning proposals) but does NOT propose new rules. New rule proposals are deferred to v1.1 when the standalone Performance Coach agent with persistent `memory: project` is implemented.

---

## 11. Security of Generated Code

### 11.1 The Problem

AI agents can inadvertently introduce security vulnerabilities into generated code: SQL string concatenation, missing input validation, hardcoded secrets, overly permissive CORS, disabled CSP headers. For non-technical VibeOS users, these vulnerabilities are invisible -- the code works, but the application is exploitable.

### 11.2 Three-Layer Defense

| Layer | Mechanism | Timing |
|-------|-----------|--------|
| Proactive | TDR process forces security architecture decisions before code | Before any source code |
| Generative | CLAUDE.md security rules guide the model toward secure patterns | During code generation |
| Reactive | Static analysis (ESLint security plugins, npm audit, secret detection) | After code is written, before PR |

### 11.3 CLAUDE.md Security Rules (Generated by Default)

Every project created by VibeOS includes these security rules in its CLAUDE.md:

```markdown
## Security Rules <!-- pinned -->

- Never hardcode API keys, tokens, passwords, or secrets in source code. Use environment variables.
- All user input must be validated with zod schemas on the server side.
- Use parameterized queries for all database operations. Never concatenate user input into SQL.
- Set Content-Security-Policy headers. Never use 'unsafe-eval' or 'unsafe-inline' for scripts.
- CORS must specify exact allowed origins. Never use Access-Control-Allow-Origin: * in production.
- All API routes that modify data must verify authentication and authorization.
- Run npm audit before creating any pull request. Fix critical and high vulnerabilities.
- Use HTTPS for all external API calls.
```

Note the `<!-- pinned -->` marker on the Security Rules section header. This ensures these rules are never proposed for auto-pruning by the CLAUDE.md size management system (Section 10).

### 11.4 Verifier Security Checklist

The Verifier agent (which combines the former Test Writer, Quality Check, and scoring roles) verifies these items before any PR is created:

| Check | Tool | Automated |
|-------|------|-----------|
| No hardcoded secrets | `detect-secrets.sh` (pre-commit hook) | Yes |
| No critical/high CVEs | `npm audit` | Yes |
| ESLint security rules pass | `eslint --plugin security` | Yes |
| TypeScript strict mode enabled | `tsc --noEmit` | Yes |
| No `eval()` or `new Function()` | ESLint security plugin | Yes |
| CORS not set to `*` in production | `grep` for permissive patterns | Yes |
| CSP headers present | Pattern check | Partially |
| Input validation on API routes | Code review | Partially |
| Authentication on protected routes | Manual review | No |

---

## 12. Testing the Safety System

### 12.1 Adversarial Test Suite

Before deploying VibeOS, the safety system must be tested with adversarial inputs. The test suite verifies that dangerous operations are blocked and safe operations are allowed:

```bash
#!/bin/bash
# test/test-safety.sh
# Smoke tests for the safety hook scripts

set -euo pipefail

PASS=0
FAIL=0

assert_blocked() {
  local description="$1"
  local exit_code="$2"
  if [[ "$exit_code" -eq 2 ]]; then
    echo "PASS: $description (blocked)"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $description (expected block, got exit $exit_code)"
    FAIL=$((FAIL + 1))
  fi
}

assert_allowed() {
  local description="$1"
  local exit_code="$2"
  if [[ "$exit_code" -eq 0 ]]; then
    echo "PASS: $description (allowed)"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $description (expected allow, got exit $exit_code)"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== protect-data.sh ==="

echo '{"tool_name":"Bash","tool_input":{"command":"sudo rm -rf /"}}' \
  | bash scripts/protect-data.sh 2>/dev/null; assert_blocked "sudo rm -rf /" $?

echo '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' \
  | bash scripts/protect-data.sh 2>/dev/null; assert_blocked "git push --force" $?

echo '{"tool_name":"Bash","tool_input":{"command":"chmod 777 /tmp"}}' \
  | bash scripts/protect-data.sh 2>/dev/null; assert_blocked "chmod 777" $?

echo '{"tool_name":"Bash","tool_input":{"command":"DROP TABLE users;"}}' \
  | bash scripts/protect-data.sh 2>/dev/null; assert_blocked "DROP TABLE" $?

echo '{"tool_name":"Bash","tool_input":{"command":"cat ~/.ssh/id_rsa"}}' \
  | bash scripts/protect-data.sh 2>/dev/null; assert_blocked "read SSH key" $?

echo '{"tool_name":"Bash","tool_input":{"command":"npm install -g typescript"}}' \
  | bash scripts/protect-data.sh 2>/dev/null; assert_blocked "global npm install" $?

echo '{"tool_name":"Bash","tool_input":{"command":"npm test"}}' \
  | bash scripts/protect-data.sh 2>/dev/null; assert_allowed "npm test" $?

echo '{"tool_name":"Bash","tool_input":{"command":"git status"}}' \
  | bash scripts/protect-data.sh 2>/dev/null; assert_allowed "git status" $?

echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: add login\""}}' \
  | bash scripts/protect-data.sh 2>/dev/null; assert_allowed "git commit" $?

echo ""
echo "=== restrict-paths.sh ==="

echo '{"tool_name":"Write","tool_input":{"file_path":"/etc/passwd"}}' \
  | bash scripts/restrict-paths.sh 2>/dev/null; assert_blocked "write /etc/passwd" $?

echo '{"tool_name":"Write","tool_input":{"file_path":"src/../../etc/passwd"}}' \
  | bash scripts/restrict-paths.sh 2>/dev/null; assert_blocked "path traversal" $?

echo '{"tool_name":"Write","tool_input":{"file_path":"src/index.ts"}}' \
  | bash scripts/restrict-paths.sh 2>/dev/null; assert_allowed "write src/index.ts" $?

echo ""
echo "=== phase-gate.sh ==="

# Test: phase gate blocks source code writes when foundation is incomplete
echo '{"tool_name":"Write","tool_input":{"file_path":"src/app.tsx"}}' \
  | bash scripts/phase-gate.sh 2>/dev/null; assert_blocked "source write before foundation" $?

# Test: phase gate allows planning artifacts when foundation is incomplete
echo '{"tool_name":"Write","tool_input":{"file_path":"VISION.md"}}' \
  | bash scripts/phase-gate.sh 2>/dev/null; assert_allowed "VISION.md during Tier 1" $?

echo '{"tool_name":"Write","tool_input":{"file_path":".vibeos/state.json"}}' \
  | bash scripts/phase-gate.sh 2>/dev/null; assert_allowed ".vibeos/ during Tier 1" $?

echo ""
echo "=== worktree isolation ==="

# Test: worktree cleanup script handles missing worktrees gracefully
bash scripts/cleanup-worktree.sh "/nonexistent/path" 2>/dev/null; assert_allowed "cleanup missing worktree" $?

echo ""
echo "=== cost guardrails ==="

# Test: check-context.sh does not crash with empty input
echo '{}' | bash scripts/check-context.sh 2>/dev/null; assert_allowed "empty hook payload" $?

# Test: check-context.sh handles missing config gracefully
echo '{"context_window_percent": 50}' \
  | bash scripts/check-context.sh 2>/dev/null; assert_allowed "missing config.json" $?

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
[[ "$FAIL" -gt 0 ]] && exit 1 || exit 0
```

### 12.2 Worktree Safety Tests

Additional tests specific to the worktree-based isolation model:

```bash
#!/bin/bash
# test/test-worktree-safety.sh
# Verifies that worktree isolation provides expected safety properties

set -euo pipefail

PASS=0
FAIL=0
TEST_REPO=$(mktemp -d)

# Setup test repository
cd "$TEST_REPO"
git init
echo "initial" > file.txt
git add -A && git commit -m "initial"

assert_true() {
  local description="$1"
  local condition="$2"
  if eval "$condition"; then
    echo "PASS: $description"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $description"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Worktree Isolation Tests ==="

# Test: worktree creation does not affect main tree
git worktree add .claude/worktrees/test-wt -b feat/test 2>/dev/null
echo "worktree change" > .claude/worktrees/test-wt/new-file.txt
assert_true "worktree file invisible to main tree" "[[ ! -f new-file.txt ]]"

# Test: worktree commit does not appear on main branch
cd .claude/worktrees/test-wt
git add -A && git commit -m "worktree commit" 2>/dev/null
cd "$TEST_REPO"
MAIN_LOG=$(git log --oneline)
assert_true "worktree commit not on main" "[[ ! \"$MAIN_LOG\" == *'worktree commit'* ]]"

# Test: worktree removal is clean
git worktree remove --force .claude/worktrees/test-wt 2>/dev/null
assert_true "worktree removed cleanly" "[[ ! -d .claude/worktrees/test-wt ]]"

# Test: main tree unchanged after worktree removal
assert_true "main tree file intact after worktree removal" "[[ -f file.txt ]]"
CONTENT=$(cat file.txt)
assert_true "main tree content unchanged" "[[ \"$CONTENT\" == 'initial' ]]"

# Cleanup
rm -rf "$TEST_REPO"

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
[[ "$FAIL" -gt 0 ]] && exit 1 || exit 0
```

### 12.3 Known Residual Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Command obfuscation (base64, eval, variable expansion) | Low | Worktree isolation + git-based rollback as last resort |
| Symlink creation followed by write through symlink | Low | `sandbox.sh` resolves symlink chain |
| Model ignoring CLAUDE.md security rules under context pressure | Medium | Static analysis catches on post-write |
| Stale locks blocking agents indefinitely | Medium | 30-minute timeout + PID-based detection |
| Context exhaustion causing safety rule amnesia | Medium | 60%/80%/90% threshold system with forced stop |
| Uncontrolled API cost during `/run-backlog` | Medium | Three-tier cost guardrails with hard stop at session limit |
| CLAUDE.md bloat degrading agent performance | Medium | 500/600 line limits with pruning mechanism |
| Worktree accumulation consuming disk space | Low | Session Startup cleans up orphaned worktrees; `cleanup-worktree.sh` script |
| Cost estimation inaccuracy (pricing changes) | Low | Conservative pricing model; users can adjust thresholds |

---

## Appendix A: Complete Hook Configuration

The full `hooks.json` configuration for the VibeOS safety system:

```json
{
  "description": "VibeOS safety and lifecycle hooks",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/protect-data.sh",
            "timeout": 10
          }
        ]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/restrict-paths.sh",
            "timeout": 10
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/phase-gate.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format-code.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh"
          }
        ]
      },
      {
        "matcher": "idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh"
          }
        ]
      }
    ],
    "PostToolUseFailure": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh error"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/check-context.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/session-startup.sh"
          }
        ]
      }
    ]
  }
}
```

## Appendix B: Safety Layer Architecture

```
Layer 8: CLAUDE.md Size Management   (check-context.sh, Verifier pruning)
         |                          Prevents instruction bloat and context waste
         v                          500-line soft limit, 600-line hard limit
Layer 7: Cost Monitoring             (check-context.sh)
         |                          Prevents uncontrolled API spend
         v                          $2/$5/$20 thresholds with hard stop
Layer 6: Context Monitoring          (check-context.sh)
         |                          Prevents degraded-reasoning safety violations
         v                          at 60%/80%/90% thresholds
Layer 5: Worktree Isolation          (git worktree, cleanup-worktree.sh)
         |                          Filesystem-level containment for Builder and Scout
         v                          Atomic rollback via worktree removal
Layer 4: Git Recovery                (checkpoint.sh, rollback.sh)
         |                          Recovery when all else fails
         v                          Non-destructive by default (--soft, stash)
Layer 3: Notifications               (notify.sh)
         |                          Alerts user on permission stall, completion, failure
         v                          Silent on all normal operations
Layer 2: Hook Validation             (restrict-paths.sh, protect-data.sh, phase-gate.sh)
         |                          Parameter-level validation with custom messages
         v                          Path canonicalization, regex command matching
Layer 1: settings.json               (allowedTools, deniedTools)
         |                          Declarative tool-level permission control
         v                          Simple glob patterns, zero tokens
Layer 0: Per-Agent Scoping           (agent .md YAML frontmatter)
         |                          Principle of least privilege per agent role
         v                          5 agents: Scout and Startup cannot write,
                                    Orchestrator writes only via Bash scripts
Foundation: CLAUDE.md Rules          (security rules, TDR security decisions)
                                    Model-level guidance for secure code generation
                                    Pinned rules protected from auto-pruning
```

Each layer compensates for the limitations of the layers above it. No single layer is sufficient on its own. The combination provides defense-in-depth that protects non-technical users from the full range of risks introduced by autonomous AI agent operation.

## Appendix C: Cross-References

This document references the following architecture documents:

| Reference | Section | What Is Referenced |
|-----------|---------|-------------------|
| `architecture/schemas.md` Section 2 | Sections 2.4, 9.3, 9.5 | `config.json` schema (cost_limits, sandbox fields) |
| `architecture/schemas.md` Section 3 | Sections 1.2, 5.3, 5.4, 5.5, 7.7 | `state.json` schema (foundation.complete, active_feature) |
| `architecture/schemas.md` Section 4 | Section 7.7 | `backlog.json` schema |
| `architecture/schemas.md` Section 5 | Sections 7.7, 9.7 | Session log schema (tokens.estimated_cost_usd) |
| `architecture/schemas.md` Section 6 | Section 7.7 | Score file schema |
| `architecture/schemas.md` Section 7 | Section 4.4 | Signal file schemas |
| `architecture/schemas.md` Section 8 | Section 7.6 | Lock file schema |
| `architecture/agents.md` | Section 4.4 | Agent YAML frontmatter, tool permissions, isolation settings |
| `architecture/scoring.md` | Section 10.6 | Vibe Score methodology |
