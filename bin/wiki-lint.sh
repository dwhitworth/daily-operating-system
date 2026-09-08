#!/usr/bin/env bash
# wiki-lint.sh — mechanical health measurement for Wiki/. Cheap by design.
#
# Sibling to bin/dos-lint.sh, and it exists for the same reason: reading 46 people
# files to check whether they're stale costs ~120k tokens, which is the problem the
# lint is supposed to find. This prints dates, counts and paths only — never content.
#
# The judgement steps (index semantics, orphan intent, contradictions, suggestions)
# stay in .claude/commands/wiki-lint.md. This script does the parts a machine can do.
# Run from the repo root.

cd "$(git rev-parse --show-toplevel)" || exit 1

PEOPLE="Wiki/wiki/people"
say() { printf '%s\n' "$*"; }
hdr() { printf '\n=== %s ===\n' "$*"; }
today_s=$(date +%s)

# ------------------------------------------------- identity-section staleness
# 🔴 THE CHECK THIS SCRIPT WAS BUILT FOR (07/09/2026).
# A people file's `updated:` field and its git date both LIE, because the bottom of
# the file (Key Interactions, Next Catchup Agenda, Open Loops) churns daily while the
# identity sections at the top rot untouched for months. Specimen: on 07/09 Sam's
# file had been edited 03/09, and its § Role still said "Old Job Title" (retitled
# Director 30/07) and named Chris Doyle — who left 24/07 — as their incoming manager.
# Every earlier lint passed it, because every earlier check looked at the file.
#
# So: date each identity section SEPARATELY, and compare it against the file's own
# newest line. A big gap is the signature of a file that looks maintained and isn't.
# Cost note: git blame once per file (~3s for 46 files) — the slowest part of the run,
# and still ~40x cheaper than reading the files.
hdr "IDENTITY-SECTION STALENESS (per-SECTION dates — the file's own date lies)"
say "  gap = days between the ORG-DERIVED sections (Role, Scope & Ownership) and the file's newest line"
say "  🔴 >90d  🟡 >45d"
say "  ⚠️ Working Style is shown but does NOT drive the flag — it's BEHAVIOURAL, so a reorg doesn't"
say "     invalidate it and an old date there is usually correct. Role and Scope are org-derived:"
say "     a retitle, a new domain or a squad split falsifies them the day it happens."
say ""
say "  file-last   Role        Scope&Own   WorkStyle   gap  file"
found_id=0
for f in "$PEOPLE"/*.md; do
  [ -e "$f" ] || continue
  case "$(basename "$f")" in _*) continue ;; esac
  out=$(git blame --line-porcelain -- "$f" 2>/dev/null | awk '
    /^author-time /  { t = $2 }
    /^\t/ {
      line = substr($0, 2)
      if (line ~ /^## /) { sec = line }
      if (t > gmax) gmax = t
      if (sec != "" && t > mx[sec]) mx[sec] = t
    }
    END {
      printf "%d %d %d %d", gmax+0, mx["## Role"]+0, mx["## Scope & Ownership"]+0, mx["## Working Style"]+0
    }')
  read -r g r s w <<<"$out"
  [ "${g:-0}" -gt 0 ] || continue
  # only the ORG-DERIVED sections drive the gap (see the legend above)
  oldest=$g
  for v in "$r" "$s"; do
    [ "${v:-0}" -gt 0 ] || continue
    [ "$v" -lt "$oldest" ] && oldest=$v
  done
  gap=$(( (g - oldest) / 86400 ))
  flag="  "
  [ "$gap" -gt 45 ] && flag="🟡"
  [ "$gap" -gt 90 ] && flag="🔴"
  [ "$gap" -gt 45 ] || continue
  found_id=1
  d() { [ "${1:-0}" -gt 0 ] && date -r "$1" +%Y-%m-%d || printf '%-10s' "—"; }
  say "$(printf '  %s %s  %s  %s  %s  %4dd %s' "$flag" "$(d "$g")" "$(d "$r")" "$(d "$s")" "$(d "$w")" "$gap" "$(basename "$f")")"
done
[ "$found_id" -eq 1 ] || say "  ✅ no identity section more than 45 days behind its own file"
say ""
say "  • A gap is a CANDIDATE, not a verdict. A role that genuinely hasn't changed is"
say "    correctly untouched — the finding is a section that contradicts current state."
say "  • Check the reorg first: squads (Access · Core Platform · Licensing, 28/08),"
say "    Sam = Director of Engineering (30/07), Morgan = Head of Engineering, formation 23/09."
say "  • Directs' § Scope & Ownership changes ON 23/09 — updating it before formation"
say "    means writing it twice. Sequence those to the formation pass, not to this lint."

# --------------------------------------------- retired facts in people files
# dos-lint sweeps the Brief and the command files for retired names. It never swept
# here, which is exactly how "Chris Doyle (Head of Engineering)" survived in the operator's
# manager's file for six weeks. Same watchlist, third scope widening.
# The subject's OWN file is skipped: chris-doyle.md is allowed to say Chris.
hdr "RETIRED FACTS IN LIVE PEOPLE FILES (candidates — history/ and the subject's own file skipped)"
for n in "Chris" "Old Job Title" "Dead Workstream" "Renamed Domain" "acting manager" "Merged Scope"; do
  slug=$(printf '%s' "$n" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z')
  files=$(grep -rlF "$n" "$PEOPLE" --include="*.md" 2>/dev/null | grep -v '/history/' || true)
  [ -n "$slug" ] && files=$(printf '%s\n' "$files" | grep -v "/${slug}-" || true)
  [ -n "$files" ] || continue
  say "  🟡 \"$n\" — $(printf '%s\n' "$files" | grep -c . ) file(s):"
  printf '%s\n' "$files" | sed "s|$PEOPLE/|       |"
done
say "  (Many are legitimate: correctly-dated history, or a \"was X\" correction still doing"
say "   work. Rule each one with the expiry test in dos-lint.md step 2 — don't bulk-edit.)"

# ------------------------------------------------------------- hot file sizes
hdr "HOT FILE SIZES (people >30k want a history/ pass; projects are sliced by /weekly-scan)"
awk 'END{}' /dev/null
for d in "$PEOPLE" Wiki/wiki/projects; do
  say "  $d/"
  find "$d" -maxdepth 1 -name '*.md' -exec wc -c {} + 2>/dev/null \
    | sort -rn | grep -v ' total$' | head -6 \
    | awk '{ f=$2; sub(".*/","",f); flag = ($1>30000) ? "🔴" : (($1>25000) ? "🟡" : "✅"); printf "    %s %7d  %s\n", flag, $1, f }'
