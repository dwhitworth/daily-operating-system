# Adapting the framework

This system was built for an **Engineering Manager** role, and the defaults reflect that —
sprint rituals, an issue-tracker sweep, DORA/reliability guardrails, 1:1 and recognition
mechanics. But the *shape* is general: a living context file, a daily intelligence pass, a
working mode, an end-of-day synthesis, and a compounding knowledge base. None of that is
EM-specific. Here's how to make it yours.

## 1. Encode your context first (`DOS/CLAUDE.md`)

This is the highest-leverage edit. The "Standing Context" block is where you tell the
assistant who you are and what matters:

- **Role & org.** Your title, team, manager, skip-level, key stakeholders. Replace the role
  placeholders with your actual reporting lines — the modes use these to know whose people
  file to read for a given meeting.
- **Stack / domain.** Swap `[your tech stack]` and `[your domain]` for yours. This is what
  lets the assistant know when to check the Wiki vs. answer from general knowledge.
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
| Recognition / squad visibility | Tracking and surfacing others' contributions in any role |
| DORA / reliability guardrails | Your field's quality bar |
| Weekly roll-up | Any periodic status synthesis you owe upward |
| The Wiki (domain knowledge) | Any compounding knowledge base for your work |

A researcher, a founder, a consultant, a PM — all have the same underlying needs: a living
context, a daily pass, a working surface, a record, and accumulated knowledge. Keep the
loop; re-label the nouns.

## 5. Memory

Claude Code's per-project memory store persists facts across sessions. The framework uses an
index file (`MEMORY.md`) that's auto-loaded each session. Decide early what's worth
remembering across conversations (preferences, durable project constraints, who-is-who) vs.
what belongs in the journal (the dated record).

## 6. A note on privacy

If you run this against real work context, the journals and people files will contain
sensitive information — performance signals, HR-adjacent context, candid reads on people.
**Keep that repo private.** This framework release is deliberately scaffolding-only so you
can publish/share the *method* without ever exposing the *content*. If you later want to
share your own adaptations, scrub the same surfaces this release scrubbed: names, emails,
tracker identifiers (cloudIds, accountIds), and anything in a journal or people file.
