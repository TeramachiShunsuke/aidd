---
id: ADR-00010
title: 知識グラフを構造層と意味層に分け、構造層だけを CI に置く
status: active
last_reviewed: 2026-08-20
owners:
  - TeramachiShunsuke
tags:
  - graph
  - ci
  - tooling
related:
  - EVID-00013
  - EVID-00014
  - ADR-00007
  - EVID-00009
  - EVID-00010
tier: 2
---

## 文脈

文書が 60 件を超え、レビューで「どの決定がどの根拠に乗っているか」「使われていない文書はどれか」を目視で追えなくなってきた。グラフ化の候補として [Graphify](https://graphify.com) を評価したところ、コードは tree-sitter でローカル・決定的に解析するが Markdown は LLM の意味抽出に回るため、コードを持たない本リポジトリでは全ノードが LLM 由来になることが分かった（[EVID-00013](../evidence/00013-graphify-needs-llm-for-docs.md)）。

一方で、本リポジトリの文書はすでに `related`・文書間リンク・ledger の錨・skill → playbook という明示的な辺を持っており、LLM なしで決定的にグラフ化できる（[EVID-00014](../evidence/00014-reference-graph-from-metadata.md)）。

## 決定

グラフを 2 層に分け、**構造層だけをリポジトリと CI に置く**。

### 層 1: 構造グラフ（採用・CI 必須）

- 生成器は `.github/scripts/build-graph.py`、出力は ルートの `GRAPH.md`
- 辺は次の 4 種類のみ。すべてファイル内の明示的な記述に遡れる
  - Frontmatter の `related` / `supersedes` / `superseded_by`
  - 文書間の Markdown リンク
  - `ledger/claims.md` の錨（`evidence:` / `adr:` / `url:`）
  - skill の `metadata.aidd-playbook`
- **推論した辺を持たない。** 意味的な近さは扱わない
- 出力は決定的で、生成日時を含めない（[ADR-00007](00007-generated-index.md) と同じ条件）
- CI を落とすのは次の 4 つに限る
  1. 解決しない `related` / 錨の ID
  2. 錨を 1 つも持たない claim
  3. リンク切れ
  4. `GRAPH.md` が再生成結果と食い違う
- それ以外は**警告**として `GRAPH.md` に出すだけで CI は落とさない（未使用の evidence、evidence の錨を持たない ADR、専用 skill 入口のない playbook、draft / deprecated を根拠にした決定、孤立ノード）

### 層 2: 意味グラフ（不採用・任意のローカル探索）

- Graphify のような LLM ベースのグラフ（docs の意味抽出経路）は、CI にも既定の運用にも入れない。なお Graphify のコード経路（tree-sitter による決定的な AST 抽出。LLM なし）は意味層ではなく構造層の性質を持ち、案件リポでの文脈の絞り込みに使える（扱いは [ADR-00027](00027-cost-and-context-per-task.md)。本リポジトリの CI には入れない）
- 使う場合はローカルの探索に限り、出力 `graphify-out/` は commit しない（`.gitignore`）
- 得られた知見は成果物ごと取り込まず、[PB-00001](../playbook/00001-add-evidence.md) で evidence に昇格させる。[ADR-00008](00008-sdd-bridge.md) の spec 取り込みと同じ扱い

### 検査の分担

`related` は**意図的に非対称**とする。playbook は実装対象の ADR を指すが、ADR は全 playbook を列挙しない。したがって片方向リンクを欠陥として扱わない。

## 根拠

- [EVID-00014](../evidence/00014-reference-graph-from-metadata.md): 明示メタデータだけで 63 ノード / 246 辺を LLM なしで構築でき、4 種の破損を検出できた
- [EVID-00013](../evidence/00013-graphify-needs-llm-for-docs.md): docs のみの corpus では Graphify のノードが全て LLM 由来になり、`--code-only` では知識が 1 ノードも入らない
- [EVID-00010](../evidence/00010-handwritten-index-rots.md): 生成物は決定的でなければ最新性を検査できない
- [EVID-00009](../evidence/00009-context-budget-is-finite.md): `alwaysApply: true` のルール注入は Tier 0 の枠を消費する

## 結果・トレードオフ

- 利点: 参照切れと錨なし主張が CI で落ちるようになり、[OQ-00003](../ledger/open-questions.md) が解ける
- 利点: レビューが「どの決定がどの根拠に乗るか」を目視ではなく表とグラフで確認できる
- 利点: LLM コストとデータ送信が発生しない。オフラインで完結する
- 代償: 検出できるのは**明示された参照**だけで、「書かれていない関係」は見えない。意味的な発見は人間か層 2 に残る
- 代償: 生成物が `INDEX.md` と `GRAPH.md` の 2 つになり、再生成の手順が増える（[PB-00010](../playbook/00010-review-with-graph.md) で 2 コマンドに固定）
- 代償: 既存のシェルスクリプト 2 本に対し、この生成器だけ Python 3 を使う。グラフ処理を bash で書くと可読性が落ちるための判断で、標準ライブラリのみに限定して外部依存は増やしていない

## 関連

- [PB-00010](../playbook/00010-review-with-graph.md)
- [.github/scripts/build-graph.py](../.github/scripts/build-graph.py)
- [ADR-00007](00007-generated-index.md)
