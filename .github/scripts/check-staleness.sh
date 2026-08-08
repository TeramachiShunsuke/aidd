#!/usr/bin/env bash
# Staleness guards for the aidd knowledge base.
# Checks:
#   1) frozen immutability
#   2) last_reviewed sync on content changes
#   3) reviews/ append-only
#   4) 90-day last_reviewed expiry
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

BASE_REF="${BASE_REF:-origin/main}"
TODAY="${TODAY:-$(date -u +%F)}"
MAX_AGE_DAYS="${MAX_AGE_DAYS:-90}"
SCOPE_DIRS=(evidence adr playbook ledger reviews)

FAIL=0
note() { printf '%s\n' "$*"; }
fail() { note "ERROR: $*"; FAIL=1; }

has_base=0
if git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
  has_base=1
else
  note "WARN: base ref '$BASE_REF' not found; skipping diff-based checks"
fi

is_scoped() {
  local f="$1"
  for d in "${SCOPE_DIRS[@]}"; do
    case "$f" in
      "$d"/*.md|"$d"/*/*.md) return 0 ;;
    esac
    [[ "$f" == "$d/"* && "$f" == *.md ]] && return 0
  done
  return 1
}

extract_fm_value() {
  # usage: extract_fm_value <file-or--> <key>
  # reads YAML-ish frontmatter between --- markers
  local src="$1" key="$2"
  local content
  if [[ "$src" == "-" ]]; then
    content="$(cat)"
  else
    content="$(cat "$src")"
  fi
  printf '%s\n' "$content" | awk -v key="$key" '
    BEGIN { in_fm=0; seen=0 }
    /^---[[:space:]]*$/ {
      if (seen==0) { in_fm=1; seen=1; next }
      if (in_fm==1) { exit }
    }
    in_fm==1 {
      if ($0 ~ ("^" key ":[[:space:]]*")) {
        sub("^[^:]+:[[:space:]]*", "", $0)
        gsub(/[[:space:]]+$/, "", $0)
        print $0
        exit
      }
    }
  '
}

strip_last_reviewed() {
  awk '
    BEGIN { in_fm=0; seen=0 }
    /^---[[:space:]]*$/ {
      print
      if (seen==0) { in_fm=1; seen=1; next }
      if (in_fm==1) { in_fm=0; next }
    }
    in_fm==1 && $0 ~ /^last_reviewed:[[:space:]]*/ { next }
    { print }
  '
}

list_scoped_head_files() {
  git ls-files "${SCOPE_DIRS[@]}" | while read -r f; do
    [[ "$f" == *.md ]] && printf '%s\n' "$f"
  done
}

note "== aidd staleness check =="
note "today(UTC)=$TODAY max_age_days=$MAX_AGE_DAYS base=$BASE_REF"

