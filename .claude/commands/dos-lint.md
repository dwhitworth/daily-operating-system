# DOS Lint

Health-check the Daily Operating System. Catches the accretion that `/daily-wrap` and
`/weekly-rollup` are supposed to prevent but don't always — plus the classes of rot that no
daily pass looks for at all (stale facts cited as current, miscited pointers, missing roll-ups).

Sibling to `/wiki-lint`, which does the same for `Wiki/`. **Run monthly, or when sessions start
feeling slow.** The slowness is the symptom this command exists to explain.

## Why this exists

Accretion is invisible per-edit and obvious in aggregate. A Standing Brief can quietly hit **64k
tokens** — 5× growth in three weeks — and a single Morning Triage can load **~144k tokens before
doing any work.** Sessions then compact mid-task. Nothing in the daily loop catches it, because
every individual append was reasonable. **This command looks at the aggregate.**

## Process

### 1. Run the measurement script — don't hand-measure

```bash
./bin/dos-lint.sh
```

**🔴 This is the whole data-gathering step. Do NOT read `DOS/Standing Brief.md`, `DOS/Backlog.md`,
`DOS/30-60-90.md`, `Brag.md` or `Growth.md` to do this lint.** The script reports sizes, counts and
paths without loading contents — a lint that costs 60k tokens to run is the problem wearing a
lab coat. Read a file only when a specific finding needs a judgment call, and then **slice it**:
`./bin/section.sh <file> "<H2 heading>"`.

The script covers: hot-file sizes vs budget · the triage floor · cold-file sizes · Brief/Backlog
boundary · frontmatter drift · journal roll-up coverage + entry-size trend · structural cruft ·
duplicate H2s · broken and miscited pointers · showcase coverage.

### 2. Stale-fact scan — the one thing the script can't judge

Grep the non-journal DOS files for facts known to have changed, then **read the hit in context** to
decide which of three things it is:

| Shape | Verdict |
|---|---|
| Cited as **current** ("[name], [old role]") | 🔴 **Real finding** — correct it |
| Cited as **superseded**, with the correction attached ("[new role] *(was [old role])*") | ✅ Correct — this is the record working. **Leave it.** |
| A **dated historical entry** in `Brag.md` / `Growth.md` / a journal / `Reference/` | ✅ Correct by design — those are append-only history. **Never "fix" these.** |

Current known-changed facts (extend as the org moves — these are illustrative examples of the
*shape* of a tracked change, not real people):
- [name] — **[current role]**, was [old role] (updated [date])
- Skip-level is **[name], [current title]** — **[predecessor] left [date]**
- **[some inherited responsibility] is DEAD** ([date]) — moved to [team]
- [some team model] **does not apply** to [other team type] ([date])

```bash
for p in "[old role]" "[predecessor]" "[deprecated responsibility]" "acting EM"; do
  echo "--- $p ---"; grep -rln "$p" DOS --include="*.md" | grep -v Journal
done
```

**⚠️ The distinction above is the entire value of this step.** A file that says *"[new role]
(was [old role])"* is not stale — it's a corrected record with its own provenance, which is exactly
what `DOS/CLAUDE.md` § Verify before asserting asks for. Flagging it as a finding wastes time and
pressures you to delete useful history.

### 3. Interpret — separate mechanical from editorial

Every finding lands in one of two buckets, and **say which**:

- **Mechanical** — fixable without knowing your intent. Broken pointer, frontmatter date,
  empty directory, duplicate H2, checked-off item left in the Brief. **Propose these as a batch
  and offer to fix them in one pass.**
- **Editorial** — requires knowing what you still intend to do. A 16k-char `Next Catchup Agenda`,
  a 90-line TODO board, a carried item that may or may not be dead. **Surface with a
  recommendation; never act.**

**🔴 Deliberate parking governs this whole command.** You park and sequence items on purpose.
**A long-carried item is not evidence of a dropped ball**, and a big `Next Catchup Agenda` is not
evidence of overload — it's a queue being managed. Ask before flagging a carry as a problem, and
never infer overload from surface-area count.

### 4. Output the report

```markdown
## DOS Health Report — [DD/MM/YYYY]

### 🔴 Critical (broken pointers, stale facts cited as current, hot file over hard limit)
- [Finding] → [the fix]

### 🟡 Warnings (over target, drifting, missing roll-up, cruft)
- ...

### 📋 Mechanical fixes — batch-fixable, want me to run them?
- [ ] ...

### 🤔 Editorial calls — your judgment, not mine
- [Finding] — [recommendation, and what it costs to leave it]

### 📊 Budget
| Surface | Now | Target | Verdict |
|---|---|---|---|
| Standing Brief | Nk chars / Nk tok | ≤60k chars | ✅/🟡/🔴 |
| Triage floor | ~Nk tok | ~40k tok | ... |
| Largest people file | Nk chars | ≤30k chars | ... |

### Trend
[Growth since the last lint — the number that matters. A Brief at 50k that was 20k a
fortnight ago is a worse finding than a stable 58k.]
```

## Rules

- **Run the script; don't re-derive it by hand.** The script is the cheap path and it's the point.
- **Don't act on editorial findings.** Surface, recommend, wait. Mechanical fixes can be batched
  and offered.
- **Never delete history to hit a size target.** Compression is a *move* — to `DOS/Backlog.md`,
  `DOS/Reference/`, a journal entry, or `Wiki/wiki/people/history/`. Archive before compressing,
  and say where it went.
- **Don't "fix" dated historical entries.** `Brag.md`, `Growth.md`, journals and `Reference/` are
  append-only records of what was true then. A superseded fact in a dated entry is correct.
- **Report the trend, not just the level.** Growth rate catches the problem before the absolute
  number would.
- **A clean report is a real result.** Say so plainly; don't manufacture findings to look useful.
- Use a consistent date format (DD/MM/YYYY).

## Known-good baseline (record one after your first remediation)

Use as the comparison point until a later lint supersedes it. Illustrative shape:

- Standing Brief **~46k chars / ~11.5k tok** (down from a bloated ~257k / ~64k)
- Triage floor **~25k tok** base, ~41k with four attendee slices (down from ~144k)
- Backlog and `Reference/org-cycle-context.md` — both cold, both fine even when large
- Largest live people file **~47k chars**; bulk is `Next Catchup Agenda`, hot and editorial
- Missing roll-up: the immediately-prior week is expected when the current week is still open
- Structural cruft cleared (e.g. an empty `DOS/People/` directory, a vestigial `Memory/MEMORY.md`
  stub) — both superseded, since people context lives in `Wiki/wiki/people/` and memory in the
  auto-memory store. Structural cruft section should stay silent afterwards.
- **Miscited journal paths are the highest-yield check** — files authored on the Monday of a new
  week get cited under the *previous* week (e.g. a `week-29/...` path that's really in `week-30`).
  Expect repeat offenders at week boundaries.
