# Daily Wrap

End the day. Synthesise everything from today's conversation into a structured journal entry, update operational state, and commit.

## Process

1. **Synthesise the day.** Review the entire conversation from today. **Read today's battle card first if one exists** — `DOS/Journal/[year]/week-[week]/battle-card-[YYYY-MM-DD].md` — it's the morning's plan and its in-day updates, so it's the ground truth for what got done vs. planned. Identify:
   - Key events, meetings, decisions
   - People interactions and new context learned
   - Wins and blockers
   - TODOs generated throughout the day
   - Battle Card items: which P0/P1/P2s landed, which slipped, which changed shape

2. **Jira sweep before writing the wrap** (when Atlassian MCP is connected). Recipes and field IDs: `Wiki/wiki/process/jira-mcp-usage.md`.

   **🔴 Scope shared boards in the JQL.** Company-wide boards (e.g. `[BUG]`, `[INCIDENT]`, `[VULN]`) span every team — scoping server-side, not in context, is the difference between 36 rows and 2. Two different ownership fields are common:
   - `[BUG]` + `[INCIDENT]` → `cf[10001] = "[team-uuid]"` (Team UUID — the display string `"[Your Team]"` silently returns zero)
   - `[VULN]` → `"Squad[Select List (multiple choices)]" = "[Your Team]"`
   - `[PROJECT]` + `[PROJECT-OPS]` → single-team, no filter needed

   **Prefer these over `assignee in (...)`** — assignee-scoping hides unassigned/untriaged tickets and your team's work assigned outside the team, both of which a wrap should see. Pass an explicit `fields` list every time; use `searchResultMode: "count"` where only the number matters.

   - **Live sprint state** — `project = [PROJECT] AND sprint in openSprints()`. Note status changes since the last journal entry: tickets that moved In Progress → PR / PR → UAT / UAT → Release, and anything that *didn't* move and should be flagged as a stall candidate.
   - **Recently-closed across all your team's spaces** — the compound-scope query (see recipes) with `AND resolved >= "<yesterday>"`. **Mandatory** — `statusCategory != Done` filters everywhere else blind the wrap to closures, including ones that invalidate live escalations in prep docs. (Known failure mode: a bug that closed is missed because every other query excludes Done, so a stale escalation citing it nearly lands in a 1:1.) Any Highest/High-priority closure or any closure that's been previously surfaced as a live escalation gets a Timeline entry.
   - **[VULN] due-soon** — `project = [VULN] AND "Squad[Select List (multiple choices)]" = "[Your Team]" AND statusCategory != Done AND duedate <= "<sprint-end>"`. Flag any **overdue** item for retro / next-1:1.
   - **[INCIDENT] board** — `project = [INCIDENT] AND cf[10001] = "[team-uuid]" AND statusCategory != Done`. Note any overdue items still Open. Team-scoped catches your team's outage items held by peer EMs (e.g. `[TICKET-123]` → [owner]) that assignee-scoping misses.
   - **Bug count delta** — `project = [BUG] AND cf[10001] = "[team-uuid]" AND priority in (Highest, High) AND statusCategory != Done`. Track movement vs. yesterday — `searchResultMode: "count"` is enough unless the delta needs explaining.
   - **Live-state-check any open prep docs** — if a `1-1-prep-*.md` exists for the next ~7 days, re-verify the state of any specific tickets cited as live escalations in that prep doc. Closures, transitions, or priority changes since the prep doc was authored should be reflected back into the prep doc *and* mentioned in the wrap. Authoring date drift on prep docs is a known failure mode — don't let stale escalations land in a 1:1.

   If anything material changed (ticket landed at end-of-day, a VULN crossed a deadline, bug priority escalated, escalation in prep doc went stale), include it in the Timeline + Projects in Flight table. Don't bury it.

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

   **🔴 TODO HYGIENE — run this every wrap, not "when it feels bad."** The Brief accumulates and has no natural deletion pressure; left alone it can balloon (one Brief reached **85 items under "This Week"**), which is a backlog wearing a deadline. Apply the same expiry discipline you'd apply to a stale-ticket policy in Jira.

   Five passes, in order:

   1. **Expire.** Any item untouched for **~3 weeks** gets closed, demoted to Watch, or **explicitly re-committed with a reason.** *"Still relevant"* is not a reason; a next action is. Silence is not re-commitment.
   2. **Dedupe.** Multiple entries for one action is the most common failure — a single clean-up session can end up as **three separate TODOs**, and a bundle can end up containing a superseded copy of itself with a note saying *"original text retained below."* Merge to one; keep the richest context.
   3. **Re-file by type** (per the TODO-surfaces table above — the Brief absorbs all three surfaces if unpoliced):
      - *Ask-when-I-see-them* → the person's `## Next Catchup Agenda`
      - *Patterns to watch* → `## Strategic Notes`, or the Brief's `👁️ Watch` block — **never a TODO**
      - *Action-blocked-on-you* → stays
   4. **Demote non-actions.** If someone else owns it, or it's a thesis rather than a task, it belongs in `👁️ Watch` **with a named re-engage trigger.** No trigger = it's not a watch item, it's noise. **Watch and Backlog live in `DOS/Backlog.md`, not the Brief.**
   5. **🔴 Move cold, don't just mark cold.** A Brief that grows unchecked (one hit **64k tokens** — 5× growth in three weeks) is what makes sessions compact mid-task. Demoting an item is not enough; **cut it to `DOS/Backlog.md`.** Destinations:
      - **`DOS/Standing Brief.md` → `This Week`** — live actions only, **one line each: the action, the venue, the warning.** Rationale goes to the journal, not the Brief. If an item needs three paragraphs to explain, the paragraphs belong in today's journal entry and the Brief gets a `→ pointer`.
      - **`DOS/Backlog.md`** — carried, gated, time-gated, Watch, Reading, low-priority, completed.
      - **`DOS/Reference/org-cycle-context.md`** — settled org/cycle narrative once it stops driving decisions (an example reference doc for org/cycle context that upward rooms turn on).
      - **A person's file** — anything person-specific.
   6. **🔴 Size check — report it every wrap, it's a one-liner:** `wc -c "DOS/Standing Brief.md"`. **Target ≤ 60k chars (~15k tokens). Over 80k, prune before writing anything new** — a Brief that forces compaction has already failed.

   **Then report the delta** (e.g. *"100 → 69 open; 18 closed, 6 merged, 10 → Watch, 7 → person files"*). ⚠️ **A wrap where nothing closed is a signal, not a clean bill of health** — surface it.

   ⚠️ **Don't mark anything done on inference.** Only you know what actually happened in rooms Claude wasn't in. **Offer the candidates and let the human call them** — several items look dead from the outside and aren't, and several look live and were quietly resolved.

