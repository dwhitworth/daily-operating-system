#!/usr/bin/env bash
# UserPromptSubmit hook: remind Claude to reconcile the Battle Board in place
# before doing new work. Fixes the twice-observed miss (13/08) where the day's
# TODOs never got ticked through the day.
#
# Points at DOS/Battle-Board.md, not the battle card. The 01/09 split made the
# board the single hot surface (stable path, ticked all day) and demoted the
# card to a write-once morning briefing that cannot rot.
board="DOS/Battle-Board.md"
[ -f "$board" ] || exit 0
cat <<REMINDER
<system-reminder>
The Battle Board ($board) is the day's single action surface. Before starting
new work this turn, reconcile it IN PLACE: tick anything completed since the
last turn ([ ] -> [x]), leave done items where they are (do NOT prune them into
a summary), strike-and-mark-void anything that turned out not to be owed (never
[x] something never done), and re-order if priorities moved.

Format contract: ONE LINE PER ITEM, no sub-bullets, no why. Context belongs in
DOS/Standing Brief.md. '## Today' caps at 8.

Today's battle card, if it exists, is a write-once BRIEFING (calendar, agendas,
landmines) and does not need ticking.

If nothing changed, do nothing. (See the *tick-in-place* rule.)
</system-reminder>
REMINDER
exit 0
