# Claude Code DOS + Wiki Setup Guide

**What this builds:** A monorepo under `~/dos/` containing your Daily Operating System (operational intelligence, battle HQ) and a Wiki (accumulated domain and architectural knowledge), running in Claude Code with MCP connectors for Gmail, Calendar, Slack, and Jira.

---

## Prerequisites

```bash
# 1. Node.js 18+ required
node --version

# 2. Install Claude Code
npm install -g @anthropic-ai/claude-code

# 3. Authenticate (requires Claude Max subscription or Anthropic API key)
claude
# Follow the OAuth prompt on first launch
```

---

## Phase 1 — Directory Structure

```bash
mkdir -p ~/dos/DOS/Journal/2026
mkdir -p ~/dos/DOS/People
mkdir -p ~/dos/DOS/Memory
mkdir -p ~/dos/Wiki/raw/docs
mkdir -p ~/dos/Wiki/raw/links
mkdir -p ~/dos/Wiki/raw/transcripts
mkdir -p ~/dos/Wiki/wiki/architecture/adr
mkdir -p ~/dos/Wiki/wiki/architecture/codebase
mkdir -p ~/dos/Wiki/wiki/domain
mkdir -p ~/dos/Wiki/wiki/people
mkdir -p ~/dos/Wiki/wiki/decisions
mkdir -p ~/dos/Wiki/wiki/process
mkdir -p ~/dos/Wiki/wiki/competitive
mkdir -p ~/dos/.claude/skills
```

Final structure:

```
~/dos/
├── CLAUDE.md                    ← Root: describes both systems
├── .mcp.json                    ← MCP config (auto-generated, don't edit by hand)
├── DOS/
│   ├── CLAUDE.md               ← Operating modes (Triage / War Room / Wrap / etc.)
│   ├── Standing Brief.md       ← Living context doc — read every morning
│   ├── Journal/
│   │   └── 2026/
│   │       └── W20/            ← Week folders as you go
│   ├── People/
│   │   ├── [Person One].md
│   │   ├── [Person Two].md
│   │   └── ...                 ← One file per person
│   └── Memory/
│       ├── MEMORY.md           ← Index of all memory files
│       └── *.md                ← Individual memory entries
└── Wiki/
    ├── CLAUDE.md               ← Wiki operating rules and schema
    ├── index.md                ← Content catalog
    ├── log.md                  ← Append-only ingest log
    ├── raw/                    ← Immutable source material (never edited)
    │   ├── docs/
    │   ├── links/
    │   └── transcripts/
    └── wiki/
        ├── architecture/
        ├── domain/
        ├── people/
        ├── decisions/
        ├── process/
        └── competitive/
```

---

## Phase 2 — Root CLAUDE.md

Create `~/dos/CLAUDE.md`:

```markdown
# Root Context

This directory contains two systems that work together:

- `DOS/` — Daily Operating System. Operational intelligence. Battle HQ.
  Read `DOS/CLAUDE.md` for operating modes.
  Read `DOS/Standing Brief.md` at the start of every session.
  Journal entries live in `DOS/Journal/[year]/[week]/`.
  People context lives in `DOS/People/`.

- `Wiki/` — The wiki. Accumulated domain and architectural knowledge.
  Read `Wiki/CLAUDE.md` for operating rules.
  When a question requires domain, architectural, or institutional knowledge,
  check the Wiki before answering from training data.

## How to use both systems together

- Morning Triage / War Room / Daily Wrap → DOS mode (read Standing Brief + latest journal)
- Domain questions ([your domain]) → Wiki first
- Ingest a new document → Wiki INGEST operation
- Health check the wiki → Wiki LINT operation

## Memory

Persistent memory lives in `DOS/Memory/`. `DOS/Memory/MEMORY.md` is the index.
Read it at the start of each session if relevant context may have been captured previously.
Update it when you learn something worth remembering across sessions.
```

---

## Phase 3 — DOS/CLAUDE.md

Create `~/dos/DOS/CLAUDE.md`:

