#!/usr/bin/env bash
# scripts/protect-data.sh
# PreToolUse hook for Bash -- blocks dangerous shell commands
# 8 categories, 51 patterns
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

if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|--recursive).*\s+/[^a-zA-Z]'; then
  block "Destructive" "rm -rf / destroys the entire filesystem." "Remove specific directories instead."
fi

if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|--recursive).*(\s+~|\$HOME)'; then
  block "Destructive" "rm -rf ~ destroys the home directory." "Remove specific directories instead."
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

# =============================================================================
# Category 2: Privilege Escalation
# =============================================================================

if echo "$COMMAND" | grep -qE '\bsudo\b'; then
  block "Privilege" "sudo executes commands with elevated privileges." "Run without sudo if possible."
fi

if echo "$COMMAND" | grep -qE '\bsu\s+-'; then
  block "Privilege" "su switches to another user (typically root)."
fi

if echo "$COMMAND" | grep -qE '\bdoas\b'; then
  block "Privilege" "doas executes commands with elevated privileges."
fi

if echo "$COMMAND" | grep -qE '\bpkexec\b'; then
  block "Privilege" "pkexec executes commands with elevated privileges."
fi

if echo "$COMMAND" | grep -qE 'chmod\s+777'; then
  block "Privilege" "chmod 777 makes files world-readable/writable/executable." "Use chmod 755 or more restrictive permissions."
fi

if echo "$COMMAND" | grep -qE 'chmod\s+(-[a-zA-Z]*R).*777'; then
  block "Privilege" "Recursive chmod 777 is extremely dangerous." "Use chmod -R 755 or more restrictive permissions."
fi

if echo "$COMMAND" | grep -qE '\bchown\b'; then
  block "Privilege" "chown changes file ownership, which can affect system security."
fi

if echo "$COMMAND" | grep -qE 'chmod\s+[u+]*s'; then
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

if echo "$COMMAND" | grep -qE 'git\s+checkout\s+\.\s*$'; then
  block "Git" "git checkout . discards all unstaged changes." "Use git stash to preserve changes."
fi

if echo "$COMMAND" | grep -qE 'git\s+stash\s+drop'; then
  block "Git" "git stash drop permanently deletes stashed changes." "Use git stash list to review stashes first."
fi

if echo "$COMMAND" | grep -qE 'git\s+push\s+.*\s+(main|master)\b'; then
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

# =============================================================================
# Category 5: Credential and Secret Exposure
# =============================================================================

if echo "$COMMAND" | grep -qE 'cat\s+.*\.env\b'; then
  block "Credentials" "Reading .env files may expose secrets." "Use specific environment variables instead."
fi

if echo "$COMMAND" | grep -qE 'cat\s+.*\.ssh/'; then
  block "Credentials" "Reading SSH keys exposes authentication credentials."
fi

if echo "$COMMAND" | grep -qE 'cat\s+.*\.aws/(credentials|config)'; then
  block "Credentials" "Reading AWS credentials exposes cloud access keys."
fi

if echo "$COMMAND" | grep -qE 'curl\s+.*(-u|--user)'; then
  block "Credentials" "curl with credentials may expose authentication tokens." "Use environment variables for credentials."
fi

if echo "$COMMAND" | grep -qE '\bprintenv\b|env\s*$|\bset\s*$'; then
  block "Credentials" "Printing all environment variables may expose secrets." "Print specific variables: echo \$VARIABLE_NAME"
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

if echo "$COMMAND" | grep -qE 'curl\s+.*(-X\s+POST|-d|--data)'; then
  block "Network" "curl POST with data may exfiltrate information." "Review the request body and destination before sending."
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

# =============================================================================
# Category 8: Resource Exhaustion
# =============================================================================

if echo "$COMMAND" | grep -qE ':\(\)\{.*:\|.*\}\s*;'; then
  block "Resource" "Fork bomb will crash the system by spawning infinite processes."
fi

if echo "$COMMAND" | grep -qE '\byes\s*\|'; then
  block "Resource" "yes | can overwhelm processes with infinite input."
fi

if echo "$COMMAND" | grep -qE 'while\s+true\s*;.*do'; then
  block "Resource" "Infinite loop without break condition." "Add a break condition or use a bounded loop."
fi

if echo "$COMMAND" | grep -qE '\bkill\s+(-9|-SIGKILL)\b'; then
  block "Resource" "kill -9 forcefully terminates a process without cleanup." "Use kill (SIGTERM) first to allow graceful shutdown."
fi

# All checks passed
exit 0
