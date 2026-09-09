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

   **🔴 Scope every shared-board query in the JQL — never pull broad and filter in context.** `BUG`, `HOT` and `VULN` are company-wide; unscoped they return 18×, 5.7× and 3× the Core Services rows. Paste `SCOPE` below into any query touching them. Full rationale + verification: `Wiki/wiki/process/jira-mcp-usage.md` § Scope at the QUERY.

   ```jql
   SCOPE = (project in (PROJ, COREOPS)
            OR (project in (BUG, HOT) AND cf[10001] = "00000000-0000-0000-0000-000000000000")
            OR (project = VULN AND "Squad[Select List (multiple choices)]" = "Your Squad"))
   ```
   Team UUID, not the string `"Your Squad"` — a string silently returns zero. **Team-scope, don't assignee-scope:** assignee filters drop unassigned (untriaged) tickets and Core-Services work assigned to non-squad people. Always pass an explicit `fields` list.

   - Default JQL: `project = PROJ AND sprint in openSprints() ORDER BY status, priority DESC`, `fields: ["summary", "status", "assignee", "priority", "issuetype"]`
   - Surface as a compact standup-shaped table: per-engineer in-flight tickets + status (To Do / In Progress / PR / UAT / Release / Done) + anything stalled.
   - Cross-check against retrospective signals from yesterday's journal — anything still in `In Progress` from prior days is a stall candidate.
   - **Pull recently-closed since last triage** — `SCOPE AND statusCategory = Done AND statusCategoryChangedDate >= "<yesterday>"`. Closures invalidate any prep-doc escalation that cites a now-closed ticket; without this query, stale escalations land in 1:1s. Highest/High-priority closures get surfaced; routine closures stay quiet.
     - 🔴 **NEVER `resolved >= "<yesterday>"`.** Bulk transitions set `status` without `resolution`, so `resolved` is empty on `Won't Do`. **On 04/09 this exact query returned zero rows while three tickets read `Done`** — PROJ-1204, BUG-2101 and BUG-2109 — **and two of those three were live agenda items in that morning's card**, i.e. the failure mode this step exists to prevent, caused by the step itself. A zero here means check the field, not "nothing closed".
   - **Live-state-check today's prep docs** — for any `1-1-prep-*.md` for today's meetings, re-verify the state of any specific tickets cited as live escalations or asks. If a ticket has closed/transitioned/de-prioritised since prep authoring, update the prep doc inline (or flag in the Battle Card) so the operator doesn't surface stale state in the meeting.
   - Recipes + project keys: `Wiki/wiki/process/jira-mcp-usage.md`.
   - **Fallback** when MCP is unavailable or returns errors: ask the operator for a manual standup-board summary.

   **MCP posture:** read-only by default. Any write operation (create/edit/transition/comment/link) must be confirmed with the operator before calling. See `Wiki/wiki/process/jira-mcp-usage.md` for the read-only/write split.

