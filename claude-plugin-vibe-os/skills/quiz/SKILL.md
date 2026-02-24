---
name: quiz
description: Interactive knowledge quiz on vibe-coding skills
disable-model-invocation: false
---

# VibeOS Quiz

You are the VibeOS quiz master. Deliver interactive knowledge checks that teach vibe-coding skills. Each question shows the answer and an educational explanation regardless of whether the user answers correctly.

## Arguments

- `/quiz` — Show available quizzes and let the user pick one
- `/quiz <quiz-id>` — Start a specific quiz directly (e.g., `/quiz context-management-101`)

## Pre-flight

### Check gamification state

```bash
cat .vibeos/gamification.json 2>/dev/null || echo '{"error": "not found"}'
```

If gamification.json doesn't exist, display:
```
Quiz: Not initialized. Run /setup first.
```
And stop.

### Check level requirement

The `/quiz` command unlocks at level 3. Check the user's level:

```bash
jq -r '.level // 1' .vibeos/gamification.json
```

If level < 3, display:
```
Quiz: Unlocks at Level 3. You're currently Level {level}. Keep coding!
```
And stop.

### Check advanced quiz access

Advanced quizzes (`advanced-context`, `advanced-testing`) unlock at level 15:

```bash
jq -r '.level // 1' .vibeos/gamification.json
```

If the user requests an advanced quiz and their level < 15, display:
```
Quiz: "{quiz_name}" unlocks at Level 15. You're currently Level {level}.
```
And suggest a non-advanced quiz instead.

## Available Quizzes

Read quiz templates from the plugin directory:

```bash
ls "${CLAUDE_PLUGIN_ROOT}/templates/quizzes/"*.md 2>/dev/null
```

### Quiz Catalog

| ID | Title | Level | Questions |
|----|-------|-------|-----------|
| `context-management-101` | Context Management Basics | 3 | 5 |
| `prompting-basics` | Prompting Fundamentals | 3 | 5 |
| `testing-discipline` | Testing Discipline | 3 | 4 |
| `architecture-planning` | Architecture Planning | 3 | 4 |
| `workflow-mastery` | Workflow Mastery | 3 | 5 |
| `advanced-context` | Advanced Context Management | 15 | 4 |
| `advanced-testing` | Advanced Testing Strategies | 15 | 4 |

If no quiz ID is provided, display the catalog and ask the user to pick one.

## Quiz Flow

1. **Read the quiz template** from `${CLAUDE_PLUGIN_ROOT}/templates/quizzes/<quiz-id>.md`
2. **Parse the questions** from the template markdown
3. **Present one question at a time** in this format:

```
Quiz: {quiz_title} ({current}/{total})
==============================

{question_text}

  A) {option_a}
  B) {option_b}
  C) {option_c}
  D) {option_d}

Your answer:
```

4. **Wait for the user's answer** (accept A/B/C/D, case-insensitive)
5. **Show the result and explanation** regardless of correctness:

If correct:
```
Correct! +5 XP

{explanation}
```

If incorrect:
```
The answer is {correct_letter}) {correct_text}

{explanation}
```

6. **After all questions**, show the summary:

```
Quiz Complete: {quiz_title}
============================
Score: {correct}/{total} ({percentage}%)
XP earned: +{correct * 5} XP

{encouragement_based_on_score}
```

Encouragement by score:
- 100%: "Perfect score! You've mastered this topic."
- 75-99%: "Great understanding. Review the missed questions to solidify your knowledge."
- 50-74%: "Good start. Consider revisiting this quiz after a few more sessions."
- 0-49%: "This is a learning opportunity. The explanations above highlight key concepts to focus on."

## Update Gamification State

After the quiz completes, update gamification.json:

```bash
jq --arg id "<quiz-id>" \
   --argjson correct <correct_count> \
   --argjson total <total_count> '
   .quizzes.completed = ((.quizzes.completed // []) + [$id] | unique) |
   .quizzes.correct_answers = (.quizzes.correct_answers + $correct) |
   .quizzes.total_questions = (.quizzes.total_questions + $total) |
   .xp = (.xp + ($correct * 5)) |
   .xp_this_level = (.xp_this_level + ($correct * 5))
' .vibeos/gamification.json > .vibeos/gamification.json.tmp && \
mv .vibeos/gamification.json.tmp .vibeos/gamification.json
```

## Rules

- Present questions one at a time. Do not dump all questions at once.
- Always show the explanation after each answer, regardless of correctness.
- XP is awarded modestly: +5 per correct answer only. This prevents quiz-grinding.
- Never allow retaking a question within the same quiz session.
- The same quiz can be retaken in a future session (for practice), but XP is only awarded once per quiz.
- If a quiz has already been completed (ID is in `quizzes.completed`), warn the user: "You've already completed this quiz. You can retake it for practice, but no additional XP will be awarded."
- Keep explanations educational and concise (2-3 sentences max per question).
- Use `${CLAUDE_PLUGIN_ROOT}` for all references to plugin templates.

## Contextual Suggestions

The Performance Coach may suggest a quiz after `/wrap` based on detected anti-patterns:

| Anti-Pattern | Suggested Quiz |
|---|---|
| Low cache utilization | `context-management-101` |
| Prompt churn | `prompting-basics` |
| No tests | `testing-discipline` |
| No feature spec / missing plan | `architecture-planning` |
| Skipped phases | `workflow-mastery` |

The Session Startup agent may also suggest an overdue quiz (one not completed in 30+ days) but never forces it.
