# Daily Wrap

End the day. Synthesise everything from today's conversation into a structured journal entry, update operational state, and commit.

**Writing style:** Before writing prose meant to be read or pasted elsewhere (the Executive Summary, and especially the 1:1 Items Discussed / Action Items artefact), read `.claude/skills/unslop-writing/SKILL.md` and apply it — no AI-default phrasing, no em-dashes. The terse internal bullets (timeline, TODOs, tags) don't need it.

**🔴 Length and density:** read `.claude/skills/terse/SKILL.md` and apply it to the journal entry, the board rebuild and everything said in chat. Hard caps live there.

## 🔴 Three day-surfaces, split by FUNCTION (established 09/09/2026)

The wrap reads all three. **No fact lives in two of them**, which is what stops them drifting apart.

| File | Holds | Read by |
|---|---|---|
| `battle-card-[date].md` | the morning's plan: calendar, per-meeting prep, sprint state, landmines. **Write-once, cold by 10am.** | the wrap, for planned-vs-actual |
| `meetings-[date].md` | **full texture of every meeting that ran** — who said what, verbatim fragments, outcomes, what went unraised | **the operator** (this is the surface they actually reads) + the wrap |
| `[date].md` (journal wrap) | **only what routes FORWARD** — decisions, owners, dates, corrections, defects. Thin. | **tomorrow's Morning Triage**, which reads the Brief + latest journal entry and nothing else |

**Why the journal cannot become a pointer:** Morning Triage reads only the Standing Brief and the
latest journal entry. Anything left solely in `meetings-*.md` is invisible to tomorrow. So the wrap
must carry forward every fact that routes a decision — and may safely leave the texture behind.

**Why the card must not absorb meetings:** appending outcomes to it on 09/09 took it to 43.6k, which
is the exact failure the 01/09 card/board split was created to prevent. It is a briefing, not a log.

If `meetings-[date].md` does not exist for a day (no meetings, or transcripts never came in), skip it —
synthesise from the conversation as before.

## Process

1. **Synthesise the day.** Review the entire conversation from today. **Read today's battle card and `meetings-[date].md` first if they exist** — `DOS/Journal/[year]/week-[week]/`. The card is the morning's plan (ground truth for planned vs done); the meetings file is what actually happened in each room. Identify:
   - Key events, meetings, decisions
   - People interactions and new context learned
   - Wins and blockers
   - TODOs generated throughout the day
   - Battle Card items: which P0/P1/P2s landed, which slipped, which changed shape

2. **Jira sweep before writing the wrap** (when Atlassian MCP is connected). Recipes and field IDs: `Wiki/wiki/process/jira-mcp-usage.md`.

   **🔴 Scope shared boards in the JQL.** `BUG`, `HOT`, `VULN` are company-wide — scoping server-side, not in context, is the difference between 36 rows and 2. Two different ownership fields:
   - `BUG` + `HOT` → `cf[10001] = "00000000-0000-0000-0000-000000000000"` (Team UUID — the string `"Your Squad"` silently returns zero)
   - `VULN` → `"Squad[Select List (multiple choices)]" = "Your Squad"`
   - `CORE` + `COREOPS` → single-squad, no filter needed

   **Prefer these over `assignee in (...)`** — assignee-scoping hides unassigned/untriaged tickets and Core-Services work assigned outside the squad, both of which a wrap should see. Pass an explicit `fields` list every time; use `searchResultMode: "count"` where only the number matters.

   - **Live sprint state** — `project = PROJ AND sprint in openSprints()`. Note status changes since the last journal entry: tickets that moved In Progress → PR / PR → UAT / UAT → Release, and anything that *didn't* move and should be flagged as a stall candidate.
   - **Recently-closed across all Core Services spaces** — the compound-scope query at recipe 9 with `AND statusCategory = Done AND statusCategoryChangedDate >= "<yesterday>"`. **Mandatory** — `statusCategory != Done` filters everywhere else blind the wrap to closures, including ones that invalidate live escalations in prep docs (e.g. BUG-2044 closed 15 Jun was missed because every other query excluded Done). Any Highest/High-priority closure or any closure that's been previously surfaced as a live escalation gets a Timeline entry.
     - 🔴 **Key it on `statusCategoryChangedDate`, NEVER on `resolved`.** Bulk transitions set `status` without `resolution`, so `resolved` is empty on `Won't Do`. **This has bitten the wrap twice on the record:** on 04/09 `resolved >= yesterday` returned **zero rows while three tickets read `Done`** (PROJ-1204, BUG-2101, BUG-2109), and at the week-36 roll-up it returned 15 against a true 19 — **the four it missed were all `Won't Do`, i.e. the descopes.** A zero from this query is a defect signal, not a quiet day.
   - **VULN due-soon** — `project = VULN AND "Squad[Select List (multiple choices)]" = "Your Squad" AND statusCategory != Done AND duedate <= "<sprint-end>"`. Flag any **overdue** item for retro / next-1:1.
   - **HOT board** — `project = HOT AND cf[10001] = "00000000-0000-0000-0000-000000000000" AND statusCategory != Done`. Note any overdue HOT items still Open. Team-scoped catches Core-Services outage items held by peer EMs (e.g. HOT-42 → Dan) that assignee-scoping misses.
   - **Bug count delta** — `project = BUG AND cf[10001] = "00000000-0000-0000-0000-000000000000" AND priority in (Highest, High) AND statusCategory != Done`. Track movement vs. yesterday — `searchResultMode: "count"` is enough unless the delta needs explaining.
   - **Live-state-check any open prep docs** — if a `1-1-prep-*.md` exists for the next ~7 days, re-verify the state of any specific tickets cited as live escalations in that prep doc. Closures, transitions, or priority changes since the prep doc was authored should be reflected back into the prep doc *and* mentioned in the wrap. Authoring date drift on prep docs is a known failure mode — don't let stale escalations land in a 1:1.

   If anything material changed (ticket landed at end-of-day, VULN crossed a deadline, bug priority escalated, escalation in prep doc went stale), include it in the Timeline + Projects in Flight table. Don't bury it.

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

