---
id: systems-deep-dive
title: VibeOS Systems Deep Dive
level: 15
questions: 6
---

# VibeOS Systems Deep Dive

## Q1

When the AI's context window approaches capacity, VibeOS runs a "compact reinject" script. What does this accomplish, and why is it limited to ~300 tokens?

- A) It saves the entire conversation to disk so it can be reloaded later; 300 tokens is the maximum file size supported
- B) It re-injects a tiny summary of project state (foundation status, active feature, recent commits) after Claude Code compresses older messages — keeping it small so it doesn't accelerate the next compaction
- C) It deletes the oldest 300 tokens from the conversation to free up space for new messages
- D) It sends a 300-token report to the Performance Coach for scoring analysis

**Answer:** B

**Explanation:** When Claude Code compacts older messages, the AI can lose track of what project it's working on and which feature is active. The compact-reinject script (compact-reinject.sh) fires automatically and outputs a brief summary: foundation status, active feature name and phase, backlog summary by column, last 5 commits, and CLAUDE.md stats. At ~300 tokens, this costs less than a single clarification question would — and it prevents the AI from asking "what were we working on?" after compaction. The small size is deliberate: injecting too much would fill the context again and trigger another compaction sooner.

---

## Q2

VibeOS uses two layers of protection against destructive commands. What are they, and why are two layers necessary?

- A) CLAUDE.md instructions and user confirmation prompts — two layers because the AI might ignore one
- B) The settings.json permission rules (tool-level blocking by Claude Code) and the protect-data.sh hook (pattern matching on command contents) — two layers because they catch different types of threats
- C) A firewall and an antivirus — two layers following standard cybersecurity practice
- D) Git branch protection and file permissions — two layers to prevent both accidental and intentional damage

**Answer:** B

**Explanation:** The first layer (settings.json) blocks entire tool categories at the Claude Code level — for example, "never allow sudo" or "never allow git push --force." This catches broad classes of dangerous operations before any code runs. The second layer (protect-data.sh PreToolUse hook) inspects the actual command contents using pattern matching — catching things like "DROP TABLE" inside a database command that settings.json can't see because it's inside a legitimate bash call. Together, they form defense-in-depth: even if a creative prompt tricks the AI into constructing a destructive command that passes the first layer, the hook's pattern matcher catches it at the second.

---

## Q3

The cost-guardrails.sh script tracks spending in real time. How does it calculate per-turn costs, and what happens when a threshold is exceeded?

- A) It estimates cost based on session duration in minutes; exceeding the threshold closes the session automatically
- B) It reads token counts (input, cache creation, cache read, output) from the hook JSON payload, applies model-specific pricing (Opus/Sonnet/Haiku rates), accumulates in session-cost.json, and emits warnings or forces a pause at configurable thresholds
- C) It queries the Anthropic billing API after each message and compares against a monthly budget
- D) It counts the number of tool calls per session and multiplies by a flat per-call rate

**Answer:** B

**Explanation:** After every assistant turn, the Stop hook passes a JSON payload containing four token counts: input_tokens, cache_creation_input_tokens, cache_read_input_tokens, and output_tokens. The cost-guardrails.sh script multiplies each by the correct per-token price for the active model (Opus, Sonnet, or Haiku — each with different rates for input, cache, and output). The result is accumulated in .vibeos/session-cost.json. At $2.00 (configurable), it emits a cost warning in the status bar. At $5.00, the agent must pause and ask permission to continue. At $20.00 daily, it emits a daily spend alert. All thresholds are configurable in .vibeos/config.json under cost_limits.

---

## Q4

What is the MCP server Context7, and how does it save tokens compared to the alternative?

- A) Context7 is a code completion engine that predicts the next line of code, reducing the number of prompts needed
- B) Context7 is a documentation lookup service — agents query it for specific API references on demand instead of pasting entire documentation pages into the conversation, saving ~1,500 tokens per lookup
- C) Context7 is a caching proxy that stores previous AI responses and replays them for similar questions
- D) Context7 is a compression tool that reduces the size of code files before they enter the context window

**Answer:** B

**Explanation:** Without Context7, when the Builder agent needs to know how Supabase authentication works, it would either guess (risky) or you'd paste the documentation into the chat (~1,500 tokens per paste). In a single session, three or four such lookups can consume 6,000+ tokens of your context window — roughly 5-10% of your total capacity. Context7 serves as an external reference library: the agent queries it with a specific question (like "Supabase createClient options") and gets back just the relevant snippet. These tokens come from the MCP server, not your context window. The Performance Coach deducts -15 points for low cache utilization when Context7 isn't being used, because it's one of the biggest efficiency gains available.

---

## Q5

VibeOS scripts use the "temp file + mv" pattern for writing state files. Why not just write directly to the file?

- A) The mv command is faster than direct file writes on macOS
- B) Writing to a temp file first, then atomically moving it into place, prevents file corruption if the script crashes mid-write — critical when multiple agents may update state concurrently
- C) Temp files are automatically encrypted, providing an extra layer of security for state data
- D) The temp file serves as a backup that can be restored if the original file is lost

**Answer:** B

**Explanation:** If a script writes directly to state.json and crashes halfway through, the file is left in a corrupted state — half old data, half new data. The next script that reads it will fail or behave unpredictably. The temp file + mv pattern avoids this: the script writes the complete new content to state.json.tmp, and only when the write is fully finished does it run "mv state.json.tmp state.json." The mv (move) command on the same filesystem is atomic — it either completes fully or not at all. There's no in-between state where the file is half-written. This is especially important in VibeOS because multiple agents in different terminal tabs might update state files at overlapping times.

---

## Q6

The Session Startup agent runs three scripts on every launch: session-startup.sh, sync-state.sh, and error-recovery.sh. What does each one do, and why do they run in this order?

- A) They check for updates, download new agents, and restart the plugin — ordered by dependency
- B) session-startup.sh checks the environment and detects project state; sync-state.sh reconciles the state file with actual git branches and files; error-recovery.sh cleans up stale locks and corrupted data from crashed sessions — ordered from orientation to reconciliation to repair
- C) They initialize the AI model, load the conversation history, and set the system prompt — ordered by the Claude Code boot sequence
- D) They verify the license key, check the subscription tier, and enable the appropriate feature set — ordered by authentication requirements

**Answer:** B

**Explanation:** The three scripts form a boot sequence that ensures every session starts clean. First, session-startup.sh checks that dependencies exist (Git, Node, jq, terminal-notifier) and detects the project state (is there a foundation? an active feature? a handoff document?). Second, sync-state.sh compares what state.json says (e.g., "feature user-auth is in Code phase on branch feat/user-auth") with filesystem reality (does the branch exist? are the expected files present?) and corrects any drift. Third, error-recovery.sh cleans up artifacts from crashed sessions: stale lock directories older than 60 seconds, orphaned .tmp files from failed atomic writes, and stuck in-progress tasks. The order matters: you need to know the environment before you can sync, and you need accurate state before you can identify what's broken.
