# Research: Safety and Sandboxing for Autonomous AI Agents

> **Phase 1 Research** | Document 08 | February 2026
>
> This document covers the safety model for VibeOS, a Claude Code plugin that grants AI agents significant autonomous power over the file system, shell, and git history. Safety is a non-negotiable foundation layer: without deterministic guardrails enforced via bash hooks, a single bad command can destroy data, leak credentials, or corrupt the repository. The target user is non-technical and may not understand the implications of risky operations. Every safety mechanism described here must be enforced without consuming model tokens and without relying on the model to "remember" safety rules.

---

## Table of Contents

1. [Restricting Operations to the Project Folder](#1-restricting-operations-to-the-project-folder)
2. [Preventing Destructive Operations](#2-preventing-destructive-operations)
3. [Safe Defaults for Autonomous Operation](#3-safe-defaults-for-autonomous-operation)
4. [User Approval Gates](#4-user-approval-gates)
5. [System Notification Mechanisms (macOS)](#5-system-notification-mechanisms-macos)
6. [Rollback and Recovery Strategies](#6-rollback-and-recovery-strategies)
7. [Context Window Safety](#7-context-window-safety)
8. [Phase Gate Implementation](#8-phase-gate-implementation)
9. [Security Considerations for AI-Generated Code](#9-security-considerations-for-ai-generated-code)
10. [Recommendations for VibeOS](#10-recommendations-for-vibeos)
11. [Sources](#11-sources)

---

## 1. Restricting Operations to the Project Folder

### 1.1 The Core Problem

When Claude Code operates autonomously, it has access to the file system via Write, Edit, and Bash tools. Without constraints, the agent can read, modify, or delete files anywhere the user's OS permissions allow -- including `~/.ssh/`, `~/.aws/`, `/etc/`, or other projects entirely.

VibeOS must confine all file operations to the project root directory and a small set of explicitly allowed paths. The confinement must be enforced deterministically by bash scripts (zero model tokens), not by asking the model to self-restrict.

### 1.2 Claude Code's `--allowedTools` Flag

Claude Code supports a `--allowedTools` flag (CLI) and a `permissions.allowedTools` array (settings.json) that controls which tools can run without prompting the user for permission. Tools not in the allowlist trigger a Y/N confirmation dialog.

This is the first layer of defense: restrict the tool palette per agent.

```bash
# Stack Scout — read-only research agent, no file writes at all
claude /agent stack-scout \
  --allowedTools "Read,Glob,Grep,WebSearch,WebFetch" \
  "Evaluate the optimal tech stack for the project"

# Test Writer — can read, write test files, and run tests, but nothing else
claude /agent test-writer \
  --allowedTools "Read,Glob,Grep,Write,Edit,Bash(npm test),Bash(npx vitest *)" \
  "Write tests for the authentication module"
```

However, `--allowedTools` does not validate file paths or command contents. A Write tool that is "allowed" can still write to `/etc/hosts` if path validation is not separately enforced. This is where hook scripts come in.

### 1.3 How PreToolUse Hooks Work

Claude Code's hook system fires **before** a tool executes, giving a bash script the ability to inspect the intended operation and block it by returning exit code 2. The JSON payload delivered via stdin contains the tool name and its parameters.

**Hook event lifecycle:**

```
Claude decides to use a tool
    |
    v
PreToolUse hook fires --> script receives JSON via stdin
    |
    v
Script inspects tool_name, parameters (file path, command, etc.)
    |
    +--> Exit 0: Operation allowed, Claude proceeds
    +--> Exit 2: Operation BLOCKED, Claude receives rejection message
```

**Key fields available in the PreToolUse JSON payload:**

| Field | Description |
|-------|-------------|
| `tool_name` | The tool being invoked: `Write`, `Edit`, `Read`, `Bash`, `Glob`, `Grep` |
| `tool_input` | Object with tool-specific parameters |
| `tool_input.file_path` | For Write/Edit/Read: the target file path |
| `tool_input.command` | For Bash: the shell command string |
| `tool_input.pattern` | For Glob/Grep: the search pattern |

### 1.4 Path Validation Strategy

The following script demonstrates a PreToolUse hook that restricts Write and Edit operations to the project folder:

```bash
#!/bin/bash
# hooks/scripts/restrict-paths.sh
# PreToolUse hook for Write/Edit — blocks writes outside project root

set -euo pipefail

# --- Configuration ---
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBEOS_DIR="$PROJECT_ROOT/.vibeos"

# Allowed paths (all must be under PROJECT_ROOT)
ALLOWED_PREFIXES=(
  "$PROJECT_ROOT/src"
  "$PROJECT_ROOT/app"
  "$PROJECT_ROOT/lib"
  "$PROJECT_ROOT/components"
  "$PROJECT_ROOT/docs"
  "$PROJECT_ROOT/tests"
  "$PROJECT_ROOT/test"
  "$PROJECT_ROOT/scripts"
  "$PROJECT_ROOT/public"
  "$PROJECT_ROOT/config"
  "$PROJECT_ROOT/.vibeos"
  "$PROJECT_ROOT/CLAUDE.md"
  "$PROJECT_ROOT/VISION.md"
  "$PROJECT_ROOT/design-system.css"
  "$PROJECT_ROOT/package.json"
  "$PROJECT_ROOT/tsconfig.json"
  "$PROJECT_ROOT/.env.example"
)

# Explicitly denied paths (even if under project root)
DENIED_PATHS=(
  "$PROJECT_ROOT/.env"
  "$PROJECT_ROOT/.env.local"
  "$PROJECT_ROOT/.env.production"
  "$PROJECT_ROOT/.git/"
)

# --- Parse input ---
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only apply to Write and Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# --- Resolve canonical path ---
# Resolve symlinks and relative paths to prevent traversal attacks
if [[ -e "$FILE_PATH" ]]; then
  CANONICAL_PATH=$(realpath "$FILE_PATH")
else
  # File doesn't exist yet — resolve the parent directory
  PARENT_DIR=$(dirname "$FILE_PATH")
  if [[ -d "$PARENT_DIR" ]]; then
    CANONICAL_PATH="$(realpath "$PARENT_DIR")/$(basename "$FILE_PATH")"
  else
    CANONICAL_PATH="$FILE_PATH"
  fi
fi

# --- Check denied paths first ---
for denied in "${DENIED_PATHS[@]}"; do
  if [[ "$CANONICAL_PATH" == "$denied"* ]]; then
    echo "BLOCKED: Writing to '$FILE_PATH' is not allowed."
    echo "This path is in the deny list (sensitive file)."
    echo "If you need to modify this file, ask the user for manual approval."
    exit 2
  fi
done

# --- Check if path is under project root ---
if [[ "$CANONICAL_PATH" != "$PROJECT_ROOT"* ]]; then
  echo "BLOCKED: Writing to '$FILE_PATH' is outside the project directory."
  echo "Resolved path: $CANONICAL_PATH"
  echo "Project root:  $PROJECT_ROOT"
  echo "All file operations must stay within the project folder."
  exit 2
fi

# --- Path is within project root — allow ---
exit 0
```

### 1.5 Detecting Path Traversal Attempts

Path traversal is when a seemingly-innocent path like `src/../../etc/passwd` resolves to a location outside the project root. The critical defense is **path canonicalization** via `realpath`.

**Common traversal patterns to detect:**

| Pattern | Example | Risk |
|---------|---------|------|
| `../` sequences | `src/../../../etc/passwd` | Escape project root |
| Absolute paths | `/etc/hosts` | Direct system file access |
| Home directory | `~/` or `$HOME/` | Access to dotfiles, credentials |
| Symlink targets | `src/link -> /etc/` | Indirect escape via symlink |
| Null bytes | `file%00.txt` | Path truncation in some parsers |
| Double encoding | `..%252f..%252f` | Bypass naive string matching |

**Detection function:**

```bash
detect_traversal() {
  local path="$1"
  local project_root="$2"

  # Check for obvious traversal patterns
  if [[ "$path" == *".."* ]]; then
    echo "WARNING: Path contains '..' sequences: $path"
    return 1
  fi

  # Check for absolute paths outside project
  if [[ "$path" == /* && "$path" != "$project_root"* ]]; then
    echo "WARNING: Absolute path outside project: $path"
    return 1
  fi

  # Check for home directory references
  if [[ "$path" == "~"* || "$path" == *'$HOME'* ]]; then
    echo "WARNING: Home directory reference: $path"
    return 1
  fi

  # Resolve and compare
  local resolved
  resolved=$(realpath -m "$path" 2>/dev/null || echo "$path")
  if [[ "$resolved" != "$project_root"* ]]; then
    echo "WARNING: Resolved path escapes project: $resolved"
    return 1
  fi

  return 0
}
```

### 1.6 Symlink Attack Prevention

Symlinks are a subtle escape vector. A symlink inside the project directory can point to an arbitrary location outside it. The agent could create or follow a symlink to read/write sensitive files.

**The attack scenario:**

```
# Agent creates a symlink inside the project
ln -s /etc/passwd src/data.txt

# Later, agent writes to "src/data.txt"
# String-based path check sees "src/data.txt" — looks safe
# But the write actually lands in /etc/passwd
```

**Defense: validate the resolved target of every symlink in the path chain:**

```bash
check_symlink_safety() {
  local path="$1"
  local project_root="$2"

  # Check if the path itself is a symlink
  if [[ -L "$path" ]]; then
    local target
    target=$(readlink -f "$path")
    if [[ "$target" != "$project_root"* ]]; then
      echo "BLOCKED: Symlink '$path' points outside project: $target"
      return 1
    fi
  fi

  # Check all parent directories for symlinks
  local current="$path"
  while [[ "$current" != "/" && "$current" != "." ]]; do
    if [[ -L "$current" ]]; then
      local target
      target=$(readlink -f "$current")
      if [[ "$target" != "$project_root"* ]]; then
        echo "BLOCKED: Parent symlink '$current' points outside project: $target"
        return 1
      fi
    fi
    current=$(dirname "$current")
  done

  return 0
}
```

### 1.7 Comprehensive Sandbox Module

Combining path canonicalization, symlink checking, and sensitive file detection into a single reusable module that other hook scripts can source:

```bash
#!/bin/bash
# hooks/scripts/sandbox.sh
# Source this from other hook scripts: source ./sandbox.sh

SANDBOX_PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SANDBOX_PROJECT_ROOT=$(realpath "$SANDBOX_PROJECT_ROOT")

sandbox_canonicalize() {
  local path="$1"
  [[ "$path" != /* ]] && path="$SANDBOX_PROJECT_ROOT/$path"
  path="${path/#\~/$HOME}"
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

sandbox_check_path() {
  local path="$1"
  local canonical=$(sandbox_canonicalize "$path")

  if [[ "$canonical" != "$SANDBOX_PROJECT_ROOT"* ]]; then
    return 1
  fi

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

sandbox_check_sensitive_file() {
  local path="$1"
  local canonical=$(sandbox_canonicalize "$path")
  local basename=$(basename "$canonical")

  local sensitive_patterns=(
    ".env" ".env.local" ".env.production" ".env.staging"
    "credentials.json" "service-account.json"
    "id_rsa" "id_ed25519"
    ".npmrc" ".pypirc"
  )

  for pattern in "${sensitive_patterns[@]}"; do
    if [[ "$basename" == "$pattern" ]]; then
      return 1
    fi
  done

  if [[ "$canonical" == *"/.git/"* || "$canonical" == *"/.git" ]]; then
    return 1
  fi

  return 0
}

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
    return 1
  fi
  return 0
}
```

### 1.8 Key Finding

The combination of `realpath` canonicalization, explicit deny lists for sensitive files, and symlink target verification provides defense-in-depth. No single check is sufficient on its own -- all three layers are needed. The sandbox module should be sourced by every hook script that needs path validation, creating a single point of truth for path safety logic.

---

## 2. Preventing Destructive Operations

### 2.1 The Threat Model

When Claude Code executes Bash commands autonomously, the following categories of damage are possible:

1. **Data destruction** -- Deleting files, databases, or git history
2. **Privilege escalation** -- Running as root, modifying system configuration
3. **Repository corruption** -- Force pushing, rebasing shared branches, deleting branches
4. **Credential exposure** -- Reading or transmitting secrets
5. **System modification** -- Installing packages globally, modifying shell profiles
6. **Network exfiltration** -- Sending project data to external services
7. **Resource exhaustion** -- Fork bombs, infinite loops, massive downloads

### 2.2 Blocked Shell Commands

The `protect-data.sh` script must detect and block the following patterns via regex matching on the Bash tool's `command` field.

#### Category 1: Destructive File Operations

| Pattern | Regex | Risk Level |
|---------|-------|------------|
| `rm -rf /` | `rm\s+(-[a-zA-Z]*r[a-zA-Z]*f\|--recursive).*\s+/[^a-zA-Z]` | Critical |
| `rm -rf ~` | `rm\s+(-[a-zA-Z]*r[a-zA-Z]*f\|--recursive).*(\s+~\|\$HOME)` | Critical |
| `rm -rf` outside project | `rm\s+(-[a-zA-Z]*r[a-zA-Z]*f\|--recursive)` (then verify path) | High |
| `> /dev/sda` | `>\s*/dev/(sd\|hd\|nvme)` | Critical |
| `mkfs` | `mkfs\b` | Critical |
| `dd if=` | `dd\s+if=` | Critical |
| Truncate files | `truncate\s+` or `>\s+/` | High |

#### Category 2: Privilege Escalation

| Pattern | Regex | Risk Level |
|---------|-------|------------|
| `sudo` | `\bsudo\b` | Critical |
| `su -` | `\bsu\s+-` | Critical |
| `doas` | `\bdoas\b` | Critical |
| `pkexec` | `\bpkexec\b` | Critical |
| `chmod 777` | `chmod\s+777` | High |
| `chmod -R 777` | `chmod\s+(-[a-zA-Z]*R).*777` | Critical |
| `chown` outside project | `\bchown\b` | High |
| `setuid` | `chmod\s+[u+]*s` | Critical |

#### Category 3: Git Danger Zone

| Pattern | Regex | Risk Level |
|---------|-------|------------|
| `git push --force` | `git\s+push\s+.*--force` | Critical |
| `git push -f` | `git\s+push\s+.*-f\b` | Critical |
| `git reset --hard` | `git\s+reset\s+--hard` | High |
| `git clean -fd` | `git\s+clean\s+.*-[a-zA-Z]*f` | High |
| `git rebase` on main/master | `git\s+rebase\s+.*(main\|master)` | High |
| `git branch -D main` | `git\s+branch\s+-D\s+(main\|master)` | Critical |
| `git checkout .` (discard all) | `git\s+checkout\s+\.\s*$` | Medium |
| `git stash drop` | `git\s+stash\s+drop` | Medium |

#### Category 4: Database Destruction

| Pattern | Regex (case-insensitive) | Risk Level |
|---------|--------------------------|------------|
| `DROP TABLE` | `DROP\s+TABLE` | Critical |
| `DROP DATABASE` | `DROP\s+DATABASE` | Critical |
| `TRUNCATE TABLE` | `TRUNCATE\s+TABLE` | Critical |
| `DELETE FROM` without WHERE | `DELETE\s+FROM\s+\w+\s*;` | High |
| `DROP SCHEMA` | `DROP\s+SCHEMA` | Critical |

#### Category 5: Credential and Secret Exposure

| Pattern | Regex | Risk Level |
|---------|-------|------------|
| Read `.env` files | `cat\s+.*\.env\b` | High |
| Read SSH keys | `cat\s+.*\.ssh/` | Critical |
| Read AWS credentials | `cat\s+.*\.aws/(credentials\|config)` | Critical |
| curl with credentials | `curl\s+.*(-u\|--user)` | High |
| Print environment vars | `\bprintenv\b\|env\s*$\|\bset\s*$` | Medium |

#### Category 6: System Modification

| Pattern | Regex | Risk Level |
|---------|-------|------------|
| `npm install -g` | `npm\s+install\s+(-g\|--global)` | High |
| `brew install` | `\bbrew\s+install\b` | Medium |
| `apt install` | `\bapt(-get)?\s+install\b` | High |
| `pip install` (system) | `pip\s+install\b` (without venv check) | Medium |
| Modify shell profiles | `.*>>?\s+.*\.(bashrc\|zshrc\|profile\|bash_profile)` | High |
| `launchctl` | `\blaunchctl\b` | High |
| `systemctl` | `\bsystemctl\b` | High |
| `crontab` | `\bcrontab\b` | High |
| `defaults write` | `\bdefaults\s+write\b` | High |

#### Category 7: Network and Exfiltration

| Pattern | Regex | Risk Level |
|---------|-------|------------|
| `curl` POST with project data | `curl\s+.*(-X\s+POST\|-d\|--data)` | Medium |
| `nc` (netcat) | `\bnc\b\|\bncat\b\|\bnetcat\b` | High |
| `scp` | `\bscp\b` | High |
| `rsync` to remote | `rsync\s+.*:` | High |

#### Category 8: Resource Exhaustion

| Pattern | Regex | Risk Level |
|---------|-------|------------|
| Fork bomb | `:\(\)\{.*:\|.*\}\s*;` | Critical |
| `yes \|` | `\byes\s*\|` | Medium |
| Infinite loop | `while\s+true\s*;.*do` (with no break detected) | Medium |

### 2.3 Blocked File Operations

In addition to shell command blocking, the `restrict-paths.sh` hook blocks file write operations to sensitive locations:

| Target | Hook | Risk |
|--------|------|------|
| System directories (`/etc`, `/usr`, `/System`) | restrict-paths.sh | Critical -- OS corruption |
| Home directory dotfiles (`.bashrc`, `.zshrc`, `.ssh/`) | restrict-paths.sh | High -- shell/credential corruption |
| `.git` directory | restrict-paths.sh | High -- repository corruption |
| `.env` files | restrict-paths.sh | High -- credential exposure |
| Files outside project root | restrict-paths.sh | High -- data integrity violation |

### 2.4 Implementation: protect-data.sh

```bash
#!/bin/bash
# hooks/scripts/protect-data.sh
# PreToolUse hook for Bash — blocks dangerous shell commands

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only apply to Bash tool
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Normalize for case-insensitive matching on SQL patterns
COMMAND_LOWER=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]')

# --- Critical blocks (always blocked, no exceptions) ---

# Destructive file operations outside project
if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|--recursive)\s+(/[^a-zA-Z]|~|\$HOME)'; then
  echo "BLOCKED: Recursive delete of system/home directory detected."
  echo "Command: $COMMAND"
  echo "This operation is never allowed."
  exit 2
fi

# Privilege escalation
if echo "$COMMAND" | grep -qE '\b(sudo|su\s+-|doas|pkexec)\b'; then
  echo "BLOCKED: Privilege escalation detected."
  echo "Command: $COMMAND"
  echo "VibeOS agents must not run commands as root."
  exit 2
fi

# Git force push
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*(--force|-f\b)'; then
  echo "BLOCKED: Git force push detected."
  echo "Command: $COMMAND"
  echo "Force pushing can destroy remote history. Use --force-with-lease on feature branches only."
  exit 2
fi

# Git rebase on main/master
if echo "$COMMAND" | grep -qE 'git\s+rebase\s+.*(main|master)\b'; then
  echo "BLOCKED: Rebase on main/master detected."
  echo "Command: $COMMAND"
  echo "Rebasing shared branches can corrupt history for all collaborators."
  exit 2
fi

# Database destruction
if echo "$COMMAND_LOWER" | grep -qE '(drop\s+(table|database|schema)|truncate\s+table)'; then
  echo "BLOCKED: Destructive database operation detected."
  echo "Command: $COMMAND"
  echo "DROP/TRUNCATE operations require manual execution."
  exit 2
fi

# chmod 777
if echo "$COMMAND" | grep -qE 'chmod\s+(-[a-zA-Z]*R\s+)?777'; then
  echo "BLOCKED: chmod 777 detected — insecure permissions."
  echo "Command: $COMMAND"
  echo "Use specific permissions instead (e.g., chmod 755 for directories, 644 for files)."
  exit 2
fi

# Fork bomb
if echo "$COMMAND" | grep -qE ':\(\)\{.*:\|.*\}'; then
  echo "BLOCKED: Fork bomb detected."
  exit 2
fi

# Disk write
if echo "$COMMAND" | grep -qE '(mkfs|dd\s+if=|>\s*/dev/(sd|hd|nvme))'; then
  echo "BLOCKED: Direct disk write operation detected."
  exit 2
fi

# Kill signals
if echo "$COMMAND" | grep -qE '\bkill\s+(-9|-SIGKILL)\b'; then
  echo "BLOCKED: kill -9 (SIGKILL) detected."
  echo "Command: $COMMAND"
  echo "Forceful process killing can cause data corruption. Use graceful signals (SIGTERM) instead."
  exit 2
fi

# System modification commands (macOS)
if echo "$COMMAND" | grep -qE '\b(launchctl|defaults\s+write)\b'; then
  echo "BLOCKED: macOS system modification detected."
  echo "Command: $COMMAND"
  echo "System-level changes require manual execution."
  exit 2
fi

# --- High-risk blocks (blocked with explanation and safer alternative) ---

# git reset --hard
if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  echo "BLOCKED: git reset --hard discards all uncommitted changes permanently."
  echo "Safer alternative: git stash (preserves changes) or git reset --soft (keeps staging)."
  exit 2
fi

# git clean -f
if echo "$COMMAND" | grep -qE 'git\s+clean\s+.*-[a-zA-Z]*f'; then
  echo "BLOCKED: git clean -f permanently deletes untracked files."
  echo "Safer alternative: git clean -n (dry run first) or manually review untracked files."
  exit 2
fi

# Delete branch main/master
if echo "$COMMAND" | grep -qE 'git\s+branch\s+-D\s+(main|master)\b'; then
  echo "BLOCKED: Deletion of main/master branch."
  exit 2
fi

# Credential file access
if echo "$COMMAND" | grep -qE 'cat\s+.*(\.ssh/|\.aws/(credentials|config)|\.env\b)'; then
  echo "BLOCKED: Attempting to read sensitive credential file."
  echo "Command: $COMMAND"
  echo "Credential files must never be read by automated agents."
  exit 2
fi

# System modification
if echo "$COMMAND" | grep -qE '\b(systemctl|crontab)\b'; then
  echo "BLOCKED: System service modification detected."
  echo "Command: $COMMAND"
  echo "System-level changes require manual execution."
  exit 2
fi

# Global package installation
if echo "$COMMAND" | grep -qE 'npm\s+install\s+(-g|--global)'; then
  echo "BLOCKED: Global npm install detected."
  echo "Command: $COMMAND"
  echo "Use local project dependencies instead: npm install <package> (without -g)."
  exit 2
fi

# Shell profile modification
if echo "$COMMAND" | grep -qE '>>?\s+.*\.(bashrc|zshrc|profile|bash_profile)'; then
  echo "BLOCKED: Shell profile modification detected."
  echo "Command: $COMMAND"
  echo "Modifying shell configuration requires manual user action."
  exit 2
fi

# Netcat / exfiltration
if echo "$COMMAND" | grep -qE '\b(nc|ncat|netcat)\b'; then
  echo "BLOCKED: Netcat usage detected — potential data exfiltration vector."
  exit 2
fi

# --- Medium-risk: path-verified blocks ---

if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|--recursive)'; then
  TARGET=$(echo "$COMMAND" | grep -oE '[^ ]+$')
  RESOLVED=$(realpath -m "$TARGET" 2>/dev/null || echo "$TARGET")
  if [[ "$RESOLVED" != "$PROJECT_ROOT"* ]]; then
    echo "BLOCKED: rm -rf target resolves outside project directory."
    echo "Target: $TARGET -> $RESOLVED"
    echo "Project: $PROJECT_ROOT"
    exit 2
  fi
fi

# --- All checks passed ---
exit 0
```

### 2.5 Defense-in-Depth

The regex-based approach is inherently imperfect -- a sufficiently creative command can bypass string matching (e.g., using base64 encoding, variable expansion, or eval). The mitigation is a layered defense:

| Layer | Mechanism | Catches |
|-------|-----------|---------|
| Layer 1 | Regex matching in `protect-data.sh` | 95% of dangerous commands |
| Layer 2 | File system path validation in `restrict-paths.sh` | Write escapes, path traversal |
| Layer 3 | Claude Code's built-in `settings.json` permissions | Unrecognized tools and patterns |
| Layer 4 | Git-based rollback | Recovery when all else fails |

No single layer is sufficient. Each layer catches what the others miss.

### 2.6 Key Finding

Regex-based command blocking is a necessary but imperfect first defense. The combination of command-level blocking (`protect-data.sh`), file-path validation (`restrict-paths.sh`), tool-level permissions (`settings.json`), and git-based recovery provides adequate safety for the VibeOS use case. The primary residual risk is command obfuscation (base64-encoded payloads, variable interpolation, eval), which is unlikely in a model-generated context but should be documented as a known limitation.

---

## 3. Safe Defaults for Autonomous Operation

### 3.1 The Trust Spectrum

The core principle is **safe by default, escalate when uncertain**. Claude Code operations fall on a spectrum from fully autonomous to requiring explicit user confirmation. VibeOS defines three trust levels:

```
FULLY AUTONOMOUS          SUPERVISED              MANUAL
(auto-approved)      (notify, then proceed)    (block until approved)
       |                      |                      |
  Read files            Create new files      Delete files (any)
  Search/Grep           Write to src/         Git operations on main
  Run tests             Install dev deps      Deploy/publish
  Format code           Git commit            Access credentials
  Lint                  Git push (feature)    System modifications
  Build                 Create branches       Database mutations
  Read .vibeos/         Run dev server        Force operations
  Context7 lookup       Modify package.json   Network requests (POST)
```

### 3.2 What Agents CAN Do Without Asking

These operations are safe because they are read-only or produce easily reversible side effects:

| Operation | Tool | Justification |
|-----------|------|---------------|
| Read any project file | Read | Read-only, no side effects |
| Search with Glob/Grep | Glob, Grep | Read-only |
| Run test suite | Bash (`npm test`, `vitest`) | Isolated, read-only output |
| Run linter | Bash (`eslint`, `prettier --check`) | Read-only output |
| Run build | Bash (`npm run build`) | Produces artifacts in known directories |
| Format code (post-write) | Bash (prettier, etc.) | Modifies only already-written files |
| Write to `.vibeos/` state files | Write | Plugin state, easily reset |
| Fetch documentation via Context7 | MCP | Read-only external data |
| Git status / log / diff | Bash | Read-only git queries |
| Create feature branches | Bash (`git checkout -b feat/...`) | Non-destructive, reversible |
| Git add and commit | Bash (`git add`, `git commit`) | Versioned, reversible |

### 3.3 What Agents MUST Ask the User For

These operations modify the project or external state in ways that are not trivially reversible:

| Operation | Tool | Why It Needs Approval |
|-----------|------|----------------------|
| Installing new npm packages | Bash (`npm install`) | Adds dependencies, modifies lockfile |
| Running database migrations | Bash | Modifies persistent data schema |
| Pushing to remote | Bash (`git push`) | Affects shared state |
| Creating/merging pull requests | Bash (`gh pr create`) | Affects collaboration workflow |
| Deleting files | Bash (`rm`) | Data loss potential |
| Modifying `.env` files | Write/Edit | Credential exposure risk |
| Any command modifying state outside project | Bash | Violates sandbox boundary |

### 3.4 What Agents Can NEVER Do

These operations are blocked unconditionally by `protect-data.sh` and cannot be overridden:

| Operation | Why It Is Forbidden |
|-----------|-------------------|
| Force push (`git push --force`) | Destroys remote history |
| Delete branches (except own feature branches after merge) | Data loss for collaborators |
| Modify system files (`/etc`, `/usr`, `/System`) | OS corruption |
| Execute `sudo` or any privilege escalation | Root access is never needed for development |
| Send network requests to unknown endpoints (except via MCP) | Data exfiltration risk |
| `kill -9` (forceful process termination) | Can corrupt running processes and data |
| Modify macOS system settings (`launchctl`, `defaults write`) | System instability |

### 3.5 Recommended settings.json for VibeOS

The `settings.json` file controls which tools run without prompting and which require user confirmation:

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
      "Bash(git push --force *)",
      "Bash(git push -f *)",
      "Bash(git reset --hard *)",
      "Bash(git clean -f *)",
      "Bash(rm -rf /)",
      "Bash(rm -rf ~)",
      "Bash(chmod 777 *)",
      "Bash(npm install -g *)",
      "Bash(kill -9 *)",
      "Bash(launchctl *)",
      "Bash(defaults write *)"
    ]
  }
}
```

### 3.6 Per-Agent Permission Scoping

Each VibeOS agent should be launched with a tailored toolset. Agents that do not need write access should not have it:

| Agent | Allowed Tools | Rationale |
|-------|--------------|-----------|
| Session Startup (Haiku) | Read, Glob, Grep, Bash(jq), Bash(git status) | Read-only environment check |
| Stack Scout (Sonnet) | Read, Glob, Grep, WebSearch, WebFetch | Read-only research, no file writes |
| UI Designer (Sonnet) | Read, Write, Edit, Glob, Grep, Bash(npm run *) | Writes design files only |
| Feature Developer (Sonnet) | Read, Write, Edit, Glob, Grep, Bash(npm *), Bash(npx *), Bash(git *) | Full project write access |
| Test Writer (Sonnet) | Read, Write, Edit, Glob, Grep, Bash(npm test), Bash(npx vitest *) | Writes test files, runs tests |
| Doc Generator (Sonnet) | Read, Write, Edit, Glob, Grep | Writes documentation only |
| Performance Coach (Sonnet) | Read, Glob, Grep, Bash(jq), Write(.vibeos/*) | Reads session data, writes scores |
| Quality Check (Haiku) | Read, Glob, Grep, Bash(npm test), Bash(npm run lint), Bash(npm run build) | Read-only quality checks |

### 3.7 The Settings/Hooks Complementarity

The `settings.json` permission system and the hook system are complementary, not redundant:

- **settings.json** controls whether the tool runs at all (permission prompt or auto-approve)
- **Hooks** validate the specific parameters of each tool invocation (path, command content)

Both layers must be configured. `settings.json` prevents the permission prompt from interrupting autonomous workflows for safe operations, while hooks provide fine-grained validation of each specific invocation.

### 3.8 Key Finding

The trust spectrum should default to **conservative** (more manual approvals) and relax over time as the user builds confidence. VibeOS can track the user's approval history in `.vibeos/approval-history.json` and suggest promoting operations from "manual" to "supervised" after N consecutive approvals of the same operation type. This progressive trust model reduces friction without sacrificing safety.

---

## 4. User Approval Gates

### 4.1 The Permission Prompt System

Claude Code has a built-in permission system. When an agent attempts to use a tool that is not in `allowedTools`, the system pauses execution and presents a Y/N prompt to the user:

```
Claude wants to run: npm install react-query

Allow? (Y/n)
```

The agent cannot proceed until the user responds. This is the primary approval gate for operations that are not auto-approved.

### 4.2 Custom Approval Gates via Hook Scripts

VibeOS adds a second layer of approval gates via PreToolUse hooks. When a hook script returns exit code 2, it blocks the operation and sends a descriptive message back to the model. The model then presents the blocked operation to the user as a permission prompt.

**The flow:**

```
Agent invokes tool
    |
    v
PreToolUse hook fires
    |
    +--> Hook returns exit 0: tool executes normally
    |
    +--> Hook returns exit 2 + message: tool is BLOCKED
         |
         v
    Claude receives the block message
         |
         v
    Claude presents the situation to the user
         |
         v
    User decides (approve/deny/modify)
         |
         v
    If approved: Claude retries with user's explicit consent
```

### 4.3 Risk Level Categorization

VibeOS categorizes all operations into three risk levels that determine the approval behavior:

#### Low Risk (Auto-Approve)

Operations that are read-only or produce trivially reversible side effects. These run without any user interaction.

| Operation Category | Examples |
|-------------------|----------|
| File reads | `Read`, `Glob`, `Grep` on any project file |
| Code quality | `npm run lint`, `prettier --check`, `eslint --report` |
| Test execution | `npm test`, `npx vitest`, `npx playwright test` |
| Build | `npm run build`, `npx tsc --noEmit` |
| Git queries | `git status`, `git log`, `git diff`, `git branch` |
| State reads | `cat .vibeos/state.json`, `jq . .vibeos/config.json` |

#### Medium Risk (Approve Once Per Session)

Operations that modify the project but are standard development workflow actions. The user approves the first invocation, and subsequent invocations of the same type are auto-approved for the remainder of the session.

| Operation Category | Examples | Approval Token |
|-------------------|----------|----------------|
| Dependency installation | `npm install <package>` | `npm-install` |
| Git push (feature branch) | `git push origin feat/*` | `git-push-feature` |
| PR creation | `gh pr create` | `pr-create` |
| File deletion (within project) | `rm src/old-component.tsx` | `file-delete` |
| New file creation | `Write` to new path in `src/` | `file-create` |

Implementation via session-scoped approval tokens stored in `.vibeos/state.json`:

```json
{
  "session_id": "abc123",
  "approved_operations": {
    "npm-install": {
      "approved_at": "2026-02-23T10:15:00Z",
      "approved_by": "user",
      "scope": "session"
    },
    "git-push-feature": {
      "approved_at": "2026-02-23T10:20:00Z",
      "approved_by": "user",
      "scope": "session"
    }
  }
}
```

#### High Risk (Always Ask)

Operations that are destructive, irreversible, or security-sensitive. These always require explicit user approval, regardless of prior approvals.

| Operation Category | Examples | Why Always Ask |
|-------------------|----------|----------------|
| File deletion (any) | `rm -rf src/module/` | Data loss is permanent |
| Force operations | `git push --force-with-lease` (if ever unblocked) | History rewrite |
| Main branch operations | `git merge feat/* -> main` | Affects all collaborators |
| System modifications | Any command blocked by protect-data.sh | OS stability |
| Credential access | Modifying `.env`, reading secrets | Security |
| Database mutations | `npx prisma migrate deploy` | Data integrity |
| Deploy/publish | `npm publish`, `vercel deploy` | Production impact |
| CLAUDE.md mutation | Performance Coach rule proposal | Project rules change |

### 4.4 Implementing Session-Scoped Approvals

The hook script can check for prior session-scoped approvals before blocking:

```bash
#!/bin/bash
# hooks/scripts/session-approval-gate.sh
# Checks if an operation type has been approved this session

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibeos/state.json"
OPERATION_TYPE="$1"  # e.g., "npm-install", "git-push-feature"

# Check if state file exists
if [[ ! -f "$STATE_FILE" ]]; then
  # No state file — operation not approved
  exit 2
fi

# Check if this operation type was approved this session
APPROVED=$(jq -r --arg op "$OPERATION_TYPE" \
  '.approved_operations[$op].approved_at // empty' \
  "$STATE_FILE" 2>/dev/null || echo "")

if [[ -n "$APPROVED" ]]; then
  # Previously approved this session — allow
  exit 0
else
  # Not approved — block and request approval
  echo "This operation requires your approval: $OPERATION_TYPE"
  echo "Approve it once to allow this type of operation for the rest of the session."
  exit 2
fi
```

### 4.5 Recording Approvals

When the user approves a medium-risk operation, VibeOS records it:

```bash
#!/bin/bash
# hooks/scripts/record-approval.sh
# Records a user approval for an operation type

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibeos/state.json"
OPERATION_TYPE="$1"

# Ensure state file exists
mkdir -p "$PROJECT_ROOT/.vibeos"
if [[ ! -f "$STATE_FILE" ]]; then
  echo '{"approved_operations":{}}' > "$STATE_FILE"
fi

# Record the approval
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
jq --arg op "$OPERATION_TYPE" \
   --arg ts "$TIMESTAMP" \
   '.approved_operations[$op] = {"approved_at": $ts, "approved_by": "user", "scope": "session"}' \
   "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

echo "Approved: $OPERATION_TYPE (valid for this session)"
```

### 4.6 Key Finding

The three-tier approval system (low/medium/high risk) balances safety with workflow fluency. The "approve once per session" model for medium-risk operations is critical for autonomous multi-agent workflows -- without it, agents would stall on every `npm install` or `git push`, defeating the purpose of autonomous operation. High-risk operations must always require explicit approval because their consequences are either irreversible or affect shared state.

---

## 5. System Notification Mechanisms (macOS)

### 5.1 Why Notifications Are Critical

When VibeOS runs agents autonomously across multiple terminal tabs, the developer is not watching every tab. The agent can hit three states that require human attention:

1. **Permission stall** (`permission_prompt`) -- Agent is blocked, waiting for Y/N approval
2. **Task completion** (`idle_prompt`) -- Agent finished its work and is idle
3. **Critical failure** (`PostToolUseFailure`) -- A tool execution failed and the agent cannot self-recover

Without notifications, the developer must manually poll tabs to discover these states. With 5-15 concurrent sessions, this polling destroys focus. Notifications are the mechanism that enables the Interrupt Protocol's core promise: **the system stays silent during normal operation and interrupts only when blocked, complete, or failed.**

### 5.2 terminal-notifier (Recommended)

A command-line tool that triggers native macOS notification center banners. Installable via Homebrew.

```bash
brew install terminal-notifier
```

**Basic usage:**

```bash
terminal-notifier \
  -title "VibeOS: Project Approval" \
  -message "Agent blocked. Needs Y/N approval to proceed." \
  -sound "Submarine" \
  -execute "open 'warp://session/$WARP_SESSION_ID'"
```

**Key flags:**

| Flag | Purpose |
|------|---------|
| `-title` | Notification title (bold text) |
| `-message` | Notification body |
| `-subtitle` | Secondary text line |
| `-sound` | System sound name (Submarine, Glass, Ping, Basso, etc.) |
| `-execute` | Shell command to run when notification is clicked |
| `-open` | URL to open when notification is clicked |
| `-group` | Group ID for replacing/updating existing notifications |
| `-remove` | Remove a notification by group ID |
| `-appIcon` | Custom icon for the notification |
| `-timeout` | Auto-dismiss after N seconds |

**Advantages:** Native macOS integration, supports click-to-execute, customizable sounds, can replace/update existing notifications.

**Limitations:** macOS only. Requires "Allow Notifications" enabled in System Settings > Notifications > terminal-notifier.

### 5.3 osascript (AppleScript) Fallback

Built-in macOS utility. No installation required.

```bash
# Simple notification
osascript -e 'display notification "Agent needs approval" with title "VibeOS"'

# Notification with sound
osascript -e 'display notification "Task complete" with title "VibeOS" sound name "Glass"'

# Dialog box that blocks until user responds (use sparingly)
osascript -e 'display dialog "Agent wants to delete src/old-module/. Allow?" buttons {"Cancel", "Allow"} default button "Cancel"'
```

**Advantages:** No installation required. Can create blocking dialogs for critical confirmations.

**Limitations:** No click-to-execute action on notifications. Dialogs are modal and disruptive. No deep-linking.

### 5.4 OSC Escape Sequences (Terminal-Native)

```bash
# OSC 9 — Simple notification (iTerm2 and some terminals)
printf '\e]9;Agent needs approval\a'

# OSC 777 — Notification with title and body (Warp and advanced terminals)
printf '\e]777;notify;VibeOS;Agent blocked — needs Y/N approval\a'

# BEL character — Simple terminal bell/badge
printf '\a'
```

**Terminal support matrix:**

| Terminal | OSC 9 | OSC 777 | BEL Badge | Deep-Link |
|----------|-------|---------|-----------|-----------|
| Warp | Yes | Yes | Yes | Yes (`warp://session/<id>`) |
| iTerm2 | Yes | No | Yes | No |
| Terminal.app | No | No | Yes (bounce dock) | No |
| VS Code Terminal | No | No | No | No |
| Alacritty | No | No | Yes | No |
| Kitty | No | No | Yes | No |

### 5.5 Warp Terminal Deep-Linking

Warp Terminal exposes a `WARP_SESSION_ID` environment variable unique to each tab. Combined with the `warp://session/<id>` URI scheme, this enables click-to-focus on the exact tab where the agent is waiting:

```bash
SESSION_ID="${WARP_SESSION_ID:-}"

if [[ -n "$SESSION_ID" ]]; then
  DEEP_LINK="warp://session/$SESSION_ID"
  terminal-notifier \
    -title "VibeOS: Approval Needed" \
    -message "Agent blocked. Click to focus the right tab." \
    -execute "open '$DEEP_LINK'"
else
  terminal-notifier \
    -title "VibeOS: Approval Needed" \
    -message "Agent blocked. Switch to the terminal to approve."
fi
```

### 5.6 The Interrupt Protocol: Notification Categories

VibeOS defines three notification categories. All other events are **silent** to preserve Deep Work state:

| Category | Trigger | Priority | Sound | Action |
|----------|---------|----------|-------|--------|
| `permission_prompt` | Agent blocked, needs Y/N | Critical | Submarine | Deep-link to tab |
| `idle_prompt` | Task complete, awaiting instruction | High | Glass | Deep-link to tab |
| `PostToolUseFailure` | Tool error, may need intervention | High | Basso | Deep-link to tab |
| All other events | Normal operation | Silent | None | None |

This is the core design principle: **the system stays silent unless it needs the human.** This is the opposite of most notification systems, which default to noisy and require the user to silence them.

### 5.7 Notification Fallback Chain

The notification script should degrade gracefully when tools are unavailable:

```
Warp deep link + terminal-notifier
    |
    v (no WARP_SESSION_ID)
terminal-notifier without deep link
    |
    v (no terminal-notifier)
osascript notification
    |
    v (osascript fails)
Terminal bell (printf '\a')
    |
    v (all else fails)
Write to .vibeos/notifications.log (silent but auditable)
```

### 5.8 Complete Notification Script

```bash
#!/bin/bash
# hooks/scripts/notify.sh
# Terminal-adaptive notification system for VibeOS

set -euo pipefail

# Ensure jq is available
if ! command -v jq &> /dev/null; then
  echo "Error: jq is required for VibeOS notifications." >&2
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

# --- Determine notification title and body ---
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
      # Non-critical event — exit silently to preserve Deep Work
      exit 0
      ;;
  esac
fi

# --- Detect terminal and dispatch notification ---
detect_terminal() {
  if [[ -n "${WARP_SESSION_ID:-}" ]]; then
    echo "warp"
  elif [[ "${TERM_PROGRAM:-}" == "iTerm.app" ]]; then
    echo "iterm2"
  elif [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
    echo "vscode"
  elif [[ "${TERM_PROGRAM:-}" == "Apple_Terminal" ]]; then
    echo "terminal_app"
  else
    echo "generic"
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
        -execute "open '$DEEP_LINK'"
      ;;
    "iterm2")
      printf '\e]9;%s\a' "$BODY"
      terminal-notifier \
        -title "$TITLE" \
        -message "$BODY" \
        -sound "$SOUND" \
        -group "vibeos-iterm"
      ;;
    *)
      terminal-notifier \
        -title "$TITLE" \
        -message "$BODY" \
        -sound "$SOUND" \
        -group "vibeos-generic"
      ;;
  esac
elif command -v osascript &> /dev/null; then
  osascript -e "display notification \"$BODY\" with title \"$TITLE\" sound name \"$SOUND\"" 2>/dev/null || true
else
  # Last resort: terminal bell
  printf '\a'
fi

# Log the notification event
LOG_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)/.vibeos"
if [[ -d "$LOG_DIR" ]]; then
  echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"type\":\"$TYPE\",\"title\":\"$TITLE\",\"terminal\":\"$TERMINAL\"}" \
    >> "$LOG_DIR/notifications.log" 2>/dev/null || true
fi

exit 0
```

### 5.9 Key Finding

The optimal notification stack for macOS is `terminal-notifier` (for native banners) combined with Warp deep-linking (for tab focus). The system must fail gracefully down the fallback chain. Critically, the notification script must always exit 0 -- it must never block the agent's execution loop due to a notification failure.

---

## 6. Rollback and Recovery Strategies

### 6.1 Why Rollback Is Critical for AI Agents

AI agents can make mistakes at scale. Unlike human developers who make small, incremental changes, AI agents can make sweeping changes across many files in a single operation. A Feature Developer agent might rewrite 20 files in one pass. If the result is wrong, the ability to undo the entire action atomically is critical.

For non-technical VibeOS users, the rollback mechanism must be simple and non-destructive. The user should never need to understand git internals to recover from an agent mistake.

### 6.2 Git as the Safety Net

Every change made by a VibeOS agent must be committed. Every commit is recoverable. Git is the ultimate safety net -- but only if the agent commits early and often.

**Principle: no uncommitted work should persist for more than one phase of a Tier 2 cycle.**

### 6.3 Strategy 1: Checkpoint Commits (Recommended)

The most robust approach for autonomous agents: create lightweight checkpoint commits before risky operations, then use `git revert` or `git reset --soft` to undo if needed.

```bash
#!/bin/bash
# scripts/checkpoint.sh
# Creates a checkpoint commit before risky agent operations

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
CHECKPOINT_MSG="checkpoint: pre-agent-action $TIMESTAMP"

cd "$PROJECT_ROOT"
git add -A
git commit --allow-empty -m "$CHECKPOINT_MSG" 2>/dev/null || true

echo "$CHECKPOINT_MSG"
```

```bash
#!/bin/bash
# scripts/rollback.sh
# Rolls back to the most recent checkpoint

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"

# Find the most recent checkpoint commit
CHECKPOINT=$(git log --oneline --grep="^checkpoint:" -1 --format="%H")

if [[ -z "$CHECKPOINT" ]]; then
  echo "No checkpoint found. Cannot rollback."
  exit 1
fi

# Reset to checkpoint (soft — preserves changes as unstaged)
git reset --soft "$CHECKPOINT"

echo "Rolled back to checkpoint: $(git log --oneline -1 "$CHECKPOINT")"
echo "Changes from the agent's work are now unstaged."
echo "Run 'git checkout -- .' to discard them, or 'git stash' to save them."
```

### 6.4 Strategy 2: Git Stash (Preserve and Undo)

Git stash saves the current working directory state and reverts to the last commit:

```bash
# Before an agent starts a risky operation
git stash push --include-untracked -m "pre-agent-checkpoint: $(date +%Y%m%d-%H%M%S)"

# If the agent's work needs to be undone
git stash pop  # Restores the pre-agent state

# If the agent's work was good, discard the checkpoint
git stash drop
```

**Limitation:** Stash does not capture untracked files unless `--include-untracked` is used. Always use `--include-untracked` for agent checkpoints.

### 6.5 Strategy 3: Feature Branch Isolation

VibeOS already uses feature branches (`feat/<name>`, `fix/<name>`). This provides natural isolation:

```bash
# If an agent's feature branch is broken
git checkout main
git branch -D feat/broken-feature  # Delete the broken branch

# Or reset it to the branching point
git checkout feat/broken-feature
BRANCH_POINT=$(git merge-base main feat/broken-feature)
git reset --soft "$BRANCH_POINT"
```

**Key advantage:** if an agent damages its feature branch, only that branch is affected. `main` and all other feature branches are untouched.

### 6.6 Strategy 4: Git Worktrees for Agent Isolation

Git worktrees allow multiple branches to be checked out simultaneously in different directories. Each agent can work in its own worktree:

```bash
# Create a worktree for an agent
git worktree add ../agent-workspace-auth feat/user-authentication

# Agent works in ../agent-workspace-auth
# If anything goes wrong, simply remove the worktree
git worktree remove ../agent-workspace-auth --force

# The branch still exists and can be cleaned up separately
git branch -D feat/user-authentication
```

**Advantages:** Complete file system isolation between agents. One agent's mistakes cannot affect another agent's working directory.

**Disadvantage:** More complex to manage. Requires coordination between worktree paths and agent configurations.

### 6.7 Strategy 5: WIP Commit Pattern for Session Recovery

VibeOS's `/wrap` command creates WIP commits for incomplete features. These serve as recovery points:

```bash
# /wrap creates this for in-progress features
git add -A
git commit -m "wip(trip-creation): plan + design + coding done"

# Next session, if something goes wrong, reset to the WIP
git log --oneline --grep="^wip(" -5
# Pick the desired WIP commit
git reset --soft <commit-hash>
```

### 6.8 Idempotent Operations

Agents should be designed so re-running the same operation does not cause harm. This is critical for recovery: if an agent fails partway through, the user should be able to restart the agent on the same task without double-applying changes.

**Patterns for idempotency:**

| Operation | Idempotent Approach |
|-----------|-------------------|
| File creation | Check if file exists before writing; overwrite if content differs |
| Dependency installation | `npm install` is naturally idempotent |
| Git branch creation | `git checkout -b` fails if branch exists; use `git checkout -B` or check first |
| Database migration | Migrations track which have been applied; re-running skips applied ones |
| Test execution | Tests are naturally idempotent |

### 6.9 Automated Checkpoint in Hook Scripts

When `protect-data.sh` blocks a dangerous command, it can create an automatic checkpoint to preserve the current state before any potential follow-up action:

```bash
# At the top of protect-data.sh
create_safety_checkpoint() {
  local reason="$1"
  local project_root="$(git rev-parse --show-toplevel 2>/dev/null)"
  if [[ -n "$project_root" ]]; then
    cd "$project_root"
    git add -A 2>/dev/null
    git commit --allow-empty -m "safety-checkpoint: $reason [$(date +%H:%M:%S)]" 2>/dev/null || true
  fi
}

# When blocking a dangerous command
create_safety_checkpoint "blocked dangerous command: $COMMAND"
echo "BLOCKED: ..."
exit 2
```

### 6.10 Rollback Decision Matrix

| Scenario | Recommended Strategy | Commands |
|----------|---------------------|----------|
| Agent wrote bad code, not committed | `git checkout -- <files>` | Discard specific file changes |
| Agent made a bad commit | `git reset --soft HEAD~1` | Undo commit, keep changes |
| Agent made multiple bad commits | `git reset --soft <checkpoint>` | Undo to checkpoint |
| Agent broke the feature branch | `git checkout main && git branch -D <branch>` | Delete branch, start over |
| Agent needs to be stopped mid-task | `git stash push --include-untracked` | Save state, review later |
| Multiple agents conflicting | Use git worktrees | Isolate each agent |
| Need to compare before/after | `git diff <checkpoint>..HEAD` | Review all agent changes |

### 6.11 Key Finding

The **checkpoint commit pattern** is the most robust rollback strategy for autonomous agents. It is non-destructive (unlike `git reset --hard`), works with git's standard tooling, and creates an auditable history of agent actions. VibeOS should automatically create checkpoint commits before every major agent operation (start of `/new-feature`, before each phase transition, before `/wrap`).

---

## 7. Context Window Safety

### 7.1 Context Exhaustion as a Safety Issue

Context window exhaustion is not merely a performance problem -- it is a **safety issue**. When an agent is operating near the limits of its context window, several dangerous things happen:

1. **Degraded reasoning** -- The model loses track of earlier instructions, including safety constraints
2. **Hallucinated context** -- The model may "remember" instructions that have been pushed out of context
3. **Instruction drift** -- The model may forget project-specific rules from CLAUDE.md
4. **Safety rule amnesia** -- Safety instructions given early in the conversation may be forgotten
5. **Poor decision making** -- The model may make incorrect architectural decisions due to incomplete context

For a non-technical VibeOS user, context exhaustion is especially dangerous because the user may not recognize that the agent's quality has degraded. The agent continues to produce output that looks correct but may violate safety rules or architectural constraints that it can no longer "see."

### 7.2 Warning Thresholds

VibeOS defines three context usage thresholds with escalating responses:

| Threshold | Level | Response |
|-----------|-------|----------|
| 60% | Soft warning | Log warning to `.vibeos/state.json` |
| 80% | Hard warning | Notification to user via `notify.sh` |
| 90% | Force stop | Agent should gracefully terminate and create a WIP commit |

### 7.3 Implementation via Stop Hook

The `check-context.sh` script is triggered by the Stop hook, which fires after each agent turn. It reads the context usage from the hook payload and takes appropriate action:

```bash
#!/bin/bash
# hooks/scripts/check-context.sh
# Stop hook — monitors context window usage and escalates warnings

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibeos/state.json"
NOTIFY_SCRIPT="$PROJECT_ROOT/claude-plugin-vibe-os/scripts/notify.sh"

# Read the hook payload from stdin
INPUT=$(cat)

# Extract context usage percentage from the payload
# The Stop hook payload includes context_window usage metrics
CONTEXT_PERCENT=$(echo "$INPUT" | jq -r '.context_window_percent // 0' 2>/dev/null || echo "0")

# Ensure state directory exists
mkdir -p "$PROJECT_ROOT/.vibeos"

# --- 60% threshold: soft warning ---
if (( $(echo "$CONTEXT_PERCENT >= 60" | bc -l 2>/dev/null || echo "0") )); then
  # Log the warning to state file
  jq --arg pct "$CONTEXT_PERCENT" \
     --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
     '.context_warnings = (.context_warnings // []) + [{"percent": $pct, "timestamp": $ts, "level": "soft"}]' \
     "$STATE_FILE" > "${STATE_FILE}.tmp" 2>/dev/null && mv "${STATE_FILE}.tmp" "$STATE_FILE" || true

  echo "WARNING: Context window is ${CONTEXT_PERCENT}% full."
  echo "Consider wrapping up the current task and using /wrap to save progress."
fi

# --- 80% threshold: hard warning with notification ---
if (( $(echo "$CONTEXT_PERCENT >= 80" | bc -l 2>/dev/null || echo "0") )); then
  echo "CRITICAL: Context window is ${CONTEXT_PERCENT}% full."
  echo "You should /wrap immediately to save progress before context is exhausted."

  # Fire notification via notify.sh
  if [[ -x "$NOTIFY_SCRIPT" ]]; then
    echo '{"notification_type":"permission_prompt","message":"Context window at '"$CONTEXT_PERCENT"'%. Wrap up now."}' \
      | bash "$NOTIFY_SCRIPT" 2>/dev/null || true
  fi
fi

# --- 90% threshold: force stop recommendation ---
if (( $(echo "$CONTEXT_PERCENT >= 90" | bc -l 2>/dev/null || echo "0") )); then
  echo "DANGER: Context window is ${CONTEXT_PERCENT}% full."
  echo "Agent quality is severely degraded. Stop immediately."
  echo "Run /wrap to save all progress, then start a new session."

  # Update state to signal forced stop
  jq '.force_stop = true' "$STATE_FILE" > "${STATE_FILE}.tmp" 2>/dev/null \
    && mv "${STATE_FILE}.tmp" "$STATE_FILE" || true
fi

exit 0
```

### 7.4 Context-Aware Agent Behavior

Beyond the hook, agents themselves should be context-aware. The Workflow Orchestrator should:

1. **Check context before dispatching** -- If context is above 60%, avoid launching expensive subagent operations (Stack Scout research, comprehensive test runs)
2. **Prefer subagents for expensive work** -- Stack Scout runs in its own context, preventing research from consuming the main agent's context
3. **Use MCP servers instead of pasting** -- Context7 lookups return only the relevant documentation snippet, not entire library docs
4. **Limit diff output** -- When reviewing changes, use `git diff --stat` first, then selectively view specific files rather than the entire diff

### 7.5 Context Budget Planning

For a typical VibeOS Tier 2 feature cycle, the context budget should be planned:

| Phase | Estimated Context Usage | Cumulative |
|-------|------------------------|------------|
| Plan (read spec, analyze) | 10-15% | 10-15% |
| UI Design (generate components) | 10-15% | 20-30% |
| Code (implement feature) | 15-25% | 35-55% |
| Test (write and run tests) | 10-15% | 45-70% |
| Docs (generate documentation) | 5-10% | 50-80% |

If any phase exceeds its budget, the agent should `/wrap` and continue in a new session rather than pushing past the 80% threshold.

### 7.6 Vibe Score Deduction for Context Violations

The Performance Coach deducts from the Vibe Score when context is mismanaged:

| Anti-Pattern | Deduction |
|-------------|-----------|
| Context exceeded 80% | -15 points |
| Context exceeded 90% (forced stop) | -20 points |
| Pasted documentation instead of using Context7 | -15 points |
| Tool loop (same failing command repeated 3+ times) | -10 points per loop |
| No `/wrap` before session end | -5 points |

### 7.7 Key Finding

Context exhaustion is a safety issue, not just a performance issue. A model operating at 90%+ context has degraded reasoning and may violate safety rules it can no longer see. The three-threshold system (60%/80%/90%) with escalating responses ensures the user is warned early and the agent stops before quality degrades to a dangerous level. The most effective mitigation is architectural: use subagents (Stack Scout) for expensive work and MCP servers (Context7) instead of pasting documentation.

---

## 8. Phase Gate Implementation

### 8.1 Purpose of the Phase Gate

The phase gate is the enforcement mechanism for VibeOS's core design principle: **research before code**. It blocks all source code writes until the Tier 1 foundation is complete. This prevents the most expensive mistake in AI-assisted development: writing code against the wrong architecture, the wrong design system, or the wrong technology stack.

### 8.2 What the Phase Gate Blocks

The phase gate intercepts all Write and Edit operations via a PreToolUse hook and checks whether the target file is "source code" (vs. planning/design artifacts). If the foundation is incomplete, source code writes are blocked.

**Source code directories (blocked when foundation is incomplete):**

| Directory/Pattern | Type |
|------------------|------|
| `src/` | Application source code |
| `app/` | Next.js app directory |
| `pages/` | Next.js pages directory |
| `components/` | UI components |
| `lib/` | Library code |
| `utils/` | Utility functions |
| `hooks/` (React) | Custom React hooks |
| `api/` | API routes |
| `server/` | Server code |
| `*.tsx`, `*.ts`, `*.jsx`, `*.js` (outside config) | Source files |

**Planning artifacts (always allowed, even before foundation is complete):**

| File/Pattern | Purpose |
|-------------|---------|
| `CLAUDE.md` | Project rules |
| `VISION.md` | Project goals and vision |
| `design-system.css` | Design system tokens |
| `*.tdr.md` or `tdr/` | Technology Decision Records |
| `roadmap.md` | Feature roadmap |
| `.vibeos/*` | VibeOS state files |
| `docs/*` | Documentation |
| `package.json` | Dependency manifest |
| `tsconfig.json` | TypeScript configuration |
| `.gitignore` | Git ignore rules |
| `.env.example` | Environment variable template |

### 8.3 Foundation Completion Criteria

The phase gate reads `.vibeos/state.json` to determine whether the foundation is complete. The foundation requires all of the following artifacts to exist and be approved:

```json
{
  "foundation": {
    "complete": false,
    "artifacts": {
      "vision": {
        "file": "VISION.md",
        "status": "complete",
        "approved_at": null
      },
      "design_system": {
        "file": "design-system.css",
        "status": "pending",
        "approved_at": null
      },
      "tdr": {
        "file": "tdr/technology-decision-record.md",
        "status": "pending",
        "approved_at": null
      },
      "roadmap": {
        "file": "roadmap.md",
        "status": "pending",
        "approved_at": null
      },
      "claude_md": {
        "file": "CLAUDE.md",
        "status": "complete",
        "approved_at": "2026-02-23T10:00:00Z"
      }
    }
  }
}
```

The `foundation.complete` flag is set to `true` only when all artifacts have `status: "complete"` and a non-null `approved_at` timestamp.

### 8.4 Implementation: phase-gate.sh

```bash
#!/bin/bash
# hooks/scripts/phase-gate.sh
# PreToolUse hook for Write/Edit — blocks source code writes before foundation

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
  # No state file — treat as foundation incomplete
  # But allow writes to .vibeos/ itself (bootstrap)
  if [[ "$FILE_PATH" == *".vibeos/"* ]]; then
    exit 0
  fi
  echo "BLOCKED: VibeOS state not initialized. Run /setup first."
  exit 2
fi

FOUNDATION_COMPLETE=$(jq -r '.foundation.complete // false' "$STATE_FILE" 2>/dev/null || echo "false")

# If foundation is complete, all writes are allowed (path validation
# is handled by restrict-paths.sh, which runs as a separate hook)
if [[ "$FOUNDATION_COMPLETE" == "true" ]]; then
  exit 0
fi

# --- Foundation is incomplete — check if this is a planning artifact ---

# Resolve the file path relative to project root
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
    exit 0  # This is a planning artifact — allow
  fi
done

# Check for TDR files by extension
if [[ "$FILENAME" == *.tdr.md ]]; then
  exit 0
fi

# --- This is a source code write during Tier 1 — BLOCK ---
echo "BLOCKED: Cannot write source code before the project foundation is complete."
echo ""
echo "File: $FILE_PATH"
echo ""
echo "VibeOS requires these Tier 1 artifacts before any source code:"
echo "  1. VISION.md — Project goals and target users"
echo "  2. design-system.css — Design tokens and component styles"
echo "  3. TDR — Technology Decision Record (tech stack rationale)"
echo "  4. roadmap.md — Feature roadmap with priorities"
echo "  5. CLAUDE.md — Project rules and conventions"
echo ""

# Show which artifacts are still missing
jq -r '.foundation.artifacts | to_entries[] | select(.value.status != "complete") | "  MISSING: \(.value.file) (\(.key))"' \
  "$STATE_FILE" 2>/dev/null || true

echo ""
echo "Complete all foundation artifacts, then run /status to verify."
exit 2
```

### 8.5 Lifting the Phase Gate

The phase gate is lifted when the user runs `/status` (or the Workflow Orchestrator detects that all artifacts are present) and all Tier 1 artifacts pass validation:

```bash
#!/bin/bash
# scripts/check-foundation.sh
# Validates that all Tier 1 artifacts exist and sets foundation.complete = true

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibeos/state.json"

REQUIRED_FILES=(
  "VISION.md"
  "design-system.css"
  "CLAUDE.md"
)

# Check for TDR (could be in tdr/ directory or root)
TDR_FOUND=false
if ls "$PROJECT_ROOT"/tdr/*.tdr.md 2>/dev/null | head -1 > /dev/null; then
  TDR_FOUND=true
elif [[ -f "$PROJECT_ROOT/tdr/technology-decision-record.md" ]]; then
  TDR_FOUND=true
fi

# Check for roadmap
ROADMAP_FOUND=false
if [[ -f "$PROJECT_ROOT/roadmap.md" ]]; then
  ROADMAP_FOUND=true
fi

# Validate all required files
ALL_PRESENT=true
for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$PROJECT_ROOT/$file" ]]; then
    echo "MISSING: $file"
    ALL_PRESENT=false
  else
    echo "FOUND: $file"
  fi
done

if [[ "$TDR_FOUND" == "false" ]]; then
  echo "MISSING: Technology Decision Record (tdr/)"
  ALL_PRESENT=false
else
  echo "FOUND: Technology Decision Record"
fi

if [[ "$ROADMAP_FOUND" == "false" ]]; then
  echo "MISSING: roadmap.md"
  ALL_PRESENT=false
else
  echo "FOUND: roadmap.md"
fi

# Update state
if [[ "$ALL_PRESENT" == "true" ]]; then
  TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  jq --arg ts "$TIMESTAMP" \
     '.foundation.complete = true | .foundation.completed_at = $ts' \
     "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
  echo ""
  echo "Foundation COMPLETE. Phase gate lifted. Source code writes are now allowed."
else
  echo ""
  echo "Foundation INCOMPLETE. Complete the missing artifacts before writing source code."
fi
```

### 8.6 Key Finding

The phase gate is the single most important safety mechanism in VibeOS for preventing wasted effort. Without it, agents will immediately start writing code against assumed (and often incorrect) architectural decisions. The gate must be enforced deterministically by a bash script, not by model instruction -- because model instruction can be forgotten or overridden. The exit code 2 mechanism provides the enforcement: the hook blocks the Write/Edit operation at the Claude Code runtime level, and the model cannot bypass it.

---

## 9. Security Considerations for AI-Generated Code

### 9.1 The Problem with AI-Generated Code

AI agents can inadvertently introduce security vulnerabilities into the code they generate. The model does not have adversarial intent, but it may:

1. **Copy insecure patterns** from its training data (e.g., SQL string concatenation instead of parameterized queries)
2. **Skip input validation** because the training data often omits it for brevity
3. **Use outdated dependencies** with known CVEs
4. **Hardcode secrets** in source code instead of using environment variables
5. **Disable security features** for convenience (e.g., `Content-Security-Policy: *`)
6. **Generate overly permissive CORS** configurations (`Access-Control-Allow-Origin: *`)
7. **Skip authentication/authorization** checks on new endpoints

For non-technical VibeOS users, these vulnerabilities are invisible -- the code works, the tests pass, but the application is exploitable.

### 9.2 Static Analysis Integration

VibeOS should integrate security-focused linting into the Quality Check agent and the PostToolUse format-code.sh hook.

#### ESLint Security Plugins

```bash
# Install ESLint security plugins
npm install --save-dev \
  eslint-plugin-security \
  eslint-plugin-no-unsanitized \
  @microsoft/eslint-plugin-sdl
```

**ESLint configuration (`.eslintrc.json`):**

```json
{
  "plugins": ["security", "no-unsanitized"],
  "extends": [
    "plugin:security/recommended-legacy",
    "plugin:no-unsanitized/DOM"
  ],
  "rules": {
    "security/detect-object-injection": "warn",
    "security/detect-non-literal-regexp": "warn",
    "security/detect-unsafe-regex": "error",
    "security/detect-buffer-noassert": "error",
    "security/detect-eval-with-expression": "error",
    "security/detect-no-csrf-before-method-override": "error",
    "security/detect-possible-timing-attacks": "warn",
    "no-unsanitized/method": "error",
    "no-unsanitized/property": "error"
  }
}
```

**What these rules catch:**

| Rule | Catches | Severity |
|------|---------|----------|
| `detect-eval-with-expression` | Dynamic code execution via `eval()` | Critical |
| `detect-unsafe-regex` | ReDoS-vulnerable regular expressions | High |
| `detect-object-injection` | Prototype pollution via bracket notation | Medium |
| `detect-non-literal-regexp` | Regex injection via user input | Medium |
| `detect-possible-timing-attacks` | Timing-based information leaks | Low |
| `no-unsanitized/method` | XSS via `innerHTML`, `document.write` | Critical |

#### TypeScript Strict Mode

TypeScript's strict mode catches several categories of bugs that can become security issues:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  }
}
```

### 9.3 Dependency Scanning

AI agents frequently install packages. Each new dependency is a potential attack surface.

#### npm audit

```bash
# Run as part of Quality Check
npm audit

# Fix automatically where possible
npm audit fix

# Report format for CI/hook integration
npm audit --json | jq '.vulnerabilities | to_entries[] | {name: .key, severity: .value.severity}'
```

#### Socket.dev

Socket.dev performs deeper analysis than `npm audit`, detecting supply chain attacks, typosquatting, and suspicious package behavior:

```bash
# Install Socket CLI
npm install --save-dev @socketsecurity/cli

# Analyze dependencies
npx socket report
```

#### Pre-Install Hook

VibeOS can intercept `npm install` commands and scan the package before installation:

```bash
#!/bin/bash
# hooks/scripts/scan-dependency.sh
# Scans a package before allowing installation

set -euo pipefail

PACKAGE="$1"

# Check npm advisory database
AUDIT_RESULT=$(npm audit --json 2>/dev/null || echo '{}')
VULN_COUNT=$(echo "$AUDIT_RESULT" | jq '.metadata.vulnerabilities.high + .metadata.vulnerabilities.critical' 2>/dev/null || echo "0")

if [[ "$VULN_COUNT" -gt 0 ]]; then
  echo "WARNING: $VULN_COUNT high/critical vulnerabilities detected after installing $PACKAGE"
  echo "Review with: npm audit"
fi
```

### 9.4 Secret Detection

AI agents should never hardcode secrets in source code. A pre-commit hook can catch this:

```bash
#!/bin/bash
# hooks/scripts/detect-secrets.sh
# Pre-commit hook — scans staged files for potential secrets

set -euo pipefail

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

# Patterns that indicate hardcoded secrets
SECRET_PATTERNS=(
  # API keys and tokens
  '(api[_-]?key|apikey)\s*[:=]\s*["\x27][a-zA-Z0-9]{16,}'
  '(secret|token|password|passwd|pwd)\s*[:=]\s*["\x27][^\s]{8,}'
  # AWS
  'AKIA[0-9A-Z]{16}'
  'aws[_-]?secret[_-]?access[_-]?key\s*[:=]'
  # GitHub
  'gh[ps]_[a-zA-Z0-9]{36}'
  # Stripe
  'sk_live_[a-zA-Z0-9]{24}'
  'pk_live_[a-zA-Z0-9]{24}'
  # Generic private keys
  '-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----'
  # JWT
  'eyJ[a-zA-Z0-9_-]{10,}\.eyJ[a-zA-Z0-9_-]{10,}'
  # Database connection strings
  '(postgres|mysql|mongodb)://[^\s]+'
)

FOUND_SECRETS=false

for file in $STAGED_FILES; do
  # Skip binary files, lock files, and this script itself
  if [[ "$file" == *.lock || "$file" == *-lock.* || "$file" == *.sh ]]; then
    continue
  fi

  for pattern in "${SECRET_PATTERNS[@]}"; do
    MATCHES=$(grep -nE "$pattern" "$file" 2>/dev/null || true)
    if [[ -n "$MATCHES" ]]; then
      echo "POTENTIAL SECRET in $file:"
      echo "$MATCHES" | head -3 | sed 's/^/  /'
      FOUND_SECRETS=true
    fi
  done
done

if [[ "$FOUND_SECRETS" == "true" ]]; then
  echo ""
  echo "Potential secrets detected in staged files."
  echo "Use environment variables (.env) instead of hardcoding secrets."
  echo "If these are false positives, commit with: git commit --no-verify"
  exit 1
fi

exit 0
```

### 9.5 Content Security Policy (CSP)

AI-generated web applications should include a restrictive Content Security Policy. VibeOS agents should generate CSP headers by default:

**Recommended default CSP for VibeOS-generated web apps:**

```javascript
// middleware.ts (Next.js)
import { NextResponse } from 'next/server';

export function middleware(request) {
  const response = NextResponse.next();

  // Strict CSP — no inline scripts, no eval, no unsafe-inline
  const csp = [
    "default-src 'self'",
    "script-src 'self'",
    "style-src 'self' 'unsafe-inline'",  // unsafe-inline needed for CSS-in-JS
    "img-src 'self' data: https:",
    "font-src 'self'",
    "connect-src 'self'",
    "frame-ancestors 'none'",
    "base-uri 'self'",
    "form-action 'self'",
  ].join('; ');

  response.headers.set('Content-Security-Policy', csp);
  response.headers.set('X-Content-Type-Options', 'nosniff');
  response.headers.set('X-Frame-Options', 'DENY');
  response.headers.set('X-XSS-Protection', '0');  // Deprecated, rely on CSP
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');

  return response;
}
```

### 9.6 Input Validation Patterns

VibeOS agents should follow consistent input validation patterns. These should be documented in the project's CLAUDE.md so the model applies them consistently:

```typescript
// Example: CLAUDE.md rule for input validation
// "All user input must be validated using zod schemas before processing.
//  Never trust client-side validation alone. Always validate on the server."

import { z } from 'zod';

// Define schema
const createUserSchema = z.object({
  email: z.string().email().max(255),
  name: z.string().min(1).max(100).trim(),
  password: z.string().min(8).max(128),
});

// Validate in API route
export async function POST(request: Request) {
  const body = await request.json();
  const result = createUserSchema.safeParse(body);

  if (!result.success) {
    return Response.json(
      { error: 'Validation failed', details: result.error.issues },
      { status: 400 }
    );
  }

  // result.data is now typed and validated
  const { email, name, password } = result.data;
  // ... proceed with validated data
}
```

### 9.7 CORS Configuration

AI agents frequently generate overly permissive CORS configurations. VibeOS should enforce restrictive defaults:

```typescript
// BAD — AI agents often generate this
// Access-Control-Allow-Origin: *

// GOOD — restrict to known origins
const allowedOrigins = [
  'https://myapp.com',
  'https://staging.myapp.com',
  process.env.NODE_ENV === 'development' ? 'http://localhost:3000' : null,
].filter(Boolean);

export function middleware(request: Request) {
  const origin = request.headers.get('origin');
  if (origin && allowedOrigins.includes(origin)) {
    // Set CORS headers for allowed origin
  }
}
```

### 9.8 Security Checklist for Generated Code

The Quality Check agent should verify these items before any PR is created:

| Check | Tool | Automated? |
|-------|------|-----------|
| No hardcoded secrets | `detect-secrets.sh` | Yes |
| Dependencies have no critical CVEs | `npm audit` | Yes |
| ESLint security rules pass | `eslint --plugin security` | Yes |
| TypeScript strict mode enabled | `tsc --noEmit` | Yes |
| CSP headers present (web apps) | Manual review / test | Partially |
| Input validation on all API routes | Code review / pattern check | Partially |
| CORS not set to `*` in production | `grep -r "Allow-Origin.*\*"` | Yes |
| No `eval()` or `new Function()` | ESLint security plugin | Yes |
| Authentication on protected routes | Manual review | No |
| SQL queries use parameterized statements | ESLint / code review | Partially |

### 9.9 CLAUDE.md Security Rules

VibeOS should generate default security rules in every project's CLAUDE.md:

```markdown
## Security Rules

- Never hardcode API keys, tokens, passwords, or secrets in source code. Use environment variables.
- All user input must be validated with zod schemas on the server side.
- Use parameterized queries for all database operations. Never concatenate user input into SQL.
- Set Content-Security-Policy headers. Never use 'unsafe-eval' or 'unsafe-inline' for scripts.
- CORS must specify exact allowed origins. Never use Access-Control-Allow-Origin: * in production.
- All API routes that modify data must verify authentication and authorization.
- Run npm audit before creating any pull request. Fix critical and high vulnerabilities.
- Use HTTPS for all external API calls. Never make HTTP requests to external services.
```

### 9.10 Key Finding

AI-generated code has a systematic tendency toward insecure defaults: overly permissive CORS, missing CSP headers, hardcoded secrets, and skipped input validation. The mitigation strategy has three layers: (1) static analysis tools (ESLint security plugins, npm audit, secret detection) run automatically as part of the Quality Check agent; (2) CLAUDE.md security rules that guide the model toward secure patterns during code generation; and (3) the TDR process, which forces security architecture decisions before any code is written. The first two layers are reactive (catching problems after they are introduced); the TDR is proactive (preventing problems by establishing secure patterns upfront).

---

## 10. Recommendations for VibeOS

Based on the research above, here are the prioritized recommendations for implementing safety and sandboxing in VibeOS.

### 10.1 Priority 1: Must-Have (Phase 3.1 -- Foundation)

These components must be in place before any autonomous agent operation is enabled:

| Component | Script | Hook Event | Purpose |
|-----------|--------|------------|---------|
| Path restriction | `restrict-paths.sh` | PreToolUse (Write\|Edit) | Confine all writes to project directory |
| Dangerous command blocking | `protect-data.sh` | PreToolUse (Bash) | Block destructive shell commands |
| Phase gate | `phase-gate.sh` | PreToolUse (Write\|Edit) | Enforce Tier 1 before source code |
| settings.json permissions | `.claude/settings.json` | N/A (configuration) | Auto-approve safe tools, deny dangerous ones |
| Checkpoint commit system | `checkpoint.sh` | Called by agent scripts | Create recoverable save points |

### 10.2 Priority 2: Should-Have (Phase 3.2 -- Core Agents)

These components support the autonomous multi-agent workflow:

| Component | Script | Hook Event | Purpose |
|-----------|--------|------------|---------|
| Native OS notifications | `notify.sh` | Notification, PostToolUseFailure | Alert user across terminal tabs |
| Context window monitoring | `check-context.sh` | Stop | Warn at 60%/80%, force stop at 90% |
| Rollback commands | `rollback.sh` | Manual invocation | Recover from agent mistakes |
| Session-scoped approvals | `session-approval-gate.sh` | PreToolUse | Approve-once-per-session for medium-risk ops |
| Per-agent tool scoping | Agent launch config | CLI flags | Restrict each agent to its needed tools |

### 10.3 Priority 3: Should-Have (Phase 3.4 -- Quality)

These components improve security posture of generated code:

| Component | Script/Config | Integration Point | Purpose |
|-----------|--------------|-------------------|---------|
| Secret detection | `detect-secrets.sh` | pre-commit hook | Prevent hardcoded secrets |
| ESLint security plugins | `.eslintrc.json` | Quality Check agent | Catch insecure code patterns |
| Dependency scanning | `npm audit` in CI | Quality Check agent | Detect vulnerable dependencies |
| CLAUDE.md security rules | Template | /setup command | Guide model toward secure defaults |
| CSP header template | Middleware template | Feature Developer agent | Enforce content security policy |

### 10.4 Priority 4: Nice-to-Have (Phase 3.7 -- Polish)

These components provide advanced protection:

| Component | Script | Purpose |
|-----------|--------|---------|
| Sandbox audit logging | `sandbox.sh` (log mode) | Audit trail of all sandboxed operations |
| Trust level progression | Auto-promote after N approvals | Reduce friction over time |
| Docker isolation | Containerized agent execution | Maximum isolation for untrusted operations |
| Symlink detection | Integrated into `restrict-paths.sh` | Prevent indirect sandbox escapes |
| Approval history analytics | `.vibeos/approval-history.json` | Track and optimize approval patterns |

### 10.5 Implementation Architecture

The safety system is layered. Each layer catches what the previous layers miss:

```
Layer 5: Git Recovery          (rollback.sh, checkpoint.sh)
         |                     Recovery when all else fails
         v
Layer 4: settings.json         (allowedTools, deniedTools)
         |                     Tool-level permission control
         v
Layer 3: Hook Validation       (restrict-paths.sh, protect-data.sh, phase-gate.sh)
         |                     Parameter-level validation
         v
Layer 2: Per-Agent Scoping     (--allowedTools per agent)
         |                     Agent-level tool restrictions
         v
Layer 1: Notifications         (notify.sh)
         |                     User awareness and intervention
         v
Layer 0: Context Monitoring    (check-context.sh)
                               Prevent degraded-reasoning safety violations
```

### 10.6 Hook Configuration for VibeOS

The complete hooks.json configuration:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "./claude-plugin-vibe-os/scripts/protect-data.sh",
        "description": "Block dangerous shell commands"
      },
      {
        "matcher": "Write|Edit",
        "command": "./claude-plugin-vibe-os/scripts/restrict-paths.sh",
        "description": "Restrict file writes to project directory"
      },
      {
        "matcher": "Write|Edit",
        "command": "./claude-plugin-vibe-os/scripts/phase-gate.sh",
        "description": "Block source code writes before foundation is complete"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "./claude-plugin-vibe-os/scripts/format-code.sh",
        "description": "Auto-format written files"
      }
    ],
    "Notification": [
      {
        "matcher": "permission_prompt|idle_prompt",
        "command": "./claude-plugin-vibe-os/scripts/notify.sh",
        "description": "Native OS notification for permission stalls and task completion"
      }
    ],
    "PostToolUseFailure": [
      {
        "matcher": "*",
        "command": "./claude-plugin-vibe-os/scripts/notify.sh error",
        "description": "Native OS notification for critical failures"
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "command": "./claude-plugin-vibe-os/scripts/check-context.sh",
        "description": "Context window usage warnings at 60%/80%/90%"
      }
    ]
  }
}
```

### 10.7 Critical Implementation Notes

1. **All hook scripts must exit 0 on success and exit 2 to block.** Exit code 1 is treated as a script error, not a deliberate block. If a hook script exits 1, Claude Code may interpret it as a broken script and ignore it.

2. **Hook scripts receive JSON via stdin.** Always parse with `jq` and handle missing fields gracefully with `// empty` defaults.

3. **Never block Notification or PostToolUseFailure hooks.** These are observation-only events; blocking them prevents the user from receiving critical alerts.

4. **The settings.json `allowedTools` and hook system are complementary.** Use `allowedTools` for broad permission control (auto-approve safe tools) and hooks for fine-grained validation (inspect specific parameters).

5. **Path validation must use `realpath`, not string comparison.** String-based path checking is trivially bypassed with `../` sequences.

6. **Sensitive file lists should be configurable** per project in `.vibeos/config.json`, as different projects have different sensitive files.

7. **Rollback should be non-destructive by default.** `git reset --soft` and `git stash` are preferred over `git reset --hard`. The destructive variant should require explicit user confirmation.

8. **The notify.sh script must always exit 0.** A notification failure should never block the agent's execution loop.

9. **Context window monitoring is a safety feature, not just a performance feature.** A model at 90%+ context has degraded reasoning and may violate safety rules.

10. **Security linting rules should be in CLAUDE.md, not just ESLint config.** The model uses CLAUDE.md rules during generation, catching issues before they are written. ESLint catches what the model misses.

### 10.8 Testing the Safety System

Before deploying VibeOS, the safety system should be tested with adversarial inputs:

```bash
#!/bin/bash
# test/test-safety.sh
# Smoke tests for the safety hooks

set -euo pipefail

PASS=0
FAIL=0

assert_blocked() {
  local description="$1"
  local exit_code="$2"
  if [[ "$exit_code" -eq 2 ]]; then
    echo "PASS: $description (blocked as expected)"
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
    echo "PASS: $description (allowed as expected)"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $description (expected allow, got exit $exit_code)"
    FAIL=$((FAIL + 1))
  fi
}

# Test protect-data.sh
echo "=== Testing protect-data.sh ==="

echo '{"tool_name":"Bash","tool_input":{"command":"sudo rm -rf /"}}' \
  | bash scripts/protect-data.sh 2>/dev/null; assert_blocked "sudo rm -rf /" $?

echo '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' \
  | bash scripts/protect-data.sh 2>/dev/null; assert_blocked "git push --force" $?

echo '{"tool_name":"Bash","tool_input":{"command":"npm test"}}' \
  | bash scripts/protect-data.sh 2>/dev/null; assert_allowed "npm test" $?

echo '{"tool_name":"Bash","tool_input":{"command":"git status"}}' \
  | bash scripts/protect-data.sh 2>/dev/null; assert_allowed "git status" $?

echo '{"tool_name":"Bash","tool_input":{"command":"chmod 777 /tmp"}}' \
  | bash scripts/protect-data.sh 2>/dev/null; assert_blocked "chmod 777" $?

echo '{"tool_name":"Bash","tool_input":{"command":"kill -9 1234"}}' \
  | bash scripts/protect-data.sh 2>/dev/null; assert_blocked "kill -9" $?

# Test restrict-paths.sh
echo ""
echo "=== Testing restrict-paths.sh ==="

echo '{"tool_name":"Write","tool_input":{"file_path":"/etc/passwd"}}' \
  | bash scripts/restrict-paths.sh 2>/dev/null; assert_blocked "write to /etc/passwd" $?

echo '{"tool_name":"Write","tool_input":{"file_path":"src/index.ts"}}' \
  | bash scripts/restrict-paths.sh 2>/dev/null; assert_allowed "write to src/index.ts" $?

echo '{"tool_name":"Write","tool_input":{"file_path":"src/../../etc/passwd"}}' \
  | bash scripts/restrict-paths.sh 2>/dev/null; assert_blocked "path traversal" $?

# Summary
echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
```

### 10.9 Key Finding

Safety in VibeOS is not a single mechanism -- it is a layered architecture where each layer compensates for the limitations of the layers above it. The most critical design decision is that safety is enforced by **deterministic bash scripts** (zero model tokens), not by model instructions that can be forgotten or overridden. The model should understand the safety rules (via CLAUDE.md), but enforcement must not depend on model compliance.

---

## 11. Sources

The following sources informed this research:

- **Claude Code Hooks Documentation**: https://code.claude.com/docs/en/hooks
- **Claude Code Hooks Guide**: https://code.claude.com/docs/en/hooks-guide
- **Claude Code Settings Documentation**: https://code.claude.com/docs/en/settings
- **Claude Code Plugins Reference**: https://code.claude.com/docs/en/plugins-reference
- **Claude Code Notifications (community)**: https://alexop.dev/posts/claude-code-notification-hooks/
- **Warp Desktop Notifications**: https://docs.warp.dev/terminal/more-features/notifications
- **Warp Session ID / Deep-Link**: https://github.com/warpdotdev/warp/issues/8611
- **terminal-notifier**: https://github.com/julienXX/terminal-notifier
- **Claude Code Hooks Mastery (community)**: https://github.com/disler/claude-code-hooks-mastery
- **Claude Code Hook Development Skill**: https://gist.github.com/alexfazio/653c5164d726987569ee8229a19f451f
- **eslint-plugin-security**: https://github.com/eslint-community/eslint-plugin-security
- **eslint-plugin-no-unsanitized**: https://github.com/nicolo-ribaudo/eslint-plugin-no-unsanitized
- **Socket.dev (dependency security)**: https://socket.dev/
- **npm audit documentation**: https://docs.npmjs.com/cli/commands/npm-audit
- **Zod (input validation)**: https://zod.dev/
- **OWASP Content Security Policy Cheat Sheet**: https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html
- **macOS sandbox-exec**: https://developer.apple.com/documentation/security/app-sandbox
- **Git documentation -- git-stash**: https://git-scm.com/docs/git-stash
- **Git documentation -- git-worktree**: https://git-scm.com/docs/git-worktree
- **VibeOS Architecture Design Paper**: docs/VibeOS_ Claude Plugin Architecture Design.pdf
- **VibeOS Complete Guide**: docs/vibeos-guide-complete.md

> **Note**: The content above is based on established documentation, specifications, and best practices for the referenced tools as of February 2026. All tool versions, APIs, and hook system behaviors were current at the time of writing. Claude Code's hook system is the authoritative reference for PreToolUse payload format and exit code semantics -- verify against the linked documentation for the latest details.
