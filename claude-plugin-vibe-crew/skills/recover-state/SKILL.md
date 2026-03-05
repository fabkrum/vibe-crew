---
name: recover-state
description: List and restore VibeCrew state backups
disable-model-invocation: false
category: utility
---

# VibeCrew State Recovery

You are VibeCrew recovering project state from a backup.

## Step 1: List Available Backups

```bash
ls -la .vibecrew/.backup/ 2>/dev/null || echo "No backups found."
```

If no backups directory or no files, output:
```
No backups available. Backups are created automatically during state sync and migration.
```

## Step 2: Present Backup Options

Group backups by file type (state.json, backlog.json) and show timestamps:

```
Available Backups
=================
state.json:
  1. state.json.2026-03-01T10-00-00Z  (2 hours ago)
  2. state.json.2026-02-28T15-30-00Z  (yesterday)

backlog.json:
  3. backlog.json.2026-03-01T10-00-00Z  (2 hours ago)
  4. backlog.json.2026-02-28T15-30-00Z  (yesterday)
```

Ask: **"Which backup(s) to restore? (number, 'all latest', or 'cancel')"**

## Step 3: Restore Selected Backup

```bash
cp ".vibecrew/.backup/<selected-backup>" ".vibecrew/<target-file>"
```

After restoring, run state sync:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/sync-state.sh"
```

Report the result:
```
Restored <file> from <timestamp> backup.
State sync: consistent.
```

## Rules

- NEVER delete backup files during recovery.
- ALWAYS run sync-state.sh after restoring to verify consistency.
- Show a diff summary (jq comparison) before confirming the restore.
