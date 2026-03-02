#!/usr/bin/env bash
# scripts/protect-data.sh
# PreToolUse hook for Bash -- blocks dangerous shell commands
# 9 categories, 54 patterns
# Exit 0 = allow, Exit 2 = deny with hookSpecificOutput

set -euo pipefail

# Read hook payload from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only apply to Bash tool
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

# Skip if no command
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# --- Config-driven allowlist ---
# Read allowed patterns from .vibecrew/config.json protect_data.allowed_patterns[]
_PD_PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
_PD_CONFIG="${_PD_PROJECT_ROOT}/.vibecrew/config.json"
if [[ -f "$_PD_CONFIG" ]]; then
  _PD_ALLOWED=$(jq -r '.protect_data.allowed_patterns // [] | .[]' "$_PD_CONFIG" 2>/dev/null || true)
  if [[ -n "$_PD_ALLOWED" ]]; then
    while IFS= read -r pattern; do
      [[ -z "$pattern" ]] && continue
      if echo "$COMMAND" | grep -qE "$pattern" 2>/dev/null; then
        exit 0
      fi
    done <<< "$_PD_ALLOWED"
  fi
fi

# --- Helper: block with message ---
block() {
  local category="$1"
  local reason="$2"
  local alternative="${3:-}"

  local message="BLOCKED [$category]: $reason"
  if [[ -n "$alternative" ]]; then
    message="$message\nSafer alternative: $alternative"
  fi

  local escaped
  escaped=$(echo -e "$message" | jq -Rs '.')

  cat <<HOOK_OUTPUT
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "reason": $escaped
  }
}
HOOK_OUTPUT
  exit 2
}

# =============================================================================
# Category 1: Destructive File Operations
# =============================================================================

if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*[rR]|--recursive).*\s+/'; then
  block "Destructive" "Recursive rm targeting / destroys the filesystem." "Remove specific directories instead."
fi

if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*[rR]|--recursive).*(\s+~|\$\{?HOME\}?)'; then
  block "Destructive" "Recursive rm targeting ~ destroys the home directory." "Remove specific directories instead."
fi

if echo "$COMMAND" | grep -qE '\bmkfs\b'; then
  block "Destructive" "mkfs formats a filesystem, destroying all data."
fi

if echo "$COMMAND" | grep -qE '\bdd\s+if='; then
  block "Destructive" "dd can overwrite disks or devices." "Use cp for file copies."
fi

if echo "$COMMAND" | grep -qE '>\s*/dev/(sd|hd|nvme)'; then
  block "Destructive" "Writing directly to a block device destroys data."
fi

if echo "$COMMAND" | grep -qE '\btruncate\s+'; then
  block "Destructive" "truncate destroys file contents." "Use a backup before truncating."
fi

if echo "$COMMAND" | grep -qE '\bfind\b.*\s-delete\b'; then
  block "Destructive" "find -delete permanently removes matched files." "Use -print first to preview, then delete manually."
fi

if echo "$COMMAND" | grep -qE '\bxargs\s+rm\b'; then
  block "Destructive" "xargs rm can delete files in bulk unpredictably." "Review the file list first, then delete manually."
fi

# =============================================================================
# Category 2: Privilege Escalation
# =============================================================================

if echo "$COMMAND" | grep -qE '(^|[;&|]\s*)\\?(sudo|/usr/bin/sudo|command\s+sudo|env\s+sudo)\b'; then
  block "Privilege" "sudo executes commands with elevated privileges." "Run without sudo if possible."
fi

if echo "$COMMAND" | grep -qE '\bsu\s+-'; then
  block "Privilege" "su switches to another user (typically root)."
fi

if echo "$COMMAND" | grep -qE '(^|[;&|]\s*)(doas|/usr/bin/doas|command\s+doas|env\s+doas)\b'; then
  block "Privilege" "doas executes commands with elevated privileges."
fi

if echo "$COMMAND" | grep -qE '(^|[;&|]\s*)(pkexec|/usr/bin/pkexec|command\s+pkexec|env\s+pkexec)\b'; then
  block "Privilege" "pkexec executes commands with elevated privileges."
fi

if echo "$COMMAND" | grep -qE 'chmod\s+777'; then
  block "Privilege" "chmod 777 makes files world-readable/writable/executable." "Use chmod 755 or more restrictive permissions."
fi

if echo "$COMMAND" | grep -qE 'chmod\s+(-[a-zA-Z]*R).*777'; then
  block "Privilege" "Recursive chmod 777 is extremely dangerous." "Use chmod -R 755 or more restrictive permissions."
fi

if echo "$COMMAND" | grep -qE '(sudo\s+chown|chown\s+root|chown\s+0:)'; then
  block "Privilege" "chown to root/system user changes file ownership, which can affect system security."
fi

