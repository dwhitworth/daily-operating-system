---
description: Write a handoff so a fresh session can resume this work with full context
argument-hint: "[note]"
---
We're about to reset context. Write a **handoff document** so a brand-new session (with none of this conversation) can pick up exactly where we are and keep going without re-discovering anything.

## Where to write it
1. Get a timestamp: run `date '+%Y-%m-%d-%H%M'` (local time is fine).
2. Ensure `.pi/handoffs/` exists (`mkdir -p .pi/handoffs`).
3. Write to `.pi/handoffs/handoff-<timestamp>.md`.

*(Handoffs live in `.pi/handoffs/`, NOT the DOS journal — they're session plumbing, not DOS knowledge, and are deliberately outside the auto-commit scope.)*

## Structure (fill every section; omit one only if it's genuinely empty)

```markdown
# Handoff — <weekday DD/MM/YYYY HH:MM>
> Optional note from the operator: ${@:-—}

## Objective
The one-paragraph "what are we actually trying to do" — the overarching goal, not the last step.

## Done this session
- Concrete, completed things (with the outcome, not just the intent).

## Left to do — next actions, in order
1. The very next action, specific enough to start cold.
2. ...
Flag which is P0 vs nice-to-have.

## Files involved
| Path | Why it matters / current state |
|------|-------------------------------|
| `relative/path` | 1-line: what it is, what we changed, what's unfinished |
List EVERY file we touched or that the next steps depend on. Real paths.

## Constraints & gotchas discovered
- Things learned the hard way this session (footguns, API quirks, "don't do X because Y",
  environment specifics, scoping rules, format requirements). This is the highest-value section —
  it's what a fresh session can't rediscover cheaply.

## Key decisions made (+ why)
- Decision → rationale. So the next session doesn't relitigate settled calls.

## Open questions / waiting on
- Unresolved questions, things blocked on the operator or an external answer.

## Mental model for the next session
- The 3–5 things you'd need to understand to be effective immediately — the shape of the problem,
  key relationships, any naming/vocabulary, the "why it's built this way." Reconstruct the context,
  not just the task.

## How to resume
- The exact first move (command to run, file to open, question to ask the operator first).
```

## Rules
- **Brief but complete** — a fresh session should need zero back-reading. Favour specifics (paths, ticket IDs, names, exact commands) over prose.
- Don't dump the whole conversation; distil it.
- Use real relative paths, not descriptions of paths.
- After writing, output: the file path, a 3–4 line preview of the Objective + next action, and the reminder that the operator can run **`/pickup`** in (or as) a fresh session to resume from it.
