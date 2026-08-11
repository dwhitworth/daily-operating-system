#!/usr/bin/env bash
# dos-lint.sh — mechanical health measurement for DOS/. Cheap by design.
#
# Prints a compact report. Reads NO file contents into the output — only counts,
# sizes and paths — so /dos-lint can run without loading the very files whose
# size it's complaining about. Run from the repo root.

cd "$(git rev-parse --show-toplevel)" || exit 1

BRIEF="DOS/Standing Brief.md"
say() { printf '%s\n' "$*"; }
hdr() { printf '\n=== %s ===\n' "$*"; }

# ---------------------------------------------------------------- hot files
hdr "HOT FILE SIZES (loaded every session — budget is real)"
if [ ! -f "$BRIEF" ]; then
  say "  ⚠️  no $BRIEF yet — copy DOS/_examples/'Standing Brief.md' and make it yours (see SETUP-GUIDE.md)"
  brief_c=0
else
  brief_c=$(wc -c < "$BRIEF" | tr -d ' ')
  say "$(printf '%7d chars  %6d tok  %s' "$brief_c" "$((brief_c / 4))" "Standing Brief  [target <=60000, prune >80000]")"
  if   [ "$brief_c" -gt 80000 ]; then say "  🔴 OVER HARD LIMIT — prune before writing anything new"
  elif [ "$brief_c" -gt 60000 ]; then say "  🟡 over target"
  else say "  ✅ within budget"; fi
fi

for f in DOS/CLAUDE.md Wiki/CLAUDE.md CLAUDE.md .claude/commands/triage.md; do
  [ -f "$f" ] && say "$(printf '%7d chars  %6d tok  %s' "$(wc -c < "$f" | tr -d ' ')" "$(( $(wc -c < "$f" | tr -d ' ') / 4 ))" "$f")"
done

hdr "TRIAGE FLOOR (what a Morning Triage costs before any tool work)"
floor=0
for f in CLAUDE.md DOS/CLAUDE.md Wiki/CLAUDE.md .claude/commands/triage.md "$BRIEF"; do
  [ -f "$f" ] && floor=$((floor + $(wc -c < "$f" | tr -d ' ')))
done
latest=$(find DOS/Journal -name '2*.md' -type f | sort | tail -1)
[ -n "$latest" ] && floor=$((floor + $(wc -c < "$latest" | tr -d ' ')))
say "$(printf '%6d tok  base (context files + Brief + latest journal: %s)' "$((floor / 4))" "$(basename "$latest")")"
say "        + ~4k tok per attendee people-file slice"

# ------------------------------------------------------------ cold files
hdr "COLD FILES (read on demand — size is cheap, but check they're not hot by accident)"
for f in DOS/Backlog.md DOS/Reference/*.md DOS/30-60-90.md DOS/Brag.md DOS/Growth.md DOS/Opportunities.md; do
  [ -f "$f" ] && say "$(printf '%7d chars  %6d tok  %s' "$(wc -c < "$f" | tr -d ' ')" "$(( $(wc -c < "$f" | tr -d ' ') / 4 ))" "$f")"
done

# --------------------------------------------------- Brief/Backlog boundary
hdr "BRIEF / BACKLOG BOUNDARY (line is this-week vs not-this-week, NOT priority)"
# grep -c exits 1 on zero matches, so capture without tripping set -e semantics.
count() { grep -cE "$1" "$2" 2>/dev/null | head -1; }
say "Brief   open [ ]: $(count '^- \[ \]' "$BRIEF")   done [x]: $(count '^- \[x\]' "$BRIEF")"
say "Backlog open [ ]: $(count '^- \[ \]' DOS/Backlog.md)   done [x]: $(count '^- \[x\]' DOS/Backlog.md)"
say "Board     lines: $(count '^- ' DOS/TODO-Board.md)"
say ""
say "Cold-shaped headings still inside the Brief (should live in Backlog):"
grep -nE '^#{2,3} .*(Watch|Backlog|Low Priority|Reading|Time-gated|Next 2 Weeks|Carried|Completed|Done)' "$BRIEF" \
  | sed 's/^/  🟡 /' || say "  ✅ none"
say "Checked-off items still in the Brief (belong in Backlog, or deleted): $(count '^- \[x\]' "$BRIEF")"

# ------------------------------------------------------ frontmatter drift
hdr "FRONTMATTER DRIFT (updated: vs last git commit touching the file)"
for f in "$BRIEF" DOS/TODO-Board.md DOS/Backlog.md DOS/Brag.md DOS/Growth.md \
         DOS/Opportunities.md DOS/30-60-90.md DOS/Reference/*.md; do
  [ -f "$f" ] || continue
  fm=$(grep -m1 -E '^(updated|generated):' "$f" 2>/dev/null | sed -E 's/^[a-z]+: *//' | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')
  git_d=$(git log -1 --format=%ad --date=short -- "$f" 2>/dev/null)
  [ -z "$fm" ] && { say "  ⚠️  no updated: field — $f"; continue; }
  if [ "$fm" != "$git_d" ]; then say "  🟡 fm=$fm  git=$git_d  $f"; else say "  ✅ $fm  $f"; fi
