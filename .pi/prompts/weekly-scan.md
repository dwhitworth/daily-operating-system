---
description: Weekly Scan
---
# Weekly Scan

Monday morning sweep across all wiki state. Surfaces stale agendas, aging TODOs, project status drift, and people who haven't been engaged in a while. Produces a punch-list of things at risk of falling through the cracks.

Invoked automatically by `/triage` on Mondays (the scan's "This Week's Top 3" folds into the Battle Card). Also runnable ad-hoc mid-week if something feels stale.

## Process

1. **Read the operational baseline.**
   - Read `DOS/Standing Brief.md`
   - Read the most recent journal entry
   - Read `Wiki/index.md` to see all tracked pages

2. **Scan all `Next Catchup Agenda` blocks.** ⚠️ **Do NOT read all ~106 people files whole — that's ~120k tokens and it will force a compaction.** Slice the section instead:
   - `./bin/section.sh Wiki/wiki/people/<name>.md "Next Catchup Agenda"` per file, or grep across the directory first to find which files even have queued `[ ]` items and only slice those.
   - Skip `Wiki/wiki/people/history/` entirely — it's cold archive, never a staleness signal.
   - Find the `## Next Catchup Agenda` block (skip files without one)
   - For each unchecked `[ ]` item, note: who, what, how long it's been queued (look at the agenda block's surrounding context — was it added before the most recent `Key Interactions` entry that postdates it?)
   - Flag items older than 14 days as **STALE** — either the question isn't important enough to ask, or there's no scheduled meeting to ask it in
   - **🔴 Check the `ASK` / `🅾️ OWED` tag on every line, and treat OWED separately.** An untagged block is itself a finding — tag it. For each `OWED` item: does a matching task exist on `DOS/Standing Brief.md § TODOs` with an owner and a by-when? **An OWED line with no Brief task is a debt that cannot move**, and it is a harder finding than staleness: it will resurface at the next 1:1 unanswered. Report these in their own table, not mixed in with stale asks.
   - **Also flag the inverse:** an `OWED` line whose Brief task is closed, or which was answered in a meeting and never ticked. Those make the next prep surface a debt that no longer exists.

3. **Scan project status.** For each file in `Wiki/wiki/projects/` — **slice, don't read whole** (the biggest project file is ~20k tokens on its own): `./bin/section.sh <file> "Status Log" "Open Questions"`.
   - Check the `Status Log` for the most recent entry — if older than 14 days and status is `kickoff` / `planning` / `research`, flag as **DRIFTING**
   - Check `Open Questions` — anything aging? Anything that should have been resolved by now?

