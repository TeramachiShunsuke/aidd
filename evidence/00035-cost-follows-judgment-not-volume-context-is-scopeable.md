---
id: EVID-00035
title: エージェント作業のコストは判断の難しさに比例し作業量には比例しない。検査で正誤が決まる作業は安い階層で足り、文脈は影響範囲で絞れる
status: draft
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - cost
  - context
  - model
  - graph
related:
  - EVID-00009
  - EVID-00013
  - EVID-00014
  - ADR-00010
  - ADR-00013
  - ADR-00017
---

## 主張

エージェントに渡す作業は「検査で正誤が決まるもの」「入力が閉じていて生成すればよいもの」「判断や批評が要るもの」に分かれ、必要なモデルの能力と推論の深さ（effort）はこの順に上がる。同じ作業でも渡す文脈を影響範囲に絞れば、トークンと時間が減り、注意が散らない。コードの影響範囲は決定的なコードグラフ（AST 由来）で機械的に出せる。

## 観測

- ベンダーのモデルは能力と価格で階層化されて提供される（例: [Anthropic の料金ページ](https://www.anthropic.com/pricing)）。本セッションの実行環境（Claude Code）でも、サブエージェントごとにモデル階層（haiku / sonnet / opus 等）と推論の深さ（effort: low〜max）を指定できる。つまり「タスクごとに階層と深さを選ぶ」操作は harness 側に既に存在する。
- 本リポジトリでは、正誤が検査で決まる作業（INDEX / GRAPH の再生成、ID の採番、frozen 不変・追記専用・鮮度の検査）はスクリプトが行い、モデルを使っていない（[ADR-00013](../adr/00013-check-grades.md): 修正方法が一意な検査は機械で固定する）。一方、敵対レビューや矛盾点検（[REV-00005](../reviews/00005-adversarial-review.md)〜[REV-00010](../reviews/00010-pdo-to-acceptance-workflow-review.md)）は高い階層のモデルに全文脈を渡して行っている。REV-00010 第 1 巡では、独立したレビュアー 2 体がそれぞれ約 9 万・15 万トークンを消費した（本セッションのタスク集計値）。機械的な編集はその数十分の一で済んでいる。コストは作業量ではなく判断の難しさに偏る。
- 文脈は有限予算であり、常時ロードは劣化を招く（[EVID-00009](00009-context-budget-is-finite.md)）。[EVID-00013](00013-graphify-needs-llm-for-docs.md) は、Graphify の Cursor 連携が `alwaysApply: true` の規則を書き込み、全会話に常時注入される（Tier 0 相当の枠を消費する）ことを観測している。グラフは「常時注入」ではなく「必要な範囲の問い合わせ」に使わないと、文脈最適化が逆に文脈を浪費する。
- [EVID-00013](00013-graphify-needs-llm-for-docs.md) の観測どおり、Graphify はコードを tree-sitter で**ローカル・決定的**に解析し（`--code-only` なら LLM 呼び出しなし）、`graph.json` にノード・辺・コミュニティを出力する。辺には `EXTRACTED` / `INFERRED` / `AMBIGUOUS` の確信度が付く。したがってコードリポでは、LLM を使わずにコードの参照関係グラフが得られ、変更起点からの近傍（影響範囲）を機械的に列挙できる。本 KB では同じことを [build-graph.py](../.github/scripts/build-graph.py) の `--impact` が行う（[EVID-00014](00014-reference-graph-from-metadata.md)）。
- 誰が決めるかの分界は既にある。status の遷移と値の決定は人（[ADR-00017](../adr/00017-machines-record-facts-humans-decide-status.md)、[ADR-00024](../adr/00024-refine-acceptance-with-bounded-review-rounds.md)）。モデルの階層をいくら上げても、要件の値を決める作業は人の側にある。

## 限界

階層ごとの誤り率・所要時間・トークンを同一タスクで比較した測定は本リポジトリにない。トークン数は本セッションの 1 回分の観測で、再現条件（モデル・プロンプト）に依存する。Graphify の `--code-only` 出力の精度（言語ごとの tree-sitter 対応、動的言語での参照の取りこぼし）は未評価で、影響範囲の見積りが外れる可能性がある。価格は変わるため、本 evidence は相対的な階層関係だけを主張し、金額は書かない。

## 関連

- [ADR-00027](../adr/00027-cost-and-context-per-task.md)
- [PB-00024](../playbook/00024-choose-model-effort-context.md)
- [EVID-00013](00013-graphify-needs-llm-for-docs.md)
- [ADR-00010](../adr/00010-knowledge-graph-layers.md)
