---
name: aidd-refine-acceptance
description: PdO の設計（ビジネススペック）を、TDD に渡せる受け入れ条件（代表例・境界・反例）までブラッシュアップする。エージェントが欠落を質問にして PdO が決め、固定観点のレビュー→修正を最大 3 巡回す。「受け入れ条件を詰めたい」「設計から受け入れ例を起こす」「PdO の設計をレビューしてテストに渡せる形にする」「受け入れ基準をブラッシュアップ」「spec リポに AIDD のワークフローを組み込む」と言われたときに使う。
metadata:
  aidd-playbook: PB-00020
  aidd-tier: "1"
---

# PdO の設計を受け入れ条件までブラッシュアップする

## いつ使うか

- PdO の設計を受け取り、実装前に受け入れ例（具体値・境界・反例）まで詰めるとき
- SDD で運用中の spec リポジトリに、この工程を AI ワークフローとして組み込むとき
- 開発側から「例が足りない」と差し戻された項目を上流でまとめて解消するとき

## 先に読むもの

1. [AGENTS.md](../../../AGENTS.md)
2. [PB-00020](../../../playbook/00020-refine-acceptance-from-design.md) — 手順の正本
3. [ADR-00024](../../../adr/00024-refine-acceptance-with-bounded-review-rounds.md) — 役割・出所・観点 L1〜L6・等級・停止条件
4. [templates/acceptance-examples.md](../../../templates/acceptance-examples.md) / [templates/acceptance-refinement-log.md](../../../templates/acceptance-refinement-log.md) — spec リポへコピーする雛形

## 手順の要点

1. 設計に明記された値だけを例に落とし、各行に `出所` を付ける。欠落は値で埋めず、選択肢付きの質問にする
2. 観点 L1〜L6 で指摘を等級付きで出し、PdO の回答を反映して記録に「指摘 / 対応 / 決めた人」を追記する
3. P0 / P1 が 0 件で終える。3 巡で残ったものは「決められていないこと」へ移し、4 巡目に進まない
4. 承認（`approved`）は PdO が行う。`提案` の行が残ったまま PB-00013 に渡さない

## 禁止事項

- 設計に書かれていない業務値・閾値・挙動を推測で埋める
- `status` を `approved` に書き換える、または `提案` の行を承認済みとして扱う
- 受け入れ例やブラッシュアップ記録を kernel（本リポジトリ）に置く
- 手順の詳細をこのファイルに書き写す（正本は PB-00020）
