---
id: advanced-context
title: Advanced Context Management
level: 15
questions: 4
---

# Advanced Context Management

## Q1

A senior developer notices their cache hit rate dropping from 85% to 40% over several sessions. Reviewing their workflow, they see they are prepending a dynamic timestamp and current task description to every system prompt. What is the most likely cause of the cache degradation and how should it be fixed?

- A) The context window is too full to cache efficiently; they should run /wrap more frequently to reset it
- B) Dynamic content early in the prompt invalidates the cached prefix for everything that follows; stable instructions should come first, with dynamic context appended at the end
- C) Cache hit rate naturally degrades over time and resets on each new session; this is expected behavior
- D) The Quality Check agent is running too frequently and flushing the cache between checks

**Answer:** B

**Explanation:** Claude's caching system works on prefixes — a cache hit occurs when the beginning of a prompt matches a previously seen sequence. Inserting a dynamic timestamp or task description at the top of every system prompt means the prefix changes every turn, invalidating the cache for all subsequent content. The fix is to structure prompts with the stable, universal instructions first (which can be cached) and append dynamic, session-specific context at the end. This single structural change can restore cache hit rates to 80%+ in complex sessions.

---

## Q2

When should a task be delegated to Stack Scout in an isolated subagent context rather than handled inline in the main session? Select the best answer.

- A) Any time the task requires reading more than one documentation page
- B) When the task requires comparing multiple libraries, fetching external documentation, or evaluating architecture options — and its output can be expressed as a compact artifact
- C) Whenever the current context window is above 40% to prevent it from filling further
- D) Only during Tier 1 foundation work; all Tier 2 feature tasks should run in the main session

**Answer:** B

**Explanation:** Stack Scout isolation is warranted when three conditions are true: the task is research-heavy (multiple doc pages, library comparisons, option evaluation), it would consume significant context to do inline, and its result can be expressed as a compact artifact — specifically a TDR. If a task is a quick lookup that results in a one-line answer, the overhead of spinning up a subagent is not justified. The key test is whether the raw research output would pollute the main session's context more than the artifact would.

---

## Q3

What is "context compaction" and how does VibeOS's /wrap command support it?

- A) Context compaction is Claude's automatic summarization of old messages; /wrap triggers it manually by sending a special system instruction
- B) Context compaction refers to reducing the number of active MCP server connections; /wrap closes unused connections before ending a session
- C) Context compaction is the practice of distilling a long session's accumulated state into a dense, structured summary; /wrap produces a handoff log that serves as the compacted representation of everything relevant from the session
- D) Context compaction is a billing optimization that compresses token counts; /wrap enables it by batching the final tool calls of a session

**Answer:** C

**Explanation:** Context compaction is the practice of replacing a long, sprawling conversation history with a concise, information-dense summary that captures the essential state. VibeOS's /wrap command implements this deliberately: the Doc Generator agent synthesizes the session into a structured handoff log covering completed work, decisions made, files changed, and immediate next steps. Starting the next session from this compact artifact (rather than replaying the full conversation history) is significantly more token-efficient and keeps the new session's cache warm from turn one.

---

## Q4

A developer is building a data pipeline that will process large files. They ask the Feature Developer agent directly: "Research whether we should use streaming or buffered file reads for this pipeline, then implement the chosen approach." What is the VibeOS-correct way to handle this request, and why?

- A) This is fine as stated — combining research and implementation in one prompt is efficient because it reduces the total number of prompts needed
- B) The research phase should be delegated to Stack Scout first to produce a TDR, then the Feature Developer implements within the constraints that TDR establishes
- C) The implementation should happen first as a prototype, and the research should validate the prototype after the fact
- D) The developer should paste relevant Node.js streaming documentation into the chat, then ask the Feature Developer to implement based on that

**Answer:** B

**Explanation:** Combining research and implementation in a single prompt to the Feature Developer violates the research-before-code principle and wastes context. The Feature Developer agent is optimized for implementation within defined boundaries — it is not designed for open-ended technology evaluation. Stack Scout should conduct the research in isolation, evaluate streaming vs. buffered approaches against the project's requirements, and produce a TDR with a clear recommendation. The Feature Developer then implements exactly what the TDR specifies, with no ambiguity and no wasted context on the research path not taken.