5. **Update People files.** If meaningful new context was captured about anyone today, update their `Wiki/wiki/people/[name].md` file directly.

   **🔴 Hot/cold split — these files are read every triage, so keep the live half small:**
   - **Hot (live file):** `Role`, `Scope & Ownership`, `Working Style`, `Current Focus`, `Next Catchup Agenda`, `Open Loops`, `Strategic Notes`, and the **3 most recent** `Key Interactions`.
   - **Cold (`Wiki/wiki/people/history/[name].md`):** older `Key Interactions` and the `Recognition Log`. **Append new recognition entries straight to the history file** — it's calibration evidence, written often and read at perf-review time, so it never needs to load at triage.
   - **When a 4th interaction is added, move the oldest to the history file** in the same edit. Don't let the inline list grow.
   - **🔴 Never create a second H2 with a name that already exists** (files can accumulate duplicated `Recognition Log` / `Strategic Notes` sections — one had six). Append to the existing section; if the qualifier matters, make it a bolded sub-line.
   - **Size check:** any people file over **~30k chars (~7.5k tokens)** gets a history pass at the next wrap.

   **Recognition scan** (see DOS/CLAUDE.md "Team recognition & squad visibility"). Review the day's timeline for team work worth *noticing* — a good catch, a clean delivery, a junior pulled into something, a strong demo.

   **🔴 Noticing ≠ reaching out. Most noticed-good-things get logged, not acknowledged.** Recognition inflates exactly like the TODO list does — if every good thing earns a back-pat, back-pats stop meaning anything. **The bar for proposing a reach-out: would saying it change something — their behaviour, their read of their standing, or the relationship?** Yes → propose it. Just nice → notice and log, don't reach out.
   - **Propose a reach-out only when the acknowledgement does work:** it's non-obvious to *them* that it landed (new hire, new role, uncertain footing) · it's above their normal bar (a stretch/first-time, where reinforcing early shapes behaviour) · the relationship is still accruing deposits (new report, thin rapport) · it's perf-review evidence (→ a quiet log to history, not necessarily a conversation).
   - **Just notice + optionally log — do NOT propose a reach-out — when:** it's routine-excellent (a strong person doing what they're reliably strong at — "good catch" to a senior on a normal catch is noise) · it's expected at their level · they were acknowledged recently. **The trigger for reaching out is drought (the weekly-scan job), not every instance.**
   - When it clears the bar: propose a **private back-pat TODO** for tomorrow ("acknowledge X's Y in 1:1 / team channel") and/or an **avenue match** ("X's work suits the next brown bag / Demo Day / showcase; or a `#kudos` if you judge it clears the high bar").
   - Log recognition *already given today* (or a queued opportunity) to the person's `## Recognition Log` block (in history).
   - **`#kudos` conservatism:** only suggest it when it clears all three tests (concrete / third-party-legible / non-routine). Never propose batched filler to hit a rhythm. If nothing clears the bar today, surface nothing — don't manufacture recognition.

6. **Regenerate the TODO Board.** After the Standing Brief TODO hygiene pass (step 4), regenerate `DOS/TODO-Board.md` — the human-readable digest of the Standing Brief `## TODOs`. See `/todos` for the full rules; the load-bearing one:
   - **🔴 REWRITE THE FILE WHOLE. Never patch it.** Editing the board with find-and-replace produced five distinct defects in one pass: a duplicated item contradicting itself across two sections, a stale line the Brief had already resolved, and priority tags that no longer sorted. **Regenerate from the Brief; don't reconcile.**
   - **The Standing Brief is the source of truth.** The board is a lossy, terse *view* — one line per open item, no why/how (that stays in the Brief).
   - **Exclude DONE/✅ items** — they collapse to the weekly roll-up, not the board.
   - If it's past a screen or two, that's the Brief needing a prune (step 4), not the board sprawling.
   - Update the `generated:` frontmatter date.

7. **Friday nudge.** If today is the last working day of the week (Friday by default) and no `weekly-rollup.md` exists in `DOS/Journal/[year]/week-[week]/` yet, ask whether to draft one before commit-and-push. A nudge only — accept "skip" without pushing.

8. **Commit and push.** Stage all modified files and commit:
   - Message format: `Daily wrap: [DD Mon YYYY] — [brief status summary]`
   - Push to remote

## Rules

- Be thorough. The wrap is the historical record.
- Use your locale's date and time format consistently (e.g. DD/MM/YYYY and your local timezone).
- Only mark TODOs complete if they were actually completed — don't silently drop unfinished items.
- Carry forward incomplete TODOs into tomorrow's list.
- Status (GREEN/AMBER/RED) should reflect overall operational health, not just mood.
