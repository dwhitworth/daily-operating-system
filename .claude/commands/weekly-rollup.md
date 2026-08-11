# Weekly Roll-up

End the week. Synthesise the week's daily wraps into a tight bullet-point roll-up, surface week-shaped Jira aggregations the dailies don't see, do Standing Brief TODO hygiene, and commit.

Run after the Friday `/daily-wrap` (or any final working day of the week).

Distinct from `/weekly-scan` (Monday-morning hygiene sweep across all wiki state). This is **end-of-week synthesis**.

## Process

1. **Read the week's journal.** Pull every daily entry from `DOS/Journal/[year]/week-[week]/` for the current week. Identify recurring themes, landed milestones, escalations made, blockers carried.

2. **Read operational baseline.**
   - `DOS/Standing Brief.md`
   - `DOS/Backlog.md` — needed for step 5 (this is one of the commands that reads it; the Brief holds only this week's live items).
   - The most recent daily wrap (today's, if just written)

3. **Jira sweep — week-shaped views** (when Atlassian MCP is connected). The journal carries day-by-day state changes; this sweep adds the *aggregations the dailies don't see*. **Complement the journal, don't replace it** — if a number conflicts with the journal narrative, trust the journal and flag the discrepancy rather than overwriting.

   Field IDs, accountIds and project keys: `Wiki/wiki/process/jira-mcp-usage.md`. **Scope shared boards (`[BUG]`, `[INCIDENT]`, `[VULN]`) in the JQL** — `cf[10001] = "[team-uuid]"` for BUG/INCIDENT, `"Squad[Select List (multiple choices)]" = "[Your Team]"` for VULN. **Team-scope, don't assignee-scope: these are team-level aggregates, and an assignee filter silently drops unassigned tickets from every count.**

   1. **Tickets resolved this week** — `project = [PROJECT] AND resolved >= "<monday>" AND resolved <= "<friday>"`. Headline number anchors the #hits. List the keys briefly so the wrap can name what landed. ([PROJECT] is single-team — no ownership filter needed, and leaving it off catches closures on unassigned tickets.)
   2. **New H+ bugs created this week** — `project = [BUG] AND cf[10001] = "[team-uuid]" AND priority in (Highest, High) AND created >= "<monday>"`. Intake-rate signal — informs whether the bug-board is being fed faster than it's being drained. **🔴 Team-scope this one specifically:** new bugs arrive *unassigned*, so an assignee-filtered intake count structurally undercounts the thing it's measuring (e.g. 8 of 36 open H+ bugs were unassigned in one snapshot).
   3. **VULNs newly entering the 14-day window** — `project = [VULN] AND "Squad[Select List (multiple choices)]" = "[Your Team]" AND statusCategory != Done AND duedate <= "<+14d>" AND duedate > "<+0d>"`. Flag anything that crossed *into* the window this week — week-over-week risk surfacing.
   4. **Code reviews entered this week** — `project = [PROJECT] AND status changed to "Code Review" during ("<monday>", "<friday>")`. **🔴 Verify the status name against the live workflow first.** Statuses get renamed (e.g. a board rename of `PR` → `Code Review`, `UAT` → `QA`, `Release` → `Ready for Release`). A JQL `status changed to` clause against a status name that no longer exists returns **zero, silently, forever** — a query can read 0 for a week where 3 tickets actually moved. **The lesson is generic: a status name that no longer exists returns zero silently — verify before trusting a zero.** **Why this query specifically:** if your manager's framing makes PR/review a known throughput bottleneck, tracking throughput-through-review week-over-week is a metric worth watching, distinct from "tickets resolved." If the number is dropping, the bottleneck is moving in the wrong direction.

   **Fallback** if MCP is unavailable: skip and note "Jira sweep deferred — MCP unavailable" in the roll-up. Don't block the wrap.

4. **Synthesise the roll-up.** Bullet points only. Weave Jira numbers inline into the relevant sections — don't create a separate Jira block. If a number is small or unsurprising, drop it; the goal is signal, not telemetry.

```markdown
# Weekly Roll-up — Week [N], [Mon DD] – [Fri DD] [Mon YYYY]

## #hits
- [Top 3 wins. Weave Jira numbers in: e.g., "6 tickets landed including [feature] ([TICKET-123])"]

## #misses
- [Top risk or delay]

## #lookingforward
- [Next week's P1]

## The Ask
*(Optional — only if there's a genuine escalation that needs manager / skip-level / CTO air cover)*
- ...

---

## 📤 Project channel updates — PASTE-READY
*(Rationale, from a leadership ask about project visibility: "I don't want projects to go into a void for six weeks… just update the project channel once a week or once a fortnight." The stated reason is the one that matters: **when you need to overflow, it isn't a surprise** — "it's not like, hang on, you didn't raise this." Cheapest possible insurance on any multi-cycle commitment.)*

**One block per live multi-cycle project. 3–5 lines each. Written for the project channel, not for you.**

### #<channel-name> — <project>
> <Paste-ready text. Plain, external voice.>

```

**Rules for this block — it's a REWRITE, not a copy** (`DOS/CLAUDE.md` § Publish, don't just author):
- **Which projects get one:** anything spanning more than one cycle, or with a stakeholder waiting. Add projects as they qualify. **Skip a project with genuinely nothing to report** — a "no change this week" post is noise, and the ask is about avoiding surprises, not producing cadence.
- **🔴 Strip everything internal:** strategic reads, political calibration, per-engineer performance observations, Claude's analysis, "my read" voice, raw JQL, TODO framing. If a named engineer's judgment is being assessed, it does not go in.
- **Say the number.** Tickets closed, points done, weeks remaining. Vague progress posts are what the ask exists to prevent.
- **⭐ Name the overflow EARLY and plainly if it's coming.** This is the entire point. *"UI sizing lands Wednesday; early reads say more than one cycle"* posted now is worth more than a polished update later. **A surprise at cycle close is the failure mode; an early flag is the deliverable.**
- **You post these yourself** — do not offer to post them. Surface the drafts; you send.
- Keep to 3–5 lines. It's a status post, not a report.

5. **Standing Brief + Backlog hygiene** — the natural moment, since the week's daily wraps are the audit trail.
   - **Delete outright** purely transactional completed items (`[x] Read X doc`, `[x] Schedule Y meeting`, `[x] message Z`) from **both files**. The journal is the audit trail.
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
- Use your locale's date and time format consistently (e.g. DD/MM/YYYY and your local timezone).
- If the journal narrative and a Jira number disagree, trust the journal and flag the discrepancy.
- Don't double-count items already surfaced in dailies — synthesise, don't repeat.
- Skip "The Ask" if there isn't one. Don't manufacture an escalation to fill the slot.
- **The project-channel block is the only outward-facing part of this document.** Everything above it is your own thinking and never leaves the repo. Keep that line clean — a strategic read pasted into a project channel is the failure mode.
