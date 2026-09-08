# Setup Guide — stand up your own DOS + Wiki

**What this builds:** a single directory you open with a terminal coding agent that holds your
**Daily Operating System** (operational intelligence — triage, war room, wraps) and a **Wiki**
(compounding domain/people knowledge), driven by `CLAUDE.md` instruction files, slash commands,
shell scripts and agent extensions. There's no app to run — the "software" is the prompts, the
file conventions, and the guardrails that make the conventions stick.

The fastest path: **clone this repo, keep the framework files, fill in your context, delete the
`_examples/`.** The phases below walk through what each piece is and how to make it yours.

A note on voice before you start: throughout these files, **"the operator" means you.** The
framework is written in the third person so it never collides with the "you" that addresses the
assistant.

---

## Phase 0 — Choose your harness

The framework ships for **both** of these, from one set of definitions. You can run either, or
both against the same directory.

| | [Claude Code](https://claude.com/claude-code) | [pi](https://github.com/earendil-works/pi-coding-agent) |
|---|---|---|
| Commands live in | `.claude/commands/*.md` | `.pi/prompts/*.md` |
| Board reminder | `UserPromptSubmit` hook | `battle-card-reminder` extension |
| Tracker permissions | allowlist in `.claude/settings.json` | `jira-scope-guard` extension |
| Blocking guards (whole-file people reads, unscoped JQL, gated writes) | ✗ | ✓ |
| `today` tool, session widget, autocommit, `/pickup` | ✗ | ✓ |

**If you only want one:** Claude Code is the lower-setup path and everything in the core loop
works. pi additionally *enforces* the hygiene rules at the moment of the mistake, which is the
difference between a rule you wrote down and a rule that holds.

**If you run both:** the command definitions are duplicated on purpose (each harness reads its
own directory), and they drift. `bin/dos-lint.sh` has a `COMMAND-COPY DIVERGENCE` section that
reports it — the two legitimate differences (pi's frontmatter block, harness-specific skill
paths) are normalised away, so anything it reports is real. Fix the stale side; a stale command
re-injects its defect on every run, in one harness only, which is exactly why it's invisible.

```bash
# 1. Node.js 18+ required either way
node --version

# 2a. Claude Code
npm install -g @anthropic-ai/claude-code
claude          # follow the OAuth prompt on first launch

# 2b. pi
npm install -g @earendil-works/pi-coding-agent
pi              # extensions in .pi/extensions/ auto-load from the project directory
```

---

## Phase 1 — Get the framework

Clone this repository (or copy its contents) into the directory you'll work from — e.g. `~/dos/`:

```bash
git clone <this-repo> ~/dos
cd ~/dos
```

Set your locale, once, in your shell profile. The date helpers and scripts default to
Australia/Sydney; the DOS house convention for written dates is DD/MM/YYYY either way:

```bash
export DOS_TZ=America/New_York      # any IANA zone
export DOS_LOCALE=en-US             # affects weekday + tz-abbreviation rendering
export DOS_CALENDAR=primary         # the calendar gcalcli should write to
```

> **Two things this framework does NOT use** (in case you've seen an older layout):
> - **No `DOS/People/` directory.** People are the single source of truth in `Wiki/wiki/people/`.
> - **No `DOS/Memory/` directory.** Cross-session memory is the harness's own per-project
>   auto-memory store (see Phase 7).

---

## Phase 2 — Encode your context (`DOS/CLAUDE.md`)

This is the **highest-leverage edit.** Open `DOS/CLAUDE.md` and fill in the **Standing Context**
block — role, company, stack, reporting lines, guardrails. Every `[placeholder]` is a thing only
you can write.

Pay particular attention to the last guardrail. The default list (reliability-first, low-ego,
metric-driven) is a reasonable general one, but the *domain* guardrail is deliberately blank:
name the place where a quality issue in your world is actually a safety or trust issue.
"Geospatial accuracy is a product safety issue." "PII never leaves the VPC." "Accessibility is a
legal requirement." The assistant will hold you to whatever you write, so make it the one that
actually costs money when it's wrong.

Leave the rest of `DOS/CLAUDE.md` alone at first — the disposition rubric, context-hygiene rules,
layout budgets and operating-mode definitions are the framework, and they work out of the box.
Read them once so you know what the assistant is enforcing; tune later.

Do the same light pass on the **root `CLAUDE.md`** (swap `[Company]` and `[your domain]`) and
**`Wiki/CLAUDE.md`** (already generic — usually no edit needed).

---

## Phase 3 — Seed the Wiki

Create the two index files the Wiki commands expect. Open your agent from the root and paste:

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

`DOS/_templates/` holds the starter shapes; `DOS/_examples/` shows them filled in. To start your
own:

1. **Standing Brief.** Copy `DOS/_examples/Standing Brief.md` to `DOS/Standing Brief.md` and
   replace its contents with your real (minimal) state — role context, this-week TODOs, any
   projects in flight. Keep it small; it loads every session. (See `DOS/CLAUDE.md` § Context
   hygiene for why.)
2. **Battle Board.** Copy `DOS/_templates/Battle-Board.md` to `DOS/Battle-Board.md`. This is the
   one file you'll actually work off all day, so open it in a pinned tab now. **Keep its
   `## Contract` section** — it's what stops the file degrading, and it's what you re-read when
   the board starts drifting.
3. **The cold surfaces.** Copy the rest of `DOS/_templates/` as you need them —
   `Backlog.md` (not-this-week items), `Brag.md` (wins log), `Growth.md` (behaviours in
   development), `Opportunities.md` (org-level theses). None of these load at triage; the
   assistant appends to them without being asked, so read each template's conventions block
   once so you agree with the bar it's applying.
4. **People files.** For each person you work with repeatedly, create
   `Wiki/wiki/people/<name>.md` from `Wiki/wiki/people/_template.md`. The `_examples/` files
   (`sam-chen.md` the manager, `alex-rivera.md` a direct, `jordan-blake.md` a peer EM) show the
   hot/cold split in practice.
5. **Journal.** Nothing to create — `/daily-wrap` writes the first entry to
   `DOS/Journal/[year]/week-[week]/[date].md`.
6. **Delete the seeds.** Once your own files exist, delete `DOS/_examples/` and
   `Wiki/wiki/people/_examples/` so the fictional data never gets mistaken for real context.

---

## Phase 5 — Wire up MCP connectors (optional, high-leverage)

The modes degrade gracefully without integrations (they'll ask you for a manual summary), but
the payoff is real when connected — triage can read your calendar and sweep your issue tracker.

Run from inside your directory so connectors are scoped to the project:

```bash
cd ~/dos

# Claude Code
claude mcp add --transport http google-calendar --scope project https://<your-calendar-mcp>/mcp
claude mcp add --transport http atlassian --scope project https://mcp.atlassian.com/v1/sse
claude            # then /mcp to authenticate each connector

# pi — declare servers in .pi/settings.json, then:
pi                # then /mcp to authenticate
```

Linear, GitHub Issues and the rest have their own MCP servers; the query *shapes* in `/triage`,
`/daily-wrap` and `/weekly-rollup` teach the technique (server-side scoping, explicit field
lists, count-mode) — adapt the project keys and field IDs to your own tracker. See
`Wiki/wiki/process/jira-mcp-usage.md` for the read-only/write posture and the query recipes.

**Two guardrails ship configured, and both need your identifiers:**

- **`.claude/settings.json`** pre-approves the Atlassian *read* tools so triage and wraps don't
  prompt on every call, while every *write* still requires confirmation. It contains no
  account-specific identifiers. Replace the `mcp__atlassian__*` entries if you use a different
  tracker.
- **`.pi/extensions/jira-scope-guard.ts`** has a `CONFIG` block at the top — the Team UUID and
  squad name that scope your company-wide boards, and the board keys themselves. It ships with a
  zeroed UUID, so **the scope check does nothing until you fill it in**. The reason it exists:
  querying a shared board unscoped returned 18× the rows, and the fix belongs *in the JQL*, not
  in a post-filter the model does in context.

> **Never hard-code cloud IDs, account IDs, or project keys into committed config** beyond that
> one CONFIG block. They're account-specific and sensitive — let the connector resolve the rest
> at runtime.

---

## Phase 6 — Understand what will block you

pi's extensions are guardrails, not decoration, and two of them **block**. That's intentional,
and both tell you the fix in the error:

- **`people-file-read-guard`** refuses a whole-file `read` of `Wiki/wiki/people/<name>.md` and
  points at `./bin/section.sh <file> "Next Catchup Agenda" "Open Loops" "Current Focus"`. People
  files run 5–12k tokens each; reading four whole ones is the single biggest avoidable cost in a
  triage. A read with an explicit `offset`/`limit` passes.
- **`jira-scope-guard`** refuses unscoped JQL against your shared boards, and prompts for
  confirmation on every tracker write.

If you find yourself fighting one of these, that's the signal to change the rule in the file,
not to work around it in the moment.

---

## Phase 7 — Memory

Cross-session memory is **the harness's own per-project auto-memory store** — a `memory/`
directory it maintains, with a `MEMORY.md` index auto-loaded into every session. You don't
create it by hand; the assistant writes to it when something is worth remembering across
conversations (durable preferences, who-is-who, project constraints).

Rule of thumb: **durable facts → memory; the dated record → the journal.**

---

## Phase 8 — First-run checklist

```
□ Open the directory with your agent (from ~/dos/: `claude` or `pi`)
□ Confirm the CLAUDE.md files loaded — the assistant should reference both DOS and Wiki
□ On pi: confirm the session-status widget shows today's date and week
□ Run /triage — with the seed examples in place, it should build a battle card and a board
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
pi                   # or: claude
> /triage

# Through the day — stream-of-consciousness into "war room" mode
> had a 1:1 with Alex; she raised the schema-registry blocker again...

# Ingest a document you received
> /wiki-ingest Wiki/raw/docs/architecture-overview.pdf

# Context getting long mid-task? (pi)
> /handoff           # distil the state to .pi/handoffs/
> /pickup            # resume in a fresh, cheap session

# End of day
> /daily-wrap        # writes the journal, updates the Brief, rebuilds the board, commits
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
