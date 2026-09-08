# DOS Lint

Health-check the Daily Operating System. Catches the accretion that `/daily-wrap` and
`/weekly-rollup` are supposed to prevent but don't always — plus the classes of rot that no
daily pass looks for at all (stale facts cited as current, miscited pointers, missing roll-ups).

Sibling to `/wiki-lint`, which does the same for `Wiki/`. **Run monthly, or when sessions start
feeling slow.** The slowness is the symptom this command exists to explain.

## Why this exists

On 05/08/2026 the Standing Brief hit **64k tokens** — 5× growth in three weeks — and a single
Morning Triage loaded **~144k tokens before doing any work.** Sessions compacted mid-task. Nothing
in the daily loop caught it, because every individual append was reasonable. **Accretion is
invisible per-edit and obvious in aggregate; this command looks at the aggregate.**

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
duplicate H2s · broken and miscited pointers · **command-copy divergence** · showcase coverage ·
**stale hot facts in the
Brief** (past dates written as pending, anticipatory language in the identity sections, retired
names, disagreeing headcounts) — candidates for step 2, never verdicts.

### 2. Stale-fact scan — the one thing the script can't judge

The script's **STALE HOT FACTS** section prints the candidates: past dates written as pending ·
anticipatory language in the identity sections · retired names · disagreeing headcounts ·
strikethrough count. **It never rules.** Read the hit in context and sort it into one of **four**
outcomes:

| Shape | Verdict |
|---|---|
| Cited as **current** ("Sam, Group EM") | 🔴 **Real finding** — correct it |
| Cited as **superseded, and the correction is still doing work** ("Director of Engineering *(was Group EM)*" — because someone will otherwise say the old title upward) | ✅ **Leave it.** This is the record working |
| Cited as **superseded, and nobody needs the correction any more** | 🟡 **MOVE IT OUT** — see the expiry test |
| A **dated historical entry** in `Brag.md` / `Growth.md` / a journal / `Reference/` | ✅ Correct by design. **Never "fix" these** |

#### ⭐ The expiry test — the check this command was missing until 01/09/2026

**A correction is a tool for a conversation, not a permanent fact.** Ask: **"which conversation in
the next fortnight needs this correction?"** If you can't name one, it has expired — move it to
`DOS/Reference/`, the wiki page, or leave it in the journal that already records it, and cut it from
the Brief.

**🔴 The governing question behind the test: the Brief exists so the day can be RUN and so things can
be FOUND.** Every line should answer *"what do I do / who is this / where do I look it up."* History
that no longer routes a decision is cost, not safety — and the Brief can point at it for free.

**Specimens from the 01/09/2026 prune. All four had survived earlier lints because the old two-state
rubric explicitly protected them:**
- **"Position: EM, Core Services (expected to split into 2–3 focused squads)"** — the split was concrete,
  named, placed and dated (16/09). **Anticipation outlived the decision**; it read as speculation
  about something already settled.
- **"Chris Doyle left 24/07 — do not cite them as skip-level"** plus a paragraph of biography, five
  weeks after they left, in the file that loads every morning. The correction did its job in week one.
- **"Data/Ops inheritance is DEAD"** — dead since 15/07, restated in three places including a roster
  of two engineers who were never the operator's reports.
- **Core Services "(5 eng)" in Org Structure against "6 engineers" in Team, 70 lines apart** — the class
  of defect no size or freshness check can see, and the one a reader hits first.

#### Keep the watchlist current — it's the only part that can't be inferred
`bin/dos-lint.sh` § STALE HOT FACTS carries the retired-names array. **Add to it the moment a title,
name or squad changes.** Keep the terms tight: `IAM` matched a candidate's Auth0/IAM/SSO background
before it was narrowed to `/ IAM` (the old squad name).

