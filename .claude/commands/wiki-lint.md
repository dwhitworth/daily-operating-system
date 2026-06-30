# Wiki Lint

Health-check the wiki. Run a full audit and report findings.

## Process

1. **Index integrity.** Read `Wiki/index.md` and verify every listed page exists on disk. Report any missing files.

2. **Orphan pages.** Scan `Wiki/wiki/` for `.md` files not listed in `Wiki/index.md`. Report them.

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

6. **Naming conventions.** Check for files not following lowercase-kebab-case naming (especially in `wiki/people/`).

7. **Suggestions.** Based on the audit, suggest:
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