if echo "$COMMAND" | grep -qE 'chmod\s+([ugoa+]*s|[2467][0-7]{3})'; then
  block "Privilege" "Setting setuid/setgid bit is a security risk."
fi

# =============================================================================
# Category 3: Git Danger Zone
# =============================================================================

if echo "$COMMAND" | grep -qE 'git\s+push\s+.*--force'; then
  block "Git" "git push --force destroys remote history." "Use git push --force-with-lease for safer force pushing."
fi

if echo "$COMMAND" | grep -qE 'git\s+push\s+.*-f\b'; then
  block "Git" "git push -f destroys remote history." "Use git push --force-with-lease for safer force pushing."
fi

if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  block "Git" "git reset --hard discards all uncommitted changes permanently." "Use git stash (preserves changes) or git reset --soft (keeps staging)."
fi

if echo "$COMMAND" | grep -qE 'git\s+clean\s+.*-[a-zA-Z]*f'; then
  block "Git" "git clean -f permanently deletes untracked files." "Use git clean -n (dry run) first to preview."
fi

if echo "$COMMAND" | grep -qE 'git\s+rebase\s+.*(main|master)'; then
  block "Git" "Rebasing onto main/master rewrites shared history." "Use git merge instead for shared branches."
fi

if echo "$COMMAND" | grep -qE 'git\s+branch\s+-D\s+(main|master)'; then
  block "Git" "Deleting main/master branch destroys the primary branch."
fi

if echo "$COMMAND" | grep -qE 'git\s+checkout\s+\.(\s|;|&|\||$)'; then
  block "Git" "git checkout . discards all unstaged changes." "Use git stash to preserve changes."
fi

if echo "$COMMAND" | grep -qE 'git\s+stash\s+drop'; then
  block "Git" "git stash drop permanently deletes stashed changes." "Use git stash list to review stashes first."
fi

if echo "$COMMAND" | grep -qE 'git\s+push\s+\S+\s+(main|master)\s*$'; then
  block "Git" "Pushing directly to main/master bypasses code review." "Push to a feature branch and create a PR instead."
fi

# =============================================================================
# Category 4: Database Destruction
# =============================================================================

if echo "$COMMAND" | grep -qiE 'DROP\s+TABLE'; then
  block "Database" "DROP TABLE permanently deletes a database table and all its data."
fi

if echo "$COMMAND" | grep -qiE 'DROP\s+DATABASE'; then
  block "Database" "DROP DATABASE permanently deletes an entire database."
fi

if echo "$COMMAND" | grep -qiE 'DROP\s+SCHEMA'; then
  block "Database" "DROP SCHEMA permanently deletes a database schema."
fi

if echo "$COMMAND" | grep -qiE 'TRUNCATE\s+TABLE'; then
  block "Database" "TRUNCATE TABLE deletes all rows from a table." "Use DELETE with a WHERE clause for targeted removal."
fi

if echo "$COMMAND" | grep -qiE 'DELETE\s+FROM\s+\w+\s*;'; then
  block "Database" "DELETE FROM without WHERE deletes all rows." "Add a WHERE clause to target specific rows."
fi

if echo "$COMMAND" | grep -qiE 'DELETE\s+FROM\s+\w+\s+WHERE\s+1\s*=\s*1'; then
  block "Database" "DELETE FROM WHERE 1=1 deletes all rows." "Add a meaningful WHERE clause to target specific rows."
fi

# =============================================================================
# Category 5: Credential and Secret Exposure
# =============================================================================

if echo "$COMMAND" | grep -qE '(cat|less|more|head|tail|bat|most|view|tac|nl)\s+.*\.env\b'; then
  block "Credentials" "Reading .env files may expose secrets." "Use specific environment variables instead."
fi

if echo "$COMMAND" | grep -qE '(cat|less|more|head|tail|bat|most|view|tac|nl)\s+.*\.ssh/'; then
  block "Credentials" "Reading SSH keys exposes authentication credentials."
fi

if echo "$COMMAND" | grep -qE '(cat|less|more|head|tail|bat|most|view|tac|nl)\s+.*\.aws/(credentials|config)'; then
  block "Credentials" "Reading AWS credentials exposes cloud access keys."
fi

if echo "$COMMAND" | grep -qE 'curl\s+.*(-u|--user)'; then
  block "Credentials" "curl with credentials may expose authentication tokens." "Use environment variables for credentials."
fi

if echo "$COMMAND" | grep -qE '\bprintenv\b|env\s*$|\bset\s*$'; then
  block "Credentials" "Printing all environment variables may expose secrets." "Print specific variables: echo \$VARIABLE_NAME"
fi

if echo "$COMMAND" | grep -qE '(^|[;&|]\s*)(source|\.)\s+.*\.env\b'; then
  block "Credentials" "Sourcing .env files loads secrets into the shell environment." "Use specific environment variables instead."
