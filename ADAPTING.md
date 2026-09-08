# Adapting the framework

This system was built for an **Engineering Manager** role, and the defaults reflect that —
sprint rituals, an issue-tracker sweep, DORA/reliability guardrails, 1:1 and recognition
mechanics. But the *shape* is general: a living context file, a daily intelligence pass, a
working surface, an end-of-day synthesis, and a compounding knowledge base. None of that is
EM-specific. Here's how to make it yours.

## 1. Encode your context first (`DOS/CLAUDE.md`)

This is the highest-leverage edit. The "Standing Context" block is where you tell the
assistant who you are and what matters:

- **Role & org.** Your title, team, manager, skip-level, key stakeholders. Replace the role
  placeholders with your actual reporting lines — the modes use these to know whose people
  file to read for a given meeting.
- **Stack / domain.** Swap the placeholders for yours. This is what lets the assistant know
  when to check the Wiki vs. answer from general knowledge.
- **Guardrails.** The defaults (reliability-first, low-ego, metric-driven) are good general
  ones, but the *domain-specific* guardrail is a placeholder on purpose. Yours might be
  "accessibility is a legal requirement," "PII never leaves the VPC," "latency budget is
  sacred" — whatever a mistake in your world actually costs.

## 2. Pick your operating modes

The five modes (Triage / War Room / Daily Wrap / Weekly Roll-up / Deep Dive) are a menu, not
a mandate. Keep the ones that fit your week; delete or rename the rest. If you don't run
sprints, the issue-tracker recipes in `Wiki/wiki/process/jira-mcp-usage.md` become "whatever
your work-tracking surface is" — the *pattern* (a daily sweep that catches closures and
stalls) transfers to any tracker.

## 3. Wire up your integrations (optional, high-leverage)

The modes degrade gracefully without integrations — they'll ask you for a manual summary.
But the payoff is real when connected:

- **Calendar** (for triage's per-meeting prep)
- **Issue tracker** (for the live sprint/board sweep) — see the Jira template; the same shape
  works for Linear, GitHub Issues, etc., via their MCP servers
- **Anything else** your work runs through

## 4. Adapting to a non-EM role

The framework generalises cleanly. Some translations:

| EM concept | Generalises to |
|---|---|
| Direct reports / people files | Anyone you work with repeatedly — clients, collaborators, stakeholders |
| Sprint / board sweep | Whatever your unit-of-work tracker is (tickets, deals, cases, papers) |
| 1:1 prep | Prep for any recurring meeting with a person |
| Recognition / team visibility | Tracking and surfacing others' contributions in any role |
| DORA / reliability guardrails | Your field's quality bar |
| Weekly roll-up | Any periodic status synthesis you owe upward |
| The Wiki (domain knowledge) | Any compounding knowledge base for your work |

A researcher, a founder, a consultant, a PM — all have the same underlying needs: a living
context, a daily pass, a working surface, a record, and accumulated knowledge. Keep the
loop; re-label the nouns.

## 5. Which rules to keep even if you change everything else

Most of this file is "bend it to fit." These four are the load-bearing ones, and each exists
because the obvious alternative was tried and failed:

- **A checkbox requires an owner, a venue, and a by-when.** Without the gate, every
  observation becomes a task and the list reaches three hundred items while the real
  deliverables sit buried. "Is this important?" is not a usable test — everything surfaced is
  important. "Who moves next?" is.
- **Hot files stay small; everything else is read on demand by a named command.** The number
  that matters isn't file size, it's *what a session loads before it does any work*.
- **Separate surfaces by lifecycle, not by topic.** The write-once briefing and the
  ticked-hourly action list cannot share a file. This one had its rule reworded three times
  before anyone noticed the problem was structural.
- **Enforce mechanically or don't bother.** A rule that must fire mid-task cannot be enforced
  by more emphatic prose — that's what the `bin/` lints, the pi extensions and the layout
  *budgets* are for. If you add a rule, add its mechanism in the same sitting, or accept that
  it's a preference rather than a rule.

## 6. Adding your own guardrails

The pi extensions in `.pi/extensions/` are small and worth reading as examples — each is
30–170 lines and each one names the specific failure it prevents in its header comment. The
patterns available:

| Pattern | Extension to copy | Use when |
|---|---|---|
| Block a tool call outright | `people-file-read-guard.ts` | A cheap alternative exists and the expensive path is a reflex |
| Soft-nudge without blocking | `cold-file-guard.ts` | The action is sometimes right, and you want it justified |
| Rewrite a command before it runs | `gcalcli-calendar-guard.ts` | A tool has a footgun with a known fix |
| Gate writes behind a confirm | `jira-scope-guard.ts` | Read-only by default; writes need a human |
| Re-state a contract every turn | `battle-card-reminder.ts` | The rule must hold continuously, not once |
| Add a tool | `today-context.ts` | The model keeps deriving something it could just be told |

If you're on Claude Code only, the equivalent surfaces are hooks
(`.claude/hooks/`) and the permission allowlist in `.claude/settings.json`.

## 7. Writing quality

`.pi/skills/unslop-writing/SKILL.md` (mirrored at `.claude/skills/`) is a "what to avoid"
profile applied to anything a human will read on an external surface — shared 1:1 docs, Slack,
email. It is not applied to code, commit messages, or internal journal shorthand. The
positive-direction section at the bottom encodes one house voice; rewrite that part for yours
and leave the anti-pattern lists alone, since those are model defaults rather than taste.

## 8. Memory

The harness's per-project memory store persists facts across sessions, with an index file
(`MEMORY.md`) auto-loaded each session. Decide early what's worth remembering across
conversations (preferences, durable project constraints, who-is-who) vs. what belongs in the
journal (the dated record).

One thing worth knowing: this framework's rules mostly originated as memory entries recording
a correction, and got promoted into `DOS/CLAUDE.md` once they proved durable. That's a good
pipeline to copy — **memory catches the correction, the instruction file encodes the rule, a
script or extension enforces it.** Each step is a promotion, and most entries never make it
past the first.

## 9. A note on privacy

If you run this against real work context, the journals and people files will contain
sensitive information — performance signals, HR-adjacent context, candid reads on people.
**Keep that repo private.** This framework release is deliberately scaffolding-only so you
can publish/share the *method* without ever exposing the *content*. If you later want to
share your own adaptations, scrub the same surfaces this release scrubbed: names, emails,
tracker identifiers (cloudIds, accountIds, custom-field values), Slack channel names, and
anything in a journal or people file.

A practical tip if you do: **make the sanitisation a script, not a habit.** This release is
generated from the private repo by a substitution map plus a denylist scan over both the
working tree *and* the full git history, because a scrub that depends on remembering will
eventually not be remembered, and a leak in history isn't fixed by editing a file.
