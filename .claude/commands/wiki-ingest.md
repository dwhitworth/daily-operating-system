# Wiki Ingest

Ingest a raw source into the the wiki. The source path is: $ARGUMENTS

## Process

1. **Read the source.** Open and read the file at the given path (under `Wiki/raw/`). Never modify raw source files.

2. **Discuss key takeaways.** Before writing anything, present:
   - A brief summary of what the source contains
   - 3-5 key takeaways or facts worth capturing
   - Which existing wiki pages this informs or updates
   - Any new pages that should be created
   
   Wait for user confirmation or guidance on emphasis before proceeding.

3. **Write or update wiki pages.** For each affected page:
   - Follow the page schema in `Wiki/CLAUDE.md` (frontmatter required)
   - Be additive — do not delete existing content without explicit instruction
   - Add the raw source path to the `sources:` frontmatter list
   - Update the `updated:` date
   - Add cross-references (`[[page-name]]` style links) where relevant
   - Prefer short, precise pages over long omnibus pages — split early

4. **Update the index.** Add any new pages to `Wiki/index.md` following the table format.

5. **Update the log.** Append to `Wiki/log.md`:
   ```
   [YYYY-MM-DD HH:MM] INGEST — <source path> → <list of pages affected>
   ```

6. **Report.** Summarise what was created/updated, with file paths.

## Rules

- Confidence: `high` only if sourced from primary docs or direct observation. Use `medium` for reasonable inferences, `speculative` for guesses.
- Never hallucinate facts. If something is unclear, write: "**UNCLEAR** — needs verification."
- Write for a senior engineer reading this cold.
- If the source touches people context, update the relevant `wiki/people/` file(s) too.
- Check for contradictions with existing wiki pages and flag them.
