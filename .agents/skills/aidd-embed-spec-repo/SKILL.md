---
name: aidd-embed-spec-repo
description: SDD で運用中の spec / 実装リポジトリに AIDD のワークフロー（要件 → 受け入れ例 → TDD → Story / PR、Jira / Confluence 接続、品質ゲート）を組み込む。「既存プロジェクトに導入する」「spec リポに組み込む」「Jira と Confluence につなぐ」と言われたときに使う。
metadata:
  aidd-playbook: PB-00021
  aidd-tier: "1"
---

# 既存の SDD spec リポジトリに AIDD ワークフローを組み込む

## いつ使うか

- SDD で運用中の spec / 実装リポジトリに、AI 込みのワークフローを載せるとき
- タスク管理が Jira、設計原文が Confluence にあり、git との役割分担を決めたいとき
- 二層（kernel / 案件）の一般則は [PB-00017](../../../playbook/00017-apply-kernel-to-project.md)。SDD リポ向けの具体化が本 skill

## 先に読むもの

1. 案件リポの `AGENTS.md`（あれば）
2. [PB-00021](../../../playbook/00021-embed-workflow-in-spec-repo.md) — 手順の正本
3. [templates/spec-repo-agents.md](../../../templates/spec-repo-agents.md) — 案件 `AGENTS.md` の雛形
4. [ADR-00024](../../../adr/00024-refine-acceptance-with-bounded-review-rounds.md) / [ADR-00025](../../../adr/00025-control-work-units-commits-prs.md) / [ADR-00027](../../../adr/00027-cost-and-context-per-task.md) — 組み込む規約

## 手順の要点

1. 棚卸し（spec の形、Confluence / Jira、言語、CI、ネットワーク）のうえ、案件 `AGENTS.md` を雛形から置き、kernel は raw URL（またはローカル clone）で参照する。Epic 単位の出荷制御を必ず書く
2. 機能ディレクトリに受け入れ例シートと記録を置き、Jira の Story = 受け入れ例の束（代表例 + 付随する境界・反例）、進行の状態は Jira だけに（tasks.md はリンクのみ）
3. 1 コマンドの品質ゲートと、コミット / PR の命名・規模検査を CI に入れる。コードグラフはローカル出力、常時注入しない
4. 1 機能で要件 → 例 → テスト → PR を通し、案件の上書き値を決める

## 禁止事項

- kernel の ADR・規範本文を案件リポへコピーする
- kernel の skill を案件リポへコピーする（OQ-00041 決着まで URL 参照）
- 状態（担当・進行）を git に書く。契約本文や見た目を Markdown に写す
- 手順の詳細をこのファイルに書き写す（正本は PB-00021）
