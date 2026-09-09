---
title: Battle Board
type: board
updated: YYYY-MM-DD
regenerated: YYYY-MM-DD
source: DOS/Standing Brief.md § TODOs (the source of truth — this is a lossy view)
reader: donovan-at-speed
---

# Battle Board — Week NN (Mon DD/MM → Fri DD/MM)

*Working surface. Tick in place; done items stay. Contract at the foot of the file.*

> **How to use this template:** copy to `DOS/Battle-Board.md`, delete these two
> instruction blocks, and let `/triage` and `/todos` fill the buckets. Keep the
> `## Contract` section — it is the thing that stops the file degrading, and it is
> re-read whenever the board starts drifting.
>
> The bucket names below are a starting set, not scripture. The load-bearing ones
> are `## ▶ Next` (one item), `## Today` (capped, ordered) and `## Contract`. Drop the rest if they don't
> earn their place in your week.

## ▶ Next

- [ ] <exactly one item: the top line of `## Today`, copied verbatim>

## 🔥 Today — <Weekday DD/MM>

*One-line orientation: what's fixed in the day, where the only real work block is.*

- [ ] <the single highest-priority action, one line, no sub-bullets>
- [ ] <next>

## ⚡ Under 5 — sweep between meetings

*Sub-five-minute items. Exempt from the Today cap; that's the whole point.*

- [ ] <no thinking, no lookup, no decision — just do it>

## 🎯 DELIVER — someone else's deadline

*Multi-session builds with an external due date. Days-remaining in the line.*

- [ ] <deliverable> — due DD/MM (Nd) · next physical step: <step>

## ✅ DO — only you can move it

- [ ] <action-blocked-on-you, actionable this week>

## 👀 Watch, don't chase

*No checkbox. If one of these grows an owner, a venue and a by-when, promote it.*

- <thing being watched>

## 🪤 Live trip-wires (not tasks — see Brief)

- If <named event>, then <action>.

## ✅ Closed <Weekday DD/MM>

*Ticks and voids carried forward at the wrap. Never silently dropped.*

- [x] <completed>
- ⛔ ~~<never owed>~~ — **void**: <why>

---

## 📋 Contract

**Format contract (the reason it stays readable):**
- **One line per item. No sub-bullets, ever.** No why, no how, no quotes.
- If an item needs context, the context lives in `DOS/Standing Brief.md` and the line
  here just names the action.
- **`## ▶ Next` holds exactly one item and it is the first line of the file.** Copy it verbatim
  from the top of `## Today`. It must be startable *now*: not waiting on someone's reply, not
  gated on a meeting that hasn't happened. If the top of Today is a wait, take the highest item
  that isn't. Re-pick it every time the board is touched, including mid-day.
  - **Why it exists:** the cap keeps Today short, but on a long board the first line is still
    the only thing read under pressure. One slot, one action, no scanning.
  - A stale Next is worse than no Next, because it gets acted on without re-reading Today.
- `## Today` is capped at **8 OPEN items**, ordered by priority (ticked/void lines don't
  compete for attention, so they don't count). No P0/P1 tags — order is the priority.
  🔴 only for a hard deadline or someone actually waiting. **Most days have none.**
  - **The cap evicts.** Adding a 9th means naming what leaves and moving it to another bucket
    or voiding it. Appending past the cap is what silently turns an ordered list into an
    unranked one, and then the top line stops meaning anything.
  - **Entry test: can this be done today, given the calendar?** If not, it belongs in DO.
    Today is what you committed to today, not what matters most in the abstract.
- **`## Under 5` is the quick-win lane.** Sub-five-minute items that would otherwise rot
  at the bottom of DELIVER/DO forever, because they're never the most important thing.
  - **Exempt from the Today 8** — that's the whole point; they must not compete with real
    priorities.
  - **Cap ~6.** Swept in gaps: before the first meeting, between meetings, end of day.
  - **Entry test: no thinking, no lookup, no decision.** "Slack X the update" qualifies.
    "Slack X about the thing we haven't decided" does not — that's a real task wearing a
    small hat.
  - **Anti-rot rule: if it survives 3 days here it was never a 5-minute task.** Promote it
    to a real bucket or delete it. A quick-win lane that accumulates is just a second backlog.

**Editing contract — state vs structure:**
- **Edit in place, any time, freely:** tick `[ ]` → `[x]` · `⛔ ~~strike~~` a void item ·
  re-order `## Today` · move an item between buckets · add something that just landed.
  This is a working surface, so **state changes are expected mid-day, not deferred to the wrap.**
- **Never `[x]` something that was never done.** If it turned out not to be owed, or was
  deliberately deferred, strike it and say why. *Done* and *never owed* are different facts,
  and keeping them apart is most of the value of the record.
- **Whole-file rebuild from the Brief happens at the wrap only** (`/todos` rules). That is the
  operation most likely to lose state, so it stays a deliberate,
  regenerate-don't-reconcile action rather than something done ad hoc.
- **Two safety rules that make the pair work:**
  1. A rebuild **carries forward every `[x]` and `⛔`** already on the board — collected into
     `## Closed <day>` at the wrap, never silently dropped. Un-ticking the day is a defect.
  2. Anything added here mid-day **must also reach the Standing Brief** (at the wrap at the
     latest), or the next rebuild deletes it. The Brief is the source of truth; this is a view.
- Mid-day edits are **small and targeted**. Never a whole-file find-and-replace shuffle, and
  re-read the section after editing — a bad splice duplicates lines silently.
