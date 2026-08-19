---
id: PB-00006
title: Tier を割り当てる・見直す
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - tier
related:
  - ADR-00006
  - PB-00007
tier: 2
---

## いつ使うか

文書を新規追加するとき、または「常に読まれてほしいのに読まれない／不要に読まれている」と感じたとき。

## 手順

1. [ADR-00006](../adr/00006-context-tiers.md) の表で、その文書の既定 Tier を確認する
2. 既定で妥当なら **`tier` を書かない**（既定規則に任せる）
3. 既定と変えたいときだけ Frontmatter に `tier: 0`〜`3` を書く。変える理由を本文の `## 関連` か該当節に 1 行残す
4. `status: frozen` の文書には `tier` を後付けしない（既定規則で決まる）
5. `status: deprecated` にした文書からは `tier` を消す（常に Tier 3 として扱われる）
6. `last_reviewed` を今日（UTC）にする
7. `bash .github/scripts/build-index.sh` で [INDEX.md](../INDEX.md) を再生成する（[PB-00007](00007-rebuild-index.md)）

## 検証

- `bash .github/scripts/build-index.sh --check` が PASSED
- `INDEX.md` の該当行の Tier が意図どおり
- Tier 0 と Tier 1 の総量が増えていない（増やすなら ADR で合意する）

## 失敗時

Tier を上げたい文書が複数ある、または Tier 0/1 を恒常的に増やしたくなった場合は、個別対応せず [ledger/open-questions.md](../ledger/open-questions.md) に論点を出し、[ADR-00006](../adr/00006-context-tiers.md) の後継 ADR で階層自体を見直す。

## 関連

- [ADR-00006](../adr/00006-context-tiers.md)
- [CONVENTIONS.md](../CONVENTIONS.md)
