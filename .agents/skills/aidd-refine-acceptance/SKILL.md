---
name: aidd-refine-acceptance
description: PdO の要件（ビジネススペック）を、TDD に渡せる受け入れ例（代表例・境界・反例・制約）まで詰める。エージェントが欠落を質問にし PdO が決め、固定観点のレビュー→修正を最大 3 巡回す。「受け入れ条件を詰めたい」「要件から受け入れ例を起こす」「受け入れ基準をブラッシュアップ」と言われたときに使う。
metadata:
  aidd-playbook: PB-00020
  aidd-tier: "1"
---

# PdO の要件（ビジネススペック）を受け入れ条件までブラッシュアップする

## いつ使うか

- PdO の要件（ビジネススペック）を受け取り、実装前に受け入れ例（具体値・境界・反例）まで詰めるとき
- 開発側から「例が足りない」と差し戻された項目を上流でまとめて解消するとき
- spec リポジトリへの組み込みがまだなら、先に [PB-00021](../../../playbook/00021-embed-workflow-in-spec-repo.md)

## 先に読むもの

1. 案件リポの `AGENTS.md`（案件で動くとき。kernel の AGENTS.md は kernel 内で動くときだけ）
2. [PB-00020](../../../playbook/00020-refine-acceptance-from-design.md) — 手順の正本
3. [ADR-00024](../../../adr/00024-refine-acceptance-with-bounded-review-rounds.md) — 役割・出所・観点 L1〜L6・等級・停止条件
4. [templates/acceptance-examples.md](../../../templates/acceptance-examples.md) / [templates/acceptance-refinement-log.md](../../../templates/acceptance-refinement-log.md) — spec リポへコピーする雛形

## 手順の要点

1. 要件に明記された値だけを例に落とし、各行に `出所` を付ける。欠落は値で埋めず、番号付き・選択肢付きの質問（Q-n）にする
2. 観点 L1〜L6 で指摘を等級付きで出す（L5 は各巡で開発が見る）。P1 は巡内で自分（または開発）が直し、P0 だけ PdO に回す。回答は URL 付きで反映し、要件の正本（requirements.md か Confluence）に書き戻して `要件 …` に更新する
3. P0 が 0 件で終える。3 巡で残ったものは「決められていないこと」へ。4 巡目に進まない
4. 承認は PdO（URL 付き）。`提案` の行が残ったまま PB-00013 に渡さない

## 禁止事項

- 要件に書かれていない業務値・閾値・挙動を推測で埋める
- URL のない回答・承認を書く。`提案` の行を承認済みとして扱う
- 自分が書いた初稿を同じセッションで自分でレビューする
- 受け入れ例やブラッシュアップ記録を kernel（本リポジトリ）に置く
- 手順の詳細をこのファイルに書き写す（正本は PB-00020）
