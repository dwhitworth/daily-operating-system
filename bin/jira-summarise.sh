#!/usr/bin/env bash
# jira-summarise.sh — turn a Jira search result (from the Atlassian MCP) into a
# compact, context-cheap table. Keeps large raw Jira JSON OUT of the agent's
# context window: fetch once, spill to a file, summarise here.
#
# WHY: the Atlassian MCP `searchJiraIssuesUsingJql` returns big JSON that spills
# to a temp file (fullResultPath) when it's large. This formats that JSON into a
# standup-shaped table instead of the agent re-parsing it by hand each triage.
#
# INPUT: Jira search JSON, from a file arg OR stdin. Accepts any of:
#   - the raw MCP result envelope   {"content":[{"type":"text","text":"{...}"}]}
#   - the spilled fullResultPath file (same envelope shape)
#   - raw Jira search JSON          {"issues":[...]}
#
# USAGE:
#   ./bin/jira-summarise.sh RESULT.json                 # flat table (status, priority)
#   ./bin/jira-summarise.sh --by-assignee RESULT.json   # standup board, grouped by engineer
#   ./bin/jira-summarise.sh --counts RESULT.json         # status tally only
#   cat RESULT.json | ./bin/jira-summarise.sh --by-assignee
#
# TYPICAL TRIAGE FLOW (the agent does the fetch in mcpScript, then):
#   1. mcpScript runs the scoped JQL (see Wiki/wiki/process/jira-mcp-usage.md § Scope)
#      → note the emitted fullResultPath
#   2. ./bin/jira-summarise.sh --by-assignee <fullResultPath>

set -u

MODE="table"
FILE=""
for arg in "$@"; do
  case "$arg" in
    --by-assignee) MODE="assignee" ;;
    --by-status)   MODE="status" ;;
    --counts)      MODE="counts" ;;
    --table)       MODE="table" ;;
    -h|--help)     sed -n '2,30p' "$0"; exit 0 ;;
    *)             FILE="$arg" ;;
  esac
done

if [ -n "$FILE" ]; then
  [ -f "$FILE" ] || { echo "jira-summarise: file not found: $FILE" >&2; exit 1; }
  DATA="$FILE"; CLEANUP=""
else
  DATA="$(mktemp)"; CLEANUP="$DATA"; cat > "$DATA"
fi
trap '[ -n "$CLEANUP" ] && rm -f "$CLEANUP"' EXIT

MODE="$MODE" DATA="$DATA" python3 - <<'PY'
import sys, json, os

MODE = os.environ.get("MODE", "table")

try:
    with open(os.environ["DATA"]) as fh:
        obj = json.load(fh)
except json.JSONDecodeError as e:
    print(f"jira-summarise: input is not valid JSON ({e})", file=sys.stderr)
    sys.exit(1)

def find_issues(o):
    # raw Jira search JSON
    if isinstance(o, dict) and "issues" in o:
        return o["issues"], o.get("total")
    # MCP envelope: content[0].text is a JSON string
    if isinstance(o, dict) and isinstance(o.get("content"), list):
        for block in o["content"]:
            txt = block.get("text") if isinstance(block, dict) else None
            if txt:
                try:
                    inner = json.loads(txt)
                    if isinstance(inner, dict) and "issues" in inner:
                        return inner["issues"], inner.get("total")
                except Exception:
                    pass
    # omitted-result summary pointer
    if isinstance(o, dict) and o.get("omitted") and o.get("fullResultPath"):
        print("jira-summarise: this is an OMITTED-result summary, not the data.",
              file=sys.stderr)
        print(f"  Re-run pointing at: {o['fullResultPath']}", file=sys.stderr)
        sys.exit(2)
    return None, None

issues, total = find_issues(obj)
if issues is None:
    print("jira-summarise: couldn't find an `issues` array in the input.", file=sys.stderr)
    sys.exit(1)

