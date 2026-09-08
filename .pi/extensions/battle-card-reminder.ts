import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync } from "node:fs";
import { join } from "node:path";

// Port of .claude/hooks/battle-card-reminder.sh (UserPromptSubmit hook).
// Reminds the agent to reconcile the Battle Board IN PLACE before doing new
// work. Appended to the per-turn system prompt (ephemeral, not persisted to the
// session) so it fires every turn without bloating history.
//
// Points at DOS/Battle-Board.md, not the dated battle card. The 01/09/2026
// split made the board the single hot surface (stable path, ticked all day) and
// demoted the card to a write-once morning briefing that cannot rot. The date
// helpers the old card-path version needed are gone with it.

function boardPath(cwd: string): string {
  return join(cwd, "DOS", "Battle-Board.md");
}

export default function (pi: ExtensionAPI) {
  pi.on("before_agent_start", async (event, ctx) => {
    const board = boardPath(ctx.cwd);
    if (!existsSync(board)) return; // silent if the board isn't there

    const rel = board.startsWith(ctx.cwd + "/") ? board.slice(ctx.cwd.length + 1) : board;
    const reminder = `\n\n<system-reminder>
The Battle Board (${rel}) is the day's single action surface. Before starting
new work this turn, reconcile it IN PLACE: tick anything completed since the
last turn ([ ] -> [x]), leave done items where they are (do NOT prune them into
a summary), strike-and-mark-void anything that turned out not to be owed (never
[x] something never done), and re-order if priorities moved.

Format contract: ONE LINE PER ITEM, no sub-bullets, no why. Context belongs in
DOS/Standing Brief.md. '## Today' caps at 8.

Today's battle card, if it exists, is a write-once BRIEFING (calendar, agendas,
landmines) and does not need ticking.

If nothing changed, do nothing. (See the *tick-in-place* rule.)
</system-reminder>`;

    return { systemPrompt: event.systemPrompt + reminder };
  });
}
