import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { existsSync } from "node:fs";
import {
  dosDate,
  DOS_TZ,
  battleCardPath,
  journalEntryPath,
  weekDir,
  relTo,
} from "./lib/dos-dates.ts";

// `today` tool — one call returns every date/path the DOS routinely shells out
// to `date` for: the local ISO + human date, ISO week, the week folder, today's
// battle-card and journal-entry paths, whether it's Monday (the /weekly-scan
// trigger), and whether the battle card already exists. Avoids repeated `date`
// calls and day/month-order mistakes. Zone + format come from DOS_TZ / DOS_LOCALE.

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "today",
    label: "Today (DOS)",
    description:
      `Return today's DOS date context (${DOS_TZ}): ISO + local-format date, ` +
      "ISO week, week folder, battle-card + journal-entry paths, isMonday, and " +
      "whether today's battle card exists yet. Use at the start of triage/wrap " +
      "instead of shelling out to `date`.",
    parameters: Type.Object({}),
    async execute(_id, _params, _signal, _onUpdate, ctx) {
      const d = dosDate();
      const card = battleCardPath(ctx.cwd, d);
      const journal = journalEntryPath(ctx.cwd, d);

      const info = {
        weekday: d.weekday,
        dateAU: d.au, // DD/MM/YYYY (DOS house convention)
        dateISO: d.iso, // YYYY-MM-DD
        isoWeek: d.week,
        timezone: d.tz,
        isMonday: d.isMonday,
        weekDir: relTo(ctx.cwd, weekDir(ctx.cwd, d)),
        battleCardPath: relTo(ctx.cwd, card),
        battleCardExists: existsSync(card),
        journalEntryPath: relTo(ctx.cwd, journal),
        journalEntryExists: existsSync(journal),
        weeklyScanDue: d.isMonday,
      };

      const summary =
        `${d.weekday} ${d.au} (${d.tz}), ISO week ${d.week}. ` +
        `Battle card: ${info.battleCardExists ? "exists" : "not yet"} ` +
        `(${info.battleCardPath}).` +
        (d.isMonday ? " Monday -> run /weekly-scan before consolidating TODOs." : "");

      return {
        content: [{ type: "text", text: summary }],
        details: info,
      };
    },
  });
}
