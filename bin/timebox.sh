#!/usr/bin/env bash
# timebox.sh — create or soften DOS "Timebox - " calendar blocks.
#
# WHY THIS EXISTS: timeboxes are an *intent* signal, not a booking. The operator wants
# colleagues to be able to book over them. That requires transparency=transparent
# ("Free") on the event, and gcalcli 4.5.1 has no --transparency flag (verified:
# no `eventType`/`transparency` write support anywhere in its source). So we create
# via the Calendar API directly, using the OAuth token gcalcli already holds.
#
# WHY NOT Google "Focus time" (eventType=focusTime): focus time exists to PROTECT
# time. Even with autoDeclineMode=declineNone it reads to a colleague as "do not
# book over this" — the opposite of the intent here. Deliberately not used.
#
# THE THREE LEVERS:
#   transparency=transparent  -> the load-bearing one; you show as FREE, and Google
#                                raises no conflict warning when someone books over
#   description               -> says it in words to anyone who clicks the event
#   colorId=8 (graphite/grey) -> reads as soft/tentative vs a real meeting
#
# The "Timebox - " title prefix is load-bearing too: /triage's calibration
# look-back greps on it. Don't change the prefix.
#
# USAGE
#   ./bin/timebox.sh add "Aman interview prep" "2026-08-31 12:10" 45
#   ./bin/timebox.sh soften 2026-08-31        # patch that day's existing Timebox events
#   ./bin/timebox.sh list 2026-08-31
#
# NOTE: `add` prepends "Timebox - " itself — pass the terse description only.

set -euo pipefail

PY="$(ls -d "$HOME"/.local/pipx/venvs/gcalcli/bin/python 2>/dev/null || true)"
if [[ -z "$PY" ]]; then
  echo "error: gcalcli's pipx venv python not found." >&2
  echo "       expected ~/.local/pipx/venvs/gcalcli/bin/python" >&2
  echo "       this script reuses gcalcli's google-api-python-client + OAuth token." >&2
  exit 1
fi

MODE="${1:-}"; shift || true
if [[ -z "$MODE" ]]; then
  sed -n '3,30p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
fi

MODE="$MODE" "$PY" - "$@" <<'PYEOF'
import os, pickle, sys, datetime as dt
from google.auth.transport.requests import Request
from googleapiclient.discovery import build

TOKEN = os.path.expanduser(
    "~/Library/Application Support/gcalcli/oauth")
TZ = os.environ.get("DOS_TZ", "Australia/Sydney")
PREFIX = "Timebox - "
GRAPHITE = "8"
BLURB = ("Self-booked work block, not a meeting. Marked Free on purpose — "
         "if you need this time, book over it and I'll move the block.")

creds = pickle.load(open(TOKEN, "rb"))
if creds.expired and creds.refresh_token:
    creds.refresh(Request())
svc = build("calendar", "v3", credentials=creds, cache_discovery=False)
mode, args = os.environ["MODE"], sys.argv[1:]

def day_bounds(datestr):
    d = dt.date.fromisoformat(datestr)
    return (f"{d}T00:00:00", f"{d + dt.timedelta(days=1)}T00:00:00")

def timeboxes(datestr):
    lo, hi = day_bounds(datestr)
    r = svc.events().list(calendarId="primary", timeMin=lo, timeMax=hi,
                          timeZone=TZ, singleEvents=True,
                          orderBy="startTime").execute()
    return [e for e in r.get("items", [])
            if (e.get("summary") or "").startswith(PREFIX)]

def show(e):
    t = (e.get("start", {}).get("dateTime") or "")[11:16] or "all-day"
    free = e.get("transparency") == "transparent"
    print(f"  {t}  {'FREE ' if free else 'BUSY '} "
          f"{'grey' if e.get('colorId') == GRAPHITE else '    '}  {e.get('summary')}")

if mode == "add":
    if len(args) != 3:
        sys.exit('usage: timebox.sh add "<desc>" "<YYYY-MM-DD HH:MM>" <minutes>')
    desc, when, mins = args[0], args[1], int(args[2])
    start = dt.datetime.strptime(when, "%Y-%m-%d %H:%M")
    end = start + dt.timedelta(minutes=mins)
    e = svc.events().insert(calendarId="primary", body={
        "summary": PREFIX + desc,
        "description": BLURB,
        "start": {"dateTime": start.isoformat(), "timeZone": TZ},
        "end":   {"dateTime": end.isoformat(),   "timeZone": TZ},
        "transparency": "transparent",   # FREE — the load-bearing bit
        "colorId": GRAPHITE,
        "reminders": {"useDefault": False},
    }).execute()
    print("created (Free, graphite):")
    show(e)

elif mode == "soften":
    if len(args) != 1:
        sys.exit("usage: timebox.sh soften <YYYY-MM-DD>")
    found = timeboxes(args[0])
    if not found:
        print(f"no '{PREFIX}' events on {args[0]}")
    for e in found:
        if e.get("transparency") == "transparent" and e.get("colorId") == GRAPHITE:
            print("  already soft:", e.get("summary")); continue
        patched = svc.events().patch(
            calendarId="primary", eventId=e["id"],
            body={"transparency": "transparent", "colorId": GRAPHITE,
                  "description": BLURB, "reminders": {"useDefault": False}}
        ).execute()
        print("  softened:")
        show(patched)

elif mode == "list":
    if len(args) != 1:
        sys.exit("usage: timebox.sh list <YYYY-MM-DD>")
    found = timeboxes(args[0])
    print(f"{len(found)} timebox(es) on {args[0]}:")
    for e in found:
        show(e)

else:
    sys.exit(f"unknown mode: {mode} (expected add | soften | list)")
PYEOF
