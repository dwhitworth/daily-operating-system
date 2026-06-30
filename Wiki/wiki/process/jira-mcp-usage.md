---
title: Jira MCP Usage (template)
type: process
confidence: high
sources: []
updated: YYYY-MM-DD
---

# Jira MCP Usage

> **Template file.** This is the contract between the DOS modes (`/triage`, `/daily-wrap`,
> `/weekly-rollup`, `/manager-1-1`) and your issue tracker. Fill in the connection facts,
> project keys, and team accountIds for your own environment. The modes read this file to
> build their JQL — keep it accurate and it does the remembering for you.
>
> ⚠️ **Do not commit real secrets.** The cloudId and accountIds below are environment
> identifiers, not secrets per se, but treat this file as sensitive if your repo is public —
> keep a private copy, or scrub before publishing.

## Purpose
Single source of truth for how the DOS talks to Jira over the Atlassian MCP: connection
facts, project keys, the canonical JQL recipes the modes rely on, and the read-only/write
posture. When a mode needs to query the board, it builds the JQL from the recipes here.

## Connection facts

| Field | Value |
|---|---|
| **Site** | `<your-site>.atlassian.net` |
| **cloudId** | `<YOUR_CLOUD_ID>` — discover via `getAccessibleAtlassianResources` |
| **Authenticated user** | `[you]` (`you@example.com`) |
| **Scopes** | `read:jira-work`, `write:jira-work` |
| **Transport endpoint** | Streamable HTTP (`https://mcp.atlassian.com/v1/mcp`, `type: http`) |

> To discover your cloudId: call `getAccessibleAtlassianResources`. To resolve accountIds:
> `lookupJiraAccountId` with a display name or email.

## Project key cheat-sheet

Map each intake surface / board to its project key. Example shape:

| Space (intake surface) | Project key | Type |
|---|---|---|
| `[your team]` (Sprint board) | `<YOUR_PROJECT>` | software |
| `[your team]` Operations | `<OPS_PROJECT>` | service_desk |
| Vulnerabilities | `<VULN_PROJECT>` | software |
| Outage / incident tracking | `<HOT_PROJECT>` | service_desk |
| Bugs | `<BUG_PROJECT>` | service_desk |

## Common queries (canonical recipes)

All queries call `searchJiraIssuesUsingJql` with your `cloudId`. The recipes below are the
JQL — wrap as needed. Replace `<YOUR_PROJECT>` etc. with your keys and
`<team-member-accountIds>` with the comma-separated accountId list from the table at the
bottom.

### 1. Live sprint state
```jql
project = <YOUR_PROJECT> AND sprint in openSprints() ORDER BY status, priority DESC
```

### 2. Sprint state for a different team
```jql
project = <OTHER_PROJECT> AND sprint in openSprints()
```

### 3. Vulnerability board — what's due before sprint end
```jql
project = <VULN_PROJECT> AND statusCategory != Done AND duedate <= "<sprint-end>" ORDER BY duedate ASC, priority DESC
```

### 4. Incident / outage board — your team's action items
```jql
project = <HOT_PROJECT> AND assignee in (<team-member-accountIds>) AND statusCategory != Done
```

### 5. Cycle op stats (periodic reporting ask)
Filter by squad assignee — an unfiltered cut pulls cross-team contamination.
```jql
# Closed bugs assigned to your team in the window
project = <BUG_PROJECT> AND assignee in (<team-member-accountIds>) AND resolved >= "<start>" AND resolved <= "<end>"
# Closed vulnerabilities in same window
project = <VULN_PROJECT> AND assignee in (<team-member-accountIds>) AND resolved >= "<start>" AND resolved <= "<end>"
```

### 6. Ticket lookup by key
```jql
key = <TICKET>
```
Or use `getJiraIssue` (single-issue full payload) / `getJiraIssueRemoteIssueLinks`
(connected PRs, pages).

### 7. A specific person's in-flight work
```jql
assignee = "<account-id>" AND sprint in openSprints()
```

### 8. Out-of-sprint work (context-loss visibility)
```jql
project = <YOUR_PROJECT> AND assignee = "<account-id>" AND sprint is EMPTY AND statusCategory != Done
```
**Use for:** spotting work someone picked up off-sprint that risks losing context if they
get pulled away.

### 9. Recently-closed across all spaces — *mandatory in /daily-wrap and /triage*
```jql
(project in (<YOUR_PROJECT>, <BUG_PROJECT>, <OPS_PROJECT>, <HOT_PROJECT>, <VULN_PROJECT>)) AND assignee in (<team-member-accountIds>) AND resolved >= "<since>" ORDER BY resolved DESC
```
**Why mandatory:** every other sweep filters `statusCategory != Done`, so they're blind to
closures. A closure can invalidate a live escalation cited in a prep doc. Without this
query, a stale escalation lands in a 1:1. (Learned the hard way: a bug that closed as
"Resolved (No code change)" was missed by every Done-filtering query and nearly surfaced as
a live escalation.)

### 10. Prep-doc live-state check
For any `1-1-prep-*.md` in the next ~7 days, re-verify the state of every ticket cited as a
live escalation. Re-query each by key (recipe 6) and reflect closures/transitions back into
the prep doc before the meeting.

## JQL tips
- Use **accountIds**, not display names — JQL prefers them and they survive renames.
- The story-points custom field id varies per instance — confirm yours (commonly
  `customfield_100xx`) rather than assuming; a wrong id returns silent zeros.
- `statusCategory` has three values: `new` (To Do), `indeterminate` (In Progress), `done`.

## Read-only vs write — keep the seatbelt on
The MCP may be authorised with `write:jira-work`. **Read-only is the default posture.**
Anything that mutates state (create / edit / transition / comment / link / worklog) must be
confirmed with the user before the call.

**Read (safe, default):** `searchJiraIssuesUsingJql`, `getJiraIssue`,
`getJiraIssueRemoteIssueLinks`, `getTransitionsForJiraIssue`, `lookupJiraAccountId`,
`getVisibleJiraProjects`, `getAccessibleAtlassianResources`.

**Write (confirm first):** `createJiraIssue`, `editJiraIssue`, `transitionJiraIssue`,
`addCommentToJiraIssue`, `createIssueLink`, `addWorklogToJiraIssue`.

## Team accountIds

Fill in your team. Resolve each via `lookupJiraAccountId`.

| Person | accountId | Email |
|---|---|---|
| `[Team member 1]` | `<account-id>` | `member1@example.com` |
| `[Team member 2]` | `<account-id>` | `member2@example.com` |

Comma-separated form for the `assignee in (...)` recipes:
```
assignee in ("<account-id-1>", "<account-id-2>", ...)
```
