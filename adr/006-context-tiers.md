---
id: ADR-006
title: 文脈を Tier 0〜3 に分け、ロード順を固定する
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - context
  - tier
related:
  - EVID-009
  - ADR-001
  - ADR-007
tier: 2
---

## 文脈

[ADR-001](001-repository-layout.md) は文書を種類別に置く場所を決めたが、**読む順序**は決めていない。文書が増えるほど、エージェントは「全部読む」か「たまたま見つけた 1 件を読む」かに二極化する。[EVID-009](../evidence/009-context-budget-is-finite.md) のとおり文脈は有限予算であり、順序と省略の規則が必要になる。

## 決定

全文書に **Tier 0〜3** を割り当てる。Tier はロードのタイミングを表し、重要度の格付けではない。

| Tier | 名前 | いつ読むか | 主な中身 |
| --- | --- | --- | --- |
| 0 | 規範 | 毎セッション、必ず全文 | `AGENTS.md` / `CONVENTIONS.md` |
| 1 | 索引 | 毎セッション、一覧のみ | `INDEX.md` / `GRAPH.md` / `GUIDE.md` / `README.md` / `ledger/*` / skills の `name` + `description` |
| 2 | 決定と手順 | 作業種別が決まったら全文 | `adr/*` / `playbook/*` |
| 3 | 根拠と監査 | 主張を疑うとき・レビュー時 | `evidence/*` / `reviews/*` / `deprecated` 全般 |

規則:

1. Tier は Frontmatter の任意キー `tier`（`0`〜`3` の整数）で明示できる。
2. `tier` がない文書は、次の既定規則で決まる。`AGENTS.md` と `CONVENTIONS.md` = 0、ルートの生成物・案内（`INDEX.md` / `GRAPH.md` / `GUIDE.md` / `README.md`）と `ledger/` と skills = 1、`adr/` と `playbook/` = 2、`evidence/` と `reviews/` = 3。
3. `status: deprecated` の文書は `tier` を持たない。常に Tier 3 として扱う。
4. `status: frozen` の文書には `tier` を後付けしない（frozen は不変のため）。既定規則で決まる値を使う。
5. 上記 3 と 4 の違反は CI が検出する（[ADR-007](007-generated-index.md)）。既定規則があるため、既存文書を 1 件も書き換えずに Tier を導入できる。
6. Tier は [INDEX.md](../INDEX.md) に出力され、機械可読な形で一覧できる。

## 根拠

- [EVID-009](../evidence/009-context-budget-is-finite.md): 常時ロード前提は文書数の増加に耐えない
- [EVID-002](../evidence/002-context-is-not-memory.md): 入口を薄くし詳細を分ける
- [EVID-012](../evidence/012-skills-are-progressive-disclosure.md): 既存ツールも同型の段階的開示を採用している

## 結果・トレードオフ

- 利点: 「まず何を読むか」が文書側に書かれるため、エージェント間で読み込み手順がぶれない
- 利点: 既定規則があるため、frozen 文書や既存文書を書き換えずに Tier を導入できる
- 代償: Tier が実態と合わなくなる可能性がある（例: 特定の evidence を常時参照したい）。是正は `tier` の明示と [PB-006](../playbook/006-assign-tier.md) のレビューで行う
- 代償: Tier 割り当ての妥当性を機械検査できない（範囲の妥当性のみ検査する）

## 関連

- [PB-006](../playbook/006-assign-tier.md)
- [ADR-007](007-generated-index.md)
- [CONVENTIONS.md](../CONVENTIONS.md)
