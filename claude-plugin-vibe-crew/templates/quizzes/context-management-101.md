---
id: context-management-101
title: Context Management 101
level: 3
questions: 5
---

# Context Management 101

## Q1

What is the primary purpose of the Context7 MCP server in VibeCrew?

- A) To store session logs and Vibe Score breakdowns between sessions
- B) To replace pasting documentation into the context window by fetching docs on demand
- C) To run automated browser tests using Chrome DevTools
- D) To calculate token usage and warn when context limits are reached

**Answer:** B

**Explanation:** Context7 is a Model Context Protocol server that fetches library documentation on demand, eliminating the need to paste large doc blocks directly into the chat. This is a core context discipline strategy in VibeCrew — MCP servers replace manual doc pasting, keeping the context window lean and reducing token waste.

---

## Q2

At what context usage percentage does VibeCrew first warn you to consider wrapping the session?

- A) 40%
- B) 50%
- C) 60%
- D) 75%

**Answer:** C

**Explanation:** The `check-context.sh` hook fires warnings at both 60% and 80% context usage. The 60% warning is your first signal that it may be time to plan a clean handoff. VibeCrew targets keeping active context below 50% as its ideal operating condition, so 60% is the early alert threshold.

---

## Q3

Why does VibeCrew route Stack Scout research into an isolated subagent context rather than running it in the main session?

- A) Because Stack Scout requires a different Claude model that cannot run in the main session
- B) Because research tasks consume large amounts of context that would pollute the main working session
- C) Because the GitHub CLI is only available inside the subagent environment
- D) Because MCP servers like Context7 cannot connect to the main session

**Answer:** B

**Explanation:** Research tasks — fetching docs, scanning libraries, comparing options — are context-expensive. By isolating Stack Scout in its own context window, VibeCrew keeps the main development session clean and cache-friendly. The subagent produces a compact TDR artifact as its output, not a wall of raw research text, so only the decision record enters the main session.

---

## Q4

Which Vibe Score deduction applies when your session has low cache utilization?

- A) -5 points
- B) -10 points
- C) -15 points
- D) -20 points

**Answer:** C

**Explanation:** Low cache utilization receives a -15 deduction from the Vibe Score. Cache utilization measures how effectively you are reusing previously computed token outputs rather than regenerating them. High cache hit rates reduce cost and latency, so VibeCrew treats cache discipline as a first-class performance metric.

---

## Q5

A developer has been working in the same Claude Code session for several hours and is deep into implementing a complex feature. The context window is at 78%. What is the VibeCrew-recommended action?

- A) Continue working since 78% is below the 80% hard stop threshold
- B) Immediately run /check to validate work before the context fills completely
- C) Begin wrapping up with /wrap to create a handoff log and start a fresh session
- D) Delete session logs from .vibecrew/sessions/ to free up context space

**Answer:** C

**Explanation:** At 78%, VibeCrew has already fired the 60% warning and is approaching the 80% warning. The correct action is to use /wrap to create a structured handoff log that captures current state, completed work, and next steps — then start a fresh session. Deleting session logs does nothing to the context window, and continuing past 80% risks running out of context mid-operation.
