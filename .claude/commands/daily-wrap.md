# Daily Wrap

End the day. Synthesise everything from today's conversation into a structured journal entry, update operational state, and commit.

## Process

1. **Synthesise the day.** Review the entire conversation from today. Identify:
   - Key events, meetings, decisions
   - People interactions and new context learned
   - Wins and blockers
   - TODOs generated throughout the day

2. **Jira sweep before writing the wrap** (when Atlassian MCP is connected). Use accountIds and project keys from `Wiki/wiki/process/jira-mcp-usage.md`:
   - **Live sprint state** — `project = <YOUR_PROJECT> AND sprint in openSprints()`. Note status changes since the last journal entry: tickets that moved In Progress → PR / PR → UAT / UAT → Release, and anything that *didn't* move and should be flagged as a stall candidate.
   - **Recently-closed across all your team's spaces** — `(project in (<YOUR_PROJECTS>)) AND assignee in (<team-member-accountIds>) AND resolved >= "<yesterday>"`. **Mandatory** — `statusCategory != Done` filters everywhere else blind the wrap to closures, including ones that invalidate live escalations in prep docs. (Known failure mode: a bug that closed without a code change was missed because every other query excluded Done, so a stale escalation citing it nearly landed in a 1:1.) Any Highest/High-priority closure or any closure that's been previously surfaced as a live escalation gets a Timeline entry.
   - **Security/vulnerability due-soon** — `project = <VULN_PROJECT> AND statusCategory != Done AND duedate <= "<sprint-end>"`. Flag any **overdue** items assigned to your directs for retro / next-1:1.
   - **Incident/hot board (your team's assignees)** — `project = <HOT_PROJECT> AND assignee in (<team-member-accountIds>) AND statusCategory != Done`. Note any overdue items still Open.
   - **Bug count delta** — high/highest-priority bugs in flight for your team (`project = <BUG_PROJECT> AND assignee in (<team-member-accountIds>) AND priority in (Highest, High) AND statusCategory != Done`). Track movement vs. yesterday.
   - **Live-state-check any open prep docs** — if a `1-1-prep-*.md` exists for the next ~7 days, re-verify the state of any specific tickets cited as live escalations in that prep doc. Closures, transitions, or priority changes since the prep doc was authored should be reflected back into the prep doc *and* mentioned in the wrap. Authoring date drift on prep docs is a known failure mode — don't let stale escalations land in a 1:1.

   (Project keys above — `<YOUR_PROJECT>`, `<VULN_PROJECT>`, `<HOT_PROJECT>`, `<BUG_PROJECT>` — are illustrative placeholders for your own Jira project keys; the JQL shape is the reusable part.)

   If anything material changed (ticket landed at end-of-day, a vulnerability crossed a deadline, bug priority escalated, escalation in prep doc went stale), include it in the Timeline + Projects in Flight table. Don't bury it.

3. **Write the journal entry.** Save to `DOS/Journal/[year]/week-[week]/[YYYY-MM-DD].md`:

```markdown
---
# Daily Wrap — [Day DD Month YYYY]

## Executive Summary
**Status:** 🟢 GREEN / 🟡 AMBER / 🔴 RED

[Single paragraph: high-level state and major themes]

## Timeline
- **HH:MM** — [Event]: [Description]

## Projects in Flight
| Project | Status | Owner | Next Milestone |
|---------|--------|-------|----------------|

## Summary & TODOs
[2-3 sentences on state of the bridge]

**TODOs for Tomorrow ([Day]):**
- [ ] [Task]

## Tags
- **#hits:** [Wins]
- **#misses:** [Blockers/Delays]
- **#lookingforward:** [Next steps]
```

4. **Update Standing Brief.** Edit `DOS/Standing Brief.md` to reflect:
   - Project status changes
   - New or resolved risks
   - New TODOs or completed TODOs
   - Update the `updated:` frontmatter date

5. **Update People files.** If meaningful new context was captured about anyone today, update their `Wiki/wiki/people/[name].md` file directly.

   **Recognition scan** (see DOS/CLAUDE.md "Team recognition & squad visibility"). Review the day's timeline for squad work worth acknowledging — a good catch, a clean delivery, a junior pulled into something, a strong demo. For anything that clears the bar:
   - Propose a **private back-pat TODO** for tomorrow ("acknowledge X's Y in 1:1 / squad channel") and/or an **avenue match** ("X's work suits the next brown bag / Demo Day / showcase; or a `#kudos` if you judge it clears the high bar").
   - Log recognition *already given today* (or a queued opportunity) to the person's `## Recognition Log` block.
   - **Conservatism rule:** default to low-bar avenues (1:1 / squad channel). Only suggest `#kudos` when it clears all three tests (concrete / third-party-legible / non-routine). Never propose batched filler to hit a rhythm. If nothing clears the bar today, surface nothing — don't manufacture recognition.

6. **Friday nudge.** If today is the last working day of the week (Friday by default) and no `weekly-rollup.md` exists in `DOS/Journal/[year]/week-[week]/` yet, ask whether to draft one before commit-and-push. A nudge only — accept "skip" without pushing.

7. **Commit and push.** Stage all modified files and commit:
   - Message format: `Daily wrap: [DD Mon YYYY] — [brief status summary]`
   - Push to remote

## Rules

- Be thorough. The wrap is the historical record.
- Use your locale's date and time format consistently (e.g. Australian DD/MM/YYYY and AEST times).
- Only mark TODOs complete if they were actually completed — don't silently drop unfinished items.
- Carry forward incomplete TODOs into tomorrow's list.
- Status (GREEN/AMBER/RED) should reflect overall operational health, not just mood.
