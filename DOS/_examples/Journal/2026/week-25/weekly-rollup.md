<!-- FICTIONAL EXAMPLE — "Acme Rockets" is a made-up company. This is what a Weekly Roll-up
     looks like. Real ones live at DOS/Journal/[year]/week-[week]/weekly-rollup.md.
     Delete DOS/_examples/ when you adopt. -->
# Weekly Roll-up — Week 25, Mon 15 – Fri 19 Jun 2026

## #hits
- Reliability dashboard v1 scope locked and endorsed by Sam; first two panels wired (on track for the 26 Jun demo).
- 4 telemetry tickets landed this week, including the dropped-packets runbook Alex turned around from last week's incident.
- Alert-actionability list reviewed with Alex — trimmed 3 noisy alerts; on-call pages dropped from 3 last week to 1.

## #misses
- Ingestion split still can't start its critical path — the schema registry (Platform) has no committed date.

## #lookingforward
- Next week's P1: finalise the dashboard for the end-of-cycle demo.
- Get a concrete schema-registry date from Jordan, or invoke Sam's air-cover offer.

## The Ask
*(Optional — only if there's a genuine escalation that needs your manager's air cover)*
- If Jordan can't commit a schema date by mid-week, ask Sam to raise it Director-to-Director.

---

## 📤 Project channel updates — PASTE-READY
*(Manager's ask: update the project channel weekly so nothing goes into a void — the point is
that when you need to overflow, it isn't a surprise. Rewrite for the channel, strip all internal reads.)*

**One block per live multi-cycle project. 3–5 lines each. Written for the channel, not for you.**

### #telemetry-project — Reliability dashboard v1
> Dashboard v1 is on track for the end-of-cycle demo (26 Jun). Uptime and change-failure-rate
> panels are wired; metric list is locked. No blockers on our side.

### #telemetry-project — Ingestion split
> Design is ready and the team is set to start. We're waiting on a date for the shared schema
> registry from Platform — flagging early: if that slips past next week, the split likely runs
> into the following cycle. Not a surprise, just visibility.
