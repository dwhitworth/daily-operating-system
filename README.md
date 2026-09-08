# DOS + Wiki — a Daily Operating System for Engineering Managers

A file-based **operating system for the management job**, run inside a terminal coding
agent. Two systems that work together:

- **`DOS/`** — *Daily Operating System.* Your operational intelligence layer: a morning
  triage that reads your calendar + issue tracker and builds a prioritised battle card, a
  "war room" working mode through the day, and an end-of-day wrap that journals everything
  and updates your living context. Plus 1:1 prep, weekly roll-ups, and a weekly hygiene scan.
- **`Wiki/`** — a compounding knowledge base. Domain, architecture, and **people** context
  accumulate here as durable pages instead of being re-derived every time. The LLM is the
  programmer; the wiki is the codebase.

It's driven by **`CLAUDE.md` instruction files**, **slash-command / prompt-template
definitions**, and a handful of **shell scripts and agent extensions** that enforce the parts
prose can't. There's no application to run: the "software" is the prompts, the file
conventions, and the guardrails that make the conventions stick.

**Runs on two harnesses, from one source of truth.** Every command exists twice — as a Claude
Code slash command under `.claude/commands/` and as a pi prompt template under `.pi/prompts/`.
Pick one, or run both; `bin/dos-lint.sh` reports when the copies drift, because a stale
command re-injects its defect on every run in the harness you *aren't* looking at.

> This is a **sanitised framework release**. All personal content — journals, real people
> files, the standing brief, memory — has been removed; what remains is the scaffolding for
> you to adopt and fill with your own context. Throughout, **"the operator" means you**: the
> framework is written in the third person so it never collides with the "you" that addresses
> the assistant. See [`ADAPTING.md`](./ADAPTING.md) for how to make it yours, including for
> non-EM roles.

## What's in the box

```
.
├── CLAUDE.md                   ← Root context (loaded every session)
├── SETUP-GUIDE.md              ← Full stand-it-up-yourself walkthrough
├── ADAPTING.md                 ← How to fit it to your role / org / stack
├── bin/                        ← The mechanical half. Scripts, not prose.
│   ├── dos-lint.sh             ← Health check: sizes, stale facts, layout, command drift
│   ├── wiki-lint.sh            ← Wiki equivalent, incl. per-SECTION staleness dating
│   ├── section.sh              ← Print only the named H2 sections of a file
│   ├── timebox.sh              ← Create calendar blocks that colleagues can book over
│   └── jira-summarise.sh       ← Fold big tracker JSON into a table, out of context
├── DOS/
│   ├── CLAUDE.md               ← Operating modes, disposition rubric, context hygiene
│   ├── _templates/             ← Starter shapes: Battle-Board, Backlog, Brag, Growth,
│   │                             Opportunities
│   └── _examples/              ← A fictional "Acme Rockets" seed: Standing Brief, a
│                                 journal day, a weekly roll-up
├── Wiki/
│   ├── CLAUDE.md               ← Wiki operating rules (Ingest / Query / Lint)
│   └── wiki/
│       ├── people/_template.md         ← Schema for a person page
│       ├── people/_examples/           ← Seed people files (hot/cold split shown)
│       └── process/jira-mcp-usage.md   ← Template: wire up your issue tracker
├── .claude/                    ← Claude Code harness
│   ├── settings.json           ← Read-only tracker allowlist + the reminder hook
│   ├── hooks/                  ← battle-card-reminder (per-turn board reconciliation)
│   ├── skills/unslop-writing/  ← Anti-AI-tell profile for anything a human will read
│   └── commands/               ← /triage /daily-wrap /weekly-rollup /weekly-scan
│                                 /manager-1-1 /prep /todos /dos-lint
│                                 /wiki-ingest /wiki-query /wiki-lint
└── .pi/                        ← pi harness — same commands, plus enforcement
    ├── prompts/                ← The 11 commands above, + /handoff
    ├── skills/unslop-writing/
    └── extensions/             ← The guardrails (see "Enforcement" below)
```

