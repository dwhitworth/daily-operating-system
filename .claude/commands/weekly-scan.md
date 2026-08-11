# Weekly Scan

Monday morning sweep across all wiki state. Surfaces stale agendas, aging TODOs, project status drift, and people who haven't been engaged in a while. Produces a punch-list of things at risk of falling through the cracks.

Invoked automatically by `/triage` on Mondays (the scan's "This Week's Top 3" folds into the Battle Card). Also runnable ad-hoc mid-week if something feels stale.

## Process

1. **Read the operational baseline.**
   - Read `DOS/Standing Brief.md`
   - Read the most recent journal entry
   - Read `Wiki/index.md` to see all tracked pages

2. **Scan all `Next Catchup Agenda` blocks.** ⚠️ **Do NOT read all people files whole — with ~100 files that's ~120k tokens and it will force a compaction.** Slice the section instead:
   - `./bin/section.sh Wiki/wiki/people/<name>.md "Next Catchup Agenda"` per file, or grep across the directory first to find which files even have queued `[ ]` items and only slice those.
   - Skip `Wiki/wiki/people/history/` entirely — it's cold archive, never a staleness signal.
   - Find the `## Next Catchup Agenda` block (skip files without one)
   - For each unchecked `[ ]` item, note: who, what, how long it's been queued (look at the agenda block's surrounding context — was it added before the most recent `Key Interactions` entry that postdates it?)
   - Flag items older than 14 days as **STALE** — either the question isn't important enough to ask, or there's no scheduled meeting to ask it in

3. **Scan project status.** For each file in `Wiki/wiki/projects/` — **slice, don't read whole** (the biggest project file can be ~20k tokens on its own): `./bin/section.sh <file> "Status Log" "Open Questions"`.
   - Check the `Status Log` for the most recent entry — if older than 14 days and status is `kickoff` / `planning` / `research`, flag as **DRIFTING**
   - Check `Open Questions` — anything aging? Anything that should have been resolved by now?

4. **Scan Standing Brief TODOs + `DOS/Backlog.md`.** This is one of the two commands that reads the Backlog — the carried items there are exactly what staleness detection is for. **Also report `wc -c` on the Brief** (target ≤60k chars) so growth gets caught weekly rather than at the point it forces a compaction.
   - Identify items that have been on the list for more than 14 days
   - Identify "This Week" items that are actually now cross-week
   - Flag completion-state inconsistencies (e.g., a meeting that already happened but its prep TODO wasn't checked)

5. **People-engagement scan.** For each direct report and key stakeholder (your directs, your manager, skip-levels, peer EMs, and key cross-functional partners — maintain the list in their people files):
   - When was the last `Key Interactions` entry?
   - If older than the expected cadence (weekly for directs, fortnightly for peers/skip-level, monthly for skip-skip), flag as **OVERDUE**

6. **Recognition Drought scan** (directs only; plus any embedded contributors). See DOS/CLAUDE.md "Team recognition & squad visibility":
   - Check each direct's `## Recognition Log` — **it lives in `Wiki/wiki/people/history/[name].md`** — and recent `Key Interactions` in the live file, for the last time they were acknowledged or given a visibility opportunity (1:1 shout-out, brown bag, demo, showcase, `#kudos`). Slice the section; don't read either file whole.
   - Flag as **RECOGNITION DROUGHT** any direct with no recognition in ~3 weeks who has had recognition-worthy work in that window (deliveries, catches, mentoring).
   - Counter any known skip-the-back-pat tendency — but **surface, don't manufacture.** If a direct genuinely hasn't had a recognition-worthy moment, don't invent one; note "nothing to surface" rather than reaching. The point is catching *missed* acknowledgement, not hitting a quota.

7. **Cross-reference open loops.** Scan all `## Open Loops` blocks across people files for items that:
   - Reference scheduling something that hasn't happened
   - Reference asking something that should have been asked by now
   - Have a date or week that's already passed

8. **Output the scan report.**

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

## Recognition Droughts
*(Directs with recognition-worthy work but no acknowledgement/visibility in ~3 weeks. Surface, don't manufacture — "all recently recognised" is a valid clean result.)*
| Person | Recognition-worthy work | Last acknowledged | Suggested avenue |
|--------|------------------------|-------------------|------------------|
| ... | ... | ... | 1:1 / team channel / brown bag / demo / `#kudos` (if bar clears) |

## This Week's Top 3
*(Synthesised from above — what should Monday actually attack?)*
1. ...
2. ...
3. ...
```

## Rules

- Use a consistent date format (DD/MM/YYYY).
- Don't act on findings — just surface them. Recommended actions are suggestions, not commands.
- Be terse. This report is a punch-list, not analysis.
- If nothing is stale/drifting/overdue, say so cleanly — don't manufacture findings.
- Cross-link to source files (`Wiki/wiki/people/[name].md`) so you can drill in.
- Don't include items that are clearly future-dated and not yet due.
