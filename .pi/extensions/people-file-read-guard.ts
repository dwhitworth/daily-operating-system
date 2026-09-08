import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

// People-file whole-read guard.
//
// Per DOS/CLAUDE.md + the triage prompt, reading a person's wiki file WHOLE
// (5-12k tokens each) is "the single biggest avoidable cost" — the section
// slicer ./bin/section.sh exists precisely to avoid it. This blocks a `read`
// of a Wiki/wiki/people/<name>.md file when no offset/limit is set (i.e. a
// whole-file read), and points at the slicer. History files and sliced reads
// pass through.

// matches .../Wiki/wiki/people/<name>.md but NOT .../people/history/<name>.md
const PEOPLE_FILE = /(^|\/)Wiki\/wiki\/people\/[^/]+\.md$/;

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, _ctx: ExtensionContext) => {
    if (!isToolCallEventType("read", event)) return;

    const path = event.input.path ?? "";
    if (!PEOPLE_FILE.test(path)) return;

    const whole = event.input.offset === undefined && event.input.limit === undefined;
    if (!whole) return; // a targeted slice is fine

    return {
      block: true,
      reason:
        `People-file guard: "${path}" is 5-12k tokens — don't read it whole. ` +
        `Use the section slicer instead, e.g.\n` +
        `  ./bin/section.sh "${path}" "Next Catchup Agenda" "Open Loops" "Current Focus"\n` +
        `Add "Strategic Notes" only for a strategic/political meeting. ` +
        `If a slice is genuinely insufficient, re-issue read with an explicit ` +
        `offset/limit (or say why the whole file is needed) and this guard won't fire.`,
    };
  });
}
