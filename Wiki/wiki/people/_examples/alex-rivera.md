<!-- FICTIONAL EXAMPLE — "Acme Rockets" is a made-up company. Delete this _examples/
     directory once you've created your own people files. Nothing here is real. -->
---
title: Alex Rivera
type: people
confidence: high
sources: []
updated: 2026-06-15
---

## Role
Senior Software Engineer, Telemetry team. Reports to me (the EM).

## Scope & Ownership
Owns the ingestion pipeline (the service that parses raw launch-vehicle telemetry into
the time-series store). De-facto reviewer for anything touching the parser. On-call rotation
lead.

## Background
~5 years at Acme Rockets, joined as a mid-level and promoted to Senior last cycle. Deep
domain knowledge of the telemetry format; the person others ask when a parse fails.

## Working Style
Direct, prefers written async over meetings. Will tell you when a plan is wrong — value it.
Goes quiet when overloaded rather than flagging it, so watch capacity actively.

## Current Focus
Splitting the ingestion monolith into per-vehicle-class workers (cross-cycle project,
`[[ingestion-split]]`). Blocking issue: the shared schema registry.

## Relationships
Pairs often with [[jordan-blake]] on schema questions. Mentors the two juniors on the team.

## Key Interactions
*(the 3 most recent only — a 4th moves the oldest to `history/alex-rivera.md`)*

- **2026-06-12 — 1:1.** Raised that the schema-registry dependency is now the critical path
  for the ingestion split; wants me to get the Platform team to commit to a date. Career ask
  restated: *"I want the next step to be scope, not just a title."* → tracked as a growth thread.
- **2026-06-05 — 1:1.** Flagged early signs of on-call fatigue on the team (3 pages in one
  week). We agreed to review the alert-actionability list together next fortnight.
- **2026-05-29 — investigation.** Led the root-cause on the dropped-packets incident; clean
  write-up, pulled a junior in to shadow. Recognition-worthy → logged.

## Strategic Notes
- **Promotion-track:** Senior→Staff is the live question. Evidence is strong on technical
  depth; the gap is org-level influence beyond the team. The ingestion-split project is the
  vehicle to build that evidence — make sure the cross-team coordination is visible.
- Under-flags overload. Treat a quiet Alex as a signal, not as "all fine."

## Next Catchup Agenda
- [ ] Confirm the Platform team's date for the schema registry — I owe them the follow-up.
- [ ] Share the alert-actionability list before the on-call review.

## Open Loops
- [ ] Chase Platform team for a schema-registry commitment date (blocking Alex).

## Notes
Prefers Thursday 1:1s. Keeps a running doc of parser edge-cases worth turning into a wiki page.