Current known-changed facts (extend as the org moves):
- Sam Chen — **Director of Engineering**, was Group EM Platform (30/07/2026)
- Skip-level is **Morgan Ellis, Head of Engineering** — Chris Doyle left 24/07/2026
  *(both corrections EXPIRED out of the Brief 01/09; the record lives in `Reference/org-context.md`)*
- **Data/Ops inheritance is DEAD** (15/07/2026) — went to Luis Marek's horizontal Eng Ops
  *(expired out of the Brief 01/09)*
- Core Services 2–3-eng model **does not apply** to platform/capability squads (30/07)
- Squads are **Access · Core Platform · Licensing** — "Renamed Domain" retired 28/08, "IAM" rejected
- Jordan Blake is a **Staff Engineer**, not an EM — Data Ops handed over 06/08/2026
- Casey (Natalie Hua) is **Product Design Manager**; Marta is **Head of Product**

```bash
# the DOS-wide sweep (the script only reads the Brief)
for p in "Old Job Title" "Chris" "Dead Workstream" "acting manager" "Renamed Domain"; do
  echo "--- $p ---"; grep -rln "$p" DOS --include="*.md" | grep -v Journal
done
```

**⚠️ The four-way distinction above is the entire value of this step.** A file that says *"Director of
Engineering (was Group EM, Platform)"* on the day the title changed is not stale — it's a corrected
record with provenance, which is what `DOS/CLAUDE.md` § Verify before asserting asks for. **Six weeks
later the same line is dead weight.** Flagging the first wastes the operator's time; protecting the second
forever is how the Brief grew to 77k.

### 3. Command-copy divergence — the defect that re-runs itself

**Every command exists twice:** `.claude/commands/` for Claude Code, `.pi/prompts/` for pi. They drift
silently, and this is the highest-leverage rot in the repo — **a stale command regenerates its defect on
every run, in one harness only.** That's what makes it invisible: the harness you last fixed behaves
correctly, so the command looks fine.

The script's **COMMAND-COPY DIVERGENCE** section reports differing line counts per side after
normalising away the two legitimate differences (pi's `description:` frontmatter block, and
harness-specific paths like `.pi/skills/` vs `.claude/skills/`). **Anything it prints is drift.**

**How to rule:**

| Shape | Verdict |
|---|---|
| One side carries a fix with a date or a specimen in it, the other has the older text | 🔴 **The newer side wins.** Propagate it verbatim; don't re-derive the fix |
| Both sides changed in the same region | 🤔 **Editorial** — the two harnesses were edited independently. Show the operator the diff |
| A file exists in one directory only | 🟡 Ask before copying. `handoff.md` is legitimately pi-only |
| A path or tool name differs and it's genuinely harness-specific | Extend the normalisation in the script, not the command file |

🔴 **When you fix a command, fix both copies in the same edit** — the same rule
the *verify-identifiers* rule already states for facts inside command files, applied to the
command text itself. **Adding a step to one copy is worse than not adding it**, because the behaviour
then depends on which harness is running and nothing announces that.

**Specimen (07/09/2026, the run that added this check).** Four pairs had drifted, all one-directional,
all `.claude`-newer: `triage.md` was missing the entire ASK/`🅾️ OWED` separation *and* the
`bin/timebox.sh` instructions in the pi copy (which still said `gcalcli add`); `prep.md` was missing
the whole endorsed 28/08 output layout — the verdict-column table and the landmines table — so pi runs
produced the *old* prose prep; `daily-wrap.md` was missing step 5, post-meeting debt capture, with
every later step misnumbered; `weekly-scan.md` was missing the OWED tagging and the
recognition-as-questions correction on one side and the whole Opportunities pass on the other, i.e.
**neither copy was a superset.** Every one of those was a deliberate fix that reached one harness.

### 4. Interpret — separate mechanical from editorial

Every finding lands in one of two buckets, and **say which**:

- **Mechanical** — fixable without knowing the operator's intent. Broken pointer, frontmatter date,
  empty directory, duplicate H2, checked-off item left in the Brief. **Propose these as a batch
  and offer to fix them in one pass.**
