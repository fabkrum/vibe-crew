---
id: how-vibeos-works
title: How VibeOS Works
level: 3
questions: 6
---

# How VibeOS Works

## Q1

VibeOS uses 12 specialized "agents" instead of one general-purpose AI. Why?

- A) It's cheaper to run 12 small models than one large model
- B) Each agent is optimized for one job, like specialists on a team — a builder writes code, a verifier runs tests, a scout researches technology
- C) Multiple agents can share the same conversation history to avoid repeating context
- D) Claude Code requires at least 10 agents to activate plugin mode

**Answer:** B

**Explanation:** VibeOS splits work across specialists, just like a real development team. The Builder focuses only on writing code. The Verifier only runs tests. The Security Auditor only checks for vulnerabilities. This specialization means each agent carries only the instructions relevant to its job — making it faster, more accurate, and less expensive than a single AI trying to do everything. Different agents also use different AI models: Opus for complex thinking, Haiku for quick tasks, and Sonnet for documentation.

---

## Q2

Some agents run "inline" while others run in a "worktree." What does this mean in plain English?

- A) Inline agents work in your terminal; worktree agents work in a web browser
- B) Inline agents work directly in your project folder; worktree agents get their own private copy of your files so they can work without affecting your real code
- C) Inline agents are free; worktree agents cost extra tokens
- D) Inline agents run one at a time; worktree agents can run in parallel only

**Answer:** B

**Explanation:** A worktree is like giving a team member their own private office with a photocopy of all your documents. They can read, write, and experiment freely without touching your real project files. When they're done, only the finished result comes back to you. This is especially important for research agents (like Stack Scout) — all the websites they visit and documentation they read stays in their private context, saving space in your main conversation. Inline agents, on the other hand, work directly in your project — they're lighter and faster, used for tasks like running tests or checking status.

---

## Q3

What are "hooks" in VibeOS?

- A) Keyboard shortcuts that trigger slash commands
- B) Automatic safety checks that run behind the scenes — like security guards that verify every action before it happens
- C) Connections to external websites that the AI uses for research
- D) Log files that record everything the AI does during a session

**Answer:** B

**Explanation:** Hooks are small programs that run automatically whenever the AI tries to do something — write a file, run a command, start a session, or end one. They act as gatekeepers: the phase gate hook blocks code writing before the foundation is complete, the protect-data hook blocks dangerous commands like deleting everything, and the format hook automatically cleans up code style after every file write. Because hooks are simple programs (not AI), they run instantly, cost nothing, and can never be "talked out of" enforcing the rules. They're the most reliable enforcement mechanism in the system.

---

## Q4

The "phase gate" prevents you from writing source code before completing the project foundation. Why is this restriction helpful rather than annoying?

- A) It forces you to pay for the premium Opus model before using cheaper models
- B) It ensures the AI knows your technology choices, design system, and project vision before writing any code — preventing hours of rework from wrong assumptions
- C) It gives VibeOS time to download all necessary dependencies in the background
- D) It allows the Security Auditor to scan your system before any code is created

**Answer:** B

**Explanation:** Without a foundation, the AI has to guess: Which framework? What database? What does the design look like? What are the coding conventions? These guesses are often wrong, and fixing code built on wrong assumptions takes longer than starting over. The 20-30 minutes you spend on the foundation (VISION.md, design system, Technology Decision Record, roadmap, CLAUDE.md) saves hours of corrections across every future session. The phase gate makes this non-negotiable — you literally cannot skip it, even accidentally.

---

## Q5

What is the Vibe Score, and why does VibeOS calculate it?

- A) A rating of your code quality from 0-100, based on test coverage and bug count
- B) A session efficiency score from 0-100 that measures how well you used the AI — penalizing wasted effort and rewarding good habits
- C) A popularity score that compares your project to similar open-source projects
- D) A performance benchmark that measures how fast your application runs

**Answer:** B

**Explanation:** The Vibe Score is like a fitness tracker for your coding sessions. It starts at 100 and loses points for anti-patterns: going back and forth with unclear prompts (-5), the AI repeating the same action in a loop (-10), not writing tests (-10), or ignoring context warnings (-20). It gains points for completing all phases and using the AI efficiently. The Performance Coach reviews the score at the end of each session and suggests a new rule to prevent the same issues next time. Over weeks, these rules accumulate and your sessions become more efficient automatically — the system literally learns from your habits.

---

## Q6

What is a "handoff" and why does VibeOS create one at the end of each session?

- A) A handoff transfers your project to a different developer on your team
- B) A handoff is a structured summary of what you worked on, what's done, what's blocked, and what to do next — so the next session can pick up where you left off
- C) A handoff sends your session data to Anthropic for quality analysis
- D) A handoff creates a backup of your entire project in case of data loss

**Answer:** B

**Explanation:** Every time you close a session and open a new one, the AI starts with a blank slate — it doesn't remember your previous conversation. The handoff document solves this by writing down everything the next session needs to know: which feature you were building, which phase you were in, any blockers you hit, and what the next steps are. The new session's startup agent reads this document and immediately knows the full context. Without a handoff, you'd spend the first few minutes of every session re-explaining what you were doing — wasting both time and tokens.
