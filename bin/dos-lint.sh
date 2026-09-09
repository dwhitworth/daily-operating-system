#!/usr/bin/env bash
# dos-lint.sh — mechanical health measurement for DOS/. Cheap by design.
#
# Prints a compact report. Reads NO file contents into the output — only counts,
# sizes and paths — so /dos-lint can run without loading the very files whose
# size it's complaining about. Run from the repo root.

cd "$(git rev-parse --show-toplevel)" || exit 1

BRIEF="DOS/Standing Brief.md"
BOARD="DOS/Battle-Board.md"
say() { printf '%s\n' "$*"; }
hdr() { printf '\n=== %s ===\n' "$*"; }

# ------------------------------------------------------------------- CONFIG
# 🔴 SITE-SPECIFIC. The retired-name watchlist IS the stale-fact check — an empty list
# means that section does nothing. Add every fact the org has moved past: a departed
# person, an old title, a dead workstream, a superseded team shape.
#
# Keep it TIGHT. A term that matches something legitimate makes the section noisy, and a
# noisy section gets skipped. One entry was tried and dropped because it matched a live
# instruction in the Brief; the retirement it covered was already caught by another term.
RETIRED_NAMES=(
  "Chris"
  "Old Job Title"
  "Dead Workstream"
  "Renamed Domain"
  "Merged Scope"
  "acting manager"
  "Jordan Blake (2 eng)"
)

# Marker glyphs the readability check counts. Extend if your artefacts use others.
MARKERS='🔴|🆕|⭐|⚠️|✅|🟡|🟢|⚡|⏸️|👁️|🪤|📄|🎁|🎯|🥇|🥈|🥉|🔌'
# --------------------------------------------------------------- END CONFIG

# A fresh clone has none of the operator's own files yet. Skip those sections cleanly
# rather than emitting a wall of "No such file" — a lint that errors is a lint nobody runs.
have_brief=0; [ -f "$BRIEF" ] && have_brief=1
have_board=0; [ -f "$BOARD" ] && have_board=1
have_journal=0; [ -d "DOS/Journal" ] && have_journal=1

# ---------------------------------------------------------------- hot files
hdr "HOT FILE SIZES (loaded every session — a size smell means check PLACEMENT)"
if [ "$have_brief" -eq 0 ]; then
  say "  ⚠️  no $BRIEF yet — copy DOS/_examples/'Standing Brief.md' and make it yours (see SETUP-GUIDE.md)"
  brief_c=0
else
  brief_c=$(wc -c < "$BRIEF" | tr -d ' ')
  say "$(printf '%7d chars  %6d tok  %s' "$brief_c" "$((brief_c / 4))" "Standing Brief  [smell >60000 — check PLACEMENT, size is a symptom]")"
  if   [ "$brief_c" -gt 80000 ]; then say "  🔴 OVER HARD LIMIT — prune before writing anything new"
  elif [ "$brief_c" -gt 60000 ]; then say "  🟡 size smell — likely misplacement, see DOS/Reference/"
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
latest=""
[ "$have_journal" -eq 1 ] && latest=$(find DOS/Journal -name '2*.md' -type f | sort | tail -1)
[ -n "$latest" ] && floor=$((floor + $(wc -c < "$latest" | tr -d ' ')))
say "$(printf '%6d tok  base (context files + Brief + latest journal: %s)' "$((floor / 4))" "${latest:+$(basename "$latest")}${latest:-none yet}")"
say "        + ~4k tok per attendee people-file slice"

