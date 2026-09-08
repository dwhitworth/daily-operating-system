# the wiki — CLAUDE.md

## Purpose
This is a compounding knowledge base, not a RAG index.
The LLM is the programmer. The wiki is the codebase.
Prefer synthesis over retrieval. Accumulate, don't re-derive.

> The design — an incrementally LLM-maintained knowledge base that integrates new
> information into existing pages, keeps cross-references current, and flags contradictions
> on ingest, rather than re-deriving from raw sources on every query — follows Andrej
> Karpathy's "LLM Wiki" pattern:
> https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
> ("a persistent, compounding artifact" where the human curates and the LLM does the
> bookkeeping).

## People Pages

`wiki/people/` is the single source of truth for all people context — both institutional
knowledge (role, scope, background, working style) and operational intel (key interactions,
strategic notes, open loops). There is no separate DOS/People directory.

- One file per person, lowercase-kebab filename (e.g. `sam-chen.md`)
- Update in place as new context accumulates
- Read the relevant file before any conversation involving that person
- All people files follow the schema in `wiki/people/_template.md`

**Hot/cold split — these files load at every Morning Triage, so the live half stays small:**

- **`wiki/people/[name].md` (hot)** — `Role`, `Scope & Ownership`, `Working Style`, `Current Focus`, `Next Catchup Agenda`, `Open Loops`, `Strategic Notes`, and the **3 most recent** `Key Interactions`.
- **`wiki/people/history/[name].md` (cold)** — older `Key Interactions` and the whole `## Recognition Log`. Same frontmatter; `type: people`. **Append new recognition entries straight here** — it's perf-review evidence, written often and read at calibration time, so it never needs to load at triage.
- Adding a 4th `Key Interactions` entry? **Move the oldest to history in the same edit.**
- **🔴 Never create a second H2 with a name that already exists** — duplicate `Recognition Log` / `Strategic Notes` sections accumulated silently across three files (one had six). Append to the existing section; make the qualifier a bolded sub-line.
- **Slice, don't read whole:** `./bin/section.sh wiki/people/[name].md "Next Catchup Agenda" "Open Loops"`. Any file over **~30k chars** gets a history pass.
- `history/` is cold archive — **never scan it for staleness or recency signals**, and don't index it in `index.md`.
- Rationale and the measured numbers: `DOS/CLAUDE.md` § Context hygiene.

---

## Core Operations

Three slash commands own the operations on this wiki:

- **`/wiki-ingest <path>`** — ingest a raw source from `raw/` into wiki pages. Discusses takeaways before writing, updates `index.md` and `log.md`.
- **`/wiki-query <question>`** — answer a question from the wiki with citations and a confidence flag.
- **`/wiki-lint`** — health-check the wiki: index integrity, orphan pages, stale sources, cross-reference health, content quality, naming.

The slash command files in `.claude/commands/` are the canonical processes.

## Transcripts pasted into chat → `raw/transcripts/` FIRST

*Rule added 03/09/2026. Trigger: six Sam 1:1 summaries said "transcript ingested" and the transcripts
were gone, so when the summarising lens turned out wrong there was no source to re-read against.*

- **Any transcript pasted into a session is saved to `raw/transcripts/<person>-<type>-YYYYMMDD.md`
  BEFORE it is summarised.** Types: `1-1`, `trio`, `retro`, `planning`, `demo`, `huddle`, `interview`,
  `sync`. Multi-person meetings use the meeting name (`sprint-retro-20260902.md`).
- The people-file / journal entry that digests it carries `**Source:** raw/transcripts/<file>` so the
  summary is a view and the transcript stays the truth.
- `raw/` is cold: never read at triage, prep, or wrap by default. It's for `/wiki-ingest`, perf-review
  prep, and re-reading a person against a question the summary can't answer. Size is not a concern
  (~30–60KB per 1:1; nothing loads it into context unasked).
- Save verbatim. No cleanup, no speaker-label fixes — note diarisation problems in the digest instead.

## Page Schema

Every wiki page must have this frontmatter:

---
title: [Human-readable title]
type: [architecture | domain | decision | people | process | competitive]
confidence: [high | medium | low | speculative]
sources: [list of raw/ paths or URLs]
updated: [YYYY-MM-DD]
---

## Content Rules

- Write for a senior engineer reading this cold.
- Confidence: `high` = sourced from primary docs or direct observation. `speculative` = inferred.
- Never hallucinate a fact. If unsure, write: "**UNCLEAR** — needs verification."
- Prefer short, precise pages over long omnibus pages. Split early.
- ADRs in `wiki/architecture/adr/` are numbered sequentially and immutable once written.

## index.md Schema

| Page | Type | Confidence | Last Updated | Summary (one line) |

## log.md Schema

Append-only. Format: `[YYYY-MM-DD HH:MM] <OPERATION> — <source> → <outcome>`

## Prohibited

- Do not edit files in `raw/`.
- Do not delete wiki pages without explicit `drop <page>` instruction.
- Do not write `confidence: high` without a source in the frontmatter.