# Pre-Meeting Prep — "What's top of mind?"

Fast, just-in-time prep for the **next meeting about to start**. This is the formalised version of the operator's standing habit — asking "what's top of mind?" in the minutes before a meeting to get the agenda broken down and know what to carry into the room.

**Trigger:** `/prep`, `/prep [meeting or person]`, or plain-language "what's top of mind for [meeting]?" / "prep me for the next one."

## What this is NOT (boundaries — don't overlap)
- **Not `/triage`** — triage is the once-a-day high-level battle card across ALL meetings. Keep triage light; this is where the depth lives. Triage surfaces the queue; `/prep` loads the room.
- **Not `/manager-1-1`** — that's heavy, forward-looking advocacy prep for a scheduled 1:1 (what to raise/ask/escalate over a multi-week window). `/prep` is lighter and works for *any* meeting type (interview, leadership sync, standup, external, 1:1). If the meeting is a substantive 1:1 and the operator wants the deep version, point them to `/manager-1-1 [name]`.

## Design intent — keep it FAST
This runs in the 2–5 minutes between meetings, sometimes under time pressure. Be concise and scannable. Lead with the answer. No preamble. If time-pressed, the first three sections (What it is / Who's in the room / What to take in) are the irreducible core — everything else is bonus.

**🔴 WHAT, not WHY — this is the load-bearing style rule.** Default output is *what the operator does/asks in the room*, as terse lines they could read off. **Omit the reasoning by default** — the ties-to, the "because", the downstream-impact, the strategic gloss. They can see the "what" in a glance and ask "expand" / "why N?" on anything they want unpacked. A prep that explains its own reasoning is slower to scan than the meeting is to walk into. When in doubt, cut the sentence that starts with "because" or "so that." *(Established 18/08 — the first-pass Casey prep was prose-heavy; the trimmed "what only" version was right.)*

**📐 And countable, because the rule above demonstrably did not hold on its own.** Measured on the 28/08 Sam prep: **93% of content lines bold** (so bold ranked nothing), longest bullet **690 chars**, five competing marker vocabularies. Budgets, per `DOS/CLAUDE.md` § Layout budgets:
- Bold on **≤25%** of content lines.
- No bullet over **~200 chars**. If it needs more, it is a table row or its own sub-heading.
- **One** marker vocabulary, ≤1 glyph per 5 lines.
- **More than ~5 parallel or ranked items goes in a table with a verdict column**, never a bold-tiered list. This is the fix that does the work: rank lives in position, not emphasis.
- Frontmatter carries `reader: donovan-at-speed`.

Check with `bin/dos-lint.sh` § READABILITY. A doc over budget usually needs re-laying-out rather than cutting.

## Process

1. **Identify the meeting.** If an argument is given, use it. Otherwise read the calendar (`gcalcli agenda "[now]" "[+3h]"`) and pick the next event starting soonest. State which meeting you're prepping so there's no ambiguity.

2. **Identify attendees.** From the calendar event's attendee list (or infer from the event title + team context for recurring rituals / group meetings). For each known person, locate `Wiki/wiki/people/[name].md`.

3. **Read the room.** For each attendee with a file, pull:
   - `## Next Catchup Agenda` — queued items, **and split them by tag before surfacing:**
     - **`ASK`** → a bullet in *What to take in*. Discharged by the meeting.
     - **🔴 `🅾️ OWED`** → **check whether the answer exists first.** If it does, lead with it. **If it does not, say so at the top of the prep as its own line** — *"you owe them X and there's no answer; here's the honest version to say in the room"* — and give the own-it-with-a-date wording. **Never surface an OWED item as "ask them about X".** That inverts it: they asked *them*.
     - An `OWED` item with no matching task on the Brief is a process defect; note it in one line so the wrap fixes it., see the *owed-vs-ask* rule
   - Relevant `## Strategic Notes` — including any **recurring behaviour / predictable ask** noted for them.
   - Recent `## Key Interactions` — last conversation, so there's continuity. The live file keeps the 3 most recent; **this is the command where reading `Wiki/wiki/people/history/[name].md` is legitimate** if the meeting turns on a longer arc (perf review, a promotion case, a months-old commitment). Prefer the section slice — `./bin/section.sh <file> "Next Catchup Agenda" "Strategic Notes" "Key Interactions"` — and go wider only when the room warrants it.
   - **🎯 Predictable-ask + pre-loaded answer (the muscle this command exists for):** if the person reliably does something in conversations (e.g. asks "where can I improve?", opens with a status dump, pushes on scope), surface **both the likely ask AND the answer already sitting in their file** (growth areas, locked focus areas, the last decision made) so the operator walks in with the response ready, not improvising in the room. *A queued question is prep; a predictable-ask-with-no-answer-ready is a miss — this is the class of thing that gets missed and shouldn't.*

4. **Pull the thread from the Standing Brief / recent journal** — any live project, TODO, landmine, or reliability item that intersects this meeting or these people. Only what's relevant to *this* room — not a full state dump.

5. **🎁 Scan `DOS/Opportunities.md` — when the room can act on org-level ideas.** Quick pass, not a full read: check the **candidate index table** at the bottom, match the `Best room` column against today's attendees, and surface at most **1–2** entries whose moment has actually arrived.

   **Do this scan when the room includes:**
   - **Upper management / skip-level+** — [[sam-chen]] (Director), [[jye-lewis]] (Head of Eng), [[jacob-richter]] (CTO), [[rory-san-miguel]] (CEO), any Director or Head-of.
   - **Org/process-relevant people, regardless of seniority** — [[ruth-cole]] (Product Ops: cycles, rituals, planning — *highly* relevant), [[ray-tang]] (Product Lead; asked the operator to help shape the PL role), [[ronalyn-villanueva]] (Eng Ops/QA, owns the P&E Jira scheme), [[stephen-pham]] (Eng Ops), [[christina-hopkins]] (People/onboarding), peer EMs ([[nick-fischer]], [[daniel-mcstravick]], [[samina-azad]]), [[christopher-keat-tang]] (Principal).
   - Any org-shaped forum: leadership syncs, all-hands, Domain Mapping, cycle/process reviews, showcases.

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

6. **Output — this exact shape.** Endorsed by the operator 28/08 off the Morgan prep (*"nearly perfect for a prep document format"*). **Rank lives in the verdict column, not in a trailing must-gets sentence.**

```markdown
## Prep — [HH:MM Meeting] ([duration], [format])

**What it is:** one line — and name why it's live *now* (the hook), not just the purpose.

**Who's in the room:** name + role + one line of disposition ("high-candour, wants real input rather than applause").

### What to take in

| # | What to say | |
|---|---|---|
| 1 | The ask/point/decision itself, as they'd say it aloud. No "because", no ties-to. | must-get |
| 2 | ... | must-get |
| 3 | ... | if it fits |
| 4 | ... | only if raised |

**Defer:** one inline sentence naming what's deliberately left out. Not its own section.

### Predictable ask, answer ready
The recurring ask + the pre-loaded answer from their file. Two or three sentences of prose. Omit if none.

### If there's room
Opportunities entry, 1–2 max, framed as follow-up not pitch. **Omit the whole section when nothing is ripe (the normal case).**

### Landmines

| Don't | Why |
|---|---|
| The thing to avoid saying | The one-line reason |

**One-liner:** the single most important thing if they read nothing else.
```

   - **Verdict column values:** `must-get` · `if it fits` · `only if raised`. Cap must-gets at 2–3.
   - **Landmines are a table, not scattered prose warnings.** Scattered ones get missed at T-minus-one-minute.
   - **🔴 If a battle card already carries this meeting's agenda, output to chat and do NOT write a file.** A second copy is the one-source-of-truth problem `triage.md` warns about. Offer the file, don't create it. If you do write one, use the `manager-1-1.md` frontmatter with `reader: donovan-at-speed`.
   - Layout budgets apply: `DOS/CLAUDE.md` § Layout budgets. Check with `bin/dos-lint.sh` § READABILITY.

## Rules
- Dates DD/MM/YYYY, times in your own zone.
- Read the person file before commenting on anyone.
- Concise > complete. This is a doorway briefing, not a dossier.
- If a meeting has no attendee files and no relevant Brief thread (e.g. a purely external/admin block), say so in one line and stop — don't manufacture prep.