- **Editorial** — requires knowing what they still intends to do. A 16k-char `Next Catchup Agenda`,
  a 90-line TODO board, a carried item that may or may not be dead. **Surface with a
  recommendation; never act.**

**🔴 The *deliberate-parking* rule governs this whole command.** The operator parks and
sequences items on purpose. **A long-carried item is not evidence of a dropped ball**, and a big
`Next Catchup Agenda` is not evidence of overload — it's a queue they's managing. Ask before
flagging a carry as a problem, and never infer overload from surface-area count.

### 5. Output the report

```markdown
## DOS Health Report — [DD/MM/YYYY]

### 🔴 Critical (broken pointers, stale facts cited as current, hot file over hard limit, command copies out of sync)
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
| Worst-laid-out prep/battle card | N% bold, Nch bullet | ≤25% bold, ≤200ch | ... |

### Trend
[Growth since the last lint — the number that matters. A Brief at 50k that was 20k a
fortnight ago is a worse finding than a stable 58k.]
```

## Rules

- **📐 READABILITY findings are layout, not volume — don't prescribe cutting.** The section reports bold%, longest bullet, marker density and declared `reader` for recent prep docs and battle cards. A file over budget is usually the right length and the wrong shape. **The fix is re-laying-out: move ranked or parallel items into a table with a verdict column so position carries rank instead of emphasis.** Budgets and rationale live in `DOS/CLAUDE.md` § Layout budgets. `reader: (unset)` on a prep doc or battle card is itself a finding — the templates in `manager-1-1.md` and `triage.md` require it. **Never apply these budgets to `reader: assistant-at-load` files** (Standing Brief, people files, Backlog, Reference); density is correct there by design.
- **Run the script; don't re-derive it by hand.** The script is the cheap path and it's the point.
- **A command fix lands in both copies or it isn't done.** `.claude/commands/` and `.pi/prompts/`
  are the same command; a one-sided edit makes behaviour depend on the harness silently.
- **Don't act on editorial findings.** Surface, recommend, wait. Mechanical fixes can be batched
  and offered.
- **Never delete history to hit a size target.** Compression is a *move* — to `DOS/Backlog.md`,
  `DOS/Reference/`, a journal entry, or `Wiki/wiki/people/history/`. Archive before compressing,
  and say where it went.
- **Don't "fix" dated historical entries.** `Brag.md`, `Growth.md`, journals and `Reference/` are
  append-only records of what was true then. A superseded fact in a dated entry is correct.
- **Report the trend, not just the level.** Growth rate caught the 05/08 problem; the absolute
  number alone wouldn't have.
- **A clean report is a real result.** Say so plainly; don't manufacture findings to look useful.
- Australian date format (DD/MM/YYYY).

## Known-good baseline (05/08/2026, post-remediation)

Use as the comparison point until a later lint supersedes it:

- Standing Brief **46,108 chars / 11,527 tok** (was 257,445 / 64,361)
- Triage floor **~25k tok** base, ~41k with four attendee slices (was ~144k)
- Backlog 136,609 chars · `Reference/org-context.md` 44,240 — both cold, both fine
- Largest live people file **47,159 chars** (priya-raman); bulk is `Next Catchup Agenda`, hot
  and editorial
- Missing roll-up: **week-29** (week-32 was current, so expected)
- Cruft cleared at this lint: the empty `DOS/People/` directory and a 90-char vestigial
  `Memory/MEMORY.md` stub (both superseded — people context lives in `Wiki/wiki/people/`, memory in
  the auto-memory store). Structural cruft section should stay silent from here.
- Pointer fixes at this lint: **five miscited journal paths.** Files authored on the Monday of a new
  week kept getting cited under the *previous* week (`week-29/platform-value-metrics-draft` was
  really in `week-30`, etc.). One was a live Backlog action pointing at a path that didn't resolve.
  **This is the highest-yield check in the script** — expect repeat offenders at week boundaries.