> A fictional **`_examples/`** seed set ships so the system is demonstrable out of the box —
> a made-up company ("Acme Rockets"), three people files, a Standing Brief, a journal day, and
> a weekly roll-up. Read them to see the conventions in action, then delete the `_examples/`
> directories once you've created your own. The cast is shared with the command files: **Sam
> Chen** is the manager, **Alex Rivera** a direct report, **Jordan Blake** a peer EM.

## The core loop

1. **Morning** — `/triage`. Reads your standing brief, latest journal, calendar, and a live
   issue-tracker sweep; produces a prioritised battle card with per-meeting agendas pulled
   from the relevant people files. *Nothing to remember — the system pulls what's queued.*
2. **Through the day** — "war room" mode, working off `DOS/Battle-Board.md`. Stream-of-
   consciousness in; the assistant captures decisions, flags risks, drafts artefacts, ticks
   the board in place.
3. **End of day** — `/daily-wrap`. Synthesises the day into a dated journal entry, sweeps the
   tracker for closures/stalls, updates the living **Standing Brief** and **people files**,
   runs a recognition scan, rebuilds the board, and commits.
4. **Continuously** — the **Wiki** accumulates durable knowledge; **people files** are the
   single source of truth for everyone you work with; **memory** persists across sessions.

Weekly: `/weekly-scan` (Monday hygiene) and `/weekly-rollup` (Friday synthesis). Monthly:
`/dos-lint` and `/wiki-lint`, which catch the slow accretion the daily passes structurally
can't see.

## The ideas that make it work

Most of the value isn't the commands — it's a handful of disciplines the instruction files
enforce, each one a scar from a specific failure:

- **The disposition rubric — what earns a checkbox.** Every observation wants to become a
  `- [ ]`; left unchecked, the list grew to ~319 open items while the real deliverables sat
  buried. The fix: a checkbox requires an **owner, a venue, and a by-when**. Missing any one,
  it's not a task — it's a *trip-wire* or a *note*. The question is never "is this important?"
  (everything is) but **"who moves next, and what unblocks it?"**
- **Two daily surfaces, split by lifecycle.** The morning briefing is cold by 10am; the action
  list is touched hourly. In one file, the thing touched hourly sat buried under the thing read
  once, and the card grew to 16k characters of nested rationale. Now `DOS/Battle-Board.md` is a
  stable pinned tab capped at 8 open items, and the dated battle card is write-once, so it
  cannot rot. **Rewording the rule three times didn't fix it; separating by lifecycle did.**
- **Hot/cold context hygiene.** Files loaded every session ("hot") are kept small; everything
  else is "cold," read on demand by a named command. Born from a real blow-up: the standing
  brief hit 64k tokens and a single morning triage loaded ~144k tokens *before doing any work*,
  forcing mid-task compaction. Two costs, not one — compaction **and** latency (editing a big
  hot file busts the prompt cache).
- **Corrections expire.** *"Was Group EM"*, *"X left, don't cite them as skip-level"* — a
  correction is a tool for a conversation, and it earns its place only while someone might
  still repeat the old fact. Test: *which conversation in the next fortnight needs this?* No
  answer, no place in a hot file. Unchecked, this is the single largest source of brief growth,
  because every correction looks load-bearing in isolation.
- **Trip-wires.** "*If `<named event>`, then `<action>`.*" No checkbox, no decay, no guilt.
  Triage already reads your calendar and board, so it fires the trip-wire on the one day it's
  actionable — strictly better than a checkbox that surfaces on 40 wrong days and gets skimmed.
- **Verify before asserting.** Never state an inference in the register of a fact. A claim
  inside a document is not verification; a status line goes stale; "access was granted" ≠ "the
  button exists." If it's checkable and load-bearing, check it.
