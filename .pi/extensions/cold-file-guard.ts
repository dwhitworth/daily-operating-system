import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

// Cold-file guard (triage/wrap hygiene).
//
// The triage prompt says: at triage, read ONLY the Standing Brief + latest
// journal entry. Backlog.md, Reference/, 30-60-90, Brag, Growth, Opportunities
// and people/history/ are deliberately COLD — pull one in only when the day's
// work actually turns on it, and say which and why.
//
// This is a SOFT nudge, not a block: when a triage session reads a cold file, we
// append a one-line reminder to the read RESULT (via tool_result). The read still
// succeeds. It only fires while a /triage turn is active, so deliberate cold-file
// reads in /todos, /weekly-scan etc. stay quiet.

const COLD_PATTERNS: RegExp[] = [
  /(^|\/)DOS\/Backlog\.md$/,
  /(^|\/)DOS\/Reference\//,
  /(^|\/)DOS\/30-60-90\.md$/,
  /(^|\/)DOS\/Brag\.md$/,
  /(^|\/)DOS\/Growth\.md$/,
  /(^|\/)DOS\/Opportunities\.md$/,
  /(^|\/)Wiki\/wiki\/people\/history\//,
];

function isCold(path: string): boolean {
  return COLD_PATTERNS.some((re) => re.test(path));
}

export default function (pi: ExtensionAPI) {
  // Track whether the current turn is a triage run. Set on the /triage input,
  // cleared by any other interactive input.
  let triageActive = false;

  pi.on("input", async (event, _ctx) => {
    if (event.source !== "interactive") return;
    const t = event.text.trim();
    if (/^\/triage\b/.test(t)) triageActive = true;
    else if (t.startsWith("/")) triageActive = false; // a different command
    // plain (non-command) messages don't change triage state
  });

  pi.on("tool_result", async (event, _ctx: ExtensionContext) => {
    if (!triageActive) return;
    if (event.toolName !== "read") return;
    const path = String((event.input as { path?: string })?.path ?? "");
    if (!isCold(path)) return;

    const note = {
      type: "text" as const,
      text:
        `\n\n<system-reminder>Cold file at triage: "${path}". These are ` +
        `deliberately not read at triage. If the day genuinely turns on it, ` +
        `state which file and why in the Battle Card; otherwise don't lean on it.` +
        `</system-reminder>`,
    };

    return { content: [...event.content, note] };
  });
}
