#!/usr/bin/env bash
# Staleness guards for the aidd knowledge base.
# Checks:
#   1) frozen immutability
#   2) last_reviewed sync on content changes (log files exempt)
#   3) append-only guard for log files (reviews/, ledger/attestations.md)
#   4) 90-day expiry on the effective review date
#   5) attestation format, resolvable ID, no future dates
#
# Freshness is the newer of the document's own `last_reviewed` and the latest
# attestation recorded for its id (ADR-012). That keeps `frozen` documents
# reviewable without touching a byte of them.
#
# Portability: no GNU-only `date -d` and no bash 4 `mapfile`, so this runs on
# macOS (bash 3.2 / BSD userland) as well as CI.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

BASE_REF="${BASE_REF:-origin/main}"
TODAY="${TODAY:-$(date -u +%F)}"
MAX_AGE_DAYS="${MAX_AGE_DAYS:-90}"
SCOPE_DIRS=(evidence adr playbook ledger reviews)
ATTEST_FILE="ledger/attestations.md"
# Append-only logs: history, not claims. Exempt from freshness and date sync.
LOG_PATHS=(reviews "$ATTEST_FILE")

FAIL=0
note() { printf '%s\n' "$*"; }
fail() { note "ERROR: $*"; FAIL=1; }

is_log_path() {
  case "$1" in
    reviews/*) return 0 ;;
    "$ATTEST_FILE") return 0 ;;
  esac
  return 1
}

# Days since 1970-01-01 for an ISO date, without GNU date.
days_since_epoch() {
  printf '%s\n' "$1" | awk -F- '
    function days(y, m, d,   era, yoe, doy, doe) {
      if (m <= 2) y -= 1
      era = int((y >= 0 ? y : y - 399) / 400)
      yoe = y - era * 400
      doy = int((153 * (m + (m > 2 ? -3 : 9)) + 2) / 5) + d - 1
      doe = yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy
      return era * 146097 + doe - 719468
    }
    { print days($1 + 0, $2 + 0, $3 + 0) }
  '
}

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
  # `--others` keeps local runs honest: a new document is checked before it is
  # staged, the same way build-index.sh sees it.
  git ls-files --cached --others --exclude-standard "${SCOPE_DIRS[@]}" \
    | sort -u \
    | while read -r f; do
        [[ "$f" == *.md && -f "$f" ]] && printf '%s\n' "$f"
      done
}

note "== aidd staleness check =="
note "today(UTC)=$TODAY max_age_days=$MAX_AGE_DAYS base=$BASE_REF"

TMPDIR_SELF="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_SELF"' EXIT
ATTEST_TSV="$TMPDIR_SELF/attestations.tsv"
DOC_IDS="$TMPDIR_SELF/ids.txt"
: >"$ATTEST_TSV"
: >"$DOC_IDS"

while read -r f; do
  [[ -z "$f" ]] && continue
  id="$(extract_fm_value "$f" id || true)"
  [[ -n "$id" ]] && printf '%s\t%s\n' "$id" "$f" >>"$DOC_IDS"
done < <(list_scoped_head_files)

# Entries live under the `## 証跡` heading; everything above it is frontmatter,
# prose and a fenced format example.
attestation_entries() {
  awk '
    /^## 証跡[[:space:]]*$/ { in_entries = 1; next }
    /^## / { in_entries = 0 }
    in_entries && /^-[[:space:]]/ { print }
  ' "$ATTEST_FILE"
}

if [[ -f "$ATTEST_FILE" ]]; then
  attestation_entries \
    | awk '/^- [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [A-Za-z0-9-]+ / { print $3 "\t" $2 }' \
      >>"$ATTEST_TSV"
fi

latest_attestation() {
  awk -F'\t' -v id="$1" '$1 == id { print $2 }' "$ATTEST_TSV" | sort | tail -n 1
}

today_days="$(days_since_epoch "$TODAY")"

# ---- 5) attestation ledger ----
note "-- check: attestation ledger --"
if [[ -f "$ATTEST_FILE" ]]; then
  while IFS=$'\t' read -r id when; do
    [[ -z "$id" ]] && continue
    if ! awk -F'\t' -v id="$id" '$1 == id { found = 1 } END { exit !found }' "$DOC_IDS"; then
      fail "$ATTEST_FILE: attestation for unknown id '$id'"
      continue
    fi
    if [[ "$when" > "$TODAY" ]]; then
      fail "$ATTEST_FILE: attestation for $id is dated in the future ($when)"
      continue
    fi
    note "OK attestation :: $id $when"
  done <"$ATTEST_TSV"
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    printf '%s\n' "$line" | awk '
      /^- [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [A-Za-z0-9-]+ [^[:space:]]/ { ok = 1 }
      END { exit ok ? 0 : 1 }
    ' || fail "$ATTEST_FILE: malformed entry '$line' (want '- YYYY-MM-DD <ID> <確認者> — <確認した内容>')"
  done < <(attestation_entries)
else
  note "WARN: $ATTEST_FILE not found; freshness falls back to last_reviewed only"
fi

# ---- 4) 90-day expiry on the effective review date (always) ----
note "-- check: ${MAX_AGE_DAYS}-day expiry (effective review date) --"
while read -r f; do
  [[ -z "$f" ]] && continue
  if is_log_path "$f"; then
    note "SKIP log file (append-only history) :: $f"
    continue
  fi
  lr="$(extract_fm_value "$f" last_reviewed || true)"
  st="$(extract_fm_value "$f" status || true)"
  id="$(extract_fm_value "$f" id || true)"
  if [[ -z "$lr" ]]; then
    fail "$f: missing last_reviewed"
    continue
  fi
  if [[ ! "$lr" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    fail "$f: invalid last_reviewed='$lr'"
    continue
  fi
  if [[ "$lr" > "$TODAY" ]]; then
    fail "$f: last_reviewed=$lr is in the future (today=$TODAY)"
    continue
  fi
  effective="$lr"
  source_of="last_reviewed"
  if [[ -n "$id" ]]; then
    att="$(latest_attestation "$id")"
    if [[ -n "$att" && "$att" > "$effective" ]]; then
      effective="$att"
      source_of="attestation"
    fi
  fi
  lr_days="$(days_since_epoch "$effective")"
  age_days=$(( today_days - lr_days ))
  if (( age_days > MAX_AGE_DAYS )); then
    fail "$f: effective review date $effective is ${age_days}d old (>${MAX_AGE_DAYS}d) status=${st:-unknown}"
  else
    note "OK age ${age_days}d <= ${MAX_AGE_DAYS}d ($source_of) :: $f"
  fi
done < <(list_scoped_head_files)

if (( has_base == 1 )); then
  # Compare base → working tree (covers uncommitted local edits and CI checkouts).
  CHANGED=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && CHANGED+=("$line")
  done < <(git diff --name-only --diff-filter=ACMR "$BASE_REF" -- "${SCOPE_DIRS[@]}" || true)
  DELETED=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && DELETED+=("$line")
  done < <(git diff --name-only --diff-filter=D "$BASE_REF" -- "${SCOPE_DIRS[@]}" || true)

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
    if is_log_path "$f"; then
      note "SKIP log file (append-only history) :: $f"
      continue
    fi
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

  # ---- 3) append-only guard for log files ----
  note "-- check: append-only logs (${LOG_PATHS[*]}) --"
  for f in "${DELETED[@]:-}"; do
    [[ -z "${f:-}" ]] && continue
    if is_log_path "$f"; then
      fail "$f: deletion of an append-only log is not allowed"
    fi
  done
  for f in "${CHANGED[@]:-}"; do
    [[ -z "${f:-}" || "$f" != *.md ]] && continue
    is_log_path "$f" || continue
    if ! git cat-file -e "$BASE_REF:$f" 2>/dev/null; then
      note "OK new log file :: $f"
      continue
    fi
    base_content="$(git show "$BASE_REF:$f")"
    head_content="$(cat "$f")"
    if [[ "$head_content" == "$base_content"* ]]; then
      note "OK append-only :: $f"
    else
      fail "$f: must be append-only (base content is not a prefix of HEAD)"
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
