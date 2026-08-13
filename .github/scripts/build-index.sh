#!/usr/bin/env bash
# Generates INDEX.md (Tier 1 entry point) from document frontmatter and skills.
#
# Usage:
#   bash .github/scripts/build-index.sh          # write INDEX.md
#   bash .github/scripts/build-index.sh --check  # fail if INDEX.md is stale
#
# Validations (both modes):
#   - required frontmatter keys on scoped documents
#   - duplicate document ids
#   - tier outside 0..3
#   - skill `name` must match its parent folder
#   - skill `metadata.aidd-playbook` must reference an existing playbook id
#
# Output is deterministic: it must not contain generation timestamps.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

MODE="write"
case "${1:-}" in
  "") ;;
  --check) MODE="check" ;;
  *) printf 'unknown argument: %s\n' "$1" >&2; exit 2 ;;
esac

OUT="INDEX.md"
SCOPE_DIRS=(evidence adr playbook ledger reviews)
SKILLS_ROOT=".agents/skills"
CLAUDE_MIRROR=".claude/skills"
ROOT_DOCS=(AGENTS.md CONVENTIONS.md GUIDE.md SETUP.md README.md GRAPH.md)
SCRIPT_REL=".github/scripts/build-index.sh"

FAIL=0
note() { printf '%s\n' "$*"; }
fail() { note "ERROR: $*"; FAIL=1; }

fm_get() {
  # usage: fm_get <file> <key>   (top-level frontmatter key)
  awk -v key="$2" '
    BEGIN { in_fm=0; seen=0 }
    /^---[[:space:]]*$/ {
      if (seen==0) { in_fm=1; seen=1; next }
      if (in_fm==1) { exit }
    }
    in_fm==1 && $0 ~ ("^" key ":[[:space:]]*") {
      sub("^[^:]+:[[:space:]]*", "", $0)
      gsub(/^["'\'']|["'\'']$/, "", $0)
      gsub(/[[:space:]]+$/, "", $0)
      print $0
      exit
    }
  ' "$1"
}

fm_get_nested() {
  # usage: fm_get_nested <file> <key>   (indented frontmatter key, e.g. under metadata:)
  awk -v key="$2" '
    BEGIN { in_fm=0; seen=0 }
    /^---[[:space:]]*$/ {
      if (seen==0) { in_fm=1; seen=1; next }
      if (in_fm==1) { exit }
    }
    in_fm==1 && $0 ~ ("^[[:space:]]+" key ":[[:space:]]*") {
      sub("^[^:]+:[[:space:]]*", "", $0)
      gsub(/^["'\'']|["'\'']$/, "", $0)
      gsub(/[[:space:]]+$/, "", $0)
      print $0
      exit
    }
  ' "$1"
}

first_heading() {
  awk '/^#[[:space:]]+/ { sub(/^#[[:space:]]+/, "", $0); print $0; exit }' "$1"
}

esc() { printf '%s' "$1" | sed 's/|/\\|/g'; }

list_files() {
  # Tracked files plus new-but-not-ignored ones, so a local run sees uncommitted documents.
  git ls-files --cached --others --exclude-standard -- "$@" | LC_ALL=C sort -u
}

