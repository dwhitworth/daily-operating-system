import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { execFileSync } from "node:child_process";

// Auto-commit the DOS knowledge base on session shutdown.
//
// The journal, people files, Standing Brief, Opportunities etc. are an
// append-heavy store with no version safety net during a session. On shutdown
// this stages + commits changes under DOS/ and Wiki/ only (never the whole tree,
// never secrets outside those dirs), with a timestamped message. Silent no-op if
// not a git repo or nothing changed. Errors are swallowed — a failed commit must
// never block exit.
//
// Note: the auto-memory store lives OUTSIDE this repo (~/.claude/.../memory/) so
// it is intentionally not covered here.

const SCOPES = ["DOS", "Wiki"];

function git(cwd: string, args: string[]): string {
  return execFileSync("git", args, {
    cwd,
    encoding: "utf8",
    timeout: 15_000,
    stdio: ["ignore", "pipe", "ignore"],
  });
}

export default function (pi: ExtensionAPI) {
  pi.on("session_shutdown", async (_event, ctx: ExtensionContext) => {
    const cwd = ctx.cwd;
    try {
      git(cwd, ["rev-parse", "--is-inside-work-tree"]); // throws if not a repo

      // Anything staged/unstaged under our scopes?
      const status = git(cwd, ["status", "--porcelain", "--", ...SCOPES]).trim();
      if (!status) return; // nothing to commit

      git(cwd, ["add", "--", ...SCOPES]);

      // Re-check the index actually has staged changes (e.g. all were ignored).
      const staged = git(cwd, ["diff", "--cached", "--name-only", "--", ...SCOPES]).trim();
      if (!staged) return;

      const stamp = new Date().toISOString().replace("T", " ").slice(0, 16);
      const count = staged.split("\n").filter(Boolean).length;
      git(cwd, [
        "commit",
        "--no-verify",
        "-m",
        `DOS auto-snapshot ${stamp} (${count} file${count === 1 ? "" : "s"})`,
      ]);

      if (ctx.hasUI) {
        ctx.ui.notify(`DOS snapshot committed (${count} file${count === 1 ? "" : "s"})`, "info");
      }
    } catch {
      // Never block shutdown on a git failure.
    }
  });
}