def g(d, *path, default="-"):
    cur = d
    for p in path:
        if not isinstance(cur, dict):
            return default
        cur = cur.get(p)
    return cur if cur not in (None, "") else default

def row(i):
    f = i.get("fields", {}) or {}
    return {
        "key": i.get("key", "?"),
        "status": g(f, "status", "name"),
        "cat": g(f, "status", "statusCategory", "name", default=""),
        "priority": g(f, "priority", "name"),
        "type": g(f, "issuetype", "name"),
        "assignee": g(f, "assignee", "displayName", default="UNASSIGNED"),
        "due": g(f, "duedate", default=""),
        "summary": g(f, "summary", default=""),
    }

rows = [row(i) for i in issues]

# Preferred status ordering (unknown statuses sort last, alphabetically).
STATUS_ORDER = ["To Do", "Backlog", "In Progress", "Design Review", "Code Review",
                "QA", "Ready for Release", "UAT", "Release", "Done"]
def status_rank(s):
    return (STATUS_ORDER.index(s), "") if s in STATUS_ORDER else (len(STATUS_ORDER), s)

PRIO_ORDER = ["Highest", "High", "Medium", "Low", "Lowest"]
def prio_rank(p):
    return PRIO_ORDER.index(p) if p in PRIO_ORDER else len(PRIO_ORDER)

def trunc(s, n=62):
    s = s.replace("\n", " ")
    return s if len(s) <= n else s[: n - 1] + "…"

def counts_line():
    from collections import Counter
    c = Counter(r["status"] for r in rows)
    parts = [f"{s}: {c[s]}" for s in sorted(c, key=status_rank)]
    return " · ".join(parts)

n = len(rows)
header = f"{n} issue(s)" + (f" of {total}" if total not in (None, n) else "")

if MODE == "counts":
    print(header)
    print(counts_line())
    sys.exit(0)

def print_table(rs):
    cols = [("key", "KEY"), ("status", "STATUS"), ("priority", "PRI"),
            ("type", "TYPE"), ("assignee", "ASSIGNEE"), ("due", "DUE")]
    widths = {k: len(h) for k, h in cols}
    for r in rs:
        for k, _ in cols:
            widths[k] = max(widths[k], len(str(r[k])))
    line = "  ".join(h.ljust(widths[k]) for k, h in cols) + "  SUMMARY"
    print(line)
    for r in rs:
        cells = "  ".join(str(r[k]).ljust(widths[k]) for k, _ in cols)
        print(f"{cells}  {trunc(r['summary'])}")

if MODE == "table":
    print(header)
    rs = sorted(rows, key=lambda r: (status_rank(r["status"]), prio_rank(r["priority"])))
    print_table(rs)
    print(f"\n{counts_line()}")
    sys.exit(0)

if MODE == "status":
    print(header + "\n")
    for s in sorted({r["status"] for r in rows}, key=status_rank):
        grp = sorted((r for r in rows if r["status"] == s), key=lambda r: prio_rank(r["priority"]))
        print(f"### {s} ({len(grp)})")
        for r in grp:
            print(f"  {r['key']}  [{r['priority']}] {r['assignee']}  — {trunc(r['summary'], 55)}")
        print()
    print(counts_line())
    sys.exit(0)

if MODE == "assignee":
    print(header + "\n")
    who = sorted({r["assignee"] for r in rows},
                 key=lambda a: (a == "UNASSIGNED", a))  # unassigned last
    for a in who:
        grp = sorted((r for r in rows if r["assignee"] == a),
                     key=lambda r: (status_rank(r["status"]), prio_rank(r["priority"])))
        print(f"### {a} ({len(grp)})")
        for r in grp:
            due = f" due {r['due']}" if r["due"] and r["due"] != "-" else ""
            print(f"  {r['key']}  {r['status']}  [{r['priority']}]{due}  — {trunc(r['summary'], 55)}")
        print()
    print(counts_line())
    sys.exit(0)
PY
