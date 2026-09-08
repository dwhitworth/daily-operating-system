import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

// Jira MCP scope-guard + write-gate.
//
// Enforces two rules from Wiki/wiki/process/jira-mcp-usage.md:
//
//   1. SCOPE AT THE QUERY. Any JQL touching the company-wide shared boards must
//      carry the squad scope or it returns 18x / 5.7x / 3x the rows. BUG/HOT
//      scope on the Ops Team UUID (cf[10001]); VULN on the Squad select field.
//      Missing -> BLOCK with the fix. Board keys + scope values are in CONFIG.
//
//   2. READ-ONLY BY DEFAULT. Any Atlassian tool outside the known read-only set
//      (create/edit/transition/comment/link/assign/delete...) must be confirmed.
//
// In THIS harness Atlassian is reached through the `mcp` gateway tool and
// `mcpScript`, not as first-class `atlassian_*` tools — so we inspect all three
// entry points:
//   - mcp        : event.input = { tool, args, server }
//   - mcpScript  : event.input = { code }  (best-effort static scan of the JS)
//   - direct     : toolName "atlassian_<tool>" (in case a setup exposes them)

// ---------------------------------------------------------------- CONFIG
// The only site-specific values in this file. Everything below is generic.
//   TEAM_UUID  — the Jira Team custom-field value that scopes the shared
//                BUG/HOT boards to one squad. A UUID, NOT the team's name:
//                passing the display string silently returns zero rows.
//   SQUAD_NAME — the VULN board scopes on a Squad select-list instead, which
//                does take the display string.
//   SHARED_BOARDS / SQUAD_BOARD — the company-wide project keys that must never
//                be queried unscoped.
const OPS_TEAM_UUID = "00000000-0000-0000-0000-000000000000";
const SQUAD_NAME = "Your Squad";
const SHARED_BOARDS = ["BUG", "HOT"] as const; // scoped by Team UUID
const SQUAD_BOARD = "VULN"; // scoped by the Squad select list
// ------------------------------------------------------------- END CONFIG

/**
 * Is the scope config actually filled in? An all-zero placeholder UUID would make every
 * shared-board query fail the `includes` test and get blocked forever — unhelpful on a
 * fresh clone, and the kind of unexplained wall that gets an extension deleted. When the
 * config is unset we skip the scope check and say so once; the write-gate still applies.
 */
const SCOPE_CONFIGURED = !/^0[0-]*0$/.test(OPS_TEAM_UUID);
let warnedUnconfigured = false;

const READ_ONLY = new Set<string>([
  "getAccessibleAtlassianResources",
  "atlassianUserInfo",
  "getVisibleJiraProjects",
  "getJiraProjectIssueTypesMetadata",
  "getJiraIssueTypeMetaWithFields",
  "searchJiraIssuesUsingJql",
  "search",
  "searchConfluenceUsingCql",
  "getJiraIssue",
  "getJiraIssueRemoteIssueLinks",
  "getTransitionsForJiraIssue",
  "getIssueLinkTypes",
  "getConfluenceSpaces",
  "getConfluencePage",
  "getPagesInConfluenceSpace",
  "getConfluencePageDescendants",
  "getConfluencePageFooterComments",
  "getConfluencePageInlineComments",
  "getConfluenceCommentChildren",
  "lookupJiraAccountId",
  "fetch",
  // Added 02/09/2026: read-only widget-markup tools that arrived in an Atlassian MCP
  // server update. Absent from the allowlist they were treated as writes and prompted
  // on ordinary reads.
  "read_jira_widget_ext_apps",
  "read_jira_widget_openai",
  "read_confluence_widget_ext_apps",
  "read_confluence_widget_openai",
]);

/**
 * Write verbs, checked against the tool's own name. This is the load-bearing test:
 * the allowlist above fails CLOSED whenever Atlassian ships a new tool, which is how
 * four read-only widget tools started demanding confirmation on 02/09/2026. Naming
 * the write verbs instead means a server update adds silent reads, not new prompts.
 */
const WRITE_TOOL = /^(create|edit|update|delete|remove|transition|add|assign|move|archive|rank)/i;

/** Reads follow stable naming conventions on this server. */
const READ_TOOL = /^(get|search|fetch|lookup|read_|list)/i;

/** True when the tool should be gated behind a confirm. */
function isWriteTool(base: string): boolean {
  if (READ_ONLY.has(base)) return false;
  if (WRITE_TOOL.test(base)) return true;
  if (READ_TOOL.test(base)) return false;
  // Genuinely unrecognised: still fail closed, but it will be rare now.
  return true;
}

