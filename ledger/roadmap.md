---
id: LEDGER-ROADMAP
title: Roadmap
status: active
last_reviewed: 2026-08-20
owners:
  - TeramachiShunsuke
tags:
  - ledger
  - roadmap
---

# Roadmap

知識ベース（kernel）自体の進め方。**期日と担当は書かない**（進行の状態は git の外。[ADR-00020](../adr/00020-platform-is-a-client.md) 結果・トレードオフ）。「正確」の定義は次の 3 つ: 錨（ADR / PB / OQ / EVID）が実在する、完了条件が検査できる、依存が循環しない。錨は Markdown リンクで書く（ADR / PB / EVID の錨は `build-graph.py` の参照解決検査に乗る。OQ 錨はファイル宛に解決されるため ID の実在は手で確認する）。錨のない項目は載せない。完了した項目は changelog に 1 行残して消す。未分類の問いは [open-questions.md](open-questions.md) を見る（ここに写さない）。

## 段階 1 — 組み込みの試走

1-1〜1-3（ワークフロー文書の `draft` → `active`）は 2026-08-20 に完了した（[OQ-00042](open-questions.md) Resolved、changelog 参照）。

| # | 項目 | 錨 | 完了条件 | 依存 |
| --- | --- | --- | --- | --- |
| 1-4 | SDD spec リポへの組み込み手順の試走 | [PB-00021](../playbook/00021-embed-workflow-in-spec-repo.md) | 1 案件で手順 1〜17 を通し、1 PR がマージされる（CI の命名・規模検査が回り、1 コマンドの品質ゲートが 1 言語以上で動き、`affected` の影響範囲が 1 Story で使われ、PR にモデル節がある）。試走の所見を PB-00021 に反映 | — |

## 段階 2 — 試走の集計で決めること

| # | 項目 | 錨 | 完了条件 | 依存 |
| --- | --- | --- | --- | --- |
| 2-1 | 巡回数 3・回答期限 5 営業日・観点 6 つの見直し | [OQ-00040](open-questions.md) / [OQ-00022](open-questions.md) | 2 機能以上の記録（巡数・残 P0・回答所要）を集計し、既定値を確定または変更 | 1-4 |
| 2-2 | kernel skill の案件リポへの配布方法 | [OQ-00041](open-questions.md) / [ADR-00009](../adr/00009-skills-as-playbook-entrypoints.md) / [ADR-00011](../adr/00011-cross-tool-agent-integration.md) | URL 参照 / コピー / submodule のいずれかを ADR で決める | 1-4 |
| 2-3 | モデル階層ごとの初回合格率・昇格回数の集計 | [OQ-00043](open-questions.md) / [ADR-00027](../adr/00027-cost-and-context-per-task.md) | PR 本文「モデル」節の記録が 20 件以上溜まり、既定の階層表と昇格規則を確定または変更 | 1-4 |
| 2-4 | Graphify `--code-only` / `affected` の実リポでの再現率（言語別） | [EVID-00036](../evidence/00036-graphify-code-only-yields-impact-sets-in-five-languages.md) / [EVID-00013](../evidence/00013-graphify-needs-llm-for-docs.md) | 玩具サンプルでの動作は EVID-00036 で確認済み。実リポ 1 つ以上で `affected` の出力と実際の変更ファイルを比較し、evidence に追記 | 1-4 |
| 2-5 | PR 規模 400 行 / 20 ファイルと共有ファイル一覧の見直し | [ADR-00025](../adr/00025-control-work-units-commits-prs.md) / [EVID-00033](../evidence/00033-work-units-align-to-acceptance-and-small-prs.md) | 超過 PR の件数と理由、合流後に赤くなった件数を集計し、既定値を確定または変更 | 1-4 |
| 2-6 | Tier 0 / 1 の総量上限 | [OQ-00004](open-questions.md) / [EVID-00009](../evidence/00009-context-budget-is-finite.md) | 今回の追加で INDEX と skill description が増えた。上限値を 1 つ仮置きし、超えたら skill の統合か Tier の見直しをする | — |

## 段階 3 — PF（クライアント第一歩）と KB の機械の強化

| # | 項目 | 錨 | 完了条件 | 依存 |
| --- | --- | --- | --- | --- |
| 3-1 | エージェント可呼び面（CLI 正準、必要なら MCP）を別リポで実装 | [ADR-00023](../adr/00023-pf-first-step-agent-callable-client.md) / [OQ-00038](open-questions.md) | 別リポが kernel の契約（読む・問い合わせる・PR を出す）を満たし、OQ-00038 を閉じる | — |
| 3-2 | 検査器の統合と fixture テスト | [OQ-00014](open-questions.md) | staleness / index / graph が 1 検証器になり、fixture で回帰を守る | — |
| 3-3 | 規範文書に散らばる手書き表の単一出所化 | [OQ-00019](open-questions.md) | Tier 表・ツール対応表が 1 か所から生成される | 3-2 |
| 3-4 | レビュー判定の指紋化、評価メタデータ | [OQ-00025](open-questions.md) / [OQ-00015](open-questions.md) | ADR で採否を決める | 3-2 |
| 3-5 | UI デザイン成果物の境界を ADR 化 | [OQ-00028](open-questions.md) / [PB-00016](../playbook/00016-large-project-usage-map.md) | ADR が `active` | — |
| 3-6 | kernel / PF 側の実行ワークフローの状態の置き場 | [OQ-00033](open-questions.md) / [OQ-00034](open-questions.md) | 案件側は Jira（ADR-00025）。kernel / PF 側を ADR で決める | 3-1 |
