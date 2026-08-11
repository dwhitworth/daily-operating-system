<!-- FICTIONAL EXAMPLE — "Acme Rockets" is a made-up company. This shows the shape of a
     Standing Brief in use: the hot, this-week-only operating doc. Copy it to
     DOS/Standing Brief.md, delete DOS/_examples/, and replace with your own. -->
---
type: standing-brief
updated: 2026-06-15
updated-by: Claude (Chief of Staff)
---

# Standing Brief

## Role Context
**Position:** Engineering Manager, Telemetry team, Acme Rockets
**Manager:** Sam Chen (Director of Engineering) — recurring Thursday 1:1
**Skip-level:** Head of Engineering

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
Cycle goal Sam endorsed on 06-11. Surfaces uptime + change-failure-rate for the telemetry
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

## 👁️ Watch
*(No action exists yet. Creates no obligation — do not surface as a TODO.)*

- On-call fatigue on the Telemetry team (3 pages in one week, flagged 06-05). Watching whether
  it recurs before deciding it's a pattern worth a structural fix.

## Team
- [[alex-rivera]] — Senior SWE, ingestion pipeline, on-call lead. Senior→Staff track.
- [[jordan-blake]] — peer EM, Platform team (owns the blocking schema registry).

## Open Risks
- Ingestion-split critical path depends on another team's prioritisation (schema registry).
