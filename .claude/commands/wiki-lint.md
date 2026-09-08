# Wiki Lint

Health-check the the wiki. Run a full audit and report findings.

Sibling to `/dos-lint`, which does the same for `DOS/`. **Run monthly, or after a reorg** — an org
change invalidates identity sections across dozens of people files at once, and nothing in the daily
loop looks at them.

## Process

### 0. Run the measurement script — don't hand-measure

```bash
./bin/wiki-lint.sh
```

**🔴 This is the whole mechanical data-gathering step. Do NOT read people files to do it.** There are
46 live ones; reading them to check whether they're stale costs ~120k tokens, which is the problem the
lint is meant to find. The script prints dates, counts and paths — never content. Read a file only when
a specific finding needs a judgment call, and then **slice it**:
`./bin/section.sh <file> "<H2 heading>"`.

It covers: **identity-section staleness** · **retired facts in people files** · hot-file sizes ·
duplicate + near-duplicate H2s · cold content in hot files · history pairing · naming · index integrity
and orphan candidates. Steps 3, 4, 5 and 8 below are the judgment work the script deliberately
doesn't attempt.

### 0b. ⭐ Identity-section staleness — the check a file date cannot make

**A people file's `updated:` field and its git date both lie.** The bottom of the file — `Key
Interactions`, `Next Catchup Agenda`, `Open Loops` — churns daily, while `Role`, `Scope & Ownership`
and `Working Style` sit untouched for months. The file reads current. The part that tells you *who
someone is* does not.

**Specimen (07/09/2026, the run this check was built for).** `sam-chen.md` had been edited
**four days earlier**. Its `§ Role` still read *"Group Engineering Manager, Platform · reports to Kai
· **Imminent change**: moving to report to **Chris Doyle** (Head of Engineering)"* — Sam was retitled
Director of Engineering on 30/07, and Chris left on 24/07. **A departed person, named as the incoming
manager of the operator's own manager, in the file that loads for every Thursday 1:1.** `§ Scope` still
listed five Platform teams including Data/Ops "transitioning to the operator in ~3 months", dead since
15/07. Every previous lint passed the file, because every previous check looked at the *file*.

**How to rule on a gap:**

| Shape | Verdict |
|---|---|
| The section contradicts current state (title, reporting line, squad, headcount) | 🔴 **Real finding** — fix it |
| The role genuinely hasn't changed and the section is still accurate | ✅ **Leave it.** An untouched section is not a stale one |
| The section is about to change on a known date | 🟡 **Sequence it to that date**, don't write it twice |
| The section carries a `~~correction~~` nobody needs any more | 🟡 Apply the expiry test in `dos-lint.md` step 2 |

🔴 **Directs' `§ Scope & Ownership` changes ON 23/09 at squad formation.** Updating it before then
means writing it twice. Sequence those to the formation pass; fix the non-squad-scoped files
(Sam, Marcus, Morgan, Casey, Kai, Nina, and the operator's own) now.

⚠️ **the operator's own file is the easiest one to forget** and the most interpretively load-bearing — it's
not in the triage hot path, so nothing forces it current, but it gets read to calibrate how to read
*them*. On 07/09 two of its sections still dated to 23/05, their third day.

1. **Index integrity.** Read `Wiki/index.md` and verify every listed page exists on disk. Report any missing files.

2. **Orphan pages.** Scan `Wiki/wiki/` for `.md` files not listed in `Wiki/index.md`. Report them. **Exclude `Wiki/wiki/people/history/` — those are cold archives by design, deliberately unindexed and deliberately un-inbound-linked. They are not orphans and never a finding.**

3. **Stale sources.** Scan `Wiki/log.md` for ingests older than 90 days. Flag pages that haven't been updated since.

4. **Cross-reference health.** Check for:
   - Pages with no inbound links from other pages
   - Broken `[[wiki-links]]` that reference non-existent pages
   - Important concepts mentioned frequently but lacking their own page

5. **Content quality.** Flag:
   - Pages still at `confidence: speculative` with no sources
   - Contradictions between pages (same fact stated differently)
   - Pages with stale `updated:` dates that newer sources may have superseded
   - Placeholder pages with no real content

6. **Naming conventions.** Check for files not following lowercase-kebab-case naming (especially in `wiki/people/`). A `history/[name].md` must match a live `people/[name].md` exactly — a history file with no live counterpart is a real finding.

7. **Hot-file size + hot/cold drift.** These files load at every Morning Triage, so growth is a real cost (see `DOS/CLAUDE.md` § Context hygiene). **The script measures all of this — don't re-derive it by hand.** What it reports and how to read it:
   - Live people files over **~30k chars** need a `history/` pass. Same check on `Wiki/wiki/projects/*.md`, which `/weekly-scan` slices.
   - **Duplicate H2s in one file** are a 🔴 finding (three files had them; one had six). **Near-duplicates matter just as much and the old exact-match check missed them** — `Background` alongside `Background & Worldview` splits the same record in two, 80 lines apart.
   - ⚠️ **A 'near-duplicate' containing stray punctuation is usually a BAD SPLICE, not a duplicate section** — prose that got truncated into starting with `## `, which markdown then renders as a heading. **07/09 specimen: `priya-raman.md` line 55, `## Parked asks` below.)*`** — which silently parked a block of completed and voided asks under a garbage heading, above the real `## Parked asks` twelve lines later.
   - **Cold content in a hot file** — a `## Recognition Log` holding actual dated entries (a 2–3-line *"moved to `history/…`"* pointer stub is correct and expected), or more than **3** `Key Interactions` entries inline. Both belong in `history/`.
   - **A history file with an empty `## Key Interactions`** — delete it and its pointer rather than leaving a hollow archive. Two were created and removed on 05/08 for exactly this.

8. **Suggestions.** Based on the audit, suggest:
   - New pages worth creating
   - Sources worth finding to fill gaps
   - Questions worth investigating
   - Pages that could be merged or split

## Output Format

```markdown
## Wiki Health Report — [Date]

### Critical (broken links, missing files, identity sections contradicting current state)
- ...

### Warnings (stale, orphaned, placeholder, oversized)
- ...

### Identity-section staleness
| Person | File last | Oldest identity section | Gap | Verdict |
|---|---|---|---|---|
| ... | ... | ... | ...d | fix now / sequence to 23/09 / accurate, leave |

### Suggestions (growth opportunities)
- ...

### Stats
- Total pages: X
- Pages with sources: X
- Placeholder pages: X
- Last ingest: [date]
```

## Rules

- **Run the script; don't re-derive it by hand.** Reading 46 people files to check dates is the cost this command exists to avoid.
- **A gap is a candidate, not a verdict.** An untouched section describing a role that hasn't changed is correct. The finding is a section that *contradicts* current state.
- **Don't bulk-edit off the retired-facts sweep.** Most hits are legitimate — correctly-dated history, or a `"was X"` correction still doing work. Rule each one.
- **A clean report is a real result.** Say so plainly; don't manufacture findings.
- Australian date format (DD/MM/YYYY).