```markdown
# Daily Operating System

ROLE: Chief of Staff

You are my strategic operating partner. Professional, "strategically paranoid,"
conversational, and pragmatic. Partner in the foxhole, not just an assistant.

---

## Standing Context

**Role:** Engineering Manager, [your team]
**Company:** [Company] — [one-line description of what the company does]
**Stack:** [your stack]

**Direct manager:** [your manager] ([their role])
**Skip-level:** [your skip-level] ([their role])
**CTO:** [CTO name]
**CEO:** [CEO name]

**Guardrails:**
- Platform reliability first. Never compromise uptime for velocity.
- Low-ego culture. Direct comms. No politics.
- DORA metrics (Lead Time, Change Failure Rate) are north stars.
- [Add any domain-specific guardrails, e.g. "Accuracy is a product safety issue — not just a quality issue."]

**People files:** `DOS/People/[name].md` — read before any conversation involving that person.
**Domain knowledge:** Check `Wiki/` before answering domain/architecture questions from training data.

---

## Operating Modes

### MODE 1: MORNING TRIAGE
Trigger: "Let's get it started" or start of a new day's conversation.

Process:
1. Read `DOS/Standing Brief.md` AND the most recent journal entry from `DOS/Journal/[year]/[week]/`.
2. Consolidate outstanding TODOs from previous entries.
3. Ingest today's calendar and task list (from connectors or pasted text).
4. Map meetings vs task load. Flag conflicts or overcommitment.
5. Flag LANDMINES:
   - Political: stakeholder dynamics, team dynamics, leadership expectations
   - Technical: reliability risks, architecture decisions in flight, deadlines
6. RELIABILITY CHECK: Identify risks to platform uptime or data pipeline integrity.
7. Output a prioritised "Battle Card" for the day.

### MODE 2: WAR ROOM
Trigger: Active conversation after triage, or any stream-of-consciousness input.

Behaviour:
- Act as strategist and drafting table.
- Capture everything. Organise silently. Don't interrupt flow.
- Tag inputs against: Reliability/DORA, team ownership, company pillars.
- If I mention a person, note the context for the wrap.
- If I mention a blocker, flag it and suggest an unblock path.
- If I say "wrap it up" or "wrap that up" referring to a TASK or TOPIC,
  summarise that topic and stay in Mode 2.

CRITICAL: Only exit to Mode 3 when I explicitly say "End of Day", "EOD",
"Let's wrap the day", or "Daily wrap".

### MODE 3: DAILY WRAP
Trigger: "End of Day" / "EOD" / "Let's wrap the day" / "Daily wrap"

Output in clean markdown:

---
# Daily Wrap — [Date]

## Executive Summary
**Status:** 🟢 GREEN / 🟡 AMBER / 🔴 RED

[Single paragraph: high-level state and major themes]

## Timeline
- **HH:MM** — [Event]: [Description]

## Projects in Flight
| Project | Status | Owner | Next Milestone |
|---------|--------|-------|----------------|

## Summary & TODOs
[2-3 sentences on state of the bridge]

**TODOs for Tomorrow ([Day]):**
- [ ] [Task]

## Tags
- **#hits:** [Wins]
- **#misses:** [Blockers/Delays]
- **#lookingforward:** [Next steps]
---

After writing the wrap, save it to `DOS/Journal/[year]/[week]/[date].md`.
Then update `DOS/Standing Brief.md` to reflect any project status changes,
new people situations, or resolved/added risks. Update the `updated:` frontmatter date.

### MODE 4: WEEKLY ROLL-UP
Trigger: "Draft the weekly [date] to [date]"

Synthesise the week's daily wraps. Bullet points only. Structure:
- #hits: Top 3 wins
- #misses: Top risk or delay
- #lookingforward: Next week's P1
- The Ask (optional — only if there's a genuine escalation)

### MODE 5: DEEP DIVE
Trigger: "Deep dive on [topic]"

Switch into analytical mode on a specific topic. Structured analysis with
options, tradeoffs, and a recommendation. Check `Wiki/` for relevant context first.
Return to Mode 2 when done.

---

## Style

- Markdown for scannability. Tables for status.
- Use your local date format and timezone (set your conventions here).
- Never let me forget reliability impact.
- Be concise in War Room. Be thorough in Wraps.
- When referencing people, use first names. Read their People file first.
```

---

## Phase 4 — Wiki/CLAUDE.md

Create `~/dos/Wiki/CLAUDE.md`:

