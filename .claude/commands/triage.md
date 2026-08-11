# Morning Triage

Start the day. Read the operational state, pull today's calendar, and produce a prioritised battle card with **per-meeting agenda intel** so person-specific TODOs surface exactly when they're actionable.

## Process

1. **Read standing context.**
   - Read `DOS/Standing Brief.md`
   - Read the most recent journal entry from `DOS/Journal/[year]/week-[week]/` (find the latest by date)

   **🔴 Read these two ONLY. Do not read `DOS/Backlog.md`, `DOS/Reference/`, `DOS/30-60-90.md`, `DOS/Brag.md`, `DOS/Growth.md`, `DOS/Opportunities.md` or `Wiki/wiki/people/history/` at triage** — they are deliberately cold. Pull one in only when the day's work actually turns on it, and say which and why.

2. **Monday weekly scan.** If today is Monday, run `/weekly-scan` before consolidating TODOs. Surface the full scan output for visibility, then fold the scan's **This Week's Top 3** into the Battle Card's P0/P1 candidate set so the Monday plan absorbs the week-shaped hygiene findings. Skip on non-Monday days.

3. **Consolidate outstanding TODOs.** Pull forward any unchecked items from the Standing Brief's `## TODOs → This Week`. **That section is the live list — it is complete on its own.** `DOS/Backlog.md` holds carried, gated, watch-only and completed items and is **not** read here (it's a `/todos` + `/weekly-scan` surface). Don't re-derive the live list by scanning old journal entries.

4. **Pull today's calendar.** Run `gcalcli agenda "[today]" "[tomorrow]" --details all` to get today's events with attendees and details.

   **Optional ~10-second look-back:** Glance at yesterday's `Timebox -` events (`gcalcli agenda "[yesterday]" "[today]"`) purely as calibration — did the boxes match reality? No judgment, no slippage flagging. This is bandwidth-learning over weeks, not a daily audit. Skip if it ever feels heavy.

5. **Pull live sprint state from Jira MCP** (when the Atlassian MCP is connected):

   **🔴 Scope every shared-board query in the JQL — never pull broad and filter in context.** Company-wide boards (`[BUG]`, `[INCIDENT]`, `[VULN]`) span every team; unscoped they return many multiples of your team's rows. Paste `SCOPE` below into any query touching them. Full rationale + verification: `Wiki/wiki/process/jira-mcp-usage.md` § Scope at the QUERY.

   ```jql
   SCOPE = (project in ([PROJECT], [PROJECT-OPS])
            OR (project in ([BUG], [INCIDENT]) AND cf[10001] = "[team-uuid]")
            OR (project = [VULN] AND "Squad[Select List (multiple choices)]" = "[Your Team]"))
   ```
   Team UUID, not the display string `"[Your Team]"` — a string silently returns zero. **Team-scope, don't assignee-scope:** assignee filters drop unassigned (untriaged) tickets and your team's work assigned to non-team people. Always pass an explicit `fields` list.

   - Default JQL: `project = [PROJECT] AND sprint in openSprints() ORDER BY status, priority DESC`, `fields: ["summary", "status", "assignee", "priority", "issuetype"]`
   - Surface as a compact standup-shaped table: per-engineer in-flight tickets + status (To Do / In Progress / PR / UAT / Release / Done) + anything stalled.
   - Cross-check against retrospective signals from yesterday's journal — anything still in `In Progress` from prior days is a stall candidate.
   - **Pull recently-closed since last triage** — `SCOPE AND resolved >= "<yesterday>"`. Closures invalidate any prep-doc escalation that cites a now-closed ticket; without this query, stale escalations land in 1:1s. Highest/High-priority closures get surfaced; routine closures stay quiet.
   - **Live-state-check today's prep docs** — for any `1-1-prep-*.md` for today's meetings, re-verify the state of any specific tickets cited as live escalations or asks. If a ticket has closed/transitioned/de-prioritised since prep authoring, update the prep doc inline (or flag in the Battle Card) so you don't surface stale state in the meeting.
   - Recipes + project keys: `Wiki/wiki/process/jira-mcp-usage.md`.
   - **Fallback** when MCP is unavailable or returns errors: ask for a manual standup-board summary.

   **MCP posture:** read-only by default. Any write operation (create/edit/transition/comment/link) must be confirmed before calling. See `Wiki/wiki/process/jira-mcp-usage.md` for the read-only/write split.

