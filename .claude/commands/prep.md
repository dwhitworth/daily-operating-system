# Pre-Meeting Prep — "What's top of mind?"

Fast, just-in-time prep for the **next meeting about to start**. This is the formalised version of the standing habit — asking "what's top of mind?" in the minutes before a meeting to get the agenda broken down and know what to carry into the room.

**Trigger:** `/prep`, `/prep [meeting or person]`, or plain-language "what's top of mind for [meeting]?" / "prep me for the next one."

## What this is NOT (boundaries — don't overlap)
- **Not `/triage`** — triage is the once-a-day high-level battle card across ALL meetings. Keep triage light; this is where the depth lives. Triage surfaces the queue; `/prep` loads the room.
- **Not `/manager-1-1`** — that's heavy, forward-looking advocacy prep for a scheduled 1:1 (what to raise/ask/escalate over a multi-week window). `/prep` is lighter and works for *any* meeting type (interview, leadership sync, standup, external, 1:1). If the meeting is a substantive 1:1 and you want the deep version, point to `/manager-1-1 [name]`.

## Design intent — keep it FAST
This runs in the 2–5 minutes between meetings, sometimes under time pressure. Be concise and scannable. Lead with the answer. No preamble. If time-pressed, the first three sections (What it is / Who's in the room / What to take in) are the irreducible core — everything else is bonus.

## Process

1. **Identify the meeting.** If an argument is given, use it. Otherwise read the calendar (`gcalcli agenda "[now]" "[+3h]"`) and pick the next event starting soonest. State which meeting you're prepping so there's no ambiguity.

2. **Identify attendees.** From the calendar event's attendee list (or infer from the event title + team context for recurring rituals / group meetings). For each known person, locate `Wiki/wiki/people/[name].md`.

3. **Read the room.** For each attendee with a file, pull:
   - `## Next Catchup Agenda` — queued questions/items for this person.
   - Relevant `## Strategic Notes` — including any **recurring behaviour / predictable ask** noted for them.
   - Recent `## Key Interactions` — last conversation, so there's continuity. The live file keeps the 3 most recent; **this is the command where reading `Wiki/wiki/people/history/[name].md` is legitimate** if the meeting turns on a longer arc (perf review, a promotion case, a months-old commitment). Prefer the section slice — `./bin/section.sh <file> "Next Catchup Agenda" "Strategic Notes" "Key Interactions"` — and go wider only when the room warrants it.
   - **🎯 Predictable-ask + pre-loaded answer (the muscle this command exists for):** if the person reliably does something in conversations (e.g. asks "where can I improve?", opens with a status dump, pushes on scope), surface **both the likely ask AND the answer already sitting in their file** (growth areas, locked focus areas, the last decision made) so you walk in with the response ready, not improvising in the room. *A queued question is prep; a predictable-ask-with-no-answer-ready is a miss — this is the class of thing that gets missed and shouldn't.*

4. **Pull the thread from the Standing Brief / recent journal** — any live project, TODO, landmine, or reliability item that intersects this meeting or these people. Only what's relevant to *this* room — not a full state dump.

5. **🎁 Scan `DOS/Opportunities.md` — when the room can act on org-level ideas.** Quick pass, not a full read: check the **candidate index table** at the bottom, match the `Best room` column against today's attendees, and surface at most **1–2** entries whose moment has actually arrived.

   **Do this scan when the room includes:**
   - **Upper management / skip-level+** — your manager, skip-level, the CTO/CEO, any Director or Head-of.
   - **Org/process-relevant people, regardless of seniority** — Product Ops (cycles, rituals, planning — *highly* relevant), a Product Lead (especially if they asked you to help shape the role), Eng Ops/QA (owns the Jira scheme), People/onboarding, peer EMs, a Principal engineer.
   - Any org-shaped forum: leadership syncs, all-hands, domain-mapping sessions, cycle/process reviews, showcases.

   **Skip the scan entirely for:** direct-report 1:1s, standups, interviews, retros, external/admin blocks. *(Exception: a direct's 1:1 where they raised the underlying observation — then it's their idea, credit it as such.)*

   **Rules for surfacing — this is the part that keeps the doc alive:**
   - **🔴 Never present an entry as a TODO or an obligation.** Frame as *"if there's room: …"*. `DOS/Opportunities.md` creates no obligations by design (see `DOS/CLAUDE.md`) — converting one into an action item in a prep doc is exactly how that contract gets broken.
   - **Only if the moment fits.** An entry needs a live hook in *this* meeting — an agenda item, a decision in flight, a question they asked. **No hook, no mention.** A meeting with nothing ripe gets no Opportunities block at all, and that is the normal case.
   - **Prefer `#unraised` entries whose `Where it's citable` names this person.** Skip `#raised`/`#landed` unless there's a natural follow-up ("you asked for this, here's the next generalisation").
   - **Lead with their problem, not the idea.** These land as help, not as a pitch — the entry is only useful if it answers something the room already cares about.
   - Cap it at 1–2. Walking in with five org-improvement ideas reads as an agenda takeover; one well-timed one reads as strategic partnership.

   Add to the output as an optional block (omit when nothing is ripe):
   ```markdown
   **🎁 If there's room (from `DOS/Opportunities.md`):** entry + the one-line citable form + the hook that makes now the moment.
   ```

6. **Output — tight and scannable:**

```markdown
## Prep — [HH:MM Meeting] (starts in ~N min)

**What it is:** one line — purpose of the meeting.

**Who's in the room:** names + one-word-relevant-context each.

**What to take in:** the 1–3 things to carry into this room — queued asks, a point to make, a decision to land. Pulled from person files + Brief.

**🎯 Predictable asks (answer ready):** if any attendee reliably asks something, the ask + the pre-loaded answer. Skip the section if none.

**🎁 If there's room (from `DOS/Opportunities.md`):** 1–2 max, only when the room is upper-management or org/process-relevant AND there's a live hook. Entry + its one-line citable form + why now. **Not a TODO — omit the whole block when nothing is ripe (the normal case).**

**Landmines:** anything to avoid / handle carefully. Skip if none.

**One-liner:** the single most important thing, if you read nothing else.
```

## Rules
- Use your locale's date and time format consistently.
- Read the person file before commenting on anyone.
- Concise > complete. This is a doorway briefing, not a dossier.
- If a meeting has no attendee files and no relevant Brief thread (e.g. a purely external/admin block), say so in one line and stop — don't manufacture prep.