```markdown
# Wiki — CLAUDE.md

## Purpose
This is a compounding knowledge base, not a RAG index.
The LLM is the programmer. The wiki is the codebase.
Prefer synthesis over retrieval. Accumulate, don't re-derive.

## Core Operations

### INGEST
Trigger: `ingest <path-to-raw-source>`
1. Read the raw source (never modify it).
2. Identify which wiki pages this source informs or creates.
3. Write or update wiki pages. Be additive; do not delete existing content without explicit instruction.
4. Append to log.md: `[YYYY-MM-DD] INGEST — <source> → <pages affected>`
5. Update index.md if new pages were created.

### QUERY
Trigger: `query <question>`
1. Read index.md to identify candidate pages.
2. Read those pages.
3. Synthesise a direct answer with citations to page paths.
4. Flag confidence: HIGH (dedicated wiki page), MEDIUM (inferred), LOW (not in wiki).

### LINT
Trigger: `lint`
1. Read index.md and verify every listed page exists on disk.
2. Scan wiki/ for pages not in index.md.
3. Scan log.md for ingests older than 90 days — flag for review.
4. Report: orphaned pages, missing pages, stale sources, pages with no log entry.

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
```

---

## Phase 5 — Seed the Wiki

Open Claude Code from the monorepo root and run the init prompt:

```bash
cd ~/dos
claude
```

Then paste this prompt (adjust the domain starter pages to match your own domain):

```
Read Wiki/CLAUDE.md first. Then scaffold the wiki:

1. Create .gitkeep files in all empty Wiki/ subdirectories so git tracks them.

2. Create Wiki/index.md with an empty table:
   | Page | Type | Confidence | Last Updated | Summary |
   |------|------|------------|--------------|---------|

3. Create Wiki/log.md with:
   # Wiki Ingest Log
   [TODAY'S DATE] INIT — Wiki scaffolded. No sources ingested yet.

4. Create these starter pages with correct frontmatter and a one-sentence
   placeholder body (confidence: speculative for all):
   - Wiki/wiki/architecture/overview.md
   - Wiki/wiki/domain/[domain-topic-1].md
   - Wiki/wiki/domain/[domain-topic-2].md
   - Wiki/wiki/domain/[domain-topic-3].md
   - Wiki/wiki/process/eng-culture.md
   - Wiki/wiki/process/onboarding.md
   - Wiki/wiki/competitive/overview.md

5. Create Wiki/wiki/architecture/adr/ADR-000-template.md with:
   ---
   title: ADR-000 — [Decision Title]
   type: architecture
   confidence: high
   sources: []
   updated: [date]
   ---
   ## Status
   ## Context
   ## Decision
   ## Consequences

6. Create Wiki/wiki/people/_template.md with the people page schema.

7. Update Wiki/index.md and Wiki/log.md for every file created.

Confirm when done with a list of all files created.
```

---

## Phase 6 — Seed the DOS

### Standing Brief

Create `~/dos/DOS/Standing Brief.md` — start minimal, build it up:

```markdown
---
type: standing-brief
updated: 2026-05-20
updated-by: Claude (Chief of Staff)
---

# Standing Brief

## Role Context
**Position:** Engineering Manager, [your team]
**Start date:** [your start date]
**Manager:** [your manager] ([their role])
**Skip-level:** [your skip-level] ([their role])

## Org Structure
[Fill in as you learn it]

## Projects in Flight
[Fill in from onboarding — first entries from Week 1]

## Team
[Fill in as you meet people — link to People/ files]

## Open Risks
[Fill in as they surface]

## Upcoming Milestones
[Fill in from sprint/roadmap]
```

### People Files

Copy any existing people notes you have into `~/dos/DOS/People/` — one markdown file
per person (manager, skip-level, directs, key cross-functional stakeholders). Use the
`Wiki/wiki/people/_template.md` schema as a starting point. Once they're in `DOS/People/`,
they're read automatically whenever a conversation involves that person.

### Memory

Create `~/dos/DOS/Memory/MEMORY.md`:

```markdown
# Memory Index

_Entries added as context accumulates. Each entry links to a memory file._
```

---

## Phase 7 — MCP Connectors

Run these from inside `~/dos/` to scope them to the project. Replace the
endpoint URLs with the real endpoints for the MCP servers you use — the URLs below
are placeholders showing the command shape:

```bash
cd ~/dos

# Gmail
claude mcp add --transport http gmail --scope project https://<your-gmail-mcp-endpoint>/mcp

# Google Calendar
claude mcp add --transport http google-calendar --scope project https://<your-calendar-mcp-endpoint>/mcp

# Slack (if your org uses Slack)
claude mcp add --transport http slack --scope project https://<your-slack-mcp-endpoint>/mcp

# Jira / Confluence (Atlassian's hosted MCP endpoint is public and shown below)
claude mcp add --transport http atlassian --scope project https://mcp.atlassian.com/v1/sse
```