function stripPrefix(tool: string): string {
  return (
    /^atlassian[_.:](.+)$/.exec(tool)?.[1] ??
    /^mcp__atlassian__(.+)$/.exec(tool)?.[1] ??
    tool
  );
}

function looksAtlassian(tool: string, server?: string): boolean {
  if (server && /atlassian/i.test(server)) return true;
  if (/^(atlassian|mcp__atlassian)/i.test(tool)) return true;
  const base = stripPrefix(tool);
  if (READ_ONLY.has(base)) return true;
  return /jira|confluence/i.test(base);
}

function referencesProject(text: string, key: string): boolean {
  return new RegExp(`project\\s*(=|in)\\s*\\(?[^)]*\\b${key}\\b`, "i").test(text);
}

/** Returns a fix message if JQL/text touches a shared board without the right scope. */
function scopeProblem(text: string): string | null {
  if (!SCOPE_CONFIGURED) return null;
  const shared = SHARED_BOARDS.some((k) => referencesProject(text, k));
  const squadBoard = referencesProject(text, SQUAD_BOARD);
  if (shared && !text.includes(OPS_TEAM_UUID)) {
    return (
      `references ${SHARED_BOARDS.join("/")} (company-wide) without the ${SQUAD_NAME} Team scope. ` +
      `Add cf[10001] = "${OPS_TEAM_UUID}" (Team UUID, not the string "${SQUAD_NAME}").`
    );
  }
  if (squadBoard && !/Squad/i.test(text)) {
    return (
      `references ${SQUAD_BOARD} (company-wide) without the Squad filter. ` +
      `Add "Squad[Select List (multiple choices)]" = "${SQUAD_NAME}" ` +
      `(${SQUAD_BOARD} uses the Squad field, NOT the ${SHARED_BOARDS.join("/")} Team UUID).`
    );
  }
  return null;
}

/** Best-effort: does mcpScript code invoke an Atlassian WRITE tool? */
const WRITE_VERB = /atlassian[_.:](create|edit|update|delete|remove|transition|add|assign|move|link|archive|rank)/i;

async function confirmWrite(
  ctx: ExtensionContext,
  what: string,
): Promise<{ block: true; reason: string } | undefined> {
  const reason = `Atlassian write "${what}" is gated (read-only by default).`;
  if (!ctx.hasUI) return { block: true, reason: `${reason} No UI to confirm -> blocked.` };
  const ok = await ctx.ui.confirm("Confirm Jira write", `${what}\n\nThis modifies Jira/Confluence. Allow it?`);
  return ok ? undefined : { block: true, reason: `${reason} Declined by the operator.` };
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx: ExtensionContext) => {
    const name = event.toolName;
    const input = event.input as Record<string, unknown>;

    if (!SCOPE_CONFIGURED && !warnedUnconfigured && ctx.hasUI) {
      warnedUnconfigured = true;
      ctx.ui.notify(
        "jira-scope-guard: CONFIG is unset, so the shared-board scope check is OFF. " +
          "Fill in OPS_TEAM_UUID / SQUAD_NAME to enable it. Write-gating is still active.",
        "warn",
      );
    }

    // --- entry point: mcp gateway ---
    if (name === "mcp") {
      const tool = String(input.tool ?? "");
      const server = input.server as string | undefined;
      if (!tool || !looksAtlassian(tool, server)) return;
      const base = stripPrefix(tool);
      const args = (input.args ?? {}) as Record<string, unknown>;

      if (base === "searchJiraIssuesUsingJql") {
        const problem = scopeProblem(String(args.jql ?? ""));
        return problem ? { block: true, reason: `Jira scope-guard: JQL ${problem}` } : undefined;
      }
      if (isWriteTool(base)) return confirmWrite(ctx, base);
      return;
    }

    // --- entry point: mcpScript (static best-effort) ---
    if (name === "mcpScript") {
      const code = String(input.code ?? "");
      if (!/atlassian|Jira|jql/i.test(code)) return;
      const problem = scopeProblem(code);
      if (problem) return { block: true, reason: `Jira scope-guard: mcpScript ${problem}` };
      const m = WRITE_VERB.exec(code);
      if (m) return confirmWrite(ctx, `mcpScript -> ${m[0]}`);
      return;
    }

    // --- entry point: direct atlassian_* tool ---
    if (looksAtlassian(name)) {
      const base = stripPrefix(name);
      if (base === "searchJiraIssuesUsingJql") {
        const problem = scopeProblem(String(input.jql ?? ""));
        return problem ? { block: true, reason: `Jira scope-guard: JQL ${problem}` } : undefined;
      }
      if (isWriteTool(base)) return confirmWrite(ctx, base);
    }
  });
}
