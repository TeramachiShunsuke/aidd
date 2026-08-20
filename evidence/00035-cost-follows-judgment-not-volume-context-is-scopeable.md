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

- ベンダーのモデルは能力と価格で階層化されて提供される。2026-08-19 に [Claude の料金ページ](https://platform.claude.com/docs/en/about-claude/pricing) を読んだ時点で、入力 / 出力とも Haiku 4.5 : Sonnet 5 : Opus 5 : Fable 5 = $1 / $5 : $2 / $10 : $5 / $25 : $10 / $50（MTok あたり）= **1 : 2 : 5 : 10** の倍率で並び、キャッシュ読みは入力の 0.1 倍、Batch は 0.5 倍だった。同ページは「単純なタスクは Haiku、大半の本番は Sonnet、最も複雑な推論は Opus」と使い分けを勧めている。本セッションの実行環境（Claude Code）では、サブエージェントごとにモデル階層（haiku / sonnet / opus 等）と推論の深さ（effort: low〜max）を指定できる。つまり「タスクごとに階層と深さを選ぶ」操作は少なくともこの harness には存在する。
- 本リポジトリでは、正誤が検査で決まる作業（INDEX / GRAPH の再生成、ID の採番、frozen 不変・追記専用・鮮度の検査）はスクリプトが行い、モデルを使っていない（[ADR-00013](../adr/00013-check-grades.md): 修正方法が一意な検査は機械で固定する）。一方、敵対レビューや矛盾点検（[REV-00005](../reviews/00005-adversarial-review.md)〜[REV-00010](../reviews/00010-pdo-to-acceptance-workflow-review.md)）は高い階層のモデルに全文脈を渡して行っている。REV-00010 第 1 巡では、独立したレビュアー 2 体がそれぞれ約 9.1 万・15.0 万トークンを消費した（本セッションの harness が返した集計値。第 2 巡は 3 体で約 15.0 万・11.0 万・17.0 万。REV-00010 の各巡見出しに記録）。この消費はレビュアーに渡した文脈の量とも相関するため、「コストは作業量ではなく判断の難しさに偏る」は本 evidence では**仮説**に留める。
- 文脈は有限予算であり、常時ロードは劣化を招く（[EVID-00009](00009-context-budget-is-finite.md)）。[EVID-00013](00013-graphify-needs-llm-for-docs.md) は、Graphify の Cursor 連携が `alwaysApply: true` の規則を書き込み、全会話に常時注入される（Tier 0 相当の枠を消費する）ことを観測している。グラフは「常時注入」ではなく「必要な範囲の問い合わせ」に使わないと、文脈最適化が逆に文脈を浪費する。
- [EVID-00013](00013-graphify-needs-llm-for-docs.md) の観測どおり、Graphify はコードを tree-sitter で**ローカル・決定的**に解析し（`--code-only` なら LLM 呼び出しなし）、`graph.json` にノード・辺・コミュニティを出力する。辺には `EXTRACTED` / `INFERRED` / `AMBIGUOUS` の確信度が付く。したがってコードリポでは、LLM を使わずにコードの参照関係グラフが得られ、変更起点からの近傍（影響範囲）を機械的に列挙できる。本 KB では [build-graph.py](../.github/scripts/build-graph.py) の `--impact` が類似の照会（被参照を辿り切る。方向と打ち切りは違う）を行う（[EVID-00014](00014-reference-graph-from-metadata.md)）。コードでの実行結果は [EVID-00036](00036-graphify-code-only-yields-impact-sets-in-five-languages.md)。
- 誰が決めるかの分界は既にある。status の遷移と値の決定は人（[ADR-00017](../adr/00017-machines-record-facts-humans-decide-status.md)、[ADR-00024](../adr/00024-refine-acceptance-with-bounded-review-rounds.md)）。モデルの階層をいくら上げても、要件の値を決める作業は人の側にある。

## 限界

階層ごとの誤り率・所要時間・トークンを同一タスクで比較した測定は本リポジトリにない。トークン数は本セッションの観測で、再現条件（モデル・プロンプト・渡した文脈）に依存し、判断の難しさと文脈量が交絡している。階層と effort の指定は Claude Code でのみ観測し、Codex / Cursor に同等の per-task 指定があるかは未確認。価格の金額は 2026-08-19 の日付付き観測であり、本 evidence の主張は比（1 : 2 : 5 : 10）だけに置く。比も変わりうる。Graphify の `--code-only` 出力の精度（言語ごとの tree-sitter 対応、動的言語での参照の取りこぼし）は未評価で、影響範囲の見積りが外れる可能性がある。価格は変わるため、本 evidence は相対的な階層関係だけを主張し、金額は書かない。

## 関連

- [ADR-00027](../adr/00027-cost-and-context-per-task.md)
- [PB-00024](../playbook/00024-choose-model-effort-context.md)
- [EVID-00013](00013-graphify-needs-llm-for-docs.md)
- [EVID-00036](00036-graphify-code-only-yields-impact-sets-in-five-languages.md)
- [ADR-00010](../adr/00010-knowledge-graph-layers.md)
