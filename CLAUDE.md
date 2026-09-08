# [Company] — Root Context

This directory contains two systems that work together:

- `DOS/` — Daily Operating System. Operational intelligence. Battle HQ.
  Read `DOS/CLAUDE.md` for operating modes.
  Read `DOS/Standing Brief.md` at the start of every session.
  Journal entries live in `DOS/Journal/[year]/week-[week]/`.
  People context lives in `Wiki/wiki/people/` (single source of truth — no separate DOS/People directory).

- `Wiki/` — the wiki. Accumulated domain and architectural knowledge.
  Read `Wiki/CLAUDE.md` for operating rules.
  When a question requires domain, architectural, or institutional knowledge,
  check the wiki before answering from training data.

## How to use both systems together

- Morning Triage / War Room / Daily Wrap → DOS mode (read Standing Brief + latest journal)
- Domain questions ([your domain], architecture) → Wiki first
- Ingest a new document → `/wiki-ingest`
- Health check the wiki → `/wiki-lint`
- Health check DOS (file sizes, pointers, stale facts, roll-up gaps) → `/dos-lint`, monthly or
  whenever sessions start feeling slow. Both lints read `bin/` scripts rather than the files
  themselves — see `DOS/CLAUDE.md` § Context hygiene for why that matters.

## Memory

Persistent cross-session memory is your agent's per-project auto-memory store
(Claude Code: `~/.claude/projects/<project-slug>/memory/`).
`MEMORY.md` in that directory is the index and is auto-loaded into every session.
Update it when something is worth remembering across conversations.
