# Gemini prompt — generate the "DOS + Wiki" Google Slides deck

Paste the block below into Gemini (Gemini app, or the Gemini side panel in Google Slides).
It's written as a single self-contained brief: audience, narrative, per-slide content, and
design direction. After it generates, use the follow-up prompts at the bottom to refine.

> **Note on the numbers:** the metrics in this deck (319 checkboxes, 64k-token Brief,
> 144k-token triage, 48.5k-char people file, ~2–4k-char target) are real measurements from
> the system's own history and are the emotional core of the story — keep them exact.

---

## THE PROMPT (copy everything below this line)

You are helping me build a Google Slides presentation. Create a ~14-slide deck. I'll give you
the audience, the story, and the exact content for every slide. Match it closely — this is a
real system I built and the specifics matter.

### Audience & tone
Audience: my peers and professional network — a "look what I built" show-and-tell (not a sales
pitch, not a formal conference talk). Tone: concrete, personal, a little wry, engineer-to-engineer.
Lead with a real problem and real numbers, not with architecture. Confident but not grandiose.

### What the thing is (context for you, don't put this verbatim on a slide)
It's a file-based "operating system for the engineering-management job" that runs inside a terminal
coding agent (Claude Code or pi). There's no app — the "software" is markdown instruction files
(`CLAUDE.md`), slash-command process definitions, file conventions, and a set of shell scripts and
agent extensions that enforce the conventions at the moment they'd otherwise be broken. Two coupled systems: **DOS/**
(daily operational loop — triage, war-room, wrap) and a **Wiki/** (a compounding knowledge base
where people and domain context accumulate). The value is a set of hard-won disciplines, each one
a scar from a specific failure.

### Design direction
- Clean, modern, high-contrast. Dark or near-dark background with one accent color. Large type.
- One idea per slide. Minimal words on the slide; put detail in the speaker notes.
- Use the speaker-notes field for the 2–4 sentences I'd actually say out loud on each slide.
- Where I describe a diagram or table, build it as a real slide element (SmartArt/table/shapes),
  not a paragraph.
- Consistent visual system across all slides (same fonts, accent, spacing).
- Monospace font for anything that represents a file, command, or code.

### The slides (build these in order)

**Slide 1 — Title.**
Title: "A Daily Operating System for the management job." Subtitle: "Built in Claude Code — no app,
just markdown and discipline." Small footer: my name + "open source, MIT."
Speaker notes: one line — "This is the system I run my week on; here's how it works and why."

**Slide 2 — The problem (open on the pain).**
Headline: "The management job lives in your head — until it doesn't fit." Four bullets:
- Notes rot; you re-derive the same context every week.
- Every observation becomes a to-do. The list gets long AND wrong.
- The tool that's supposed to help drowns in its own accumulated context.
- The real deliverables end up buried under conversational residue.
Speaker notes: set up that these aren't hypotheticals — I measured all four.

**Slide 3 — The numbers (make the pain concrete).**
Headline: "I measured it. It was worse than it felt." Four big stat callouts (large number + small label):
- **319** — open checkboxes across brief + backlog + people files, on one day.
- **64k tokens** — size the "standing brief" reached (5× growth in 3 weeks).
- **~144k tokens** — loaded by a single morning triage *before doing any work*.
- **15.2k chars** — one 1-hour 1:1 written up as a single note (a second copy of the meeting).
Speaker notes: "The list was long and wrong at the same time. This is what triggered the redesign."

**Slide 4 — The one-line idea.**
Big centered statement: "The LLM is the programmer. Markdown files are the codebase." Sub-line:
"No application to run. The software is the prompts, the file conventions, and the discipline they encode."
Speaker notes: explain there's nothing to install for me to 'use' it — it's instruction files an
agentic CLI loads automatically.

**Slide 5 — Architecture (one diagram).**
Headline: "Two systems that work together." A simple two-box diagram:
- Box 1: **DOS/** — "Operational intelligence. The daily loop." (triage · war room · wrap · roll-up)
- Box 2: **Wiki/** — "Compounding knowledge. People + domain context that accumulates."
Below both, a thin bar: "Driven by CLAUDE.md instruction files + slash commands + shell-script lints + agent extensions that block the expensive mistake."
Speaker notes: DOS is what I do today; the Wiki is what I know, and it gets smarter every week.

**Slide 6 — The daily loop.**
Headline: "The loop." A horizontal flow: **Morning Triage → War Room (all day) → Daily Wrap**, with a
second row below showing the hygiene layers: **Weekly Scan · Weekly Roll-up · Monthly Lint**.
One-liners under each: Triage = "reads calendar + tracker, builds a battle card." War Room = "stream of
consciousness in; it captures, flags, drafts." Wrap = "journals the day, updates state, commits."
Speaker notes: the point is I never have to *remember* to do the bookkeeping — the modes pull it.

**Slide 7 — Key idea 1: the disposition rubric.**
Headline: "What earns a checkbox." The core rule, large: "A task needs an OWNER, a VENUE, and a
BY-WHEN. Missing any one → it's not a task." Below, a compact table of the 6 dispositions:
DELIVER / DO / DELEGATE / ASK / WATCH / NOTE — with a one-word "checkbox? ✅/❌" column (first four ✅,
last two ❌). Footer line: "The question is never 'is this important?' — everything is. It's 'who
moves next, and what unblocks it?'"
Speaker notes: this one rule is what killed the 319-checkbox problem.

**Slide 8 — Key idea 2: hot/cold context hygiene.**
Headline: "Keep the hot files small." Two columns: **HOT** ("loaded every session — brief, latest
journal, today's people") vs **COLD** ("read on demand by a named command — backlog, history, archives").
Pull-quote, prominent: "A lint that loads 60k tokens to complain about file sizes is the problem
wearing a lab coat." Small line: "Two costs: compaction AND latency — editing a big hot file busts
the prompt cache."
Speaker notes: this is the fix for the 64k / 144k blow-up on slide 3.

**Slide 9 — Key idea 3: trip-wires.**
Headline: "Not-ignored, without on-the-list." Big format example: "**If** ‹named event› **then** ‹action›."
Sub-bullets: "No checkbox. No decay. No guilt." / "Triage reads the calendar + board, so it fires the
trip-wire on the one day it's actionable." / "Beats a checkbox that surfaces on 40 wrong days and gets skimmed."
Speaker notes: give the example "if a senior hiring round gets scheduled, re-read the decision rule."

**Slide 10 — The supporting doctrine (one fast slide).**
Headline: "The rest of the scar tissue." Four tight bullets:
- **Verify before asserting** — never state an inference in the register of a fact.
- **Write less than you think** — a 1:1 write-up is ~2–4k chars, not a transcript.
- **Publish, don't just author** — a doc someone else must act on isn't done while it's private.
- **Recognition is pulled, not remembered** — the system surfaces who to acknowledge.
Speaker notes: each of these is also a failure I hit and encoded so I wouldn't repeat it.

**Slide 11 — Live-ish walkthrough.**
Headline: "What it actually looks like." Show a mock terminal / monospace block of a session:
```
> /triage
  Battle Card — Mon 15 Jun
  📦 DELIVER  Reliability dashboard v1 · 11 days · next: metric list w/ Alex (Thu 1:1)
  ⚡ Trip-wire armed: if Platform commits a schema date → update critical path
...
> /daily-wrap
  ✅ journal written · Brief 42k→39k chars · 1 people-file updated · committed
```
Speaker notes: mention this runs against a fictional "Acme Rockets" seed that ships with the repo, so
anyone can try it without my real data.

**Slide 12 — Results (the payoff).**
Headline: "Before → after." A small before/after table:
| | Before | After |
| Standing brief | 64k tokens | held ≤ 60k, actively pruned |
| Triage load | ~144k tokens | brief + latest journal + only today's people |
| Open checkboxes | ~319 | small, gated list — the rest are trip-wires/notes |
| 1:1 write-up | up to 15.2k chars | ~2–4k char budget |
Speaker notes: the system stopped compacting mid-task, and the real deliverables stopped getting buried.

**Slide 13 — How it generalises.**
Headline: "It's not really about engineering management." A two-column mapping table (EM concept →
generalises to): direct reports → anyone you work with repeatedly · sprint board → your unit-of-work
tracker · 1:1 prep → any recurring meeting · weekly roll-up → any status you owe upward · the Wiki →
any compounding knowledge base. Footer: "Keep the loop; re-label the nouns."
Speaker notes: researchers, founders, PMs, consultants — same underlying needs.

**Slide 14 — Open source + try it.**
Headline: "It's open source." Bullets: "MIT licensed on GitHub." / "Ships scaffolding + a fictional
seed — clone it, fill in your context, run /triage." / "Keep your real repo private; share the method,
not the content." Big call-to-action line for the repo link (leave a placeholder ‹repo URL›).
Small credit line: "Wiki layer follows Andrej Karpathy's 'LLM Wiki' pattern; the DOS layer is my own."
Speaker notes: close on "happy to walk anyone through standing up their own."

### After you build it
Give me the deck, then tell me: (1) which slides are the weakest and why, (2) where a diagram would
land better than bullets, and (3) two alternative titles for slide 1.

---

## Follow-up prompts (use after the first generation)

- "Tighten every slide to a 6-word headline and move the rest to speaker notes."
- "Slide 5 and 6 are too text-heavy — rebuild them as real diagrams using shapes/SmartArt."
- "Make the stat callouts on slide 3 the visual anchor of the whole deck — big numbers, small labels."
- "Generate a 30-second version: which 5 slides survive?"
- "Draft what I'd say out loud for slides 2, 3, and 7 as if presenting live, ~30 seconds each."
