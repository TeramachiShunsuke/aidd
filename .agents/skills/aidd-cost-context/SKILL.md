---
name: aidd-cost-context
description: エージェントに渡すタスクごとにモデル階層（S / M / L）・effort・文脈（コードグラフの影響範囲）を選び、自動検査で落ちたら階層を上げる。「どのモデルを使うか」「コストを抑えたい」「Graphify で影響範囲を出す」と言われたときに使う。
metadata:
  aidd-playbook: PB-00024
  aidd-tier: "1"
---

# タスクごとにモデル階層・effort・文脈を選ぶ

## いつ使うか

- エージェントにタスクを渡す直前
- トークンや時間が膨らんできたとき、並走タスクの影響範囲を確かめたいとき

## 先に読むもの

1. 案件リポの `AGENTS.md`（階層 → 銘柄の対応表、コードグラフの出し方）
2. [PB-00024](../../../playbook/00024-choose-model-effort-context.md) — 手順の正本
3. [ADR-00027](../../../adr/00027-cost-and-context-per-task.md) — 種別 × 階層 × effort の既定、昇格規則、文脈の規則
4. [EVID-00013](../../../evidence/00013-graphify-needs-llm-for-docs.md) — Graphify の決定的経路と常時注入の観測

## 手順の要点

1. タスクを 4 種別（機械的 / 入力が閉じた生成 / 判断・批評 / 人の決定）に当て、S / M / L と effort を付ける。人の決定は渡さない
2. `graphify extract . --code-only` → `graphify affected "<起点>" --depth 2`（KB なら `build-graph.py --impact`）に共有ファイルを足して影響範囲にし、指示の文脈を「案件 AGENTS.md + 受け入れ例の行 + 影響範囲 + 契約 + 1 コマンド」に限る
3. 自動検査で落ちたら失敗出力を添えて同階層で 1 回 → 1 つ上へ → L でも落ちたら人へ（最大 4 試行）。人のレビュー指摘は同階層で直す
4. PR 本文「モデル」節の 5 項目を書き、集計で既定を見直す

## 禁止事項

- リポ全体やグラフ全体を文脈に渡す。グラフ出力を常時注入の規則や Tier 0 に入れる。`graphify-out/` を commit する
- 「判断・批評」以外で最初から L を使う。自動検査の失敗なしに階層を上げる。`graphify install` を使う
- 推測でモデルの既定表を変える（集計に基づく）
- 手順の詳細をこのファイルに書き写す（正本は PB-00024）
