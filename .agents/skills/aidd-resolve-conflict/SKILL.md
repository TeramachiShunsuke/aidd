---
name: aidd-resolve-conflict
description: AIDD 知識ベースのマージ競合と ID の衝突を、ファイルの種類ごとに決まった方法で解決する。「コンフリクトを直して」「マージが競合した」「rebase が止まった」「ID が重複している」「番号を振り直したい」と言われたときに使う。
metadata:
  aidd-playbook: PB-015
  aidd-tier: "1"
---

# 競合と ID 衝突を解決する

## いつ使うか

- `git merge` / `git rebase` が競合したとき
- `build-index.sh --check` や `build-graph.py --check` が ID の重複を報告したとき
- 別のブランチと同じ番号を使ってしまったと分かったとき

## 先に読むもの

1. [ADR-016](../../../adr/016-shrink-conflict-surface.md) — 競合を 3 種類に分ける決定
2. [PB-015](../../../playbook/015-resolve-conflicts.md) — 手順の正本
3. 振り直しの実例は [REV-006](../../../reviews/006-lifecycle-self-review.md)

## 手順の要点

1. 競合したファイルを種類で分ける。生成物 / 追記専用の台帳 / 文書本文 / ID 衝突
2. `INDEX.md` と `GRAPH.md` は読まずに再生成する（`build-graph.py` → `build-index.sh` の順）
3. 台帳は両側の行を残し、重複 ID を検査で確認する
4. `reviews/**` と `ledger/attestations.md` は既存行に触らず、両側の追記を時系列で並べる
5. ID を振り直すなら、ファイル名 → 文書内の `id` と参照 → ledger の順に直し、`--check` 3 種が緑になるまで終わらせない

## 禁止事項

- 生成物の競合を手で解決する（再生成が正解）
- `frozen` 文書の側を捨てる、または 1 バイトでも変える
- `reviews/**` の既存行を書き換えて競合を消す（追記専用。旧内容は新内容の prefix でなければならない）
- 検査を通すためだけに `related` や ID を削る（参照が消えると根拠の系譜が切れる）
- 手順の詳細をこのファイルに書き写す（正本は PB-015）