fi

# =============================================================================
# Category 6: System Modification
# =============================================================================

if echo "$COMMAND" | grep -qE 'npm\s+install\s+(-g|--global)'; then
  block "System" "Global npm install modifies system packages." "Use local install: npm install <package> (without -g)."
fi

if echo "$COMMAND" | grep -qE '\bbrew\s+install\b'; then
  block "System" "brew install modifies system packages." "Install manually if needed."
fi

if echo "$COMMAND" | grep -qE '\bapt(-get)?\s+install\b'; then
  block "System" "apt install modifies system packages."
fi

if echo "$COMMAND" | grep -qE '>>?\s+.*\.(bashrc|zshrc|profile|bash_profile)'; then
  block "System" "Modifying shell profiles affects all terminal sessions."
fi

if echo "$COMMAND" | grep -qE '\blaunchctl\b'; then
  block "System" "launchctl manages macOS system services."
fi

if echo "$COMMAND" | grep -qE '\bsystemctl\b'; then
  block "System" "systemctl manages system services."
fi

if echo "$COMMAND" | grep -qE '\bcrontab\b'; then
  block "System" "crontab modifies scheduled system tasks."
fi

if echo "$COMMAND" | grep -qE '\bdefaults\s+write\b'; then
  block "System" "defaults write modifies macOS system preferences."
fi

# =============================================================================
# Category 7: Network Exfiltration
# =============================================================================

if echo "$COMMAND" | grep -qE 'curl\s+.*(-X\s+POST|-d|--data|--json)'; then
  # Exempt localhost/loopback addresses
  if ! echo "$COMMAND" | grep -qE 'localhost|127\.0\.0\.1|0\.0\.0\.0|\[::1\]'; then
    block "Network" "curl POST with data may exfiltrate information." "Review the request body and destination before sending."
  fi
fi

if echo "$COMMAND" | grep -qE '\bnc\b|\bncat\b|\bnetcat\b'; then
  block "Network" "netcat can establish arbitrary network connections."
fi

if echo "$COMMAND" | grep -qE '\bscp\b'; then
  block "Network" "scp transfers files to remote hosts."
fi

if echo "$COMMAND" | grep -qE 'rsync\s+.*:'; then
  block "Network" "rsync to remote hosts transfers data externally."
fi

if echo "$COMMAND" | grep -qE 'wget\s+.*-O\s*-\s*\|'; then
  block "Network" "wget piped to another command may execute remote code."
fi

if echo "$COMMAND" | grep -qE 'wget\s+.*--post-(data|file)\b'; then
  # Exempt localhost/loopback addresses
  if ! echo "$COMMAND" | grep -qE 'localhost|127\.0\.0\.1|0\.0\.0\.0|\[::1\]'; then
    block "Network" "wget --post-data/--post-file may exfiltrate information." "Review the request body and destination before sending."
  fi
fi

# =============================================================================
# Category 8: Resource Exhaustion
# =============================================================================

if echo "$COMMAND" | grep -qE ':\(\)\{.*:\|.*\}\s*;'; then
  block "Resource" "Fork bomb will crash the system by spawning infinite processes."
fi

if echo "$COMMAND" | grep -qE '\byes\s*\|'; then
  block "Resource" "yes | can overwhelm processes with infinite input."
fi

if echo "$COMMAND" | grep -qE 'while\s+(true|:)\s*;.*do'; then
  block "Resource" "Infinite loop without break condition." "Add a break condition or use a bounded loop."
fi

if echo "$COMMAND" | grep -qE '\bkill\s+(-9|-SIGKILL)\b'; then
  block "Resource" "kill -9 forcefully terminates a process without cleanup." "Use kill (SIGTERM) first to allow graceful shutdown."
fi

# =============================================================================
# Category 9: Indirect Execution
# =============================================================================

if echo "$COMMAND" | grep -qE '(^|[;&|]\s*)\beval\b'; then
  block "Indirect" "eval executes arbitrary code, bypassing all safety checks." "Write the command directly instead of using eval."
fi

if echo "$COMMAND" | grep -qE '\b(bash|sh|zsh|dash|ksh|fish)\s+(-[a-zA-Z]*\s+)*-c\b'; then
  block "Indirect" "Shell -c executes arbitrary code in a subshell." "Write the command directly instead of wrapping in a shell -c."
fi

if echo "$COMMAND" | grep -qE '\bbase64\b.*\|\s*(bash|sh)\b'; then
  block "Indirect" "Decoding and piping to shell executes obfuscated code."
fi

if echo "$COMMAND" | grep -qE '\b(bash|sh|zsh)\s*(<<<|<<)'; then
  block "Indirect" "Here-string/here-document to shell executes arbitrary code." "Write the command directly."
fi

# All checks passed
exit 0
