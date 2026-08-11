# Wiki Lint

Health-check the wiki. Run a full audit and report findings.

## Process

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

7. **Hot-file size + hot/cold drift.** These files load at every Morning Triage, so growth is a real cost (see `DOS/CLAUDE.md` § Context hygiene). Cheap check, run it every lint:
   - `wc -c Wiki/wiki/people/*.md | sort -n | tail -10` — flag any live file over **~30k chars** as needing a history pass.
   - **Duplicate H2s in one file** — `grep -c "^## Recognition Log"` and the same for `Strategic Notes` / `Key Interactions`. More than one of any is a 🔴 finding (files have been found with duplicates; one had six).
   - **Cold content in a hot file** — a `## Recognition Log` in `people/[name].md` holding actual dated entries (a 2–3-line *"moved to `history/…`"* pointer stub is correct and expected), or more than **3** `Key Interactions` entries inline. Both belong in `history/`.
   - **A history file with an empty `## Key Interactions`** — delete it and its pointer rather than leaving a hollow archive.
   - Same size check on `Wiki/wiki/projects/*.md`, which `/weekly-scan` slices.

8. **Suggestions.** Based on the audit, suggest:
   - New pages worth creating
   - Sources worth finding to fill gaps
   - Questions worth investigating
   - Pages that could be merged or split

## Output Format

```markdown
## Wiki Health Report — [Date]

### Critical (broken links, missing files)
- ...

### Warnings (stale, orphaned, placeholder)
- ...

### Suggestions (growth opportunities)
- ...

### Stats
- Total pages: X
- Pages with sources: X
- Placeholder pages: X
- Last ingest: [date]
```
