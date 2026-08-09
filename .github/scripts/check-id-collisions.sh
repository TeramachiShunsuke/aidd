#!/usr/bin/env bash
# Report document ids that another branch already uses for a different file.
#
# Git does not report a conflict when two branches introduce the same id under
# different filenames, so the collision stays invisible until both land (see
# EVID-021 / REV-006). This scan makes it visible while the PR is still open.
#
# Grade: warning (ADR-013). Which branch should renumber is not mechanically
# decidable, so this never fails the build.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

SCOPE_DIRS=(evidence adr playbook reviews)
SELF_REF="${SELF_REF:-HEAD}"
REMOTE="${REMOTE:-origin}"

note() { printf '%s\n' "$*"; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# id<TAB>path for one ref
ids_of_ref() {
  local ref="$1"
  git ls-tree -r --name-only "$ref" -- "${SCOPE_DIRS[@]}" 2>/dev/null | while read -r f; do
    [[ "$f" == *.md ]] || continue
    git show "$ref:$f" 2>/dev/null | awk -v path="$f" '
      BEGIN { in_fm = 0; seen = 0 }
      /^---[[:space:]]*$/ {
        if (seen == 0) { in_fm = 1; seen = 1; next }
        if (in_fm == 1) { exit }
      }
      in_fm == 1 && /^id:[[:space:]]/ {
        sub(/^id:[[:space:]]*/, "", $0)
        gsub(/[[:space:]]+$/, "", $0)
        print $0 "\t" path
        exit
      }
    '
  done
}

note "== aidd id collision scan =="
note "self=$SELF_REF remote=$REMOTE"

ids_of_ref "$SELF_REF" | sort -u >"$TMP/self.tsv"
self_count="$(wc -l <"$TMP/self.tsv" | tr -d ' ')"
note "scanned $self_count ids on $SELF_REF"

found=0
scanned_branches=0
while read -r ref; do
  [[ -z "$ref" ]] && continue
  case "$ref" in
    */HEAD) continue ;;
  esac
  # Branches already contained in this ref cannot collide with it.
  if git merge-base --is-ancestor "$ref" "$SELF_REF" 2>/dev/null; then
    continue
  fi
  scanned_branches=$((scanned_branches + 1))
  ids_of_ref "$ref" | sort -u >"$TMP/other.tsv"
  while IFS=$'\t' read -r id path; do
    [[ -z "$id" ]] && continue
    other_path="$(awk -F'\t' -v id="$id" '$1 == id { print $2; exit }' "$TMP/other.tsv")"
    [[ -z "$other_path" ]] && continue
    [[ "$other_path" == "$path" ]] && continue
    note "WARN: $id is '$path' here but '$other_path' on ${ref#refs/remotes/}"
    found=$((found + 1))
  done <"$TMP/self.tsv"
done < <(git for-each-ref --format='%(refname)' "refs/remotes/$REMOTE/")

note "-- summary --"
note "compared against $scanned_branches branch(es); $found collision(s)"
if (( found > 0 )); then
  note "See PB-015 for how to renumber. The branch that lands on main first keeps its number."
fi
exit 0