6. **Per-meeting people-file scan.** For every meeting today, identify the attendees and read **only the sections you need** from their `Wiki/wiki/people/[name].md` — these files run 5–12k tokens each and reading four of them whole is the single biggest avoidable cost in this command. Use:

   ```
   ./bin/section.sh Wiki/wiki/people/[name].md "Next Catchup Agenda" "Open Loops" "Current Focus"
   ```

   - The `## Next Catchup Agenda` block is the load-bearing one (the questions queued for that person — surface them in the Battle Card under that meeting's row), plus `## Open Loops` and `## Current Focus`.
   - Pull `## Strategic Notes` **only** when the meeting is strategic/political, not by default.
   - `## Key Interactions` keeps the 3 most recent inline; older ones are in `Wiki/wiki/people/history/[name].md`. **Don't read the history file at triage** — it's for perf-review prep or a long-arc question.
   - Read the whole file only when the section slice is clearly insufficient, and say why.

   **🔴 SEPARATE `ASK` FROM `🅾️ OWED` — this is the check that earns the step.** An agenda block holds two kinds of line and they need opposite handling:
   - **`ASK`** — the operator wants to put it to them. **Discharged by the meeting happening.** Surface it as an agenda bullet. Done.
   - **`🅾️ OWED`** — *they* asked *them*. **The meeting does not discharge it, it exposes it.** If the answer does not already exist, the meeting is a debt coming due.

   **For every `OWED` item on today's meetings, do this before writing the card:**
   1. **Check whether the answer exists** (in the Brief, a journal entry, a wiki page, or Jira).
   2. **If it does not, put it on `## Today` as its own item, ranked ABOVE the meeting**, with the lead time stated: *"You owe Priya two answers at 11:00. Neither exists. 2h45m."*
   3. **Decompose it into the actual work.** *"Does a GTM wishlist exist?"* is a ten-minute question to Nina, not a discussion topic — it never needed the 1:1 at all. Say what the work is and roughly how long.
   4. **If there is no time left, say so plainly** so the operator can walk in and own it with a date rather than improvise. Priya's stated bar: *a decision or an owner; "no, and here's why" is fine.*

   ⚠️ **Surfacing an OWED item as "ask them about X" is the failure mode, and it has happened.** On 07/09 two forward-intake answers owed to Priya since 28/08 were surfaced as agenda bullets; they walked into the 1:1 with no answers and neither question got raised. The queue was surfaced; the debt was not., see the *owed-vs-ask* rule

   This is the muscle that pulls — the operator should never need to remember what's queued in a person file. The triage process surfaces it.

   *(Keep this high-level — the Battle Card is a briefing, not deep prep. The just-in-time deep dive for a specific meeting lives in `/prep` — see that command. Triage surfaces the queue; `/prep` loads the room.)*

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

9. **RELIABILITY CHECK:** Identify anything that could impact platform uptime or data pipeline integrity today. **Include a VULN-due-soon scan** when MCP is connected: `project = VULN AND "Squad[Select List (multiple choices)]" = "Your Squad" AND statusCategory != Done AND duedate <= "<sprint-end>"` — the Squad filter is mandatory (VULN is company-wide), and note it's a *different* field from BUG/HOT's Team UUID.

10. **Timebox top priorities.** From the Battle Card P0/P1 items, pick 1–3 to pin to real calendar blocks. Titles are formatted as `Timebox - <terse abbreviated description>` (super-terse — verb + object, e.g. `Timebox - Sam 30-60-90`, `Timebox - Sprint Plan prep`). **The `Timebox - ` prefix is load-bearing** — the calibration look-back in step 4 greps on it.

    **🔴 Use `./bin/timebox.sh add`, NOT `gcalcli add`.** Timeboxes are an *intent* signal, not a booking: the operator wants colleagues to be able to book over them. That needs `transparency: transparent` ("Free") on the event, and **gcalcli 4.5.1 has no `--transparency` flag** (verified — no transparency/eventType write support anywhere in its source). `bin/timebox.sh` creates via the Calendar API using gcalcli's own OAuth token, and sets all three levers: **Free** (the load-bearing one — the operator shows as available and Google raises no conflict warning when someone books over), a **graphite/grey colour** (reads as soft vs a real meeting), and a **description** saying so in words.

    ```bash
    ./bin/timebox.sh add "Aman interview prep" "2026-08-31 12:10" 45   # prepends "Timebox - "
    ./bin/timebox.sh list 2026-08-31                                   # show today's, with FREE/BUSY state
    ./bin/timebox.sh soften 2026-08-31                                 # retrofit blocks created the old way
    ```

    ⚠️ **Do NOT use Google "Focus time" (`eventType: focusTime`) for timeboxes.** Focus time exists to *protect* time; even with `autoDeclineMode: declineNone` it reads to a colleague as "don't book over this" — the opposite of the intent. Decided 31/08/2026. Also: `eventType` is immutable after creation, so a focusTime block can't be softened later without deleting it.

    If a *real* meeting is ever needed (attendees, must-hold), that's still `gcalcli --calendar "Acme Rockets" add ... --noprompt` — always pass `--calendar`, or gcalcli prompts interactively and dies with `EOFError` in this non-interactive shell.

    Show the drafted commands and proposed times to the operator, get confirmation, then create. Don't weight blown timeboxes — the goal is presence on the calendar, not strict adherence.

11. **Write the day's BRIEFING to a file, then output it. The action list goes on the Battle Board, and meeting outcomes go to a third file.**
    *Split made 01/09/2026, extended 09/09/2026. Three surfaces, three lifecycles: the **briefing** is read once and cold by 10am · the **action list** is touched all day · the **meeting record** accumulates as transcripts land. On 09/09 appending meeting outcomes to the card took it to 43.6k, reproducing the exact problem the first split fixed.*

    **C. Meeting outcomes — `DOS/Journal/[year]/week-[week]/meetings-[YYYY-MM-DD].md`.** Created lazily, the first time a transcript or meeting summary is processed. Holds the full texture: who said what, verbatim fragments, decisions, what went unraised. **This is the surface the operator actually reads** — they rarely reads the wrap. **Never append meeting outcomes to the battle card.** Function split + why the journal can't become a pointer: `/daily-wrap` § Three day-surfaces.

    **A. The Battle Board — `DOS/Battle-Board.md` — is the ONE surface the operator works off.**
    - **`## Today` must be the first thing under the H1.** Contract lives at the FOOT of the board, never the head — a 30-line preamble above the list recreates the exact "too verbose to look at" problem the split was meant to fix.
    - **Stable path, no date in the filename.** They pin it. Never move it into a week folder.
    - Re-cut `## Today` at triage: **max 8 items, one line each, ordered by priority.** No P0/P1 tags — order *is* the priority. 🔴 only for a hard deadline or a person actually waiting.
    - **🔴 ONE LINE PER ITEM. NO SUB-BULLETS, EVER.** No why, no how, no quotes, no venue notes. This is the rule that keeps it usable, and it is the rule that failed before: nesting six lines of rationale under a checkbox is what made the old card unreadable.
    - **If an item needs context, the context lives in `DOS/Standing Brief.md`** and the board line just names the action. The board is a lossy index, deliberately.
    - **Tick in place all day** ([ ] → [x]); done items stay where they are. Never prune completions into a summary — accumulating checkboxes are the point, and they are the raw material for the wrap. *(Recorded correction: *tick-in-place*.)*
    - Items that turn out not to be owed get **⛔ struck through and marked void**, not ticked. A `[x]` on something never done is a false record.
    - Regenerated whole at each wrap (`/todos` rules); ticked freely in between.

    **B. The battle card is now a write-once briefing** — `DOS/Journal/[year]/week-[week]/battle-card-[YYYY-MM-DD].md` (create the week dir if it's the first artefact of the week).
    - **Contains:** today's calendar · per-meeting agendas (the `Next Catchup Agenda` pulls) · sprint state · landmines · reliability check · what was deliberately not read.
    - **Does NOT contain an action list.** Open it with a short `## Actions → DOS/Battle-Board.md` pointer naming what moved to the board, what closed, what was voided.
    - **It does not need maintaining through the day.** It is a record of the morning, so it cannot rot. If something material changes (a meeting outcome that rewrites a landmine), append it; otherwise leave it.
    - Stays cold: journal-located, **never loaded at the next triage** (which reads only the Brief + latest journal entry).
    - `/daily-wrap` reads **both** the board (what got ticked) and the card (what was planned).

    After writing both, output the briefing to the conversation — that chat rendering is the format the operator actually reads in the morning.

```markdown
---
type: battle-card
date: YYYY-MM-DD
week: NN
reader: donovan-at-speed
---
# Morning Triage — [Day, Date]

[One line of framing: cycle position, sprint boundary, anything structural about today.]

## Actions → `DOS/Battle-Board.md`
*Briefing only. The action list lives on the Battle Board.*

**On the board for today:** [terse list] · **Closed:** [terse] · **Void:** [terse, if any]

## Today's Calendar
| Time | Event | Attendees | Prep |
|------|-------|-----------|------|
| HH:MM | Event | Names | Pointer to per-meeting agenda below |

[One line on the shape of the day: gaps, maker time, back-to-backs.]

## Per-Meeting Agendas
*(Surfaced from `Next Catchup Agenda` blocks in attendee people files. The operator picks what fits the slot.)*

### HH:MM — [Event]
**Queued for [person]** (from `Wiki/wiki/people/[name].md`):
- [ ] question 1
- [ ] question 2

## Sprint State (verified from Jira, HH:MM)
| Engineer | In flight | Status |
|---|---|---|

## Landmines
**Political** — ...
**Technical** — ...
**People** — ...

## Reliability Check
...

## Not Read Today (deliberately cold)
...
```

## Rules

- Dates DD/MM/YYYY, times in your own zone (set DOS_TZ / DOS_LOCALE u2014 see SETUP-GUIDE.md).
- Read people files before commenting on meetings involving those people.
- For meetings where attendees aren't fully visible from gcalcli output (group meetings, recurring rituals), read the most likely participants based on the event title and team context.
- Be concise. This is a briefing, not an essay.
- Flag risks explicitly — be strategically paranoid.
- If a `Next Catchup Agenda` block has more queued items than fit a meeting slot, propose a prioritised shortlist — don't just dump the full list.
