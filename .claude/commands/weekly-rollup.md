# Weekly Roll-up

End the week. Synthesise the week's daily wraps into a tight bullet-point roll-up, surface week-shaped Jira aggregations the dailies don't see, do Standing Brief TODO hygiene, and commit.

Run after the Friday `/daily-wrap` (or any final working day of the week).

Distinct from `/weekly-scan` (Monday-morning hygiene sweep across all wiki state). This is **end-of-week synthesis**.

## Process

1. **Read the week's journal.** Pull every daily entry from `DOS/Journal/[year]/week-[week]/` for the current week. Identify recurring themes, landed milestones, escalations made, blockers carried.

2. **Read operational baseline.**
   - `DOS/Standing Brief.md`
   - The most recent daily wrap (today's, if just written)

3. **Jira sweep — week-shaped views** (when Atlassian MCP is connected). The journal carries day-by-day state changes; this sweep adds the *aggregations the dailies don't see*. **Complement the journal, don't replace it** — if a number conflicts with the journal narrative, trust the journal and flag the discrepancy rather than overwriting.

   Use accountIds and project keys from `Wiki/wiki/process/jira-mcp-usage.md`. (Project keys below are illustrative placeholders for your own.)

   1. **Tickets resolved this week** — `project = <YOUR_PROJECT> AND assignee in (<team-member-accountIds>) AND resolved >= "<monday>" AND resolved <= "<friday>"`. Headline number anchors the #hits. List the keys briefly so the wrap can name what landed.
   2. **New H+ bugs created this week** — `project = <BUG_PROJECT> AND priority in (Highest, High) AND assignee in (<team-member-accountIds>) AND created >= "<monday>"`. Intake-rate signal — informs whether the bug-board is being fed faster than it's being drained.
   3. **Vulnerabilities newly entering the 14-day window** — `project = <VULN_PROJECT> AND statusCategory != Done AND duedate <= "<+14d>" AND duedate > "<+0d>"`. Flag anything that crossed *into* the window this week — week-over-week risk surfacing.
   4. **PRs cleared this week** — count tickets that transitioned to or past `PR` status during the week (`project = <YOUR_PROJECT> AND status changed to PR during ("<monday>", "<friday>")` if changelog JQL is available, else use `resolved this week` as a proxy). **Why this query specifically:** if PR review is a known throughput bottleneck, tracking throughput-through-PR week-over-week is a metric worth watching, distinct from "tickets resolved." If the number is dropping, the bottleneck is moving in the wrong direction.

   **Fallback** if MCP is unavailable: skip and note "Jira sweep deferred — MCP unavailable" in the roll-up. Don't block the wrap.

4. **Synthesise the roll-up.** Bullet points only. Weave Jira numbers inline into the relevant sections — don't create a separate Jira block. If a number is small or unsurprising, drop it; the goal is signal, not telemetry.

```markdown
# Weekly Roll-up — Week [N], [Mon DD] – [Fri DD] [Mon YYYY]

## #hits
- [Top 3 wins. Weave Jira numbers in: e.g., "6 tickets landed including <feature> (<TICKET>)"]

## #misses
- [Top risk or delay]

## #lookingforward
- [Next week's P1]

## The Ask
*(Optional — only if there's a genuine escalation that needs manager / skip-level air cover)*
- ...
```

5. **Standing Brief TODO hygiene** — the natural moment, since the week's daily wraps are the audit trail.
   - **Delete outright** purely transactional completed items (`[x] Read X doc`, `[x] Schedule Y meeting`, `[x] message Z`). The journal is the audit trail.
   - **Migrate** items with context-residue (milestones, completed projects, calibration moments) to **Projects in Flight** (status update), **Upcoming Milestones** (as ✅ past-anchor), or **Strategic Notes** on the relevant person file.
   - **Don't touch** anything still `[ ]` — those are live operating context.
   - If unsure, default to deletion. `Brag.md` catches anything worth long-term recall.

6. **Save the roll-up** to `DOS/Journal/[year]/week-[week]/weekly-rollup.md`.

7. **Commit and push.** Stage the roll-up and any Standing Brief / people file changes:
   - Message format: `Weekly roll-up: Week [N] [DD Mon YYYY] — [brief headline]`
   - Push to remote.

## Rules

- Bullet points only. No prose paragraphs. The dailies are the prose; this is the index.
- Use your locale's date and time format consistently (e.g. Australian DD/MM/YYYY and AEST times).
- If the journal narrative and a Jira number disagree, trust the journal and flag the discrepancy.
- Don't double-count items already surfaced in dailies — synthesise, don't repeat.
- Skip "The Ask" if there isn't one. Don't manufacture an escalation to fill the slot.
