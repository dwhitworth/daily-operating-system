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
├── bin/
│   ├── dos-lint.sh            ← Cheap health check — reports sizes/counts, loads no file bodies
│   └── section.sh             ← Slice named H2 sections out of a file (read part, not whole)
├── DOS/
│   ├── CLAUDE.md              ← Operating modes + the disposition rubric + context hygiene
│   └── _examples/             ← A fictional "Acme Rockets" seed: Standing Brief, a journal day, a roll-up
├── Wiki/
│   ├── CLAUDE.md              ← Wiki operating rules (Ingest / Query / Lint)
│   └── wiki/
│       ├── people/_template.md         ← Schema for a person page
│       ├── people/_examples/           ← Fictional seed people files (hot/cold split shown)
│       └── process/jira-mcp-usage.md   ← Template: wire up your issue tracker
└── .claude/
    ├── settings.json          ← Read-only issue-tracker permission allowlist (no identifiers)
    └── commands/              ← The slash commands that drive the whole thing
        ├── triage.md          ← /triage       — morning battle card
        ├── daily-wrap.md      ← /daily-wrap   — end-of-day journal + state update
        ├── weekly-rollup.md   ← /weekly-rollup
        ├── weekly-scan.md     ← /weekly-scan  — hygiene + recognition-drought check
        ├── manager-1-1.md     ← /manager-1-1  — 1:1 prep from a person's file
        ├── prep.md            ← /prep         — fast "what's top of mind?" doorway briefing
        ├── todos.md           ← /todos        — regenerate the terse TODO board view
        ├── dos-lint.md        ← /dos-lint     — monthly DOS health check
        └── wiki-ingest.md / wiki-query.md / wiki-lint.md
```

> A fictional **`_examples/`** seed set ships so the system is demonstrable out of the box —
> a made-up company ("Acme Rockets"), three people files, a Standing Brief, a journal day, and
> a weekly roll-up. Read them to see the conventions in action, then delete the `_examples/`
> directories once you've created your own.

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

## The ideas that make it work

Most of the value isn't the commands — it's a handful of disciplines the instruction files
enforce, each one a scar from a specific failure:

- **The disposition rubric — what earns a checkbox.** Every observation wants to become a
  `- [ ]`; left unchecked, the list grew to ~319 open items while the real deliverables sat
  buried. The fix: a checkbox requires an **owner, a venue, and a by-when**. Missing any one,
  it's not a task — it's a *trip-wire* or a *note*. The question is never "is this important?"
  (everything is) but **"who moves next, and what unblocks it?"**
- **Hot/cold context hygiene.** Files loaded every session ("hot") are kept small; everything
  else is "cold," read on demand by a named command. Born from a real blow-up: the standing
  brief hit 64k tokens and a single morning triage loaded ~144k tokens *before doing any work*,
  forcing mid-task compaction. Two costs, not one — compaction **and** latency (editing a big
  hot file busts the prompt cache).
- **Trip-wires.** "*If `<named event>`, then `<action>`.*" No checkbox, no decay, no guilt.
  Triage already reads your calendar and board, so it fires the trip-wire on the one day it's
  actionable — strictly better than a checkbox that surfaces on 40 wrong days and gets skimmed.
- **Verify before asserting.** Never state an inference in the register of a fact. A claim
  inside a document is not verification; a status line goes stale; "access was granted" ≠ "the
  button exists." If it's checkable and load-bearing, check it.
- **Write less than you think.** A 1:1 write-up should land in ~2–4k chars — reformatting a
  transcript and calling it synthesis is the named anti-pattern. The cost isn't disk, it's the
  attention those files consume every time they load.
- **The lint reads a script, not the files.** `/dos-lint` runs `bin/dos-lint.sh`, which reports
  sizes and counts without loading any file bodies — *a lint that loads 60k tokens to complain
  about file sizes is the problem wearing a lab coat.*

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
