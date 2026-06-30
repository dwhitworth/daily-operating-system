# DOS + Wiki — a Daily Operating System for Engineering Managers, in Claude Code

A file-based **operating system for the management job**, run entirely inside
[Claude Code](https://claude.com/claude-code). Two systems that work together:

- **`DOS/`** — *Daily Operating System.* Your operational intelligence layer: a morning
  triage that reads your calendar + issue tracker and builds a prioritised battle card, a
  "war room" working mode through the day, and an end-of-day wrap that journals everything
  and updates your living context. Plus 1:1 prep, weekly roll-ups, and a weekly hygiene scan.
- **`Wiki/`** — a compounding knowledge base. Domain, architecture, and **people** context
  accumulate here as durable pages instead of being re-derived every time. The LLM is the
  programmer; the wiki is the codebase.

It's driven by **`CLAUDE.md` instruction files** (loaded automatically by Claude Code) and
**slash-command definitions** under `.claude/commands/`. There's no application to run — the
"software" is the prompts, the file conventions, and the discipline they encode.

> This is a **sanitised framework release**. All personal content (journals, real people
> files, the standing brief, memory) has been removed; what remains is the scaffolding —
> instructions, command definitions, templates, and a setup guide — for you to adopt and
> fill with your own context. See [`ADAPTING.md`](./ADAPTING.md) for how to make it yours
> (including for non-EM roles).

## What's in the box

```
.
├── CLAUDE.md                  ← Root context (loaded every session)
├── SETUP-GUIDE.md             ← Full stand-it-up-yourself walkthrough
├── ADAPTING.md                ← How to fit it to your role / org / stack
├── DOS/
│   └── CLAUDE.md              ← Operating modes (Triage / War Room / Wrap / Weekly / Deep Dive)
├── Wiki/
│   ├── CLAUDE.md              ← Wiki operating rules (Ingest / Query / Lint)
│   └── wiki/
│       ├── people/_template.md       ← Schema for a person page
│       └── process/jira-mcp-usage.md ← Template: wire up your issue tracker
└── .claude/
    └── commands/              ← The slash commands that drive the whole thing
        ├── triage.md          ← /triage      — morning battle card
        ├── daily-wrap.md      ← /daily-wrap  — end-of-day journal + state update
        ├── weekly-rollup.md   ← /weekly-rollup
        ├── weekly-scan.md     ← /weekly-scan — hygiene + recognition-drought check
        ├── manager-1-1.md     ← /manager-1-1 — 1:1 prep from a person's file
        └── wiki-ingest.md / wiki-query.md / wiki-lint.md
```

## The core loop

1. **Morning** — `/triage`. Reads your standing brief, latest journal, calendar, and a live
   issue-tracker sweep; produces a prioritised battle card with per-meeting agendas pulled
   from the relevant people files. *Nothing to remember — the system pulls what's queued.*
2. **Through the day** — "war room" mode. Stream-of-consciousness in; the assistant captures
   decisions, flags risks, drafts artefacts, and notes people-context as it lands.
3. **End of day** — `/daily-wrap`. Synthesises the day into a dated journal entry, sweeps the
   tracker for closures/stalls, updates the living **Standing Brief** and **people files**,
   runs a recognition scan, and commits.
4. **Continuously** — the **Wiki** accumulates durable knowledge; **people files** are the
   single source of truth for everyone you work with; **memory** persists across sessions.

## Design principles

- **One source of truth per thing.** People context lives in one place. The standing brief
  is the living state. The journal is the immutable record.
- **The system pulls, you don't push.** Queued questions, recognition opportunities, stale
  escalations — the modes surface them at the right moment so you don't have to hold them in
  your head.
- **Compounding, not retrieval.** The wiki synthesises and accumulates; it doesn't just index.
- **Reliability-first, low-ego defaults** baked into the guardrails — adapt to your own.

## Getting started

Read [`SETUP-GUIDE.md`](./SETUP-GUIDE.md). In short:

1. Clone into a directory and open it with Claude Code.
2. Fill in `DOS/CLAUDE.md` standing context (your role, org, stack, guardrails).
3. Seed a `Standing Brief.md` and your first people files.
4. Wire up MCP connectors (calendar, issue tracker) — optional but high-leverage.
5. Run `/triage` and start the loop.

## Acknowledgements

The **Wiki** layer is an implementation of **Andrej Karpathy's "LLM Wiki" pattern**
([gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)): instead of
retrieving raw documents on every query (RAG), an LLM incrementally maintains a persistent,
interlinked knowledge base — integrating new information into existing pages, updating
cross-references, and flagging contradictions on ingest. As Karpathy puts it, the human is
"in charge of sourcing, exploration, and asking the right questions" while "the LLM does all
the grunt work — the summarizing, cross-referencing, filing, and bookkeeping." The
`/wiki-ingest`, `/wiki-query`, and `/wiki-lint` commands here are that pattern in practice.

The **DOS** layer — the operating modes, the daily loop, the people / recognition /
standing-brief mechanics — is the author's own.

## License

MIT — see [`LICENSE`](./LICENSE). Use it, fork it, make it yours.

---

*Built as a personal system and shared because a few people asked. It encodes one EM's
operating discipline; the value is the structure, not the specifics — bend it to fit yours.*