# ---- 4) 90-day expiry (always) ----
note "-- check: 90-day last_reviewed expiry --"
while read -r f; do
  [[ -z "$f" ]] && continue
  lr="$(extract_fm_value "$f" last_reviewed || true)"
  st="$(extract_fm_value "$f" status || true)"
  if [[ -z "$lr" ]]; then
    fail "$f: missing last_reviewed"
    continue
  fi
  if [[ ! "$lr" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    fail "$f: invalid last_reviewed='$lr'"
    continue
  fi
  # GNU date
  lr_epoch="$(date -u -d "$lr" +%s 2>/dev/null || true)"
  today_epoch="$(date -u -d "$TODAY" +%s)"
  if [[ -z "$lr_epoch" ]]; then
    fail "$f: cannot parse last_reviewed='$lr'"
    continue
  fi
  age_days=$(( (today_epoch - lr_epoch) / 86400 ))
  if (( age_days > MAX_AGE_DAYS )); then
    fail "$f: last_reviewed=$lr is ${age_days}d old (>${MAX_AGE_DAYS}d) status=${st:-unknown}"
  else
    note "OK age ${age_days}d <= ${MAX_AGE_DAYS}d :: $f"
  fi
done < <(list_scoped_head_files)

if (( has_base == 1 )); then
  # Compare base → working tree (covers uncommitted local edits and CI checkouts).
  mapfile -t CHANGED < <(git diff --name-only --diff-filter=ACMR "$BASE_REF" -- "${SCOPE_DIRS[@]}" || true)
  mapfile -t DELETED < <(git diff --name-only --diff-filter=D "$BASE_REF" -- "${SCOPE_DIRS[@]}" || true)

  # ---- 1) frozen immutability ----
  note "-- check: frozen immutability --"
  while read -r f; do
    [[ -z "$f" || "$f" != *.md ]] && continue
    if ! git cat-file -e "$BASE_REF:$f" 2>/dev/null; then
      continue
    fi
    base_status="$(git show "$BASE_REF:$f" | extract_fm_value - status || true)"
    if [[ "$base_status" != "frozen" ]]; then
      continue
    fi
    if [[ ! -f "$f" ]]; then
      fail "$f: frozen on $BASE_REF but deleted in working tree"
      continue
    fi
    if ! git diff --quiet "$BASE_REF" -- "$f"; then
      fail "$f: frozen on $BASE_REF but content changed"
    else
      note "OK frozen unchanged :: $f"
    fi
  done < <(git ls-tree -r --name-only "$BASE_REF" -- "${SCOPE_DIRS[@]}")

  for f in "${DELETED[@]:-}"; do
    [[ -z "${f:-}" || "$f" != *.md ]] && continue
    base_status="$(git show "$BASE_REF:$f" | extract_fm_value - status || true)"
    if [[ "$base_status" == "frozen" ]]; then
      fail "$f: frozen file deleted"
    fi
  done

  # ---- 2) last_reviewed sync ----
  note "-- check: last_reviewed sync on content changes --"
  for f in "${CHANGED[@]:-}"; do
    [[ -z "${f:-}" || "$f" != *.md ]] && continue
    is_scoped "$f" || continue
    if ! git cat-file -e "$BASE_REF:$f" 2>/dev/null; then
      lr="$(extract_fm_value "$f" last_reviewed || true)"
      if [[ "$lr" != "$TODAY" ]]; then
        fail "$f: new file last_reviewed='$lr' must be $TODAY"
      else
        note "OK new file dated $TODAY :: $f"
      fi
      continue
    fi
    base_norm="$(git show "$BASE_REF:$f" | strip_last_reviewed)"
    head_norm="$(strip_last_reviewed <"$f")"
    if [[ "$base_norm" == "$head_norm" ]]; then
      note "OK only last_reviewed (or nothing semantic) changed :: $f"
      continue
    fi
    lr="$(extract_fm_value "$f" last_reviewed || true)"
    if [[ "$lr" != "$TODAY" ]]; then
      fail "$f: content changed but last_reviewed='$lr' (want $TODAY)"
    else
      note "OK content change synced last_reviewed=$TODAY :: $f"
    fi
  done

  # ---- 3) reviews/ append guard ----
  note "-- check: reviews/ append-only --"
  for f in "${DELETED[@]:-}"; do
    [[ -z "${f:-}" ]] && continue
    case "$f" in
      reviews/*.md|reviews/*/*.md)
        fail "$f: deletion in reviews/ is not allowed"
        ;;
    esac
  done
  for f in "${CHANGED[@]:-}"; do
    [[ -z "${f:-}" || "$f" != *.md ]] && continue
    case "$f" in
      reviews/*) ;;
      *) continue ;;
    esac
    if ! git cat-file -e "$BASE_REF:$f" 2>/dev/null; then
      note "OK new review file :: $f"
      continue
    fi
    base_content="$(git show "$BASE_REF:$f")"
    head_content="$(cat "$f")"
    if [[ "$head_content" == "$base_content"* ]]; then
      note "OK append-only :: $f"
    else
      fail "$f: reviews/ must be append-only (base content is not a prefix of HEAD)"
    fi
  done
fi

note "-- summary --"
if (( FAIL != 0 )); then
  note "FAILED"
  exit 1
fi
note "PASSED"
exit 0