4. **Scan Standing Brief TODOs + `DOS/Backlog.md`.** This is one of the two commands that reads the Backlog — the carried items there are exactly what staleness detection is for. **Also report `wc -c` on the Brief** (target ≤60k chars) so growth gets caught weekly rather than at the point it forces a compaction.
   - Identify items that have been on the list for more than 14 days
   - Identify "This Week" items that are actually now cross-week
   - Flag completion-state inconsistencies (e.g., a meeting that already happened but its prep TODO wasn't checked)

5. **People-engagement scan.** For each direct report and key stakeholder (Jordan, Sam, Morgan, Nina, Riley, Riya, Alex Rei, Alex Rivera, Dev, Priya, Daniel, Marta, Kai, Nick):
   - When was the last `Key Interactions` entry?
   - If older than the expected cadence (weekly for directs, fortnightly for peers/skip-level, monthly for skip-skip), flag as **OVERDUE**

6. **Recognition Drought scan** (directs only — Riya, Alex Rei, Alex Rivera, Dev, Riley, Priya; + Robin as embedded). See DOS/CLAUDE.md "Team recognition & squad visibility":

   🔴 **OUTPUT THIS AS QUESTIONS TO DONOVAN, NOT AS FINDINGS.** Log dates are **not evidence** — they frequently acknowledge people verbally and doesn't record it (the *recognition-bar* rule). The scan reads file dates, so treating them as gaps manufactures false droughts. **31/08 specimen: the scan produced a five-row drought table from log dates alone and at least one had already been given.**
   - **Ask:** *"Alex W's alerts overhaul went to production 27/08 — has that been acknowledged?"* — one line per candidate, phrased as a question.
   - **Never** render it as a findings table, **never** put it on the battle card as a TODO before they answer, **never** call it a drought until they confirm one.
   - The file date is a **prompt for the question**, not proof of an omission.
   - Check each direct's `## Recognition Log` — **it now lives in `Wiki/wiki/people/history/[name].md`** — and recent `Key Interactions` in the live file, for the last time they were acknowledged or given a visibility opportunity (1:1 shout-out, brown bag, demo, showcase, `#kudos`). Slice the section; don't read either file whole.
   - Flag as **RECOGNITION DROUGHT** any direct with no recognition in ~3 weeks who has had recognition-worthy work in that window (deliveries, catches, mentoring).
   - Counter the operator's known skip-the-back-pat tendency — but **surface, don't manufacture.** If a direct genuinely hasn't had a recognition-worthy moment, don't invent one; note "nothing to surface" rather than reaching. The point is catching *missed* acknowledgement, not hitting a quota.

7. **Cross-reference open loops + prune stale ones.** Scan all `## Open Loops` blocks across people files. Open Loops = **live, action-blocked-on-the-operator items ONLY** — not a log. Flag (and offer to cut) items that:
   - Reference scheduling something that hasn't happened
   - Reference asking something that should have been asked by now
   - Have a date or week that's already passed
   - **Are `[x]` completed and left in place** — git preserves history; they should have been removed at completion (see the *close-loops-on-completion* rule).
   - **Are done-in-practice zombies** — "formalise the cadence" when the 1:1 already runs weekly; "set up the shared doc" when the doc exists (check for the artefact link in the file). These never self-close because no single moment declares them done — this is the main rot mechanism.
   - Surface as a **Stale Open Loops** table; propose cuts, let the operator veto (don't auto-delete). If an artefact link is missing for a done-in-practice item, offer to fetch/add it.

8. **Opportunities ripeness pass** (`DOS/Opportunities.md`). **🔴 Non-obligating — this surfaces, it NEVER creates a TODO** (same contract as the doc itself; an entry with no room this week stays unmentioned, and that's the doc working).
   - Read the **candidate index** table (bottom of the doc). Don't read all 22 entries whole — the index rows carry the citable form + `Best room`.
   - **Re-score the 🔥/🌱 ripeness marker** for each entry against current live context (reorg state, active deliverables like Aug-30, decisions in flight, air cover that just appeared), and update the snapshot date on the legend line. 🔥 = a live hook exists now; 🌱 = valid but dormant.
   - **Cross-reference `Best room` against this week's calendar** (`gcalcli agenda "[today]" "[+7d]"`) + the live threads in the Brief/journal.
   - Output only the 🔥 entries that have an **actual room this week** (or a live non-meeting hook). **Cap the shortlist at ~3–5** so it stays a prioritised signal, not a dump of the whole doc.
   - Frame every line as *"ripe to raise if the room opens,"* never as an action item. **Do NOT fold these into This Week's Top 3** (that section is hygiene to attack; folding an Opportunity in would convert it into an obligation).

9. **Growth rep check — FIRST SCAN OF EACH MONTH ONLY. Skip it every other week.** Read `DOS/Growth.md` § Practising now (it's small by design — max 5 items). For each 🎯 PRACTISE item, two questions only: **did its named venue actually happen, and did the behaviour get a rep?** ⚠️ **This is not a new ritual and it never creates a TODO.** A venue that didn't happen is information, not a failure. **Graduation is declared by the operator, never inferred from quiet** — quiet means it never got a rep. If an item has had no venue for two consecutive monthly checks, ask whether it should be parked, not whether it graduated.
   - **Also ask about the 📌 stickies, in one line: is each of the three still being read?** A sticky that has become wallpaper has stopped working. **Swapping is expected and healthy** — but a swap-in must DISPLACE one of the three, never make it four, and putting the new one up is a one-off Battle Board task. The operator calls the swap; never propose one unprompted off a stale date.

10. **Output the scan report.**

```markdown
# Weekly Scan — Monday [DD/MM/YYYY]

## Stale Agendas (queued >14 days)
| Person | Question | Queued Since | Recommended Action |
|--------|----------|--------------|---------------------|
| ... | ... | ... | Ask Mon catchup / drop / re-schedule |

## Drifting Projects (no status update >14 days)
| Project | Status | Last Update | Recommended Action |
|---------|--------|-------------|---------------------|
| ... | ... | ... | ... |

## Stale Standing Brief TODOs
- [ ] (Item — N days on the list)
- ...

## Overdue People Engagements
| Person | Last Interaction | Expected Cadence | Action |
|--------|------------------|-------------------|--------|
| ... | ... | weekly | Schedule 1:1 |

## Cross-Reference Loose Ends
- [Person] — [issue] (e.g., "Schedule X 1:1" on file but no calendar invite)

## Stale Open Loops (prune candidates — the operator vetoes)
| Person | Loop | Why stale | Action |
|--------|------|-----------|--------|
| ... | ... | done-in-practice / `[x]` left / date passed | cut / add artefact link / keep |

## Recognition — questions, not findings
*(🔴 Log dates are prompts, not evidence. Ask; don't report a drought. See the *recognition-bar* rule.)*
- [Person] — [specific work + date]. Has this been acknowledged?

## Opportunities — ripe this week
*(From `DOS/Opportunities.md`. **Non-obligating — NOT TODOs.** Only 🔥 entries whose moment has a room on this week's calendar or a live hook; capped at ~3–5. Raise if the room opens; otherwise they stay in the doc. Ripeness markers in the index were re-scored as part of this run.)*
| # | Entry (citable form) | Room / occasion this week |
|---|----------------------|---------------------------|
| ... | ... | ... |

## Growth reps (first scan of the month only — omit this section entirely otherwise)
*(One row per 🎯 PRACTISE item in `DOS/Growth.md`. Non-obligating: no TODOs. Graduation is declared, not inferred.)*
| Practising | Venue | Did the venue happen? | Rep? |
|---|---|---|---|
| ... | ... | ... | ... |

## This Week's Top 3
*(Synthesised from above — what should Monday actually attack?)*
1. ...
2. ...
3. ...
```

## Rules

- Australian date format (DD/MM/YYYY).
- Don't act on findings — just surface them. Recommended actions are suggestions, not commands.
- Be terse. This report is a punch-list, not analysis.
- If nothing is stale/drifting/overdue, say so cleanly — don't manufacture findings.
- Cross-link to source files (`Wiki/wiki/people/[name].md`) so the operator can drill in.
- Don't include items that are clearly future-dated and not yet due.
- **The Opportunities pass surfaces, never obligates** — re-score the index markers, list only what has a room this week, and keep it out of This Week's Top 3. An empty Opportunities section is a valid, healthy result.
- **The Growth rep check is monthly, not weekly, and never obligates** — omit the section entirely on the other scans. Graduation is declared by the operator, never inferred from quiet.
