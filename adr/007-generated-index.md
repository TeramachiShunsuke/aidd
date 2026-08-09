---
id: ADR-007
title: INDEX.md を生成物とし、CI で最新性を強制する
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - index
  - ci
related:
  - EVID-010
  - ADR-006
  - ADR-004
tier: 2
---

## 文脈

入口が [README.md](../README.md) のディレクトリ表しかないため、エージェントは個々の文書 ID・status・鮮度を知るのにディレクトリを走査する必要がある。手書きの目次を足しても、[EVID-010](../evidence/010-handwritten-index-rots.md) のとおり実体と食い違う。

## 決定

1. リポジトリルートに **`INDEX.md`** を置き、Tier 1（索引）の単一の入口とする。
2. `INDEX.md` は **生成物**であり、手で編集しない。生成は `.github/scripts/build-index.sh` が行う。
3. 生成元は Frontmatter（`id` / `title` / `status` / `last_reviewed` / `tier`）と、`.agents/skills/*/SKILL.md` の `name` / `description`。
4. 出力は**決定的**とする。生成日時など実行ごとに変わる値を出力に含めない。
5. CI は `build-index.sh --check` を実行し、再生成結果と差分があれば失敗させる。あわせて次の妥当性も検査する。
   - `id` の重複
   - `tier` が `0`〜`3` の範囲外
   - skill の `name` と親フォルダ名の不一致
   - skill が参照する playbook ID（`metadata.aidd-playbook`）の不在
6. `INDEX.md` は鮮度検査（[ADR-004](004-staleness-policy.md)）の対象ディレクトリに含めない。生成物に `last_reviewed` を持たせると、実体のレビューなしに日付だけが進むため。

## 根拠

- [EVID-010](../evidence/010-handwritten-index-rots.md): 導出可能なデータの二重管理はドリフトを生む
- [EVID-003](../evidence/003-doc-drift-is-regression.md): 文書ドリフトは回帰であり CI で止める対象
- [ADR-006](006-context-tiers.md): Tier を機械可読に一覧する場所が必要

## 結果・トレードオフ

- 利点: 文書の追加・改名・status 変更が索引に必ず反映される（反映しないと CI が赤）
- 利点: エージェントは 1 ファイルで全 ID・status・鮮度・Tier を把握できる
- 代償: 文書を触るたびに再生成コミットが必要になる（[PB-007](../playbook/007-rebuild-index.md) で 1 コマンド化）
- 代償: 生成物をリポジトリに置くためレビュー差分が増える。Frontmatter 由来の行のみに出力を絞って抑える

## 関連

- [PB-007](../playbook/007-rebuild-index.md)
- [.github/scripts/build-index.sh](../.github/scripts/build-index.sh)
- [.github/workflows/index.yml](../.github/workflows/index.yml)
