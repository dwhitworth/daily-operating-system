# TODO Board

Regenerate (or show) the human-readable TODO digest at `DOS/TODO-Board.md`.

This is the scannable view you read when you want a quick human pass over outstanding work. The rich, context-laden source of truth is `DOS/Standing Brief.md` → `## TODOs` — the board is a lossy view of it.

## Process

1. **Read** `DOS/Standing Brief.md` → `## TODOs` (live items) **and `DOS/Backlog.md`** (carried, gated, Watch, Reading, low-priority). **Read both fresh, every time** — never regenerate from a remembered or partial picture. This is one of the two commands that reads the Backlog; keep the board's sections aligned to that split so a live item is never buried under a carried one.
2. **🔴 REWRITE `DOS/TODO-Board.md` WHOLE — never patch it.**
   - **Use `Write`, not `Edit`.** Build the new file from the Brief and overwrite. **Do NOT find-and-replace individual lines**, and do not reconcile the existing board against the Brief line-by-line.
   - **Why this is a hard rule:** patching it produced five distinct defects in a single pass — a duplicated item that *contradicted itself* across two sections, a stale line the Brief had already resolved, a missing item, and priority tags that no longer sorted. The board is cheap to rebuild and expensive to reconcile. **When in doubt, throw it away and regenerate.**
   - One line per **open** item — terse, verb-first, no why/how (that lives in the Brief).
   - **Exclude DONE/✅ items** entirely (they belong in weekly roll-ups).
   - Preserve the Brief's timeframe buckets (Focus/This Week · Active · Watch · Standing · Next 2 Weeks · Time-gated · Reading · Low Priority).
   - **Sort strictly by priority within each bucket** (🔴 → 🟡 → 🟢 → 👁️). Interleaved priorities defeat the entire purpose — the board exists to be scanned in ten seconds.
   - Update the `generated:` frontmatter date.
3. **Report**: what changed since last generation, and the open-item delta. **Flag if Focus is past ~15 items** — that's the Brief needing a prune (see `/daily-wrap` step 4), not licence for the board to sprawl.

## Rules

- The board is **derived and disposable** — it exists only because it's easier to read than the Brief. Never treat it as the source of truth. **It's expected to drift between regenerations; the answer is always to regenerate, never to patch.**
- Don't ask for the board to be hand-edited.
- **If an item looks stale or complete but is still open in the Brief, surface it as a hygiene candidate — don't silently drop it.** ⚠️ And don't mark it done on inference: only you know what happened in rooms Claude wasn't in. Items regularly look dead from the outside and aren't — and vice versa.
- Use a consistent date format (DD/MM/YYYY).
- Keep it to a screen or two. Unscannable = the signal to prune the Brief.
