// Suppress MCP UI widget windows (pi-mcp-adapter).
//
// The Atlassian MCP server attaches a browser widget (ui://widget/jira-widget.html)
// to searchJiraIssuesUsingJql. pi-mcp-adapter opens it in a browser tab on every
// call; batched calls from mcpScript replace the session each time and the orphaned
// tab shows "Connection lost" with a Done/Cancel footer. It is NOT a confirmation —
// the query has already run and the inline result is returned regardless.
//
// The adapter has no settings key for this; the only switch is MCP_UI_VIEWER
// (ui-session.ts, read at call time). Setting it here means it holds no matter
// which shell launched pi. Added 03/09/2026.
export default function () {
  if (!process.env.MCP_UI_VIEWER) process.env.MCP_UI_VIEWER = "none";
}
