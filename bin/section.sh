#!/usr/bin/env bash
# section.sh <file> <H2 heading prefix>... — print only the named H2 sections
f="$1"; shift
for h in "$@"; do
  awk -v want="$h" '
    /^## /{ on = (index($0, "## " want) == 1) }
    on { print }
  ' "$f"
done
