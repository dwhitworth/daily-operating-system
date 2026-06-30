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

1. **Resolve the person.** Default to your manager if no argument. Locate `Wiki/wiki/people/[name].md`. If not found, error cleanly with the closest matches.

2. **Identify the last interaction.** Read the person's `## Key Interactions` block. Find the most recent dated entry — this is the **since-window anchor**. All synthesis below filters to "things that happened since that date."

3. **Read the operational baseline.**
   - `DOS/Standing Brief.md` (full)
   - All journal entries since the since-window anchor (`DOS/Journal/[year]/[week]/`)
   - The person's full file (Working Style, Strategic Notes, Next Catchup Agenda, Open Loops, Watch Items)

4. **Pull live Jira state** (when Atlassian MCP connected, only if the person is in the engineering reporting chain):
   - **Sprint state delta** since since-window — `project = <YOUR_PROJECT> AND sprint in openSprints()`. Note tickets that landed, tickets that stalled.
   - **Security/vulnerability due-soon** — `project = <VULN_PROJECT> AND statusCategory != Done AND duedate <= "<+14d>"`. Flag any assigned to your directs.
   - **Incident/hot board overdue** — `project = <HOT_PROJECT> AND assignee in (<team-member-accountIds>) AND duedate < now() AND statusCategory != Done`.
   - **H+ bugs new this period** — `project = <BUG_PROJECT> AND priority in (Highest, High) AND created >= "<since-window>" AND assignee in (<team-member-accountIds>)`.
   - Use accountIds from `Wiki/wiki/process/jira-mcp-usage.md`. (Project keys are illustrative placeholders for your own.)
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
- Use your locale's date and time format consistently (e.g. Australian DD/MM/YYYY and AEST times).
- Cross-link to source files so you can drill in (`Wiki/wiki/people/[name].md`, project files, journal entries).
- If the MCP is unavailable, still produce the doc — flag the Jira sweep as "manual pull required" and continue.

## Default-manager context (the recurring case)

The manager 1:1 is typically a recurring weekly slot (e.g. a 45-min slot, observed pattern: dense-then-done at ~22 min — capture your manager's actual pattern in their people file). The since-window is typically the prior week — i.e., the last 7 days of operational state.

Capture your manager's flagship workstreams in `Wiki/wiki/people/[your-manager].md` and surface convergence between them and your own framing — don't double-count overlapping initiatives.

If air-cover has been explicitly committed, asks for scope cuts / prioritisation help are within mandate — note the commitment in their file so the prep doc can lean on it.

When a deliverable has been committed for a specific session (e.g. a 30-60-90 plan), treat it as the central artefact for *that* session (step 5). Reuse the central-artefact pattern for any future deliverable-driven session.

**Manager logistics defaults** (block 7) — populate from observed pattern, e.g.:
- Slot: [length], expect [observed actual run-time].
- Format: walk for register-setting / alignment; sit-down for structural transfer (artefacts, role definitions). Pick by content shape.
- Pre-share: [yes/no — some managers prefer a verbal walkthrough first, written artefact after; keep written deliverables ready in case they ask to keep one].
- Mood-check at top: [per their preference].
