import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

// gcalcli --calendar guard.
//
// `gcalcli add` prompts interactively for a calendar when --calendar is absent,
// which fails with EOFError in pi's non-interactive shell (documented footgun in
// the triage prompt). This mutates any `gcalcli ... add` bash command in place to
// inject --calendar "<work calendar>" before it runs. Agenda/other subcommands are
// left alone (only `add` prompts).

// CONFIG — the work calendar gcalcli should write to. Override with DOS_CALENDAR.
const CALENDAR = process.env.DOS_CALENDAR ?? "primary";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx: ExtensionContext) => {
    if (!isToolCallEventType("bash", event)) return;

    const cmd = event.input.command ?? "";
    if (!/\bgcalcli\b/.test(cmd)) return;
    if (!/\badd\b/.test(cmd)) return; // only `add` prompts for a calendar
    if (/--calendar\b/.test(cmd)) return; // already specified

    // Insert --calendar as a global option right after the first `gcalcli`.
    event.input.command = cmd.replace(
      /\bgcalcli\b/,
      `gcalcli --calendar "${CALENDAR}"`,
    );

    if (ctx.hasUI) {
      ctx.ui.notify(`gcalcli: injected --calendar "${CALENDAR}" (avoids EOFError)`, "info");
    }
  });
}
