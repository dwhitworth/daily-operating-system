<!-- Person-page schema. Copy to Wiki/wiki/people/<lowercase-kebab-name>.md.

     🔴 The section ORDER matters, because it encodes the hot/cold split. Everything in this
     file is HOT: it is read at every triage where the person has a meeting, and re-read before
     every 1:1 with them. Anything that is written often but read rarely goes to
     Wiki/wiki/people/history/<same-name>.md instead — see the note at the foot.

     Budget: keep the live file under ~30k chars. Over that, `/wiki-lint` will flag it and the
     next wrap should do a history pass. A file that outgrows its budget buries its own good
     facts; the cost is attention, not disk. -->
---
title: [Full Name]
type: people
confidence: speculative
sources: []
updated: YYYY-MM-DD
# Optional: link to the shared 1:1 doc, so /prep and /manager-1-1 can cite it.
# Their pre-filled AGENDA items there are excellent prep. Their pre-filled SENTIMENT is
# theirs — never read it, never use it as a signal, never write it.
shared-1-1-doc:
---

## Role
[Title, team, reporting line]

## Scope & Ownership
[What they own, what they decide on, key responsibilities]

<!-- Role and Scope are ORG-DERIVED: a retitle, a new domain or a team split falsifies them the
     day it happens, and they rot silently because the bottom of the file churns daily while the
     top doesn't. bin/wiki-lint.sh dates these two sections separately for exactly that reason. -->

## Background
[Prior experience, tenure at the company, relevant expertise]

## Working Style
[Communication preferences, decision-making style, things to know when collaborating.
BEHAVIOURAL, so a reorg doesn't invalidate it — an old date here is usually still correct.]

## Current Focus
[Active initiatives, projects, priorities]

## Next Catchup Agenda
<!-- The ASK queue: questions and items queued for the next conversation with this person.
     Capped at ~5 open items. Overflow goes to a `## Parked asks` sub-block in this file —
     visible when the file is read, not surfaced at triage.

     Decay rule: an ask that survives three catchups un-raised was never load-bearing. Drop
     it, or promote it to a `## Strategic Notes` line if it turns out to be a pattern. Never
     auto-delete — /weekly-scan surfaces it as "these three keep not coming up, kill or park?"
     and the operator calls it.

     TWO CLASSES, OPPOSITE MECHANICS. Tag every line with one:

       ASK   — you want to put something to them. DISCHARGED by the meeting happening.
               No prep debt. This is the queue described above.

       OWED  — they asked YOU for something. BLOCKED by the meeting happening; the slot
               exposes the debt rather than clearing it. The answer has to exist BEFORE
               the slot, so it must also be a task on DOS/Standing Brief.md with an owner
               and a by-when.

     OWED lines carry two extra tags, and they are what make a debt visible before its venue:

       size   — the honest time to finish it: `5m`, `30m`, or `block` (needs a protected block).
       since  — DD/MM, the date the debt was incurred, NOT the date you wrote it down.

     Format:  - [ ] **OWED · `30m` · since DD/MM —** [what they asked for]

     Why bother: importance without a date always loses to whatever is loudest that morning,
     so DERIVE the date instead of inventing one. The next 1:1 is the real deadline and the
     calendar already holds it — /triage looks 5 working days ahead and compares each debt's
     size against the working time left before its slot. A `block` item found with two days
     left is a different problem from a `5m` item found the same morning, and the size tag is
     the only thing that separates them.

     Age is the backstop for debts to people you have no recurring slot with (peer managers,
     stakeholders, projects): over 14 days by its `since` date, it goes on the board's Today
     regardless of the calendar. Without that, those debts are invisible until someone asks
     again. -->
- [ ] [thing to raise next time you talk]

## Relationships
[Who they work closely with — link to other people pages with [[name]]]

## Key Interactions
<!-- Dated log of significant conversations, meetings, observations. Newest first.

     🔴 KEEP THE 3 MOST RECENT HERE. Adding a 4th? Move the oldest to
     history/<name>.md in the same edit. The rule only works if the move is part of the write.

     Budget per 1:1: ~2–4k chars. An hour of conversation transcribes to 7–8k words and yields
     maybe 5–8 things worth keeping for a year. If a write-up is over ~6k, something
     non-durable got in. Reformatting a transcript is not synthesis.

     What earns space: facts about the person (what they want, what worries them, what they
     committed to) · load-bearing verbatim quotes, ONE LINE not a paragraph · anything that
     changes what happens next.

     What does not: commentary on the analysis itself · pre-empting objections nobody raised ·
     the same finding restated in three registers · narrating the meeting's shape · emphasis
     inflation (if every third line is bold, none of it ranks). -->

### DD/MM/YYYY — [what it was]
- [the durable fact]

## Strategic Notes
[Patterns, risks, opportunities, watch-outs. Multi-month watch-fors that never "complete" —
so they live here rather than as a TODO, and surface when relevant to the conversation.]

## Open Loops
<!-- ONLY action-blocked-on-the-operator items specific to this person, e.g. "Schedule first
     1:1". Questions to ask them go to `## Next Catchup Agenda`. Anything with a due date and
     a venue goes to DOS/Standing Brief.md. Anything not-this-week goes to DOS/Backlog.md. -->
- [ ] [outstanding action involving this person]

## Notes
[Other context worth remembering]

<!-- ─────────────────────────────────────────────────────────────────────────────────────────
     COLD — lives in Wiki/wiki/people/history/<same-kebab-name>.md, never here:

       ## Key Interactions   — everything older than the 3 most recent
       ## Recognition Log    — the full log. One line per recognition given or opportunity
                               surfaced: `[DD/MM/YYYY] <what> → <avenue> (given / queued)`.
                               Written often, read at performance-review time, so it must
                               never load at triage. One grew to 13k chars while loading
                               every morning for no operational reason.

     `/prep` and `/manager-1-1` are the commands allowed to read history. Triage never does.
     Don't leave a duplicate `## Recognition Log` heading in the live file — append straight
     to history. Duplicate H2s split the record silently, and one file accumulated six.
     ───────────────────────────────────────────────────────────────────────────────────────── -->