## Closed on the board today
*Verbatim copy of `DOS/Battle-Board.md § ✅ Closed <Day DD/MM>`, ticks and ⛔ voids both.*

## Tags
- **#hits:** [Wins]
- **#misses:** [Blockers/Delays]
- **#looking-forward:** [Next steps]
```


   **🔴 The `## Closed on the board today` section is not optional, and it is not a duplicate.**
   The wrap regenerates `DOS/Battle-Board.md` whole (step 6), which **overwrites the previous day's
   `## Closed <day>` section.** Before 03/09 that meant the only surviving copy of each day's closed
   ledger was git history of the board — recoverable in theory, never read in practice. The Timeline
   captures events in prose; it does **not** capture the small ticks, and it does **not** capture the
   **⛔ void lines at all.** Voids are the highest-value half of the record: they say what was decided
   *not* to be owed and why, which is exactly what stops an item being re-added three weeks later.
   **Copy the section verbatim from the board before regenerating it.** (Backfilled for 01/09 and
   02/09 on 03/09; earlier days are still only in git.)

4. **Update Standing Brief.** Edit `DOS/Standing Brief.md` to reflect:
   - Project status changes
   - New or resolved risks
   - New TODOs or completed TODOs
   - Update the `updated:` frontmatter date

   **🔴 TODO HYGIENE — run this every wrap, not "when it feels bad."** The Brief accumulates and has no natural deletion pressure; left alone it reached **85 items under "This Week"** (29/07/2026), which is a backlog wearing a deadline. The operator is simultaneously authoring a stale-ticket expiry policy for Jira — apply the same discipline here.

   Four passes, in order:

   1. **Expire.** Any item untouched for **~3 weeks** gets closed, demoted to Watch, or **explicitly re-committed with a reason.** *"Still relevant"* is not a reason; a next action is. Silence is not re-commitment.
   2. **Dedupe.** Multiple entries for one action is the most common failure — the squad clean-up session existed as **three separate TODOs** for one meeting, and the refresh-sprint bundle contained a superseded copy of itself with a note saying *"original text retained below."* Merge to one; keep the richest context.
   3. **Re-file by type** (per the TODO-surfaces table above — the Brief absorbs all three surfaces if unpoliced):
      - *Ask-when-I-see-them* → the person's `## Next Catchup Agenda`
      - *Patterns to watch* → `## Strategic Notes`, or the Brief's `👁️ Watch` block — **never a TODO**
      - *Action-blocked-on-the-operator* → stays
   4. **Demote non-actions.** If someone else owns it, or it's a thesis rather than a task, it belongs in `👁️ Watch` **with a named re-engage trigger.** No trigger = it's not a watch item, it's noise. **Watch and Backlog live in `DOS/Backlog.md`, not the Brief.**
   5. **🔴 Move cold, don't just mark cold.** The Brief hit **64k tokens (05/08/2026)** — 5× growth in three weeks — which is what made sessions compact mid-task. Demoting an item is not enough; **cut it to `DOS/Backlog.md`.** Destinations:
      - **`DOS/Standing Brief.md` → `This Week`** — live actions only, **one line each: the action, the venue, the warning.** Rationale goes to the journal, not the Brief. If an item needs three paragraphs to explain, the paragraphs belong in today's journal entry and the Brief gets a `→ pointer`.
      - **`DOS/Backlog.md`** — carried, gated, time-gated, Watch, Reading, low-priority, completed.
      - **`DOS/Reference/org-context.md`** — settled org/reorg/cycle narrative once it stops driving decisions.
      - **A person's file** — anything person-specific.
   6. **🔴 Size check — report it every wrap, it's a one-liner:** `wc -c "DOS/Standing Brief.md"`. **Target ≤ 60k chars (~15k tokens). Over 80k, prune before writing anything new** — a Brief that forces compaction has already failed (per the `wrap_budget_context` memory).

   **Then report the delta** (e.g. *"100 → 69 open; 18 closed, 6 merged, 10 → Watch, 7 → person files"*). ⚠️ **A wrap where nothing closed is a signal, not a clean bill of health** — surface it.

   ⚠️ **Don't mark anything done on inference.** Only the operator knows what actually happened in rooms Claude wasn't in. **Offer the candidates and let them call them** — several items look dead from the outside and aren't, and several look live and were quietly resolved.

