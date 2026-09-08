# Weekly Roll-up

End the week. Synthesise the week's daily wraps into a tight bullet-point roll-up, surface week-shaped Jira aggregations the dailies don't see, do Standing Brief TODO hygiene, and commit.

**Writing style:** If any part of the roll-up will be shared or pasted (a Slack summary, a Notion update), read `.claude/skills/unslop-writing/SKILL.md` and apply it — no AI-default phrasing, no em-dashes. Pure internal bullet shorthand doesn't need it.

Run after the Friday `/daily-wrap` (or any final working day of the week).

Distinct from `/weekly-scan` (Monday-morning hygiene sweep across all wiki state). This is **end-of-week synthesis**.

## Process

1. **Read the week's journal.** Pull every daily entry from `DOS/Journal/[year]/week-[week]/` for the current week. Identify recurring themes, landed milestones, escalations made, blockers carried.

2. **Read operational baseline.**
   - `DOS/Standing Brief.md`
   - `DOS/Backlog.md` — needed for step 5 (this is one of the commands that reads it; the Brief holds only this week's live items).
   - The most recent daily wrap (today's, if just written)

3. **Jira sweep — week-shaped views** (when Atlassian MCP is connected). The journal carries day-by-day state changes; this sweep adds the *aggregations the dailies don't see*. **Complement the journal, don't replace it** — if a number conflicts with the journal narrative, trust the journal and flag the discrepancy rather than overwriting.

   Field IDs, accountIds and project keys: `Wiki/wiki/process/jira-mcp-usage.md`. **Scope shared boards (`BUG`, `HOT`, `VULN`) in the JQL** — `cf[10001] = "00000000-0000-0000-0000-000000000000"` for BUG/HOT, `"Squad[Select List (multiple choices)]" = "Your Squad"` for VULN. **Team-scope, don't assignee-scope: these are squad-level aggregates, and an assignee filter silently drops unassigned tickets from every count.**

   1. **Tickets closed this week** — `project = PROJ AND statusCategory = Done AND statusCategoryChangedDate >= "<monday>" AND statusCategoryChangedDate <= "<friday>"`. Headline number anchors the #hits. List the keys briefly so the wrap can name what landed. (CORE is single-squad — no ownership filter needed, and leaving it off catches closures on unassigned tickets.)
      - 🔴 **NEVER key this on `resolved`, and that is not a style preference.** Bulk status transitions set `status` but not `resolution`, so **`resolved` is empty on `Won't Do` — and `Won't Do` is where descoping lives.** Measured on week 36 (04/09): `resolved` returned **15**, `statusCategoryChangedDate` returned **19**, and **all four missing tickets were `Won't Do`, three of them live LM2 scope being cut.** So a `resolved`-keyed query does not merely undercount, **it hides descoping specifically** — the single most decision-relevant signal in the sweep, and the one a velocity chart most needs. ~316+ CORE tickets carry the same defect (`DOS/Backlog.md` § Data-integrity finding).
      - ⚠️ **Cross-check the row count against `searchResultMode: "count"` on identical JQL.** List responses truncate **silently, with no notice**: on 04/09 a list returned 15 rows against a count of 20, and because truncation drops a contiguous `ORDER BY` tail, the missing rows were *every* `In Progress` ticket — which read as "someone emptied the sprint this afternoon". If the two disagree, the list is short.
   2. **New H+ bugs created this week** — `project = BUG AND cf[10001] = "00000000-0000-0000-0000-000000000000" AND priority in (Highest, High) AND created >= "<monday>"`. Intake-rate signal — informs whether the bug-board is being fed faster than it's being drained. **🔴 Team-scope this one specifically:** new bugs arrive *unassigned*, so an assignee-filtered intake count structurally undercounts the thing it's measuring (8 of 36 open H+ bugs were unassigned on 05/08).
   3. **VULNs newly entering the 14-day window** — `project = VULN AND "Squad[Select List (multiple choices)]" = "Your Squad" AND statusCategory != Done AND duedate <= "<+14d>" AND duedate > "<+0d>"`. Flag anything that crossed *into* the window this week — week-over-week risk surfacing.
   4. **Code reviews entered this week** — `project = PROJ AND status changed to "Code Review" during ("<monday>", "<friday>")`. **🔴 The status is `Code Review`, NOT `PR`** — it was renamed in the 31/07 board work (along with `UAT` → `QA` and `Release` → `Ready for Release`). A JQL `status changed to` clause against a status name that no longer exists returns **zero, silently, forever** — this query read 0 for a week where 3 tickets moved (caught 06/08). **Verify the status name against the live workflow before trusting a zero.** **Why this query specifically:** Marcus's PR-bottleneck framing (12 Jun) makes throughput-through-review a metric worth tracking week-over-week, distinct from "tickets resolved." If the number is dropping, the bottleneck is moving in the wrong direction.

   **Fallback** if MCP is unavailable: skip and note "Jira sweep deferred — MCP unavailable" in the roll-up. Don't block the wrap.

4. **Synthesise the roll-up.** Bullet points only. Weave Jira numbers inline into the relevant sections — don't create a separate Jira block. If a number is small or unsurprising, drop it; the goal is signal, not telemetry.

```markdown
# Weekly Roll-up — Week [N], [Mon DD] – [Fri DD] [Mon YYYY]

## #hits
- [Top 3 wins. Weave Jira numbers in: e.g., "6 tickets landed including LM2 stage 4 (PROJ-1180)"]

## #misses
- [Top risk or delay]

## #looking-forward
- [Next week's P1]

## The Ask
*(Optional — only if there's a genuine escalation that needs Sam / Morgan / Marcus air cover)*
- ...

---

## 📤 Project channel updates — PASTE-READY
*(Marcus's ask, Tessa's cycle session 31/07: "I don't want projects to go into a void for six weeks… just update the project channel once a week or once a fortnight." Their stated reason is the one that matters: **when you need to overflow, it isn't a surprise** — "it's not like, hang on, you didn't raise this." Cheapest possible insurance on any multi-cycle commitment.)*

**One block per live multi-cycle project. 3–5 lines each. Written for the project channel, not for the operator.**

### #<channel-name> — <project>
> <Paste-ready text. Plain, external voice.>

```

**Rules for this block — it's a REWRITE, not a copy** (`DOS/CLAUDE.md` § Publish, don't just author):
- **Which projects get one:** anything spanning more than one cycle, or with a stakeholder waiting. Currently that's LM2 (→ `#ft-example-project`), and add others as they qualify. **Skip a project with genuinely nothing to report** — a "no change this week" post is noise, and Marcus's ask is about avoiding surprises, not producing cadence.
- **🔴 Strip everything internal:** strategic reads, political calibration, per-engineer performance observations, Claude's analysis, "my read" voice, raw JQL, TODO framing. If a named engineer's judgment is being assessed, it does not go in.
- **Say the number.** Tickets closed, points done, weeks remaining. Vague progress posts are what the ask exists to prevent.
- **⭐ Name the overflow EARLY and plainly if it's coming.** This is the entire point. *"UI sizing lands Wednesday; early reads say more than one cycle"* posted now is worth more than a polished update later. **A surprise at cycle close is the failure mode; an early flag is the deliverable.**
- **the operator posts these themselves** — do not offer to post them. Surface the drafts; they send.
- Keep to 3–5 lines. It's a status post, not a report.

5. **Standing Brief + Backlog hygiene** — the natural moment, since the week's daily wraps are the audit trail.
   - **Delete outright** purely transactional completed items (`[x] Read X doc`, `[x] Schedule Y meeting`, `[x] Slack Z`) from **both files**. The journal is the audit trail.
   - **Migrate** items with context-residue (milestones, completed projects, calibration moments) to **Projects in Flight** (status update), **Upcoming Milestones** (as ✅ past-anchor), or **Strategic Notes** on the relevant person file.
   - **Sweep the week boundary:** any `This Week` item in the Brief that didn't land moves to `DOS/Backlog.md` → *Carried*, and anything from the Backlog that's genuinely next-week's work moves up into the Brief. **This is the only place the two files rebalance** — the Brief is *this week*, by definition, so a new week means a re-cut.
   - **Don't touch** anything still `[ ]` other than to re-file it by that boundary rule — those are live operating context.
   - If unsure, default to deletion. `Brag.md` catches anything worth long-term recall.
   - **Report `wc -c` on both files.** Brief target ≤ 60k chars (~15k tokens); over 80k, prune before writing anything new. A Brief that forces a compaction has already failed.

6. **Save the roll-up** to `DOS/Journal/[year]/week-[week]/weekly-rollup.md`.

7. **Commit and push.** Stage the roll-up and any Standing Brief / people file changes:
   - Message format: `Weekly roll-up: Week [N] [DD Mon YYYY] — [brief headline]`
   - Push to remote.

## Rules

- Bullet points only. No prose paragraphs. The dailies are the prose; this is the index.
- Dates DD/MM/YYYY, times in your own zone (set DOS_TZ / DOS_LOCALE u2014 see SETUP-GUIDE.md).
- If the journal narrative and a Jira number disagree, trust the journal and flag the discrepancy.
- Don't double-count items already surfaced in dailies — synthesise, don't repeat.
- Skip "The Ask" if there isn't one. Don't manufacture an escalation to fill the slot.
- **The project-channel block is the only outward-facing part of this document.** Everything above it is the operator's own thinking and never leaves the repo. Keep that line clean — a strategic read pasted into a project channel is the failure mode.
