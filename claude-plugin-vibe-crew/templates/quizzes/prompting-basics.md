---
id: prompting-basics
title: Prompting Basics
level: 3
questions: 5
---

# Prompting Basics

## Q1

What is "prompt churn" in the context of VibeCrew, and what Vibe Score penalty does it carry?

- A) Switching between agent types too frequently; -10 per switch
- B) Sending repeated corrective follow-up prompts because earlier instructions were unclear; -5 per sequence
- C) Pasting documentation into the chat instead of using Context7; -15 per occurrence
- D) Running the same tool call more than once in a session; -10 per loop

**Answer:** B

**Explanation:** Prompt churn occurs when a vague or incomplete initial prompt forces a back-and-forth correction cycle — you send a prompt, the agent does something wrong, you send a correction, and so on. Each churn sequence costs -5 Vibe Score points. The solution is the spec-first approach: write a complete, unambiguous feature spec before issuing implementation instructions.

---

## Q2

Which of the following best describes the spec-first approach to prompting in VibeCrew?

- A) Always write unit tests before writing any prompt to the AI
- B) Define acceptance criteria, edge cases, and constraints in writing before asking the agent to implement anything
- C) Research the technology stack before choosing which agent to assign the task to
- D) Create a VISION.md document before starting any feature development

**Answer:** B

**Explanation:** Spec-first means capturing what the feature should do — its acceptance criteria, edge cases, and constraints — before you send an implementation prompt. This single practice is the most effective way to reduce prompt churn because the agent has complete information from the start. VISION.md is a Tier 1 foundation artifact, not the same as a feature spec for a specific task.

---

## Q3

A developer sends this prompt: "Make the login better." Which Vibe Score consequence is most likely?

- A) No penalty, because the agent will ask clarifying questions automatically
- B) A -20 context violation because the prompt is too short to fill context efficiently
- C) A -5 prompt churn deduction when the follow-up corrections begin
- D) A -10 tool loop deduction because the agent will call multiple tools without direction

**Answer:** C

**Explanation:** "Make the login better" is an underspecified prompt that will almost certainly trigger a correction cycle — the agent will make assumptions, implement something partially wrong, and the developer will send follow-up corrections. Each such sequence earns a -5 churn deduction. A well-specified prompt would define exactly what "better" means: faster load time, better error messages, accessibility improvements, etc.

---

## Q4

What is the relationship between the feature spec and the -5 Vibe Score deduction for "no feature spec"?

- A) The deduction applies when a feature is implemented without a corresponding entry in backlog.json
- B) The deduction applies when a developer skips the /plan-features command entirely
- C) The deduction applies when code is committed without a linked GitHub issue
- D) The deduction applies when a session ends without any spec document being created

**Answer:** A

**Explanation:** VibeCrew tracks each feature's spec status in backlog.json. When the Performance Coach reviews a session and finds that feature work was done without a corresponding spec entry (acceptance criteria, constraints, and context documented), it applies the -5 deduction. The spec does not need to be lengthy — it must simply exist and contain actionable acceptance criteria.

---

## Q5

Which of the following prompting habits most directly improves cache utilization and reduces token cost over a session?

- A) Using shorter prompts to minimize tokens sent per request
- B) Keeping system instructions stable and consistent rather than rewriting them each turn
- C) Avoiding all use of MCP servers so fewer external calls are made
- D) Starting a new session for every individual task to reset the context

**Answer:** B

**Explanation:** Claude's caching system rewards stable, repeated prefixes. When your system prompt and persistent instructions remain consistent across turns, the model can cache those token computations and reuse them. Rewriting instructions in every prompt prevents caching. Shorter prompts reduce input tokens but do not improve cache hit rate — stability is the key variable that drives cache efficiency in extended sessions.