- **Write less than you think.** A 1:1 write-up should land in ~2–4k chars — reformatting a
  transcript and calling it synthesis is the named anti-pattern. The cost isn't disk, it's the
  attention those files consume every time they load.
- **Layout budgets, because volume rules miss layout failure.** One prep doc measured 12k chars
  (inside every size budget) and was unreadable three minutes before the meeting: 48 of 54
  content lines carried bold, so bold ranked nothing. Three prose rules already forbade it and
  all three were ignored, because none of them fails at write time. So it's countable now —
  bold ≤25% of content lines, longest bullet ≤200 chars — and `bin/dos-lint.sh` measures it.
- **The lint reads a script, not the files.** `/dos-lint` runs `bin/dos-lint.sh`, which reports
  sizes and counts without loading any file bodies — *a lint that loads 60k tokens to complain
  about file sizes is the problem wearing a lab coat.*

## Enforcement — the parts prose can't do

Every rule above was written down before it was enforced, and written-down rules got ignored,
because **a rule that must fire mid-task cannot be enforced by louder prose**. The pi
extensions in `.pi/extensions/` close that gap at the moment of the mistake:

| Extension | What it stops |
|---|---|
| `battle-card-reminder` | The board silently not getting ticked. Re-states the reconcile contract every turn, ephemerally. |
| `people-file-read-guard` | **Blocks** a whole-file read of a person's page (5–12k tokens each) and points at `bin/section.sh`. |
| `cold-file-guard` | Soft-nudges when a `/triage` turn reads a file that is deliberately cold. |
| `jira-scope-guard` | **Blocks** unscoped JQL against company-wide boards, and gates every tracker *write* behind a confirm. |
| `gcalcli-calendar-guard` | Injects `--calendar` so a calendar write can't hang on an interactive prompt. |
| `today-context` | A `today` tool: local date, ISO week, journal + card paths. Stops date-arithmetic mistakes. |
| `session-status` | A start-of-session widget: date, whether today's card exists, Monday nudge. |
| `dos-autocommit` | Commits `DOS/` + `Wiki/` on shutdown. An append-heavy store with no safety net otherwise. |
| `handoff` (`/pickup`) | Resumes from a distilled handoff in a fresh session instead of dragging a bloated one. |
| `mcp-ui-suppress` | Stops MCP widget browser tabs opening on every tracker query. |

Claude Code users get the board reminder as a `UserPromptSubmit` hook
(`.claude/hooks/battle-card-reminder.sh`) and the read-only tracker allowlist in
`.claude/settings.json`; the blocking guards are pi-only.

## Design principles

- **One source of truth per thing.** People context lives in one place. The standing brief
  is the living state. The journal is the immutable record.
- **The system pulls, you don't push.** Queued questions, recognition opportunities, stale
  escalations — the modes surface them at the right moment so you don't have to hold them in
  your head.
- **Compounding, not retrieval.** The wiki synthesises and accumulates; it doesn't just index.
- **Every rule earns its place by naming the failure it prevents.** If you can't name the
  specimen, delete the rule.
- **Reliability-first, low-ego defaults** baked into the guardrails — adapt to your own.

## Getting started

Read [`SETUP-GUIDE.md`](./SETUP-GUIDE.md). In short:

1. Clone into a directory and open it with your agent (Claude Code or pi).
2. Fill in `DOS/CLAUDE.md` § Standing Context (your role, org, stack, guardrails).
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

The `unslop-writing` skill is adapted from [mshumer/unslop](https://github.com/mshumer/unslop).

The **DOS** layer — the operating modes, the daily loop, the people / recognition /
standing-brief mechanics — is the author's own.

## License

MIT — see [`LICENSE`](./LICENSE). Use it, fork it, make it yours.

---

*Built as a personal system and shared because a few people asked. It encodes one EM's
operating discipline; the value is the structure, not the specifics — bend it to fit yours.*
