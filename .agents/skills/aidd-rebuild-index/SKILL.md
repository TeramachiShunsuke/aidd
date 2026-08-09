---
name: aidd-rebuild-index
description: AIDD 知識ベースの生成インデックス INDEX.md を再生成し、CI の index チェックを通す。文書を追加・改名・削除したとき、status / tier / title を変えたとき、または「INDEX が古い」「index check が失敗する」と言われたときに使う。
metadata:
  aidd-playbook: PB-007
  aidd-tier: "1"
---

# INDEX.md を再生成する

## いつ使うか

- 文書や skill を追加・改名・削除した直後（PR を出す前は毎回）
- CI の index チェックが差分を報告しているとき

## 先に読むもの

1. [ADR-007](../../../adr/007-generated-index.md) — INDEX.md は生成物であり手編集しない
2. [PB-007](../../../playbook/007-rebuild-index.md) — 手順の正本
3. Tier の割り当ては [ADR-006](../../../adr/006-context-tiers.md)

## 手順の要点

1. 文書側の変更をすべて終える
2. `bash .github/scripts/build-index.sh` を実行する
3. `git diff INDEX.md` が意図どおりか確認する
4. 差分が意図と違うときは `INDEX.md` ではなく**生成元の Frontmatter**を直して再生成する
5. `bash .github/scripts/build-index.sh --check` が PASSED であることを確認する

## 禁止事項

- `INDEX.md` を手で編集する
- 生成物に日付など実行ごとに変わる値を持ち込む
- 手順の詳細をこのファイルに書き写す（正本は PB-007）