done

# ------------------------------------------------------------ journal
hdr "JOURNAL — roll-up coverage + entry size trend"
for w in $(ls -d DOS/Journal/*/week-* 2>/dev/null | sort -t- -k2 -n); do
  # Dated dailies only — prep docs and drafts in the same dir aren't "entries".
  dailies=$(find "$w" -type f -name '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md')
  n=$(printf '%s' "$dailies" | grep -c . || true)
  other=$(( $(find "$w" -type f -name '*.md' | wc -l | tr -d ' ') - n ))
  if [ "$n" -gt 0 ]; then
    tot=$(printf '%s\n' "$dailies" | tr '\n' '\0' | xargs -0 cat 2>/dev/null | wc -c | tr -d ' ')
    avg=$((tot / n))
  else avg=0; fi
  roll=$([ -f "$w/weekly-rollup.md" ] && echo "rollup ✅" || echo "rollup ❌ MISSING")
  warn=""; [ "$avg" -gt 25000 ] && warn="  🟡 entries oversized"
  printf '  %-10s %2d dailies (+%d other)  avg %6d chars  %s%s\n' \
    "$(basename "$w")" "$n" "$other" "$avg" "$roll" "$warn"
done
say "  Daily entries averaging >25k chars are a cost: /manager-1-1 reads a multi-day"
say "  window of them. The CURRENT week's missing roll-up is expected; earlier gaps are real."

# ------------------------------------------------------- structural cruft
hdr "STRUCTURAL CRUFT"
find DOS -type d -empty 2>/dev/null | sed 's/^/  🟡 empty dir: /'
for f in DOS/Memory/MEMORY.md; do
  [ -f "$f" ] && [ "$(wc -c < "$f" | tr -d ' ')" -lt 500 ] && \
    say "  🟡 vestigial stub ($(wc -c < "$f" | tr -d ' ') chars): $f — auto-memory store superseded it"
done
say "Duplicate H2 headings within a single file:"
for f in DOS/*.md DOS/Reference/*.md DOS/Showcase/*.md; do
  [ -f "$f" ] || continue
  d=$(grep -E '^## ' "$f" | sort | uniq -d)
  [ -n "$d" ] && { say "  🔴 $f:"; printf '%s\n' "$d" | sed 's/^/       /'; }
done
say "  (silence above = clean)"

# ------------------------------------------------------------- pointers
hdr "BROKEN POINTERS (path-style refs to files that don't exist)"
# Placeholders in docs are intentional, not broken: cycle-N, [name], [year], week-[week].
grep -rhoE '`(DOS|Wiki|bin)/[A-Za-z0-9._/-]+\.(md|sh)`' \
     DOS/*.md DOS/Reference/*.md .claude/commands/*.md 2>/dev/null \
  | tr -d '`' | sort -u \
  | grep -vE '(\[|\]|cycle-N|/N\.|name\.md|year)' \
  | while read -r p; do [ -e "$p" ] || say "  🔴 missing: $p"; done
say "  (silence above = all pointers resolve; [placeholder] paths are skipped by design)"

# Bare week-relative refs are the dominant citation style in DOS, and the most
# error-prone: a file authored on Monday of week N+1 gets cited as week N.
# Where the basename exists under a DIFFERENT week, report the correct path.
say ""
say "Miscited week-relative journal refs (file exists, wrong week):"
grep -rhoE 'week-[0-9]+/[A-Za-z0-9._-]+\.md' DOS/*.md DOS/Reference/*.md .claude/commands/*.md 2>/dev/null \
  | sort -u | while read -r p; do
      find DOS/Journal -path "*/$p" -print -quit 2>/dev/null | grep -q . && continue
      real=$(find DOS/Journal -name "$(basename "$p")" -print -quit 2>/dev/null)
      say "  🔴 $p  ->  ${real:-NOT FOUND ANYWHERE}"
    done
say "  (silence = clean. 'NOT FOUND ANYWHERE' means the artefact was never written"
say "   or was deleted — check whether the citing item is still live.)"

hdr "SHOWCASE COVERAGE"
ls DOS/Showcase/ 2>/dev/null | sed 's/^/  /'
say "  Cross-check against the current cycle in the Brief — a delivered cycle with no file is a gap."

printf '\n=== END — interpret per .claude/commands/dos-lint.md ===\n'