done

# ---------------------------------------------------------- structural checks
hdr "DUPLICATE + NEAR-DUPLICATE H2s (a 2nd section with the same job splits the record)"
say "  ⚠️ A 'near-duplicate' with stray punctuation in it is usually not a duplicate at all"
say "     — it's a BAD SPLICE that left prose starting with '## ', which markdown then"
say "     renders as a heading. 07/09 specimen: priya-raman.md line 55."
found_h2=0
for f in "$PEOPLE"/*.md Wiki/wiki/projects/*.md; do
  [ -e "$f" ] || continue
  dup=$(grep '^## ' "$f" | sort | uniq -d)
  [ -n "$dup" ] && { found_h2=1; say "  🔴 exact duplicate in $(basename "$f"): $(printf '%s' "$dup" | tr '\n' '|')"; }
  # near-duplicates: two H2s where one's name is a prefix of the other
  near=$(grep '^## ' "$f" | sed 's/^## //' | awk '{a[NR]=$0} END{for(i=1;i<=NR;i++)for(j=1;j<=NR;j++) if(i!=j && index(a[j],a[i])==1 && length(a[j])>length(a[i])) print a[i]" ~ "a[j]}')
  [ -n "$near" ] && { found_h2=1; say "  🟡 near-duplicate in $(basename "$f"): $near"; }
done
[ "$found_h2" -eq 1 ] || say "  ✅ clean"

hdr "COLD CONTENT IN HOT FILES (belongs in people/history/)"
found_cold=0
for f in "$PEOPLE"/*.md; do
  [ -e "$f" ] || continue
  ki=$(grep -c '^### ' "$f" 2>/dev/null || true)
  rl=$(sed -n '/^## Recognition Log/,/^## /p' "$f" 2>/dev/null | grep -c '^- \|^### ' || true)
  [ "${rl:-0}" -gt 2 ] && { found_cold=1; say "  🟡 $(basename "$f"): § Recognition Log holds ${rl} entry lines (a pointer stub is what belongs here)"; }
done
[ "$found_cold" -eq 1 ] || say "  ✅ no Recognition Log carrying dated entries inline"

hdr "HISTORY PAIRING + NAMING"
for h in "$PEOPLE"/history/*.md; do
  [ -e "$h" ] || continue
  b=$(basename "$h")
  [ -f "$PEOPLE/$b" ] || say "  🔴 history/$b has NO live counterpart"
  n=$(sed -n '/^## Key Interactions/,$p' "$h" | grep -c '^### ' || true)
  [ "${n:-0}" -eq 0 ] && say "  🟡 history/$b § Key Interactions is empty — delete it and its pointer"
done
bad=$(find "$PEOPLE" -name '*.md' | grep -v '/_' | grep -vE '/[a-z0-9]+(-[a-z0-9]+)*\.md$' || true)
[ -n "$bad" ] && say "  🔴 not lowercase-kebab-case:" && printf '%s\n' "$bad" | sed 's/^/       /'
say "  (silence above = paired, named and non-hollow)"

hdr "INDEX INTEGRITY (Wiki/index.md — history/ is deliberately unindexed, never a finding)"
missing=0
grep -oE '\(\.?/?wiki/[a-z0-9/-]+\.md\)|\[\[[a-z0-9-]+\]\]' Wiki/index.md 2>/dev/null \
  | tr -d '()[]' | sed 's|^\./||' | sort -u | while read -r ref; do
      case "$ref" in
        wiki/*) [ -f "Wiki/$ref" ] || say "  🔴 listed in index, not on disk: $ref" ;;
        *)      ls Wiki/wiki/*/"$ref".md >/dev/null 2>&1 || say "  🔴 [[${ref}]] in index resolves to nothing" ;;
      esac
    done
unlisted=$(for f in Wiki/wiki/*/*.md; do b=$(basename "$f" .md); grep -qF "$b" Wiki/index.md || echo "$f"; done)
[ -n "$unlisted" ] && say "  🟡 on disk, absent from index (orphan candidates):" && printf '%s\n' "$unlisted" | sed 's|^|       |'

printf '\n=== END — interpret per .claude/commands/wiki-lint.md ===\n'