# ------------------------------------------------------------ cold files
hdr "COLD FILES (read on demand — size is cheap, but check they're not hot by accident)"
for f in DOS/Backlog.md DOS/Reference/*.md DOS/30-60-90.md DOS/Brag.md DOS/Growth.md DOS/Opportunities.md; do
  [ -f "$f" ] && say "$(printf '%7d chars  %6d tok  %s' "$(wc -c < "$f" | tr -d ' ')" "$(( $(wc -c < "$f" | tr -d ' ') / 4 ))" "$f")"
done

# --------------------------------------------------- Brief/Backlog boundary
hdr "BRIEF / BACKLOG BOUNDARY (line is this-week vs not-this-week, NOT priority)"
if [ "$have_brief" -eq 0 ]; then
  say "  (skipped — no Standing Brief yet)"
else
# grep -c exits 1 on zero matches, so capture without tripping set -e semantics.
count() { grep -cE "$1" "$2" 2>/dev/null | head -1; }
say "Brief   open [ ]: $(count '^- \[ \]' "$BRIEF")   done [x]: $(count '^- \[x\]' "$BRIEF")"
say "Backlog open [ ]: $(count '^- \[ \]' DOS/Backlog.md)   done [x]: $(count '^- \[x\]' DOS/Backlog.md)"
if [ "$have_board" -eq 1 ]; then
board_today=$(sed -n '/^## .* Today/,/^## /p' "$BOARD" 2>/dev/null)
say "Board     lines: $(count '^- ' "$BOARD")   today OPEN: $(printf '%s' "$board_today" | grep -c '^- \[ \]' || true)/8   done: $(printf '%s' "$board_today" | grep -c '^- \[x\]' || true)"
# The Contract section documents the FORMAT (it explains sub-bullets), so its own
# indented lines are prose, not items. Counting them made the check permanently
# non-zero, which is how a check gets ignored. Measure above the Contract only.
board_items=$(sed '/^## .*Contract/,$d' "$BOARD" 2>/dev/null)
say "Board sub-bullets (must be 0): $(printf '%s' "$board_items" | grep -c '^  \+- ' || true)  (§ Contract excluded — it documents the format)"

# --- NEXT SLOT: the one line they read first. A wrong or stale Next is worse than none,
# --- because they acts on it without re-reading Today.
next_block=$(sed -n '/^## .*Next$/,/^## /p' "$BOARD" 2>/dev/null | grep '^- ' || true)
next_count=$(printf '%s' "$next_block" | grep -c '^- ' || true)
today_first=$(printf '%s' "$board_today" | grep -m1 '^- \[ \]' || true)
today_open=$(printf '%s' "$board_today" | grep -c '^- \[ \]' || true)
# Compare on substance, not decoration: Next may carry the marker or not.
norm() { printf '%s' "$1" | sed 's/🔴//g; s/⭐//g; s/⚠️//g; s/  */ /g; s/ *$//'; }
if [ -z "$next_block" ] && [ "$next_count" -eq 0 ]; then
  say "Next slot: ❌ MISSING — add '## ▶ Next' above Today with exactly one item"
elif [ "$next_count" -ne 1 ]; then
  say "Next slot: ❌ holds $next_count items, must hold exactly 1"
elif [ "$(norm "$next_block")" != "$(norm "$today_first")" ]; then
  say "Next slot: ❌ does not match Today's top open line — one of them is stale"
  say "    next : $next_block"
  say "    today: $today_first"
else
  say "Next slot: ✅ one item, matches Today's top line"
  case "$next_block" in
    *[Ww]aiting*|*"is raising"*|*"when "*|*"once "*|*"chasing"*)
      say "    🟡 reads like a wait, not an action — Next must be startable now" ;;
  esac
fi
[ "$today_open" -gt 8 ] && say "Today cap: ❌ $today_open open, cap is 8 — the cap EVICTS, name what leaves" \
                        || say "Today cap: ✅ $today_open/8 open"
else
say "Board: no $BOARD yet — copy DOS/_templates/Battle-Board.md"
fi
say ""
say "Cold-shaped headings still inside the Brief (should live in Backlog):"
grep -nE '^#{2,3} .*(Watch|Backlog|Low Priority|Reading|Time-gated|Next 2 Weeks|Carried|Completed|Done)' "$BRIEF" \
  | sed 's/^/  🟡 /' || say "  ✅ none"
say "Checked-off items still in the Brief (belong in Backlog, or deleted): $(count '^- \[x\]' "$BRIEF")"
fi

# ---------------------------------------------------- stale hot facts
if [ "$have_brief" -eq 1 ]; then
# Everything below is CANDIDATES, never verdicts. The 01/09/2026 prune found four
# classes of rot that every existing check passed: "expected to split" (a concrete
# dated event written as anticipation), "seconded until 31/08" (a date that had
# passed), "Core Services (5 eng)" one section away from "6 engineers", and a departed
# person carried with biography five weeks after they left. All four are cheap to spot
# mechanically and impossible to judge mechanically — so print the line, don't rule.
hdr "STALE HOT FACTS in the Brief (candidates for the EXPIRY TEST — see /dos-lint step 2)"
today_iso=$(date +%Y-%m-%d)

