# Morning Triage

Start the day. Read the operational state, pull today's calendar, and produce a prioritised battle card with **per-meeting agenda intel** so person-specific TODOs surface exactly when they're actionable.

## Process

1. **Read standing context.**
   - Read `DOS/Standing Brief.md`
   - Read the most recent journal entry from `DOS/Journal/[year]/week-[week]/` (find the latest by date)

2. **Monday weekly scan.** If today is Monday, run `/weekly-scan` before consolidating TODOs. Surface the full scan output for visibility, then fold the scan's **This Week's Top 3** into the Battle Card's P0/P1 candidate set so the Monday plan absorbs the week-shaped hygiene findings. Skip on non-Monday days.

3. **Consolidate outstanding TODOs.** Pull forward any unchecked items from previous journal entries and the Standing Brief.

4. **Pull today's calendar.** Run `gcalcli agenda "[today]" "[tomorrow]" --details all` to get today's events with attendees and details.

   **Optional ~10-second look-back:** Glance at yesterday's `Timebox -` events (`gcalcli agenda "[yesterday]" "[today]"`) purely as calibration — did the boxes match reality? No judgment, no slippage flagging. This is bandwidth-learning over weeks, not a daily audit. Skip if it ever feels heavy.

5. **Pull live sprint state from Jira MCP** (when the Atlassian MCP is connected):
   - Default JQL: `project = <YOUR_PROJECT> AND sprint in openSprints() ORDER BY status, priority DESC`
   - Surface as a compact standup-shaped table: per-engineer in-flight tickets + status (To Do / In Progress / PR / UAT / Release / Done) + anything stalled.
   - Cross-check against retrospective signals from yesterday's journal — anything still in `In Progress` from prior days is a stall candidate.
   - **Pull recently-closed since last triage** — `(project in (<YOUR_PROJECTS>)) AND assignee in (<team-member-accountIds>) AND resolved >= "<yesterday>"`. Closures invalidate any prep-doc escalation that cites a now-closed ticket; without this query, stale escalations land in 1:1s. Highest/High-priority closures get surfaced; routine closures stay quiet.
   - **Live-state-check today's prep docs** — for any `1-1-prep-*.md` for today's meetings, re-verify the state of any specific tickets cited as live escalations or asks. If a ticket has closed/transitioned/de-prioritised since prep authoring, update the prep doc inline (or flag in the Battle Card) so you don't surface stale state in the meeting.
   - Recipes + project keys: `Wiki/wiki/process/jira-mcp-usage.md`. (Project keys above are illustrative placeholders for your own.)
   - **Fallback** when MCP is unavailable or returns errors: ask for a manual standup-board summary.

   **MCP posture:** read-only by default. Any write operation (create/edit/transition/comment/link) must be confirmed before calling. See `Wiki/wiki/process/jira-mcp-usage.md` for the read-only/write split.

6. **Per-meeting people-file scan.** For every meeting today, identify the attendees and read their `Wiki/wiki/people/[name].md` file. From each file, capture:
   - The full `## Next Catchup Agenda` block (these are the questions queued for the next conversation with that person — surface them in the Battle Card under that meeting's row)
   - Any relevant `Strategic Notes` for prep intel
   - Recent `Key Interactions` if context informs the upcoming meeting

   This is the muscle that pulls — you should never need to remember what's queued in a person file. The triage process surfaces it.

7. **Map meetings vs task load.** Identify:
   - Schedule conflicts (overlapping events)
   - Overcommitment (back-to-back with no gaps)
   - Meetings that need prep
   - Meetings where the queued agenda is too long for the slot — flag for prioritisation
   - **Visibility events** — if today's calendar has a Demo Day, brown bag, or end-of-cycle showcase, treat it as a recognition opportunity (see DOS/CLAUDE.md "Team recognition & squad visibility"). Pull candidate squad work into the Battle Card so the slot gets used — who/what should be presented or surfaced, so a delivery doesn't go unshown. Don't manufacture filler; if there's nothing strong to surface, leave it.

8. **Flag LANDMINES:**
   - **Political:** Stakeholder dynamics, team dynamics, leadership expectations
   - **Technical:** Reliability risks, architecture decisions in flight, deadlines
   - **People:** Anyone referenced in meetings (not just attendees) who has relevant context in their people file

9. **RELIABILITY CHECK:** Identify anything that could impact platform uptime or data pipeline integrity today. **Include a vulnerability-due-soon scan** when MCP is connected: `project = <VULN_PROJECT> AND statusCategory != Done AND duedate <= "<sprint-end>"`.

10. **Timebox top priorities.** From the Battle Card P0/P1 items, pick 1–3 to pin to real calendar blocks. Draft `gcalcli add` commands with titles formatted as `Timebox - <terse abbreviated description>` (super-terse — verb + object, e.g. `Timebox - 30-60-90 plan`, `Timebox - Sprint Plan prep`). Show the drafted commands and proposed times, get confirmation, then create. Don't weight blown timeboxes — the goal is presence on the calendar, not strict adherence.

11. **Output the Battle Card.** Structured, prioritised plan for the day:

```markdown
# Morning Triage — [Day, Date]

## Outstanding TODOs (carried forward)
- [ ] ...

## Today's Calendar
| Time | Event | Attendees | Prep |
|------|-------|-----------|------|
| HH:MM | Event | Names | Pointer to per-meeting agenda below |

## Per-Meeting Agendas
*(Surfaced from `Next Catchup Agenda` blocks in attendee people files. You pick what fits the slot.)*

### HH:MM — [Event]
**Queued for [person]** (from `Wiki/wiki/people/[name].md`):
- [ ] question 1
- [ ] question 2

## Landmines
...

## Reliability Check
...

## Battle Card
| Priority | Action |
|----------|--------|
| P0 | ... |
| P1 | ... |
| P2 | ... |
```

## Rules

- Use your locale's date and time format consistently (e.g. Australian DD/MM/YYYY and AEST times).
- Read people files before commenting on meetings involving those people.
- For meetings where attendees aren't fully visible from gcalcli output (group meetings, recurring rituals), read the most likely participants based on the event title and team context.
- Be concise. This is a briefing, not an essay.
- Flag risks explicitly — be strategically paranoid.
- If a `Next Catchup Agenda` block has more queued items than fit a meeting slot, propose a prioritised shortlist — don't just dump the full list.
