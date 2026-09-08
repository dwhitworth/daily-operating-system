<!-- FICTIONAL EXAMPLE — "Acme Rockets" is a made-up company. This shows the shape of a
     Standing Brief in use: the hot, this-week-only operating doc. Copy it to
     DOS/Standing Brief.md, delete DOS/_examples/, and replace with your own.

     Two things to notice, because they're the rules that keep this file usable:
       1. Everything here is THIS WEEK. Not-this-week goes to DOS/Backlog.md — the line is
          timing, not priority. A 🔴 that can't move until next cycle belongs in the Backlog.
       2. One line per live item: the action, the venue, the warning. Rationale lives in the
          journal, with a pointer from here. If an item needs three paragraphs, the
          paragraphs are a journal entry. -->
---
type: standing-brief
updated: 2026-06-15
updated-by: Claude (Chief of Staff)
last-wrap: 2026-06-15
reader: assistant-at-load
---

# Standing Brief

> **What this file is for:** everything needed to **run today** and to **know where to look
> things up**. Three tests for any line: *what do I do · who is this · where do I find the
> detail.* Nothing else earns space. History that no longer routes a decision belongs in
> `DOS/Reference/`, on a wiki page, or in the journal — and this file can point at all three
> for free. **Corrections expire:** keep "was X, now Y" only while someone might still repeat
> the old fact.

## Role Context
**Position:** Engineering Manager, Telemetry team, Acme Rockets
**Manager:** [[sam-chen]] (Director of Engineering) — recurring Thursday 1:1
**Skip-level:** Head of Engineering

## Org Structure
- Telemetry (mine, 4 eng) · Platform ([[jordan-blake]], 5 eng) · Vehicle Software (3 eng)
- Cycle model: 6-week cycles, showcase in the final week. Currently cycle 4 (ends 26 Jun).

## TODOs

### This Week
*(Ordered by deliverable, not recency. DELIVER items first, with days-remaining.
Everything here has an OWNER, a VENUE, and a BY-WHEN — that's the gate.)*

- [ ] **📦 DELIVER — Reliability dashboard v1** · due Fri 26 Jun (11 days) · next step: **finalise the metric list with Alex in Thu 1:1** → see `## Projects in Flight`
- [ ] **Send the first weekly project-channel update** (Sam's ask) · venue: `#telemetry-project` · by Fri
- [ ] Share the alert-actionability list with Alex before the on-call review · venue: Thu 1:1
- [ ] **DELEGATE** — hand the dropped-packets write-up to Alex to turn into a wiki runbook (the handoff, not the work)

## Projects in Flight

### Reliability dashboard v1 — **due Fri 26 Jun**
Cycle goal Sam endorsed on 11/06. Surfaces uptime + change-failure-rate for the telemetry
services on one page.
- [x] Agree the scope with Sam
- [ ] Finalise the metric list (with Alex, Thu 1:1)
- [ ] Wire the first two panels
- [ ] Demo at end-of-cycle showcase

### Ingestion split — **cross-cycle**, no fixed external date
Splitting the ingestion monolith into per-vehicle-class workers. Owned by Alex.
- 🔴 Critical path runs through the **schema registry** (Platform team, Jordan). Not
  controllable by us → see trip-wire below. Sam has offered air cover if it slips.

## Trip-wires
*(If `<named event>`, then `<action>`. No checkbox, no decay — triage fires these on the
one day they're actionable.)*

- *If Jordan gives a schema-registry date (or an explicit "not this cycle") → update the
  ingestion-split critical path and tell Sam whether air cover is needed.*
- *If a third on-call page lands this week → pull the alert-actionability review forward.*
- *If the reliability dashboard slips past Wed 24 Jun → flag in the weekly project update
  early (Sam's "no surprises" rule), don't wait for the deadline.*

## Team
- [[alex-rivera]] — Senior SWE, ingestion pipeline, on-call lead. Senior→Staff track.
- [[jordan-blake]] — peer EM, Platform team (owns the blocking schema registry).

## Open Risks
- Ingestion-split critical path depends on another team's prioritisation (schema registry).

## Upcoming Milestones
| When | What | Who's watching |
|---|---|---|
| Wed 24 Jun | Dashboard slip-point (trip-wire above) | Sam |
| Fri 26 Jun | Reliability dashboard v1 due | Sam |
| w/c 29 Jun | End-of-cycle showcase | Org |

<!-- NOTE: there is deliberately no "👁️ Watch" section here. Demoting an item to Watch and
     leaving it in the Brief saves nothing — it still loads every session. Watch items live in
     DOS/Backlog.md § Watch, which is cold. Move cold; don't just mark cold. -->
