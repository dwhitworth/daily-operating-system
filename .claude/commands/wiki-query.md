# Wiki Query

Answer a question using the wiki knowledge base. The question is: $ARGUMENTS

## Process

1. **Search the wiki.** Read `Wiki/index.md` to identify candidate pages relevant to the question. Read those pages.

2. **Synthesise an answer.** Provide a direct, structured answer with citations to wiki page paths (e.g. `[wiki/domain/<topic>.md]`).

3. **Flag confidence:**
   - **HIGH** — answer drawn from dedicated wiki page(s) with primary sources
   - **MEDIUM** — inferred from multiple wiki pages or partial coverage
   - **LOW** — not well covered in wiki, drawing from general knowledge

4. **Identify gaps.** If the wiki doesn't fully cover the question, note:
   - What's missing
   - What sources might fill the gap
   - Whether a new wiki page should be created from this answer

5. **Offer to persist.** If the synthesised answer is valuable (a comparison, analysis, or connection), offer to save it as a new wiki page so the insight compounds in the knowledge base rather than disappearing into chat history.

## Rules

- Prefer wiki content over training data. If they conflict, flag the contradiction.
- Never hallucinate facts. If unsure, say so explicitly.
- Keep answers scannable — use markdown, tables, bullet points.
- Cite specific page paths so the user can verify.