default_tier() {
  # usage: default_tier <path> <status>
  local p="$1" st="$2"
  if [[ "$st" == "deprecated" ]]; then printf '3'; return; fi
  case "$p" in
    AGENTS.md|CONVENTIONS.md) printf '0' ;;
    README.md|GUIDE.md|SETUP.md|INDEX.md|GRAPH.md) printf '1' ;;
    ledger/*) printf '1' ;;
    "$SKILLS_ROOT"/*) printf '1' ;;
    adr/*|playbook/*) printf '2' ;;
    evidence/*|reviews/*) printf '3' ;;
    *) printf '3' ;;
  esac
}

root_doc_id() {
  case "$1" in
    AGENTS.md) printf 'ROOT-AGENTS' ;;
    CONVENTIONS.md) printf 'ROOT-CONVENTIONS' ;;
    README.md) printf 'ROOT-README' ;;
    GUIDE.md) printf 'ROOT-GUIDE' ;;
    SETUP.md) printf 'ROOT-SETUP' ;;
    GRAPH.md) printf 'ROOT-GRAPH' ;;
    *) printf 'ROOT' ;;
  esac
}

# ---------- collect documents ----------
DOC_ROWS="$(mktemp)"
SKILL_ROWS="$(mktemp)"
IDS="$(mktemp)"
PB_IDS="$(mktemp)"
trap 'rm -f "$DOC_ROWS" "$SKILL_ROWS" "$IDS" "$PB_IDS"' EXIT

add_doc_row() {
  # usage: add_doc_row <path> <id> <title> <status> <last_reviewed> <tier>
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$6" "$1" "$2" "$3" "$4" "$5" >>"$DOC_ROWS"
}

for f in "${ROOT_DOCS[@]}"; do
  [[ -f "$f" ]] || continue
  title="$(first_heading "$f")"
  [[ -z "$title" ]] && title="$f"
  id="$(root_doc_id "$f")"
  add_doc_row "$f" "$id" "$title" "-" "-" "$(default_tier "$f" "")"
done

while read -r f; do
  [[ -z "$f" || "$f" != *.md ]] && continue
  id="$(fm_get "$f" id)"
  title="$(fm_get "$f" title)"
  status="$(fm_get "$f" status)"
  lr="$(fm_get "$f" last_reviewed)"
  tier="$(fm_get "$f" tier)"

  [[ -z "$id" ]] && fail "$f: missing frontmatter key 'id'"
  [[ -z "$title" ]] && fail "$f: missing frontmatter key 'title'"
  [[ -z "$status" ]] && fail "$f: missing frontmatter key 'status'"
  [[ -z "$lr" ]] && fail "$f: missing frontmatter key 'last_reviewed'"

  # A union merge (ADR-016) can leave two copies of a scalar key. Readers take
  # the first and the second silently wins nothing, so catch it here.
  dupe_keys="$(awk '
    BEGIN { in_fm = 0; seen = 0 }
    /^---[[:space:]]*$/ {
      if (seen == 0) { in_fm = 1; seen = 1; next }
      if (in_fm == 1) { exit }
    }
    in_fm == 1 && /^(id|title|status|last_reviewed|tier):[[:space:]]/ {
      split($0, parts, ":")
      count[parts[1]]++
    }
    END { for (k in count) if (count[k] > 1) print k }
  ' "$f")"
  if [[ -n "$dupe_keys" ]]; then
    fail "$f: duplicate frontmatter key(s): $(printf '%s' "$dupe_keys" | tr '\n' ' ')"
  fi

  if [[ -n "$id" ]]; then
    if grep -Fxq "$id" "$IDS" 2>/dev/null; then
      fail "$f: duplicate id '$id'"
    else
      printf '%s\n' "$id" >>"$IDS"
    fi
    [[ "$f" == playbook/* ]] && printf '%s\n' "$id" >>"$PB_IDS"
  fi

  if [[ -n "$tier" ]]; then
    if [[ ! "$tier" =~ ^[0-3]$ ]]; then
      fail "$f: tier '$tier' is out of range (0..3)"
      tier=""
    elif [[ "$status" == "deprecated" ]]; then
      fail "$f: deprecated document must not pin 'tier' (always Tier 3)"
      tier=""
    elif [[ "$status" == "frozen" ]]; then
      fail "$f: frozen document must not carry 'tier' (use the default rule)"
      tier=""
    fi
  fi
  [[ -z "$tier" ]] && tier="$(default_tier "$f" "$status")"

  add_doc_row "$f" "${id:-?}" "${title:-?}" "${status:-?}" "${lr:-?}" "$tier"
done < <(list_files "${SCOPE_DIRS[@]}")

# ---------- collect skills ----------
if [[ -d "$SKILLS_ROOT" ]]; then
  while read -r f; do
    [[ -z "$f" ]] && continue
    dir="$(dirname "$f")"
    folder="$(basename "$dir")"
    name="$(fm_get "$f" name)"
    desc="$(fm_get "$f" description)"
    pb="$(fm_get_nested "$f" aidd-playbook)"

    [[ -z "$name" ]] && fail "$f: missing frontmatter key 'name'"
    [[ -z "$desc" ]] && fail "$f: missing frontmatter key 'description'"
    if [[ -n "$name" && "$name" != "$folder" ]]; then
      fail "$f: skill name '$name' does not match folder '$folder'"
    fi
    if [[ -z "$pb" ]]; then
      fail "$f: missing 'metadata.aidd-playbook'"
    elif ! grep -Fxq "$pb" "$PB_IDS" 2>/dev/null; then
      fail "$f: unknown playbook '$pb'"
    fi

    printf '%s\t%s\t%s\t%s\n' "${name:-$folder}" "$f" "${pb:-?}" "${desc:-?}" >>"$SKILL_ROWS"
  done < <(list_files "$SKILLS_ROOT" | grep '/SKILL\.md$' || true)

  # Claude Code reads only .claude/skills, so each skill is mirrored there as a
  # symlink back to the canonical folder (ADR-011).
  while read -r f; do
    [[ -z "$f" ]] && continue
    name="$(basename "$(dirname "$f")")"
    mirror="$CLAUDE_MIRROR/$name"
    want="../../$SKILLS_ROOT/$name"
    if [[ ! -L "$mirror" ]]; then
      fail "$mirror: missing symlink to '$want' (Claude Code mirror)"
    elif [[ "$(readlink "$mirror")" != "$want" ]]; then
      fail "$mirror: symlink points to '$(readlink "$mirror")', want '$want'"
    else
      note "OK claude mirror :: $mirror"
    fi
  done < <(list_files "$SKILLS_ROOT" | grep '/SKILL\.md$' || true)

  while read -r mirror; do
    [[ -z "$mirror" ]] && continue
    name="$(basename "$mirror")"
    if [[ ! -f "$SKILLS_ROOT/$name/SKILL.md" ]]; then
      fail "$mirror: mirror without a skill at $SKILLS_ROOT/$name/SKILL.md"
    fi
  done < <(list_files "$CLAUDE_MIRROR")
fi

# ---------- render ----------
tier_label() {
  case "$1" in
    0) printf '規範（毎セッション、全文）' ;;
    1) printf '索引（毎セッション、一覧のみ）' ;;
    2) printf '決定と手順（作業種別が決まったら）' ;;
    3) printf '根拠と監査（主張を疑うとき）' ;;
  esac
}

render() {
  cat <<'HEADER'
<!-- Generated by .github/scripts/build-index.sh — DO NOT EDIT BY HAND. -->
<!-- 再生成: bash .github/scripts/build-index.sh -->

# INDEX

知識ベース全体の索引。Tier はロードのタイミングを表し、重要度の格付けではない（[ADR-006](adr/006-context-tiers.md)）。
このファイルは生成物であり、手で編集しない（[ADR-007](adr/007-generated-index.md)）。文書側を直してから再生成する。
HEADER

  local t
  for t in 0 1 2 3; do
    printf '\n## Tier %s — %s\n\n' "$t" "$(tier_label "$t")"
    printf '| ID | タイトル | パス | status | last_reviewed |\n'
    printf '| --- | --- | --- | --- | --- |\n'
    local count=0
    while IFS=$'\t' read -r rt path id title status lr; do
      [[ "$rt" != "$t" ]] && continue
      printf '| %s | %s | [%s](%s) | %s | %s |\n' \
        "$(esc "$id")" "$(esc "$title")" "$(esc "$path")" "$path" "$(esc "$status")" "$(esc "$lr")"
      count=$((count + 1))
    done < <(LC_ALL=C sort -t$'\t' -k1,1 -k2,2 "$DOC_ROWS")
    if (( count == 0 )); then
      printf '| — | （なし） | — | — | — |\n'
    fi

    if [[ "$t" == "1" && -s "$SKILL_ROWS" ]]; then
      printf '\nSkills（起動時は `description` のみロードされる。本文は一致時に読まれる）:\n\n'
      printf '| skill | playbook | description |\n'
      printf '| --- | --- | --- |\n'
      while IFS=$'\t' read -r name path pb desc; do
        printf '| [%s](%s) | %s | %s |\n' "$(esc "$name")" "$path" "$(esc "$pb")" "$(esc "$desc")"
      done < <(LC_ALL=C sort -t$'\t' -k1,1 "$SKILL_ROWS")
    fi
  done

  printf '\n## 内訳\n\n'
  printf '| 区分 | 件数 |\n'
  printf '| --- | --- |\n'
  for t in 0 1 2 3; do
    printf '| Tier %s | %s |\n' "$t" "$(awk -F'\t' -v t="$t" '$1==t {n++} END {print n+0}' "$DOC_ROWS")"
  done
  local s
  for s in active frozen draft deprecated; do
    printf '| status: %s | %s |\n' "$s" "$(awk -F'\t' -v s="$s" '$5==s {n++} END {print n+0}' "$DOC_ROWS")"
  done
  printf '| skills | %s |\n' "$(wc -l <"$SKILL_ROWS" | tr -d ' ')"
}

TMP_OUT="$(mktemp)"
render >"$TMP_OUT"

if (( FAIL != 0 )); then
  rm -f "$TMP_OUT"
  note "-- summary --"
  note "FAILED (validation)"
  exit 1
fi

if [[ "$MODE" == "check" ]]; then
  if [[ ! -f "$OUT" ]]; then
    rm -f "$TMP_OUT"
    note "ERROR: $OUT is missing. Run: bash $SCRIPT_REL"
    exit 1
  fi
  if ! diff -u "$OUT" "$TMP_OUT" >/dev/null; then
    note "ERROR: $OUT is stale. Run: bash $SCRIPT_REL"
    diff -u "$OUT" "$TMP_OUT" || true
    rm -f "$TMP_OUT"
    exit 1
  fi
  rm -f "$TMP_OUT"
  note "PASSED (index up to date)"
  exit 0
fi

mv "$TMP_OUT" "$OUT"
note "wrote $OUT"
exit 0
