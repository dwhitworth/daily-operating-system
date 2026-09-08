# Manager 1:1 Prep

Generates a focused 1:1 prep document for an upcoming conversation with a specific person — most often Sam (Director of Engineering, recurring Thursdays 11:15 local time), but works for any 1:1 surface (Morgan, Marcus, Kai, peer EMs, directs).

Distinct from `/weekly-scan` (Monday-morning hygiene sweep across all surfaces) and `/triage` (today's calendar). This is **forward-looking advocacy** — what to raise, ask for, escalate at *this* upcoming conversation.

## 🔴 Style — read-before-a-meeting scannable, not a dossier (load-bearing)

**The output is a glance-and-go, not an essay.** The operator reads this in the 2–3 minutes before walking in — dense prose fails them exactly when they need it. Same rule as `/prep`'s WHAT-not-WHY (established 18/08; reinforced 20/08 when a Sam prep came back "way too dense").

- **Terse bullet statements, one line each.** The line is the *thing to say/ask/do*, not the reasoning behind it. Cut "because…", "so that…", "the reason is…", the ties-to, the strategic gloss.
- **🔴 Open with `## Cover` — a numbered list of one-liners, in running order, that is the whole meeting.** Added 03/09/2026: a prep with must-gets + seven detailed blocks still forced the operator to read the blocks to know what to say. `## Cover` is the doc they read in the doorway; everything under `# Detail` is what they drill into if a line needs unpacking. If a line in Detail isn't in Cover, either add it or cut it.
- **Open with a 2-line header:** the 1–2 **must-gets** + the **running order**. Everything else is support they can drop.
- **No ⭐/🔴 emphasis inflation** — if every line is bold-starred, none ranks. Reserve markers for the genuine must-gets.
- **Load-bearing quotes only** — a number, a one-sentence framing line, the exact words for a delicate walk-back. Not the run-up.
- **Reasoning lives in the person file / journal, not here.** If a bullet needs a caveat to be sayable, keep it to a trailing half-clause. The operator can ask "expand N" / "why N?" for the rationale on any line.
- Target: the whole doc scannable in **under a minute**. If a block is a paragraph, it's failed — cut it to bullets.

## Usage

```
/manager-1-1 [name]
```

- `name` is optional. Default: **Sam** (recurring Thursday 1:1, the most frequent use case).
- Accepts kebab-case (`sam-chen`), first name (`andrei`), or full name (`Sam Chen`). Resolve to the matching `Wiki/wiki/people/[name].md` file.
- Examples: `/manager-1-1`, `/manager-1-1 ralf`, `/manager-1-1 jacob`, `/manager-1-1 niklas`.

## Process

1. **Resolve the person.** Default to Sam if no argument. Locate `Wiki/wiki/people/[name].md`. If not found, error cleanly with the closest matches.

2. **Identify the last interaction.** Slice the person's `## Key Interactions` block — `./bin/section.sh Wiki/wiki/people/[name].md "Key Interactions"`. The live file keeps only the **3 most recent** entries, which is all the anchor needs: the topmost dated entry is the **since-window anchor**. All synthesis below filters to "things that happened since that date." Older entries live in `Wiki/wiki/people/history/[name].md` — go there only if step 3 needs the longer arc.

3. **Read the operational baseline.** *(Also give `DOS/Opportunities.md` a quick pass — its candidate index — when the person is upper management or org/process-relevant. See block 6 for who qualifies and the rules for surfacing.)*
   - `DOS/Standing Brief.md` (full) — and `DOS/Reference/org-context.md` when the person is Sam / Morgan / Marcus / Tessa / Nina (it holds the reorg + cycle-model record their conversations turn on).
   - All journal entries since the since-window anchor (`DOS/Journal/[year]/[week]/`). ⚠️ **Recent entries run 25–30k chars each — if the window spans more than ~3 days, read the weekly roll-up plus the two most recent dailies rather than every entry**, and say that's what you did.
   - The person's full file (Working Style, Strategic Notes, Next Catchup Agenda, Open Loops, Watch Items) — plus `Wiki/wiki/people/history/[name].md` when the prep needs a longer arc than the 3 inline interactions (perf review, promotion case, an old commitment).
   - **🔴 If the file has an `### Observed conversational moves` block (under `## 1:1 Structure`), read it and shape every block below against it.** It's the source-cited read of how this person actually runs a conversation — what they interrupt with, what lens they apply, what they don't react to. **It's a prior, not a script:** use it to pick framings and drop noise, not to constrain what gets raised. If the block is missing and `raw/transcripts/` has ≥2 sessions for this person, that's a gap worth filling after the meeting.
   - **Raw transcripts (`Wiki/raw/transcripts/<person>-*.md`) are legitimate reading here** when the digest can't answer a question about how they'll receive something. Prefer the observed-moves block first; go to source only when it's silent.

4. **Pull live Jira state** (when Atlassian MCP connected, only if the person is in the engineering reporting chain):

   **Scope the shared boards, then narrow to the person.** This is the one command where `assignee` *is* the right narrowing — the question is per-person — but the board scope still comes first, or `VULN`/`HOT`/`BUG` return every squad's work. `AND assignee = "<their-accountId>"` is the second clause, never the only one. Field IDs and accountIds: `Wiki/wiki/process/jira-mcp-usage.md`.

   - **Sprint state delta** since since-window — `project = PROJ AND sprint in openSprints() AND assignee = "<accountId>"`. Note tickets that landed, tickets that stalled.
   - **VULN due-soon** — `project = VULN AND "Squad[Select List (multiple choices)]" = "Your Squad" AND statusCategory != Done AND duedate <= "<+14d>"`. Squad-scope first; then flag which are theirs.
   - **HOT overdue** — `project = HOT AND cf[10001] = "00000000-0000-0000-0000-000000000000" AND duedate < now() AND statusCategory != Done`.
   - **H+ bugs new this period** — `project = BUG AND cf[10001] = "00000000-0000-0000-0000-000000000000" AND priority in (Highest, High) AND created >= "<since-window>"`.
   - **Load context, not just their tickets** — squad-wide scoping answers "is this person carrying more than their share", which an assignee-only query can't. Unassigned H+ bugs are squad load too.
   - Skip this step entirely for non-engineering 1:1s (e.g., Mia, Beth, Bella).

5. **Check for a central artefact.** If a load-bearing deliverable was committed *for* this specific session (e.g., a 30-60-90 plan, a written proposal, a structured walk-through), the artefact becomes the spine of the meeting — not just one bullet in the status block. Lead the prep doc with a `## ⭐ Central artefact:` block above the seven-block structure. The seven blocks become the *frame around* the artefact, not equal-weight content.
   - Detect from: explicit prior-1:1 commitment ("I'll bring X next time"), the operator's Standing Brief TODO marked ⭐ for this person, or a deliverable date in the person's `## Next Catchup Agenda` block matching the meeting date.
   - If no central artefact, skip this block.

6. **Synthesise the prep document.** Seven-block structure (drop blocks that have nothing to say — don't pad). **Apply the § Style rule to every block: terse bullet statements, one line each, no reasoning-prose. If you're writing a paragraph, you're doing it wrong.**

```markdown
# 1:1 Prep — [Person] — [Day, DD/MM/YYYY HH:MM local time]

## Cover
1. [one line — the thing to say or ask, in running order]
2. ...
(8–15 lines. Every item in the detail below that the operator might actually raise appears here as ONE line. No sub-bullets, no reasoning, no quotes longer than a number or a phrase.)

**Must-gets:** [item numbers]. **Don't say:** [2–4 person-specific landmines, terse].

---

# Detail

## Since-window: [last interaction date] → today

[One line — what's happened relevant to this person since last conversation.]

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

## 3b. Predictable questions (answer ready)

*(From the observed-moves block: the questions this person reliably asks, each with the answer pre-loaded. A queued ask is prep; a predictable question with no answer ready is a miss. Drop the block if the file has no observed pattern yet.)*

- *"[their likely question]"* → [the answer, one line]

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

*(Include this sub-block when the person is **upper management** — Sam, Morgan, Marcus, Dana, any Director/Head-of — **or org/process-relevant**: Tessa (Product Ops: cycles, rituals, planning — highly relevant), Nina (Product Lead), Omar (Eng Ops / P&E Jira scheme), Luis Marek (Eng Ops), Beth (People), peer EMs, Kai (Principal). **Omit entirely for direct-report 1:1s** — unless the direct raised the underlying observation, in which case it's their idea and gets credited as such.)*

**Method:** read the candidate index table at the bottom of `DOS/Opportunities.md`, match the `Best room` column to this person, then filter hard on **is there a live hook in this session?** — an agenda item, a decision in flight, something they asked for. No hook, no entry.

- **Cap: 1–2 per session.** Five org-improvement ideas is an agenda takeover; one well-timed one is strategic partnership.
- **🔴 These are NOT asks and NOT commitments.** They go in this block, never in `## 2. The Asks`. `DOS/Opportunities.md` creates no obligations by design (`DOS/CLAUDE.md`) — promoting one into an ask breaks that contract and quietly converts an idea into work.
- **Lead with their problem.** The entry earns its place only if it answers something the room already cares about. Frame as help, not as a pitch.
- Prefer `#unraised` entries. Use `#raised`/`#landed` only for a natural follow-up ("you asked for this — here's the next generalisation").
- **Format per entry:** the citable one-liner → the hook that makes now the moment → who'd own it if it went anywhere (often *not* The operator — say so).

- ...

## 7. Logistics + landmines

*(Banked working pattern for this person — slot length, format preferences, pre-share preferences, mood-check norms. Pull from the person file's Working Style + 1:1 Structure + Observed conversational moves blocks. **Landmines are person-specific:** derive them from what this person actually reacts badly to per the observed-moves block, not from a generic "don't mention X" list. For a low-drama operational manager the real landmines are usually a soft date, an "all good" that isn't, a breakable metric, or a preference without a mechanism — not political sensitivities.)*

- **Slot:** [length, expected actual run-time per pattern]
- **Format:** [in-office / walk / remote — and which to choose for this session's content]
- **Pre-share?** [yes/no, and why]
- **Mood-check at top?** [yes/no per their pattern]
- **Leave room for their list?** [yes/no — some people bring the bigger half]
- **Landmines for THIS person:** [2–4, derived from observed pattern]
- Anything else useful for the moment.

---

## Notes from this 1:1

*(The operator fills in live during the conversation; banks back to person file's Key Interactions afterwards.)*
```

7. **Save the prep document** to `DOS/Journal/[year]/[week]/1-1-prep-[person-slug]-[YYYY-MM-DD].md`.
   - **Frontmatter is required, and `reader` is load-bearing:**
     ```yaml
     ---
     type: 1-1-prep
     date: YYYY-MM-DD
     week: NN
     person: [person-slug]
     reader: donovan-at-speed
     ---
     ```
     `reader: donovan-at-speed` invokes the layout budgets in `DOS/CLAUDE.md` § Layout budgets: bold on ≤25% of content lines, no bullet over ~200 chars, one marker vocabulary, and **ranked or parallel items in a table with a verdict column rather than a bold-tiered list.** This doc is read at pace minutes before the room, so layout matters more than completeness. Check with `bin/dos-lint.sh` § READABILITY.
   - Date in the filename = the date of the **upcoming meeting**, not today.
   - Person-slug uses the kebab convention (e.g., `sam-chen`, `jacob-richter`).
   - Multiple prep docs in the same week are fine — they're per-meeting.
   - If `DOS/Journal/[year]/[week]/` doesn't exist yet (e.g., prepping for a meeting in a future week), create the directory.

## Rules

- **Open with `## Cover`, always.** 8–15 numbered one-liners in running order + a must-gets/don't-say line. It is the only part guaranteed to be read.
- **Don't pad.** Drop sections that have nothing to put in them. A 4-bullet prep doc beats a 25-bullet one with filler.
- **Terse bullets, not prose (§ Style).** One line per point, the what-not-why. The whole doc scannable in under a minute; lead with the must-gets. Reasoning goes in the person file/journal — expandable on request, never inline by default.
- **The Asks are specific.** "Get Sam's read on X" is fine; "discuss strategy" is not. Answerable in the meeting.
- **Walked-back items are non-negotiable.** If you committed to it and it's changed, name it before they catch it. This is the air-cover-doesn't-work-if-you-look-evasive rule.
- **Surface without instructing.** This is a prep doc, not a script. The operator picks what fits the slot.
- **Don't bank to memory or person files.** That happens *after* the meeting via the standard ingestion flow. Pre-meeting is read-only on the wiki.
- Dates DD/MM/YYYY, times in your own zone (set DOS_TZ / DOS_LOCALE u2014 see SETUP-GUIDE.md).
- Cross-link to source files so the operator can drill in (`Wiki/wiki/people/[name].md`, project files, journal entries).
- If the MCP is unavailable, still produce the doc — flag the Jira sweep as "manual pull required" and continue.

## Default-Sam context (the recurring case)

Sam 1:1 is a recurring Thursday at 11:15 (45-min slot, observed pattern: dense-then-done at ~22 min, but they stay over when there's content). The since-window is typically the prior Thursday — i.e., the last 7 days of operational state.

**Read `## 1:1 Structure → ### Observed conversational moves` in their file first** (added 03/09/2026 from three raw transcripts). Short version: they listen through your list, then interrupt with a mechanism question; answer ops topics with Infra's precedent; want a date + RAG + a pre-emptive thread write-up; ask what the customer sees; their positions have stated premises that data can move; and they bring their own list at the end. They do not react to political framing — don't spend landmine budget there.

Sam's flagship workstreams (per `Wiki/wiki/people/sam-chen.md`):
1. Core Services Operational Process Overhaul → now the metrics-for-the-business ask (time-to-done, attribution, SLA table, W5 dashboards)
2. Platform Metrics (DORA dashboard, end-of-year deck, leadership-sync round-robin)
3. The Core Services split (16/09) and its mechanics — on-support, paging, boards, ceremonies
4. 2027 roadmap exercise (Sep→Oct, their template, approved before the December freeze)

Air-cover commitment is explicit (*"90% of the time people were okay"*, 11 Jun). Asks for scope cuts / prioritisation help are within mandate.

When a session has a central artefact (a plan, a number, a decision), frame the meeting around it (step 5) — the 30-60-90 on 18/06 was the first instance of the pattern.

**Sam logistics defaults** (block 7):
- Slot: 45 min, expect ~22-min dense-then-done; leave ~10 min for their list.
- Format: walk for register-setting / alignment; sit-down for structural transfer (artefacts, role definitions). Pick by content shape.
- Pre-share: no — Sam prefers verbal walkthrough first, written artefact after. Keep written deliverables ready in case they ask to keep one.
- Mood-check at top: optional, appreciated.
- Landmines: a soft date · "all good" when it isn't · a metric they can break in one question · a preference without a mechanism · ops without the customer view.