6. **Per-meeting people-file scan.** For every meeting today, identify the attendees and read **only the sections you need** from their `Wiki/wiki/people/[name].md` — these files can run 5–12k tokens each and reading four of them whole is the single biggest avoidable cost in this command. Use:

   ```
   ./bin/section.sh Wiki/wiki/people/[name].md "Next Catchup Agenda" "Open Loops" "Current Focus"
   ```

   - The `## Next Catchup Agenda` block is the load-bearing one (the questions queued for that person — surface them in the Battle Card under that meeting's row), plus `## Open Loops` and `## Current Focus`.
   - Pull `## Strategic Notes` **only** when the meeting is strategic/political, not by default.
   - `## Key Interactions` keeps the 3 most recent inline; older ones are in `Wiki/wiki/people/history/[name].md`. **Don't read the history file at triage** — it's for perf-review prep or a long-arc question.
   - Read the whole file only when the section slice is clearly insufficient, and say why.

   This is the muscle that pulls — you should never need to remember what's queued in a person file. The triage process surfaces it.

   *(Keep this high-level — the Battle Card is a briefing, not deep prep. The just-in-time deep dive for a specific meeting lives in `/prep` — see that command. Triage surfaces the queue; `/prep` loads the room.)*

7. **Map meetings vs task load.** Identify:
   - Schedule conflicts (overlapping events)
   - Overcommitment (back-to-back with no gaps)
   - Meetings that need prep
   - Meetings where the queued agenda is too long for the slot — flag for prioritisation
   - **Visibility events** — if today's calendar has a Demo Day, brown bag, or end-of-cycle showcase, treat it as a recognition opportunity (see DOS/CLAUDE.md "Team recognition & squad visibility"). Pull candidate team work into the Battle Card so the slot gets used — who/what should be presented or surfaced, so a delivery doesn't go unshown. Don't manufacture filler; if there's nothing strong to surface, leave it.

8. **Flag LANDMINES:**
   - **Political:** Stakeholder dynamics, team dynamics, leadership expectations
   - **Technical:** Reliability risks, architecture decisions in flight, deadlines
   - **People:** Anyone referenced in meetings (not just attendees) who has relevant context in their people file

9. **RELIABILITY CHECK:** Identify anything that could impact platform uptime or data pipeline integrity today. **Include a VULN-due-soon scan** when MCP is connected: `project = [VULN] AND "Squad[Select List (multiple choices)]" = "[Your Team]" AND statusCategory != Done AND duedate <= "<sprint-end>"` — the Squad filter is mandatory (VULN is company-wide), and note it's a *different* field from BUG/INCIDENT's Team UUID.

10. **Timebox top priorities.** From the Battle Card P0/P1 items, pick 1–3 to pin to real calendar blocks. Draft `gcalcli add` commands with titles formatted as `Timebox - <terse abbreviated description>` (super-terse — verb + object, e.g. `Timebox - 30-60-90 draft`, `Timebox - Sprint Plan prep`). **Always pass `--calendar "[Your Calendar]"` on `gcalcli add`** — without it gcalcli prompts interactively for a calendar and fails with `EOFError` in a non-interactive shell. Canonical form: `gcalcli --calendar "[Your Calendar]" add --title "Timebox - <desc>" --when "YYYY-MM-DD HH:MM" --duration <mins> --noprompt`. Show the drafted commands and proposed times, get confirmation, then create. Don't weight blown timeboxes — the goal is presence on the calendar, not strict adherence.

11. **Write the Battle Card to a file, then output it.** The card is the day's operating surface — it must survive context compaction and be updatable as the day moves, so it lives on disk, not just in chat.
    - **Path:** `DOS/Journal/[year]/week-[week]/battle-card-[YYYY-MM-DD].md` (same week folder as the day's journal entry; create the week dir if it's the first artefact of the week).
    - **It is the living source of truth for the day.** As TODOs get done, meetings happen, or priorities shift in the War Room, **update the file in place** — check boxes, add outcomes, re-rank — rather than only tracking changes in conversation. When something is done or something new lands, reflect it in the card. Tick boxes in place and let done items accumulate (don't prune to a summary) — seeing checked boxes is motivating.
    - **It stays cold** — journal-located, read on demand, **never loaded at the next triage** (which reads only the Brief + latest journal entry). No hot/cold-hygiene cost.
    - `/daily-wrap` reads the day's battle card as an input (what got done vs. planned) before writing the journal entry.
    - After writing the file, also output the card to the conversation.

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

- Use your locale's date and time format consistently (e.g. DD/MM/YYYY and your local timezone).
- Read people files before commenting on meetings involving those people.
- For meetings where attendees aren't fully visible from gcalcli output (group meetings, recurring rituals), read the most likely participants based on the event title and team context.
- Be concise. This is a briefing, not an essay.
- Flag risks explicitly — be strategically paranoid.
- If a `Next Catchup Agenda` block has more queued items than fit a meeting slot, propose a prioritised shortlist — don't just dump the full list.