5. **🔴 Post-meeting debt capture — run this BEFORE the people-file update, for every 1:1 or meeting held today.**

   Whenever the operator said *"I'll find out"*, *"let me get back to you"*, *"I'll ask X"*, *"we should figure that out"*, or left a question of theirs unanswered, that is a **debt**, and it needs to land in **two** places with different jobs:
   - **`DOS/Standing Brief.md § TODOs` — the WORK.** Decomposed into what actually has to be done, with an owner, a venue and a by-when. *"Ask Nina whether a GTM wishlist exists — this week"*, not *"Priya's forward-intake answer"*.
   - **The person's `## Next Catchup Agenda` — the DEBT, tagged `🅾️ OWED`,** so it resurfaces at the next 1:1 whether or not the work happened.
   - **Stamp both tags on the OWED line as you write it: the size (`5m` / `30m` / `block`) and `since DD/MM`, the date the debt was incurred.** Capture time is the only moment the honest size is known; a debt tagged later gets tagged optimistically. Triage's debt radar ranks off these two fields, so an untagged line is invisible until its 1:1 arrives.

   **The person file alone is not enough, and that is the whole failure this step exists to prevent.** A debt recorded only on a person file is a record, not a worklist — nothing forces it forward, and it resurfaces as a topic to discuss rather than a thing to have done. Priya's forward-intake questions sat on their agenda from 28/08 to 07/09 and reached the 1:1 unanswered twice.

   **Also check the reverse:** anything a person asked for that the operator *answered* today gets its `OWED` line ticked and its Brief task closed. An `OWED` line that outlives its answer is how the next prep surfaces a debt that no longer exists.

