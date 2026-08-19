#!/usr/bin/env bash
# Report document ids that another ref already uses for a different file.
#
# Git does not report a conflict when two branches introduce the same id under
# different filenames, so the collision stays invisible until both land (see
# EVID-021 / EVID-023 / REV-006). This scan makes it visible while the PR is
# still open.
#
# Grades (ADR-013 / ADR-018):
#   error   - the base branch took the id after we branched. The fix is unique:
#             this branch renumbers, because main never rewrites its past.
#   warning - another unmerged branch uses the id. Which side should renumber is
#             not mechanically decidable; whoever lands on main first keeps it.
#
# Usage:
#   check-id-collisions.sh            scan for collisions
#   check-id-collisions.sh --next ID  print the next free number for a prefix
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

SCOPE_DIRS=(evidence adr playbook reviews)
NEXT_DIRS=(evidence adr playbook reviews ledger)
SELF_REF="${SELF_REF:-HEAD}"
REMOTE="${REMOTE:-origin}"
BASE_REF="${BASE_REF:-refs/remotes/$REMOTE/main}"

note() { printf '%s\n' "$*"; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

remote_refs() {
  git for-each-ref --format='%(refname)' "refs/remotes/$REMOTE/" | grep -v '/HEAD$' || true
}

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

# --- --next -----------------------------------------------------------------
# Scans every ref, not just this branch, so the number is free across all open
# work (ADR-018 decision 2). Mentions of an id count as taken, which can only
# over-reserve, never hand out a number someone else is already using.
next_id() {
  local prefix="$1"
  prefix="${prefix%%-*}"
  prefix="$(printf '%s' "$prefix" | tr '[:lower:]' '[:upper:]')"

  {
    grep -rhoE "\b${prefix}-[0-9]+\b" "${NEXT_DIRS[@]}" 2>/dev/null || true
    while read -r ref; do
      [[ -z "$ref" ]] && continue
      git grep -hoE "\b${prefix}-[0-9]+\b" "$ref" -- "${NEXT_DIRS[@]}" 2>/dev/null || true
    done < <(remote_refs)
  } | sed "s/^${prefix}-//" | sed 's/^0*//' | grep -E '^[0-9]+$' | sort -n | tail -1 >"$TMP/max" || true

  local max
  max="$(cat "$TMP/max" 2>/dev/null || true)"
  [[ -z "$max" ]] && max=0
  printf '%s-%05d\n' "$prefix" "$((max + 1))"
}

if [[ "${1:-}" == "--next" ]]; then
  if [[ -z "${2:-}" ]]; then
    note "usage: check-id-collisions.sh --next <PREFIX>   (EVID, ADR, PB, REV, CLAIM, OQ)"
    exit 2
  fi
  next_id "$2"
  exit 0
fi

# --- collision scan ---------------------------------------------------------
note "== aidd id collision scan =="
note "self=$SELF_REF base=${BASE_REF#refs/remotes/} remote=$REMOTE"

ids_of_ref "$SELF_REF" | sort -u >"$TMP/self.tsv"
self_count="$(wc -l <"$TMP/self.tsv" | tr -d ' ')"
note "scanned $self_count ids on $SELF_REF"

errors=0
warnings=0

# 1. Against the base branch: error. A path that the base holds but that did not
#    exist at the merge base means the base took the id while we were open. A
#    path that already existed at the merge base means we renamed a file, which
#    is a different problem and not this check's business.
if git rev-parse --verify --quiet "$BASE_REF" >/dev/null; then
  MERGE_BASE="$(git merge-base "$SELF_REF" "$BASE_REF" 2>/dev/null || true)"
  ids_of_ref "$BASE_REF" | sort -u >"$TMP/base.tsv"
  while IFS=$'\t' read -r id path; do
    [[ -z "$id" ]] && continue
    base_path="$(awk -F'\t' -v id="$id" '$1 == id { print $2; exit }' "$TMP/base.tsv")"
    [[ -z "$base_path" ]] && continue
    [[ "$base_path" == "$path" ]] && continue
    if [[ -n "$MERGE_BASE" ]] && git cat-file -e "$MERGE_BASE:$base_path" 2>/dev/null; then
      continue
    fi
    note "ERROR: $id is '$path' here but '$base_path' on ${BASE_REF#refs/remotes/}"
    errors=$((errors + 1))
  done <"$TMP/self.tsv"
else
  note "note: $BASE_REF not available; skipping the base-branch check"
fi

# 2. Against every other unmerged branch: warning.
scanned_branches=0
while read -r ref; do
  [[ -z "$ref" ]] && continue
  [[ "$ref" == "$BASE_REF" ]] && continue
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
    warnings=$((warnings + 1))
  done <"$TMP/self.tsv"
done < <(remote_refs)

note "-- summary --"
note "compared against ${BASE_REF#refs/remotes/} and $scanned_branches other branch(es)"
note "$errors error(s), $warnings warning(s)"
if (( errors > 0 || warnings > 0 )); then
  note "See PB-015 for how to renumber, and '--next <PREFIX>' for a free number."
fi
if (( errors > 0 )); then
  note "Errors must be fixed here: the base branch keeps its numbers (ADR-018)."
  exit 1
fi
exit 0
