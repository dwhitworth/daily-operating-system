# Setup Guide — stand up your own DOS + Wiki

**What this builds:** a single directory you open with [Claude Code](https://claude.com/claude-code)
that holds your **Daily Operating System** (operational intelligence — triage, war room, wraps)
and a **Wiki** (compounding domain/people knowledge), driven by `CLAUDE.md` instruction files and
slash commands. There's no app to run — the "software" is the prompts, the file conventions, and
the discipline they encode.

The fastest path: **clone this repo, keep the framework files, fill in your context, delete the
`_examples/`.** The phases below walk through what each piece is and how to make it yours.

---

## Prerequisites

```bash
# 1. Node.js 18+ required
node --version

# 2. Install Claude Code
npm install -g @anthropic-ai/claude-code

# 3. Authenticate (Claude subscription or Anthropic API key)
claude          # follow the OAuth prompt on first launch
```

---

## Phase 1 — Get the framework

Clone this repository (or copy its contents) into the directory you'll work from — e.g. `~/dos/`:

```bash
git clone <this-repo> ~/dos
cd ~/dos
```

What you're starting with:

```
~/dos/
├── CLAUDE.md                  ← Root context — describes both systems (loaded every session)
├── bin/
│   ├── dos-lint.sh            ← Cheap health check (reports sizes/counts, loads no file bodies)
│   └── section.sh             ← Print only named H2 sections of a file
├── DOS/
│   ├── CLAUDE.md              ← Operating modes + disposition rubric + context hygiene
│   └── _examples/             ← Fictional "Acme Rockets" seed — Standing Brief, journal, roll-up
├── Wiki/
│   ├── CLAUDE.md              ← Wiki operating rules and schema
│   └── wiki/
│       ├── people/_template.md   ← Person-page schema
│       ├── people/_examples/     ← Fictional seed people files
│       └── process/jira-mcp-usage.md
└── .claude/
    └── commands/              ← The 11 slash commands that drive everything
```

> **Two things this framework does NOT use** (in case you've seen an older layout):
> - **No `DOS/People/` directory.** People are the single source of truth in `Wiki/wiki/people/`.
> - **No `DOS/Memory/` directory.** Cross-session memory is Claude Code's own per-project
>   auto-memory store (see Phase 6).

---

## Phase 2 — Encode your context (`DOS/CLAUDE.md`)

This is the **highest-leverage edit.** Open `DOS/CLAUDE.md` and fill in the **Standing Context**
block — role, company, stack, reporting lines, guardrails. The placeholders (`[Company]`,
`[your manager]`, `[your domain]`, …) show exactly what to replace.

Leave the rest of `DOS/CLAUDE.md` alone at first — the disposition rubric, context-hygiene rules,
and operating-mode definitions are the framework, and they work out of the box. Read them once so
you know what the assistant is enforcing; tune later.

Do the same light pass on the **root `CLAUDE.md`** (swap `[Company]` and `[your domain]`) and
**`Wiki/CLAUDE.md`** (already generic — usually no edit needed).

---

## Phase 3 — Seed the Wiki

Create the two index files the Wiki commands expect. Open Claude Code from the root and paste:

```
Read Wiki/CLAUDE.md first. Then scaffold the wiki:

1. Create .gitkeep files in all empty Wiki/ subdirectories so git tracks them.
2. Create Wiki/index.md with an empty table:
   | Page | Type | Confidence | Last Updated | Summary |
   |------|------|------------|--------------|---------|
3. Create Wiki/log.md with a header line:
   # Wiki Ingest Log
   [TODAY] INIT — Wiki scaffolded. No sources ingested yet.
4. Create a few starter pages (confidence: speculative) for my domain, using the
   frontmatter schema in Wiki/CLAUDE.md — e.g. architecture/overview.md and a couple of
   domain/ pages. Update index.md and log.md for each.

Confirm with a list of files created.
```

From here on, `/wiki-ingest <path>` turns raw sources into pages, `/wiki-query <q>` answers from
them with citations, and `/wiki-lint` health-checks the wiki.

---

## Phase 4 — Seed the DOS

The `_examples/` directories show the target shape. To start your own:

1. **Standing Brief.** Copy `DOS/_examples/Standing Brief.md` to `DOS/Standing Brief.md` and
   replace its contents with your real (minimal) state — role context, this-week TODOs, any
   projects in flight. Keep it small; it loads every session. (See `DOS/CLAUDE.md` § Context
   hygiene for why.)
2. **People files.** For each person you work with repeatedly, create
   `Wiki/wiki/people/<name>.md` from `Wiki/wiki/people/_template.md`. The `_examples/` files
   (`alex-rivera.md`, `sam-chen.md`, `jordan-blake.md`) show the hot/cold split in practice.
3. **Journal.** Nothing to create — `/daily-wrap` writes the first entry to
   `DOS/Journal/[year]/week-[week]/[date].md`.
4. **Delete the seeds.** Once your own files exist, delete `DOS/_examples/` and
   `Wiki/wiki/people/_examples/` so the fictional data never gets mistaken for real context.

---

## Phase 5 — Wire up MCP connectors (optional, high-leverage)

The modes degrade gracefully without integrations (they'll ask you for a manual summary), but
the payoff is real when connected — triage can read your calendar and sweep your issue tracker.

Run from inside your directory so connectors are scoped to the project:

```bash
cd ~/dos

# Google Calendar (for triage's per-meeting prep)
claude mcp add --transport http google-calendar --scope project https://<your-calendar-mcp-endpoint>/mcp

# Issue tracker — Atlassian's hosted endpoint shown; Linear/GitHub have their own MCP servers
claude mcp add --transport http atlassian --scope project https://mcp.atlassian.com/v1/sse
```

Then authenticate inside Claude Code:

```bash
claude       # launch from ~/dos/
/mcp         # opens the MCP auth panel — auth each connector
```

See `Wiki/wiki/process/jira-mcp-usage.md` for the read-only/write posture and the query recipes
the commands use. The issue-tracker query *shapes* in `/triage`, `/daily-wrap`, and
`/weekly-rollup` teach the technique (server-side scoping, explicit field lists, count-mode) —
adapt the project keys and field IDs to your own tracker.

**A read-only permission allowlist ships in `.claude/settings.json`** — it pre-approves the
Atlassian *read* tools (search, get-issue, get-page, …) so triage and wraps don't prompt on every
call, while every *write* (create/edit/transition/comment) still requires explicit confirmation.
It contains no account-specific identifiers. Trim or extend it for your own connectors; if you use
a non-Atlassian tracker, replace the `mcp__atlassian__*` entries with your server's read tools.

> **Never hard-code cloud IDs, account IDs, or project keys into committed config.** They're
> account-specific and sensitive — let the connector resolve them at runtime.

---

## Phase 6 — Memory

Cross-session memory is **Claude Code's own per-project auto-memory store** — a `memory/`
directory the harness maintains, with a `MEMORY.md` index auto-loaded into every session. You
don't create it by hand; the assistant writes to it when something is worth remembering across
conversations (durable preferences, who-is-who, project constraints).

Rule of thumb: **durable facts → memory; the dated record → the journal.**

---

## Phase 7 — First-run checklist

```
□ Open the directory with Claude Code (from ~/dos/, run: claude)
□ Confirm the CLAUDE.md files loaded — the assistant should reference both DOS and Wiki
□ Run /triage — with the seed examples in place, it should build a battle card
□ Say something in "war room" mode, then run /daily-wrap — confirm a journal entry is written
   to DOS/Journal/... and the Standing Brief is updated
□ Run /wiki-query on one of your seed pages — confirm a cited answer with a confidence flag
□ Run /dos-lint — confirm the health check reports sizes/counts (it should NOT dump file bodies)
□ Run /mcp — confirm any connectors are authenticated and responding
□ Once your own context is in: delete DOS/_examples/ and Wiki/wiki/people/_examples/
```

---

## The daily loop, once you're running

```bash
# Morning
claude
> /triage

# Through the day — stream-of-consciousness into "war room" mode
> had a 1:1 with Alex; she raised the schema-registry blocker again...

# Ingest a document you received
> /wiki-ingest Wiki/raw/docs/architecture-overview.pdf

# End of day
> /daily-wrap        # writes the journal, updates the Brief, commits
```

Weekly, `/weekly-scan` (Monday hygiene) and `/weekly-rollup` (Friday synthesis) keep the system
honest; monthly, `/dos-lint` and `/wiki-lint` catch the slow accretion the daily passes can't see.

---

## Making it yours

- **Non-EM roles, mode selection, and integration swaps:** see [`ADAPTING.md`](./ADAPTING.md).
  The five modes are a menu, not a mandate; the nouns re-label cleanly (directs → clients,
  sprint board → whatever tracks your unit of work).
- **A note on privacy:** if you run this against real work context, your journals and people
  files *will* contain sensitive information. **Keep that repo private.** This release is
  scaffolding-only so you can share the *method* without ever exposing the *content*.
