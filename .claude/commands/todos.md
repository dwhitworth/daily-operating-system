# Battle Board

Regenerate (or show) the Battle Board at `DOS/Battle-Board.md`.

**This is the ONE surface the operator works off day to day** (split 01/09/2026 — the battle card became a write-once briefing, the board took the action list). Stable path, no date in the filename, so they keep it pinned. The rich, context-laden source of truth is `DOS/Standing Brief.md` → `## TODOs` — the board is a lossy view of it.

## Process

1. **Read** `DOS/Standing Brief.md` → `## TODOs` (live items) **and `DOS/Backlog.md`** (carried, gated, Watch, Reading, low-priority). **Read both fresh, every time** — never regenerate from a remembered or partial picture. This is one of the two commands that reads the Backlog; keep the board's sections aligned to that split so a live item is never buried under a carried one.
2. **🔴 REBUILD `DOS/Battle-Board.md` WHOLE at the wrap. Mid-day, edit it in place.**

   **The line is STATE vs STRUCTURE, not time of day** (scoped 01/09/2026 — the blanket "never patch" was written when the board was a derived digest nobody edited; it is now the operator's working surface, and "never patch" directly contradicted the every-turn reconcile reminder):
   - **In place, any time:** tick `[ ]` → `[x]` · `⛔ ~~strike~~` a void item · re-order `## Today` · move an item between buckets · add something that just landed. **the operator ticks this file themselves, so state changes are expected mid-day.**
   - **Whole-file rebuild = this command, at the wrap.** Re-deriving every section from the Brief + Backlog is the operation that produced five defects in one pass; keep it deliberate.
   - **A rebuild MUST carry forward every `[x]` and `⛔` already on the board.** Read the current board for tick state before overwriting. Silently un-ticking the operator's day is a defect, not a refresh.
   - **Anything added to the board mid-day must reach the Standing Brief** by the wrap, or the rebuild deletes it. Sweep for board lines with no Brief equivalent and either promote them or flag them.
   - Mid-day edits stay **small and targeted** — never a whole-file find-and-replace shuffle, and re-read the section afterwards (a bad splice duplicated a line on 01/09).
   - **At the wrap: use `Write`, not `Edit`.** Build the new file from the Brief and overwrite. **Do NOT find-and-replace individual lines** across the whole file, and do not reconcile the board against the Brief line-by-line. *(Mid-day is the opposite: targeted `Edit` only.)*
   - **Why this is a hard rule:** patching it produced five distinct defects in a single pass (29/07/2026) — a duplicated item that *contradicted itself* across two sections, a stale line the Brief had already resolved, a missing item, and priority tags that no longer sorted. The board is cheap to rebuild and expensive to reconcile. **When in doubt, throw it away and regenerate.**
   - **🔴 ONE LINE PER ITEM. NO SUB-BULLETS, EVER.** Terse, verb-first, no why/how/quotes/venue (all of that lives in the Brief). This is the rule that keeps the board usable — nesting rationale under a checkbox is exactly what made the old battle card unreadable at 16k chars.
   - **Open with `## Today` — max 8 items, ordered by priority.** No P0/P1 tags; order *is* the priority. 🔴 only for a hard deadline or a person actually waiting. If more than 8 compete, that is a choice to force, not a cap to break.
   - **Then `## ⚡ Under 5 — sweep between meetings` (added 02/09).** Sub-five-minute items route here instead of the bottom of DELIVER/DO, where they rot because they're never the most important thing. **Exempt from the Today 8** — the lane exists so quick wins don't compete with real priorities. Cap ~6. **Entry test: no thinking, no lookup, no decision** ("Slack X the update" yes; "Slack X about the undecided thing" no — that's a real task wearing a small hat). **Anti-rot: anything that survives 3 days here was never a 5-minute task — promote it to a real bucket or delete it**, and say which at rebuild time.
   - **Preserve ticks and void marks that the operator made since the last regeneration.** They tick this file directly. A regeneration that silently un-ticks their work is a defect, so read the current board for `[x]` and `⛔` state before overwriting. *(This is the one exception to "don't reconcile" — carry their marks, rebuild everything else.)*
   - **Items that turned out not to be owed get `⛔ ~~struck~~` and marked void, never `[x]`.** A tick on something never done is a false record that reads as fact months later.
   - **Exclude DONE/✅ items** entirely (they belong in weekly roll-ups).
   - Preserve the Brief's timeframe buckets (Today · Focus/This Week · Active · Watch · Standing · Next 2 Weeks · Time-gated · Reading · Low Priority).
   - **Sort strictly by priority within each bucket** (🔴 → 🟡 → 🟢 → 👁️). Interleaved priorities defeat the entire purpose — the board exists to be scanned in ten seconds.
   - Update the `updated:` **and** `regenerated:` frontmatter dates (a mid-day edit bumps only `updated:`, so a gap between them shows how stale the board is against the Brief).
3. **Report** to the operator: what changed since last generation, and the open-item delta. **Flag if Focus is past ~15 items** — that's the Brief needing a prune (see `/daily-wrap` step 4), not licence for the board to sprawl.

## Rules

- The board is **derived but no longer disposable** — the operator works off it and ticks it directly, so it carries state the Brief does not yet have. It is still not the source of truth. **Structural drift between rebuilds is expected and gets fixed by rebuilding; tick state gets carried forward, never discarded.**
- Don't ask the operator to hand-edit it.
- **If an item looks stale or complete but is still open in the Brief, surface it as a hygiene candidate — don't silently drop it.** ⚠️ And don't mark it done on inference: only the operator knows what happened in rooms Claude wasn't in. Items regularly look dead from the outside and aren't — and vice versa.
- Australian date format (DD/MM/YYYY).
- Keep it to a screen or two. Unscannable = the signal to prune the Brief.
