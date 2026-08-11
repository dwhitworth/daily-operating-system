# Manager 1:1 Prep

Generates a focused 1:1 prep document for an upcoming conversation with a specific person — most often your manager (a recurring weekly slot), but works for any 1:1 surface (skip-level, peer EMs, directs).

Distinct from `/weekly-scan` (Monday-morning hygiene sweep across all surfaces) and `/triage` (today's calendar). This is **forward-looking advocacy** — what to raise, ask for, escalate at *this* upcoming conversation.

## Usage

```
/manager-1-1 [name]
```

- `name` is optional. Default: **your manager** (the recurring 1:1, the most frequent use case).
- Accepts kebab-case (`first-last`), first name (`first`), or full name (`First Last`). Resolve to the matching `Wiki/wiki/people/[name].md` file.
- Examples: `/manager-1-1`, `/manager-1-1 [your-manager]`, `/manager-1-1 [a-peer-em]`, `/manager-1-1 [a-direct-report]`.

## Process

1. **Resolve the person.** Default to your manager (your recurring 1:1) if no argument. Locate `Wiki/wiki/people/[name].md`. If not found, error cleanly with the closest matches.

2. **Identify the last interaction.** Slice the person's `## Key Interactions` block — `./bin/section.sh Wiki/wiki/people/[name].md "Key Interactions"`. The live file keeps only the **3 most recent** entries, which is all the anchor needs: the topmost dated entry is the **since-window anchor**. All synthesis below filters to "things that happened since that date." Older entries live in `Wiki/wiki/people/history/[name].md` — go there only if step 3 needs the longer arc.

3. **Read the operational baseline.** *(Also give `DOS/Opportunities.md` a quick pass — its candidate index — when the person is upper management or org/process-relevant. See block 6 for who qualifies and the rules for surfacing.)*
   - `DOS/Standing Brief.md` (full) — and `DOS/Reference/org-cycle-context.md` when the person is upper management or org/process-relevant (it holds the org/cycle record their conversations turn on).
   - All journal entries since the since-window anchor (`DOS/Journal/[year]/[week]/`). ⚠️ **Recent entries can run 25–30k chars each — if the window spans more than ~3 days, read the weekly roll-up plus the two most recent dailies rather than every entry**, and say that's what you did.
   - The person's full file (Working Style, Strategic Notes, Next Catchup Agenda, Open Loops, Watch Items) — plus `Wiki/wiki/people/history/[name].md` when the prep needs a longer arc than the 3 inline interactions (perf review, promotion case, an old commitment).

4. **Pull live Jira state** (when Atlassian MCP connected, only if the person is in the engineering reporting chain):

   **Scope the shared boards, then narrow to the person.** This is the one command where `assignee` *is* the right narrowing — the question is per-person — but the board scope still comes first, or company-wide boards (`[VULN]`/`[INCIDENT]`/`[BUG]`) return every team's work. `AND assignee = "<their-accountId>"` is the second clause, never the only one. Field IDs and accountIds: `Wiki/wiki/process/jira-mcp-usage.md`.

   - **Sprint state delta** since since-window — `project = [PROJECT] AND sprint in openSprints() AND assignee = "<accountId>"`. Note tickets that landed, tickets that stalled.
   - **[VULN] due-soon** — `project = [VULN] AND "Squad[Select List (multiple choices)]" = "[Your Team]" AND statusCategory != Done AND duedate <= "<+14d>"`. Team-scope first; then flag which are theirs.
   - **[INCIDENT] overdue** — `project = [INCIDENT] AND cf[10001] = "[team-uuid]" AND duedate < now() AND statusCategory != Done`.
   - **H+ bugs new this period** — `project = [BUG] AND cf[10001] = "[team-uuid]" AND priority in (Highest, High) AND created >= "<since-window>"`.
   - **Load context, not just their tickets** — team-wide scoping answers "is this person carrying more than their share", which an assignee-only query can't. Unassigned H+ bugs are team load too.
   - Skip this step entirely for non-engineering 1:1s.

5. **Check for a central artefact.** If a load-bearing deliverable was committed *for* this specific session (e.g., a 30-60-90 plan, a written proposal, a structured walk-through), the artefact becomes the spine of the meeting — not just one bullet in the status block. Lead the prep doc with a `## ⭐ Central artefact:` block above the seven-block structure. The seven blocks become the *frame around* the artefact, not equal-weight content.
   - Detect from: explicit prior-1:1 commitment ("I'll bring X next time"), a Standing-Brief TODO marked ⭐ for this person, or a deliverable date in the person's `## Next Catchup Agenda` block matching the meeting date.
   - If no central artefact, skip this block.

6. **Synthesise the prep document.** Seven-block structure (drop blocks that have nothing to say — don't pad):

```markdown
# 1:1 Prep — [Person] — [Day, DD/MM/YYYY HH:MM]

## Since-window: [last interaction date] → today

[One sentence on what's happened that's relevant to this person since the last conversation.]

---

## ⭐ Central artefact: [name of deliverable]
*(Only when one applies — see step 5. Frame the meeting around it; recommend slot allocation and ordering. The seven blocks below are the support structure around this artefact, not the main content.)*

[2–4 lines on the artefact's structure, what to walk through, and how to sequence the slot around it.]

---

## 1. Status updates on their projects

*(Things they sponsored, asked for, or care about. Status changes since last 1:1. Bullet form. Each bullet ends with the read — landed / on-track / slipping / blocked.)*

- ...

## 2. The Asks

*(Decision / air-cover / introduction / resource. Specific. Each ask should be answerable in the meeting itself, not "let me think about it.")*

- ...

## 3. Escalations

*(Risks at their altitude — things they need to know but you don't need them to act on. Pre-empts being caught flat-footed when the surface comes up elsewhere.)*

- ...

## 4. Walked-back items

*(Things you committed to last time that have changed scope, slipped, or been re-shaped. Frame as "here's what I said, here's what's actually happening, here's why." Don't let them spot it on the board cold.)*

- ...

## 5. Open agenda from their file

*(Pull every `[ ]` from `## Next Catchup Agenda` in their people file. Triage into two lists: 3–5 to **surface this session**, the rest **deferred with a one-line reason**. The one-line reason is the discipline — it forces a real call on each item rather than rolling everything forward indefinitely.)*

**Surface this session:**
- [ ] ...

**Defer (one-line reason):**
- Item — reason it's not this session.

## 6. Strategic / cultural threads

*(Longer-arc things. Test a framing, surface a pattern from the last fortnight of directs' 1:1s, get their read on a developing dynamic. Where the meeting earns its keep beyond status.)*

- ...

### 🎁 From `DOS/Opportunities.md` — org-level ideas whose moment may have arrived

*(Include this sub-block when the person is **upper management** — your manager, skip-level, a Director/Head-of, the CTO/CEO — **or org/process-relevant**: Product Ops (cycles, rituals, planning — highly relevant), a Product Lead, Eng Ops (the Jira scheme owner), People/onboarding, peer EMs, a Principal engineer. **Omit entirely for direct-report 1:1s** — unless the direct raised the underlying observation, in which case it's their idea and gets credited as such.)*

**Method:** read the candidate index table at the bottom of `DOS/Opportunities.md`, match the `Best room` column to this person, then filter hard on **is there a live hook in this session?** — an agenda item, a decision in flight, something they asked for. No hook, no entry.

- **Cap: 1–2 per session.** Five org-improvement ideas is an agenda takeover; one well-timed one is strategic partnership.
- **🔴 These are NOT asks and NOT commitments.** They go in this block, never in `## 2. The Asks`. `DOS/Opportunities.md` creates no obligations by design (`DOS/CLAUDE.md`) — promoting one into an ask breaks that contract and quietly converts an idea into work.
- **Lead with their problem.** The entry earns its place only if it answers something the room already cares about. Frame as help, not as a pitch.
- Prefer `#unraised` entries. Use `#raised`/`#landed` only for a natural follow-up ("you asked for this — here's the next generalisation").
- **Format per entry:** the citable one-liner → the hook that makes now the moment → who'd own it if it went anywhere (often *not* you — say so).

- ...

## 7. Logistics

*(Banked working pattern for this person — slot length, format preferences, pre-share preferences, mood-check norms. Cheap surface that prevents friction in the moment. Pull from the person file's Working Style + 1:1 Structure blocks.)*

- **Slot:** [length, expected actual run-time per pattern]
- **Format:** [in-office / walk / remote — and which to choose for this session's content]
- **Pre-share?** [yes/no, and why]
- **Mood-check at top?** [yes/no per their pattern]
- Anything else useful for the moment.

---

## Notes from this 1:1

*(You fill this in live during the conversation; banks back to the person file's Key Interactions afterwards.)*
```

7. **Save the prep document** to `DOS/Journal/[year]/[week]/1-1-prep-[person-slug]-[YYYY-MM-DD].md`.
   - Date in the filename = the date of the **upcoming meeting**, not today.
   - Person-slug uses the kebab convention (e.g., `first-last`).
   - Multiple prep docs in the same week are fine — they're per-meeting.
   - If `DOS/Journal/[year]/[week]/` doesn't exist yet (e.g., prepping for a meeting in a future week), create the directory.

## Rules

- **Don't pad.** Drop sections that have nothing to put in them. A 4-bullet prep doc beats a 25-bullet one with filler.
- **The Asks are specific.** "Get their read on X" is fine; "discuss strategy" is not. Answerable in the meeting.
- **Walked-back items are non-negotiable.** If you committed to it and it's changed, name it before they catch it. This is the air-cover-doesn't-work-if-you-look-evasive rule.
- **Surface without instructing.** This is a prep doc, not a script. You pick what fits the slot.
- **Don't bank to memory or person files.** That happens *after* the meeting via the standard ingestion flow. Pre-meeting is read-only on the wiki.
- Use your locale's date and time format consistently (e.g. DD/MM/YYYY and your local timezone).
- Cross-link to source files so you can drill in (`Wiki/wiki/people/[name].md`, project files, journal entries).
- If the MCP is unavailable, still produce the doc — flag the Jira sweep as "manual pull required" and continue.

## Default-manager context (the recurring case)

The manager 1:1 is typically a recurring weekly slot (e.g. a 45-min slot; capture the observed pattern — some managers run dense-then-done at ~22 min — in their people file). The since-window is typically the prior week — i.e., the last 7 days of operational state.

Capture your manager's flagship workstreams in `Wiki/wiki/people/[your-manager].md` and surface convergence between them and your own framing — don't double-count overlapping initiatives. A workstream that's active at CTO altitude should be noted so you surface convergence rather than double-counting.

If air-cover has been explicitly committed, asks for scope cuts / prioritisation help are within mandate — note the commitment in their file so the prep doc can lean on it.

When a deliverable has been committed for a specific session (e.g. a 30-60-90 plan), treat it as the central artefact for *that* session (step 5). Reuse the central-artefact pattern for any future deliverable-driven session.

**Manager logistics defaults** (block 7) — populate from observed pattern, e.g.:
- Slot: [length], expect [observed actual run-time].
- Format: walk for register-setting / alignment; sit-down for structural transfer (artefacts, role definitions). Pick by content shape.
- Pre-share: [yes/no — some managers prefer a verbal walkthrough first, written artefact after; keep written deliverables ready in case they ask to keep one].
- Mood-check at top: [per their preference].