say "Past dates written as pending (until/by/due/expected/this week + a date now behind us):"
grep -nE '(until|by|due|deadline|expected|pending|this week|next week|later this week)[^.]{0,60}[0-9]{1,2}/[0-9]{1,2}' "$BRIEF" \
  | while IFS=: read -r ln rest; do
      # take every DD/MM on the line; flag if any is >7 days in the past this year
      for d in $(printf '%s' "$rest" | grep -oE '\b[0-9]{1,2}/[0-9]{1,2}\b'); do
        dd=${d%%/*}; mm=${d##*/}
        [ "$mm" -ge 1 ] 2>/dev/null && [ "$mm" -le 12 ] || continue
        iso=$(printf '%s-%02d-%02d' "$(date +%Y)" "$mm" "$dd" 2>/dev/null) || continue
        if [ "$iso" \< "$today_iso" ]; then
          days=$(( ( $(date -j -f %Y-%m-%d "$today_iso" +%s 2>/dev/null || date -d "$today_iso" +%s) \
                   - $(date -j -f %Y-%m-%d "$iso" +%s 2>/dev/null || date -d "$iso" +%s) ) / 86400 ))
          [ "$days" -gt 7 ] && say "  🟡 L$ln  ${d} (${days}d ago): $(printf '%s' "$rest" | cut -c1-70)"
          break
        fi
      done
    done
say "  (a past date is fine as PROVENANCE — 'agreed 28/08'. It is a finding when the sentence"
say "   still reads as a commitment: 'seconded until 31/08', 'due 30/08', 'later this week'.)"

say ""
say "Anticipatory language in the identity sections (Role Context / Org Structure / Team"
say "should assert CURRENT state — 'expected to split' outlived a dated, concrete decision):"
awk '/^## Role Context/,/^## Projects in Flight/' "$BRIEF" \
  | grep -nE '(expected to|will likely|likely to|TBC|TBD|for now|not yet decided|up for debate)' \
  | sed 's/^/  🟡 /' | cut -c1-90 || say "  ✅ none"

