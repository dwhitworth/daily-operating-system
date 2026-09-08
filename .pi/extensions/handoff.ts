import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { existsSync, mkdirSync, readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

// /pickup — resume from a handoff in a fresh, low-token session.
//
// Pairs with the /handoff prompt template (which WRITES a handoff to
// .pi/handoffs/). /pickup READS one and seeds a brand-new session with it, so
// the bloated session is dropped and work continues with just the distilled
// context.
//
//   /pickup            resume from the most recent handoff
//   /pickup list       list available handoffs and choose one
//   /pickup <fragment> resume from the newest handoff whose filename matches
//
// Named /pickup (not /resume) so it doesn't shadow pi's built-in /resume
// session switcher.

const HANDOFF_DIR = ".pi/handoffs";

function listHandoffs(cwd: string): string[] {
  const dir = join(cwd, HANDOFF_DIR);
  if (!existsSync(dir)) return [];
  return readdirSync(dir)
    .filter((f) => f.startsWith("handoff-") && f.endsWith(".md"))
    .sort()
    .reverse(); // newest first (timestamped filenames sort lexicographically)
}

function kickoffFor(cwd: string, file: string): string {
  const body = readFileSync(join(cwd, HANDOFF_DIR, file), "utf8");
  return (
    `Resuming from a handoff written before a context reset ` +
    `(\`${HANDOFF_DIR}/${file}\`). This is your full context — the previous ` +
    `conversation is gone. Read it, then confirm in 2–3 lines: the objective, ` +
    `the immediate next action, and any constraint you must respect. Don't ` +
    `redo completed work.\n\n---\n\n${body}`
  );
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("pickup", {
    description: "Resume from a handoff in a fresh session (latest, or `list`, or a name fragment)",
    handler: async (args: string, ctx: ExtensionCommandContext) => {
      mkdirSync(join(ctx.cwd, HANDOFF_DIR), { recursive: true });
      const files = listHandoffs(ctx.cwd);
      if (files.length === 0) {
        ctx.ui.notify(`No handoffs in ${HANDOFF_DIR}. Write one first with /handoff.`, "warn");
        return;
      }

      const arg = args.trim();
      let chosen: string | undefined;

      if (arg === "" ) {
        chosen = files[0]; // latest
      } else if (arg === "list") {
        chosen = await ctx.ui.select("Resume from which handoff?", files);
        if (!chosen) return; // cancelled
      } else {
        chosen = files.find((f) => f.includes(arg));
        if (!chosen) {
          ctx.ui.notify(`No handoff matching "${arg}". Try /pickup list.`, "warn");
          return;
        }
      }

      const kickoff = kickoffFor(ctx.cwd, chosen); // plain string — safe across session replacement
      const parentSession = ctx.sessionManager.getSessionFile() ?? undefined;

      const result = await ctx.newSession({
        parentSession,
        withSession: async (freshCtx) => {
          await freshCtx.sendUserMessage(kickoff);
        },
      });

      if (result?.cancelled) {
        ctx.ui.notify("Pickup cancelled — staying in the current session.", "info");
      }
    },
  });
}
