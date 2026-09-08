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

## 🔴 Scope at the QUERY, not after — the shared-board rule

**Company-wide boards are shared across every team.** An unscoped pull returns other teams'
work, which then has to be filtered *in context* — the expensive way to do it, and the way
that quietly turns a 2-row answer into a 36-row read. **Always scope in the JQL.** Measured
live on one real instance:

| Board | Unscoped open | Team-scoped | Overfetch |
|---|---|---|---|
| `BUG` (High+ priority) | **36** | **2** | **18×** |
| `HOT` (incidents) | **68** | **12** | **5.7×** |
| `VULN` | **6** | **2** | **3×** |

**Each board may use a DIFFERENT ownership field — don't assume one works everywhere.** Check
yours once, write it down here, and let the file do the remembering:

```jql
# Atlassian Teams field — the value is a UUID. A display string like "Your Squad"
# silently returns ZERO rows, which reads as "nothing open" rather than as an error.
project = <BUG_PROJECT> AND cf[10001] = "<TEAM_UUID>" AND statusCategory != Done
project = <HOT_PROJECT> AND cf[10001] = "<TEAM_UUID>" AND statusCategory != Done

# A plain "Squad" select list — here the string value DOES work
project = <VULN_PROJECT> AND "Squad[Select List (multiple choices)]" = "Your Squad" AND statusCategory != Done

# Single-team projects need no ownership filter
project = <YOUR_PROJECT> AND sprint in openSprints()
```

**🔴 Prefer the Team/Squad field over `assignee in (<accountIds>)`.** Assignee-scoping has two
failure modes, both verified live:
- **Unassigned work vanishes.** 8 of those 36 open High+ bugs had no assignee — untriaged
  tickets haven't been assigned yet, and untriaged is exactly what a triage should surface.
- **Team-owned work assigned to someone outside the team vanishes.** An incident ticket owned
  by the team via the Team field but assigned to a peer manager is missed by every
  assignee-scoped query.

Use `assignee in (...)` only when the question is genuinely *per-person* ("what is X working
on", per-direct load). Use the Team field when the question is *"what does my team own."*

**Also trim the payload.** `fields` defaults to ~13 fields including `description` — pass an
explicit list. Every assignee object carries four avatar URLs and every status a full category
object, so even a 2-ticket response is a couple of thousand characters.

```
fields: ["summary", "status", "assignee", "priority", "issuetype"]   # standup shape
fields: ["summary", "status", "priority", "duedate"]                  # due-date scan
searchResultMode: "count"                                             # when only the NUMBER matters
```

**`searchResultMode: "count"` returns `totalCount` and an empty issues array** — use it for
count deltas and "is anything overdue" checks, where a number answers the question and the
ticket list is noise. Add `maxResults` when a list is needed but unbounded growth isn't.

> If you run pi, `.pi/extensions/jira-scope-guard.ts` **blocks** an unscoped query against the
> boards named in its `CONFIG` block. Fill that in and the rule stops depending on memory.

---

## 🔴 List queries TRUNCATE SILENTLY — cross-check the number with `count` mode

**Verified live, and it manufactured a phantom finding before it was caught.** A sprint query
with an explicit `fields` list returned **15 issues with no truncation notice**. The identical
JQL with `searchResultMode: "count"` returned **`totalCount: 20`**.

The five missing rows were **all the `In Progress` tickets**, so the truncated read looked
exactly like "someone pulled every in-flight ticket out of the sprint this afternoon" — a real,
reportable event that had not happened. Truncation is not random: it drops a contiguous tail, so
the omission lands on whatever the `ORDER BY` puts last and therefore reads as a pattern.

**The rule: whenever a list result is going to be counted, characterised, or compared against an
earlier sweep, run the same JQL twice — once for rows, once for `count`. If they disagree, the
list is short.** `fullResultPath` responses are the safe case (the temp file holds everything);
it is the inline-`content` responses that quietly clip.

**Don't diagnose sprint membership from the sprint custom field** — it can return empty even for
tickets the same query just returned as being in the open sprint. Test membership with JQL
instead: `key = <TICKET> AND sprint in openSprints()` (and `futureSprints()` /
`closedSprints()` to locate it).

**When the payload is big, don't parse it in context.** `bin/jira-summarise.sh` takes either the
MCP result envelope or the spilled `fullResultPath` file and prints a standup-shaped table, so
the raw JSON never enters the conversation.

---

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

**🔴 Filter on `statusCategoryChangedDate`, NEVER on `resolved`.** Bulk transitions set
`status` without setting `resolution`, so `resolved` is empty on anything closed as
`Won't Do` — and on this exact query that produced **zero rows while three tickets read
`Done`**, two of which were live agenda items in that morning's card. That is the precise
failure this recipe exists to prevent, caused by the recipe itself. **A zero here means
check the field, not "nothing closed."**

```jql
(project in (<YOUR_PROJECT>, <BUG_PROJECT>, <OPS_PROJECT>)) AND statusCategory = Done AND statusCategoryChangedDate >= "<since>" ORDER BY statusCategoryChangedDate DESC
```

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