say ""
# ⚠️ SCOPE: sweep the Brief AND the command files. A retired name inside a command is
# strictly worse than one in the Brief, because the command re-injects it on every run —
# 07/09 found Chris (gone 24/07) still in /weekly-scan's engagement roster, /weekly-rollup's
# air-cover line, and /manager-1-1's opening line (which also still called Sam "Old Job Title"),
# six weeks after the Brief itself was corrected. See the *verify-identifiers* rule.
# dos-lint.md is EXCLUDED from the command sweep: it carries the watchlist, so every term
# appears there by design and counting it would make this section permanently noisy.
# Terms stay TIGHT. "Kiran" was tried and dropped 07/09 — it matched a live do-not-discuss
# instruction in the Brief; "Dead Workstream" already covers that retirement.
say "Retired names still present (extend RETIRED_NAMES in the CONFIG block — it is the whole check):"
if [ ${#RETIRED_NAMES[@]} -eq 0 ]; then
  say "  ⚠️  RETIRED_NAMES is empty — this check is doing nothing. Populate it (see CONFIG)."
else
for n in "${RETIRED_NAMES[@]}"; do
  for tgt in "$BRIEF" .claude/commands .pi/prompts; do
    if [ "$tgt" = "$BRIEF" ]; then
      hits=$(grep -cF "$n" "$BRIEF" 2>/dev/null | head -1)
      [ "${hits:-0}" -gt 0 ] || continue
      say "  🟡 ${hits}× \"$n\"  Brief (lines: $(grep -nF "$n" "$BRIEF" | cut -d: -f1 | tr '\n' ' '))"
    else
      files=$(grep -rlF "$n" "$tgt" --include="*.md" 2>/dev/null | grep -v 'dos-lint\.md$' || true)
      [ -n "$files" ] || continue
      say "  🔴 \"$n\" in $tgt — a command re-injects it EVERY run:"
      printf '%s\n' "$files" | sed 's/^/       /'
    fi
  done
done
fi
say "  (0 hits = silence. A hit is only a finding if the fact is asserted as CURRENT;"
say "   a correction that still earns its place reads 'X (was Y)' — see the expiry test.)"

say ""
say "Headcount claims across the Brief (they must agree — 01/09 had '5 eng' vs '6 engineers'):"
grep -noE '\(?[0-9]+ (eng|engineers)\b' "$BRIEF" | sed 's/^/  /' | head -12
say "  (differing numbers are not automatically wrong — squad vs group vs available — but two"
say "   numbers for the SAME scope is a contradiction a reader will hit before you do.)"

say ""
say "Strikethrough corrections in the Brief (each one is a candidate for the expiry test): $(count '~~' "$BRIEF")"
else
say ""
hdr "STALE HOT FACTS in the Brief"
say "  (skipped — no Standing Brief yet)"
fi

# ------------------------------------------------------ frontmatter drift
hdr "FRONTMATTER DRIFT (updated: vs last git commit touching the file)"
for f in "$BRIEF" "$BOARD" DOS/Backlog.md DOS/Brag.md DOS/Growth.md \
         DOS/Opportunities.md DOS/30-60-90.md DOS/Reference/*.md; do
  [ -f "$f" ] || continue
  fm=$(grep -m1 -E '^(updated|generated):' "$f" 2>/dev/null | sed -E 's/^[a-z]+: *//' | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')
  git_d=$(git log -1 --format=%ad --date=short -- "$f" 2>/dev/null)
  [ -z "$fm" ] && { say "  ⚠️  no updated: field — $f"; continue; }
  if [ "$fm" != "$git_d" ]; then say "  🟡 fm=$fm  git=$git_d  $f"; else say "  ✅ $fm  $f"; fi
done

# ------------------------------------------------------------ journal
hdr "JOURNAL — roll-up coverage + entry size trend"
if [ "$have_journal" -eq 0 ]; then
  say "  (no DOS/Journal yet — /daily-wrap writes the first entry)"
else
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
fi

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
say "  (silence above = all pointers resolve; [placeholder] paths are skipped by design.)"
say "  On a fresh clone, the files YOU create are expected here: Standing Brief, Battle-Board,"
say "  Backlog, Brag, Growth, Opportunities, 30-60-90, Wiki/index.md, Wiki/log.md, people files."
say "  Once they exist, anything left in this list is a real dangling reference."

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

# --------------------------------------------------- readability (layout)
# Layout failure is invisible to every size check: the 28/08 Sam prep doc was
# 12k chars (well inside budget) and unreadable at 11:25 for an 11:30 — 48 of 54
# content lines were bold, so bold ranked nothing. Size lints pass it; this catches it.
# Applies to artefacts read under time pressure (frontmatter `reader: donovan-at-speed`).
# Budgets: bold on <=25% of content lines | longest bullet <=200 chars
#          | markers <=1 per 5 content lines (0.20).
hdr "READABILITY (prep docs + battle cards — layout, not size)"
MARK="$MARKERS"
say "  bold%  longest  mark/ln  reader           file"
found_rd=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  found_rd=1
  read -r cl bl mx <<<"$(awk '
    /^[[:space:]]*([-*]|[0-9]+\.)[[:space:]]/ { c++; if ($0 ~ /\*\*/) b++; if (length($0) > m) m = length($0) }
    END { printf "%d %d %d", c+0, b+0, m+0 }' "$f")"
  mk=$(grep -oE "$MARK" "$f" 2>/dev/null | wc -l | tr -d ' ' || true); mk=${mk:-0}
  rdr=$(sed -n '1,12{s/^reader:[[:space:]]*//p;}' "$f" 2>/dev/null | head -1); rdr=${rdr:-"(unset)"}
  [ "$cl" -gt 0 ] || continue
  bp=$(( bl * 100 / cl )); mr=$(( mk * 100 / cl ))
  flag="✅"
  [ "$bp" -gt 25 ] || [ "$mx" -gt 200 ] || [ "$mr" -gt 20 ] && flag="🟡"
  { [ "$bp" -gt 60 ] || [ "$mx" -gt 400 ]; } && flag="🔴"
  say "$(printf '  %s %3d%%  %5dch  %5s%%  %-16s %s' "$flag" "$bp" "$mx" "$mr" "$rdr" "$f")"
done <<<"$(find DOS/Journal -type f \( -name '1-1-prep-*.md' -o -name 'battle-card-*.md' \) 2>/dev/null | sort | tail -10)"
[ "$found_rd" -eq 1 ] || say "  (no prep docs or battle cards found)"
say "  budgets: bold <=25% | bullet <=200ch | markers <=20% | 🔴 = bold >60% or bullet >400ch"
say "  a doc over budget doesn't need cutting so much as RE-LAYING OUT: move ranked/parallel"
say "  items into a table with a verdict column so position carries rank instead of emphasis."

# ------------------------------------------------- command-copy divergence
# The third surface, and until 07/09/2026 it had ZERO lint coverage: every command
# exists twice (`.claude/commands/` for Claude Code, `.pi/prompts/` for pi) and the
# copies drift silently. This is the highest-leverage drift in the repo because a
# stale command REGENERATES ITS DEFECT ON EVERY RUN, in one harness only, which is
# why it's invisible: the harness you last fixed behaves correctly.
# Two differences are LEGITIMATE and are normalised away before diffing:
#   1. the pi copy's leading `---\ndescription: ...\n---` frontmatter block
#   2. harness-specific paths (`.pi/skills/...` vs `.claude/skills/...`)
# Anything left is drift. Report it; the script never rules on which copy is right.
# PI_ONLY_OK: files that are legitimately one-sided. A permanent false positive trains
# you to skip the whole section, so known-intentional cases are named here instead.
PI_ONLY_OK=" handoff.md "
hdr "COMMAND-COPY DIVERGENCE (.claude/commands vs .pi/prompts — a stale command re-runs its defect)"
norm() {
  awk 'NR==1 && $0=="---" { fm=1; next } fm==1 && $0=="---" { fm=2; next } fm==1 { next } { print }' "$1" \
    | sed -e 's#\.pi/skills/#.claude/skills/#g' -e 's#\.pi/prompts/#.claude/commands/#g'
}
say "  claude-only  pi-only  command"
found_cmd=0
for f in .claude/commands/*.md; do
  [ -e "$f" ] || continue
  b=$(basename "$f"); p=".pi/prompts/$b"
  if [ ! -f "$p" ]; then
    found_cmd=1; say "$(printf '  %s %s' '🔴' "MISSING IN .pi/prompts     $b")"; continue
  fi
  d=$(diff <(norm "$f") <(norm "$p") || true)
  l=$(printf '%s' "$d" | grep -c '^<' || true); r=$(printf '%s' "$d" | grep -c '^>' || true)
  l=${l:-0}; r=${r:-0}
  [ "$l" -eq 0 ] && [ "$r" -eq 0 ] && continue
  found_cmd=1
  flag="🟡"; [ $(( l + r )) -gt 10 ] && flag="🔴"
  say "$(printf '  %s %8s %8s  %s' "$flag" "$l" "$r" "$b")"
done
for p in .pi/prompts/*.md; do
  [ -e "$p" ] || continue
  b=$(basename "$p")
  case "$PI_ONLY_OK" in *" $b "*) continue ;; esac
  [ -f ".claude/commands/$b" ] || { found_cmd=1; say "  🟡 MISSING IN .claude/commands  $b"; }
done
[ "$found_cmd" -eq 1 ] || say "  ✅ all command pairs identical (modulo pi frontmatter + harness paths)"
say "  intentionally pi-only, not reported:$PI_ONLY_OK"
say "  🔴 = >10 differing lines. Diff a pair with:"
say "     diff .claude/commands/<cmd>.md .pi/prompts/<cmd>.md"
say "  The count does NOT say which copy is right — read the diff. Usually one copy got a"
say "  fix and the other did not, so the newer side wins; genuine harness differences are"
say "  normalised out above and should never appear here."

hdr "OWED DEBT RADAR (every OWED line needs a size + a since date; >14d escalates)"
owed_total=0; owed_bad=0; owed_old=0
today_s=$(date +%s)
while IFS= read -r line; do
  [ -z "$line" ] && continue
  owed_total=$((owed_total + 1))
  file=${line%%:*}; text=${line#*:}
  who=$(basename "$file" .md)
  has_size=$(printf '%s' "$text" | grep -cE '`?(5m|30m|block)`?' || true)
  since=$(printf '%s' "$text" | sed -nE 's|.*since ([0-9]{2})/([0-9]{2}).*|\2-\1|p' | head -1)
  if [ "$has_size" -eq 0 ] || [ -z "$since" ]; then
    owed_bad=$((owed_bad + 1))
    miss=""
    [ "$has_size" -eq 0 ] && miss="size"
    [ -z "$since" ] && miss="${miss:+$miss + }since"
    say "  ❌ $who — missing $miss"
  else
    y=$(date +%Y)
    s=$(date -j -f %Y-%m-%d "$y-$since" +%s 2>/dev/null || date -d "$y-$since" +%s 2>/dev/null || echo "$today_s")
    age=$(( (today_s - s) / 86400 ))
    if [ "$age" -gt 14 ]; then
      owed_old=$((owed_old + 1))
      say "  🟡 $who — ${age}d old, promote to Today regardless of the next 1:1"
    fi
  fi
done <<EOF
$(grep -rn 'OWED' Wiki/wiki/people/*.md 2>/dev/null | grep -v '_template.md' || true)
EOF
say "OWED lines: $owed_total total, $owed_bad untagged, $owed_old over 14 days"
[ "$owed_total" -lt 4 ] && say "  🟡 only $owed_total tagged across all people files — under-tagging is why debts surface at prep"

hdr "SHOWCASE COVERAGE"
ls DOS/Showcase/ 2>/dev/null | sed 's/^/  /'
say "  Cross-check against the current cycle in the Brief — a delivered cycle with no file is a gap."

printf '\n=== END — interpret per .claude/commands/dos-lint.md ===\n'