6. **Update People files.** If meaningful new context was captured about anyone today, update their `Wiki/wiki/people/[name].md` file directly.

   **🔴 Hot/cold split — these files are read every triage, so keep the live half small:**
   - **Hot (live file):** `Role`, `Scope & Ownership`, `Working Style`, `Current Focus`, `Next Catchup Agenda`, `Open Loops`, `Strategic Notes`, and the **3 most recent** `Key Interactions`.
   - **Cold (`Wiki/wiki/people/history/[name].md`):** older `Key Interactions` and the `Recognition Log`. **Append new recognition entries straight to the history file** — it's calibration evidence, written often and read at perf-review time, so it never needs to load at triage.
   - **When a 4th interaction is added, move the oldest to the history file** in the same edit. Don't let the inline list grow.
   - **🔴 Never create a second H2 with a name that already exists** (three files had duplicated `Recognition Log` / `Strategic Notes` sections, one had six). Append to the existing section; if the qualifier matters, make it a bolded sub-line.
   - **Size check:** any people file over **~30k chars (~7.5k tokens)** gets a history pass at the next wrap.

   **Recognition scan** (see DOS/CLAUDE.md "Team recognition & squad visibility"). Review the day's timeline for squad work worth *noticing* — a good catch, a clean delivery, a junior pulled into something, a strong demo.

   **🔴 Noticing ≠ reaching out. Most noticed-good-things get logged, not acknowledged.** Recognition inflates exactly like the TODO list did — if every good thing earns a back-pat, back-pats stop meaning anything (the *recognition-bar* rule). **The bar for proposing a reach-out: would saying it change something — their behaviour, their read of their standing, or the relationship?** Yes → propose it. Just nice → notice and log, don't reach out.
   - **Propose a reach-out only when the acknowledgement does work:** it's non-obvious to *them* that it landed (new hire, new role, uncertain footing) · it's above their normal bar (a stretch/first-time, where reinforcing early shapes behaviour) · the relationship is still accruing deposits (new report, thin rapport) · it's perf-review evidence (→ a quiet log to history, not necessarily a conversation).
   - **Just notice + optionally log — do NOT propose a reach-out — when:** it's routine-excellent (a strong person doing what they're reliably strong at — "good catch" to a senior on a normal catch is noise) · it's expected at their level · they were acknowledged recently. **The trigger for reaching out is drought (the weekly-scan job), not every instance.**
   - When it clears the bar: propose a **private back-pat TODO** for tomorrow ("acknowledge X's Y in 1:1 / squad channel") and/or an **avenue match** ("X's work suits the next brown bag / Demo Day / showcase; or a `#kudos` if you judge it clears the high bar").
   - Log recognition *already given today* (or a queued opportunity) to the person's `## Recognition Log` block (in history).
   - **`#kudos` conservatism:** only suggest it when it clears all three tests (concrete / third-party-legible / non-routine). Never propose batched filler to hit a rhythm. If nothing clears the bar today, surface nothing — don't manufacture recognition.

7. **Regenerate the Battle Board.** After the Standing Brief TODO hygiene pass (step 4), regenerate `DOS/Battle-Board.md` — the single surface the operator works off, and a lossy view of the Standing Brief `## TODOs`. See `/todos` for the full rules; the load-bearing ones:
   - **🔴 REBUILD THE FILE WHOLE — and carry over every `[x]` tick and `⛔` void mark from the day.** They work off this file directly; un-ticking their work is a defect. *(Mid-day the rule inverts: targeted in-place edits only. Whole-file rebuild is a wrap operation. See `/todos` step 2.)*
   - **Sweep for board items that never reached the Brief** — anything added mid-day and not promoted gets deleted by the rebuild.
   - **One line per item, no sub-bullets. `## Today` re-cut for tomorrow, max 8, ordered.**
   - **Re-pick `## ▶ Next` as part of the rebuild** — exactly one item, `## Today`'s top line verbatim, startable without waiting on anyone. It is the first thing they read tomorrow, so a stale Next is worse than none.
   - **The cap evicts.** If tomorrow's candidates exceed 8, the surplus goes to DO/DELIVER by name. Never append a 9th.
   - **🔴 ORIGINAL RULE, still load-bearing:** Editing the board with find-and-replace produced five distinct defects in one pass (29/07): a duplicated item contradicting itself across two sections, a stale line the Brief had already resolved, and priority tags that no longer sorted. **Regenerate from the Brief; don't reconcile.**
   - **The Standing Brief is the source of truth.** The board is a lossy, terse *view* — one line per open item, no why/how (that stays in the Brief).
   - **Exclude DONE/✅ items** — they collapse to the weekly roll-up, not the board.
   - If it's past a screen or two, that's the Brief needing a prune (step 4), not the board sprawling.
   - Update both `updated:` and `regenerated:` frontmatter dates.

8. **Friday nudge.** If today is the last working day of the week (Friday by default) and no `weekly-rollup.md` exists in `DOS/Journal/[year]/week-[week]/` yet, ask the operator whether to draft one before commit-and-push. A nudge only — accept "skip" without pushing.

9. **Commit and push.** Stage all modified files and commit:
   - Message format: `Daily wrap: [DD Mon YYYY] — [brief status summary]`
   - Push to remote

## Rules

- Be thorough. The wrap is the historical record.
- Dates DD/MM/YYYY, times in your own zone (set DOS_TZ / DOS_LOCALE u2014 see SETUP-GUIDE.md).
- Only mark TODOs complete if they were actually completed — don't silently drop unfinished items.
- Carry forward incomplete TODOs into tomorrow's list.
- Status (GREEN/AMBER/RED) should reflect overall operational health, not just mood.