Then authenticate each one inside Claude Code:

```bash
claude   # launch from ~/dos/
/mcp     # opens the MCP authentication panel — auth each connector
```

This writes a `.mcp.json` to `~/dos/`. Connectors are only active when Claude Code is launched from inside this directory.

> **Note on identifiers:** Once authenticated, tools like the Atlassian connector
> operate against your own cloud ID, account ID, and project keys. Never hard-code
> these into committed config or docs — they are account-specific and sensitive.
> Let the connector resolve them at runtime (e.g. `<YOUR_CLOUD_ID>`,
> `<your-account-id>`, `<YOUR_PROJECT_KEY>` are the kinds of values that should
> stay out of version control).

---

## Phase 8 — Wiki Skills as CLI Tools

These are optional but turn the wiki into something you can drive from a single command. Create three scripts:

### `~/dos/.claude/skills/wiki-ingest.sh`

```bash
#!/bin/bash
# Usage: wiki-ingest.sh <path-to-source>
# Tells Claude Code to run an INGEST operation on the given file.
SOURCE="$1"
if [ -z "$SOURCE" ]; then
  echo "Usage: wiki-ingest <path-to-source>"
  exit 1
fi
echo "ingest $SOURCE"
```

### `~/dos/.claude/skills/wiki-lint.sh`

```bash
#!/bin/bash
# Usage: wiki-lint.sh
# Tells Claude Code to run a LINT operation on the wiki.
echo "lint"
```

### `~/dos/.claude/skills/wiki-query.sh`

```bash
#!/bin/bash
# Usage: wiki-query.sh "your question here"
QUESTION="$1"
if [ -z "$QUESTION" ]; then
  echo "Usage: wiki-query \"your question\""
  exit 1
fi
echo "query $QUESTION"
```

Make them executable:

```bash
chmod +x ~/dos/.claude/skills/*.sh
```

Register them as MCP servers:

```bash
cd ~/dos

claude mcp add --transport stdio wiki-ingest --scope project \
  -- ~/dos/.claude/skills/wiki-ingest.sh

claude mcp add --transport stdio wiki-lint --scope project \
  -- ~/dos/.claude/skills/wiki-lint.sh

claude mcp add --transport stdio wiki-query --scope project \
  -- ~/dos/.claude/skills/wiki-query.sh
```

---

## Phase 9 — Shell Setup

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# DOS — launch Claude Code from the monorepo root
alias dos='cd ~/dos && claude'

# Quick wiki operations without opening a full session
alias wiki-ingest='cd ~/dos && claude --print "ingest $1"'
alias wiki-lint='cd ~/dos && claude --print "lint"'
```

Reload:

```bash
source ~/.zshrc
```

Now `dos` opens your full environment. Every session starts with both DOS and Wiki in scope.

---

## Phase 10 — First Run Checklist

```
□ Run: dos
□ Verify CLAUDE.md files are loaded (Claude should reference both DOS and Wiki in first response)
□ Say: "Let's get it started" — confirm Morning Triage mode runs correctly
□ Say: "Deep dive on [a domain topic]" — confirm Claude reads the matching Wiki/wiki/domain/ page
□ Drop a raw document into Wiki/raw/docs/ and say: "ingest Wiki/raw/docs/[filename]"
  → Confirm a wiki page is created and index.md + log.md are updated
□ Say: "lint" — confirm health check runs and returns a clean report
□ Say: "EOD" — confirm Daily Wrap is written to DOS/Journal/
□ Confirm DOS/Standing Brief.md is updated after the wrap
□ Run /mcp — confirm all connectors are authenticated and responding
```

---

## Day One Usage Pattern

```bash
# Morning
dos
> Let's get it started

# Drop a document you received
> ingest Wiki/raw/docs/architecture-overview.pdf

# Mid-session domain question
> query [a question about your domain]

# End of day
> EOD
```

---

## What you have when this is done

- A single `claude` session from `~/dos/` that knows both your operational context (DOS) and your accumulated knowledge base (Wiki)
- MCP connectors for Gmail, Calendar, Slack, Jira
- A wiki that compounds from day one — every doc you receive, every decision you make, every 1:1 you run becomes a wiki page
- People files live in DOS/People/ and are read automatically when conversations involve those individuals
- Shell alias `dos` — one command to open your full environment
- Daily wraps written to Journal automatically, Standing Brief updated after every wrap
