import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { existsSync } from "node:fs";
import { dosDate, battleCardPath } from "./lib/dos-dates.ts";

// Session-start status widget.
//
// Removes the "what day is it / did I triage yet / is a card already open?"
// friction. On session start (and reload) it renders a small widget above the
// editor with: the local date + ISO week, whether today's battle card exists, and
// a Monday -> /weekly-scan nudge. Fire-and-forget; no tokens, no history.

function render(cwd: string): string[] {
  const d = dosDate();
  const cardExists = existsSync(battleCardPath(cwd, d));

  const lines = [
    `DOS · ${d.weekday} ${d.au} (${d.tz}) · week ${d.week}`,
    cardExists
      ? `Battle card: exists ✓`
      : `Battle card: not yet — run /triage to start the day`,
  ];
  if (d.isMonday) lines.push(`Monday → run /weekly-scan before consolidating TODOs`);
  return lines;
}

export default function (pi: ExtensionAPI) {
  const update = (ctx: ExtensionContext) => {
    if (!ctx.hasUI) return; // no-op in print/json
    ctx.ui.setWidget("dos-status", render(ctx.cwd));
  };

  pi.on("session_start", async (_event, ctx) => update(ctx));
  // Refresh after a day rolls over or a card gets created mid-session.
  pi.on("agent_settled", async (_event, ctx) => update(ctx));
}
