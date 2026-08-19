---
id: ADR-00027
title: タスク種別ごとにモデル階層と effort の既定を決め、文脈はコードグラフの影響範囲で絞る。昇格は検査の失敗で機械的に行う
status: draft
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - cost
  - context
  - model
  - graph
  - workflow
related:
  - EVID-00035
  - EVID-00009
  - EVID-00013
  - ADR-00010
  - ADR-00013
  - ADR-00017
  - ADR-00019
  - ADR-00025
---

## 文脈

運用者は、このワークフローの各タスクで使うモデルと effort を定義してコストを最適化したい。同時に、コード解析に Graphify（Python のグラフツール）を前提にして文脈を絞り、コストと作業速度の両方を意識したい。harness にはモデル階層と effort を指定する手段があり、コストは判断の難しさに偏る（[EVID-00035](../evidence/00035-cost-follows-judgment-not-volume-context-is-scopeable.md)）。一方で [ADR-00010](00010-knowledge-graph-layers.md) は意味グラフ（LLM 経路）を KB の CI と既定運用に入れないと決めている。

## 決定

### 1. タスク種別と既定の階層・effort

モデルは銘柄でなく **階層** で指定する。S（小・速い・安い）/ M（中）/ L（大・判断用）。銘柄への対応表は案件 `AGENTS.md` に置き、変わったらそこだけ直す（例: 本セッションの環境では S = Haiku 4.5、M = Sonnet 5、L = Opus 5 / Fable 5）。

| 種別 | 例 | 階層 | effort | 理由 |
| --- | --- | --- | --- | --- |
| 機械的（検査で正誤が決まる） | INDEX / GRAPH の再生成、ID 採番、整形、ledger への追記、雛形のコピー、コミットの分割、Issue キーの付与 | スクリプト。モデルが要るなら S | low | 正誤は検査が決める。誤れば検査が落ちる |
| 入力が閉じた生成 | 要件 → 受け入れ例の初稿、外側テストの骨格、影響範囲が閉じた green（テストを通す実装）、コミットメッセージ、PR 本文 | M | medium | 入力と検査がある。誤りはテストとレビューが拾う |
| 判断・批評 | レビュー巡（L1〜L6）、敵対レビュー、契約設計の比較、ADR の起草、未決の切り分け、衝突した影響範囲の整理 | L | high | 誤りが検査で拾えず、コストが大きい |
| 要件の決定・承認 | 値・境界・挙動・承認 | 人 | — | モデルに任せない（[ADR-00017](00017-machines-record-facts-humans-decide-status.md)、[ADR-00024](00024-refine-acceptance-with-bounded-review-rounds.md)） |

**昇格規則**: S / M の出力が検査（1 コマンドの品質ゲート、CI、レビュー）で落ちたら、同じ階層で 1 回だけ再試行し、再び落ちたら 1 つ上の階層に渡す。L でも落ちたら人に戻す。最初から L を使うのは「判断・批評」だけ。

### 2. 文脈は影響範囲で絞る

- 1 タスクに渡す文脈は、**案件の Tier 0（`AGENTS.md`）+ 対象の受け入れ例の行 + 影響範囲のファイル + 関係する契約ファイル** に限る。リポ全体を渡さない
- コードの影響範囲は **Graphify の `--code-only`（tree-sitter による決定的解析、LLM なし）** で出したグラフから、変更起点の近傍として列挙する。既定は `EXTRACTED` 辺のみ、深さ 1〜2。`INFERRED` / `AMBIGUOUS` は人が確認したときだけ足す
- KB 側の影響範囲は `build-graph.py --impact <ID>`（[PB-00010](../playbook/00010-review-with-graph.md)）
- グラフの出力（`graphify-out/`）は commit しない。**常時注入（always-apply の規則、Tier 0 への挿入）はしない**。必要なタスクのときだけ問い合わせて、結果の一覧だけを渡す（[EVID-00013](../evidence/00013-graphify-needs-llm-for-docs.md) の観測）
- LLM 経路（docs の意味抽出）は案件でも既定にしない。使うなら人が確認したうえで evidence に昇格させる（[ADR-00010](00010-knowledge-graph-layers.md) を変えない）

### 3. 担当と並走への接続

影響範囲の一覧は [ADR-00025](00025-control-work-units-commits-prs.md) §4 の「影響範囲が閉じている」「並走は影響集合が交わらないものだけ」の判定に使う。

### 4. 計測

PR 本文（[templates/project-pr.md](../templates/project-pr.md)）にモデル階層・effort・再試行回数を任意で書き、案件で集計する。階層の既定を見直す根拠はこの集計であり、推測で変えない（[OQ-00043](../ledger/open-questions.md)）。

## 根拠

- [EVID-00035](../evidence/00035-cost-follows-judgment-not-volume-context-is-scopeable.md): 階層と effort は harness にあり、コストは判断の難しさに偏り、影響範囲は決定的グラフで出せる
- [EVID-00009](../evidence/00009-context-budget-is-finite.md): 文脈は有限予算
- [EVID-00013](../evidence/00013-graphify-needs-llm-for-docs.md): Graphify のコード経路は決定的、常時注入は文脈を消費する

## 結果・トレードオフ

- 利点: 階層と effort の既定がタスク種別で決まり、人が毎回選ばない。昇格は検査の失敗で機械的に起きる
- 利点: 文脈が影響範囲に絞られ、トークンと時間が減る。並走の衝突判定にも同じ一覧を使える
- 利点: 銘柄は案件の表にだけあり、モデルの更新で kernel を直さない
- 代償: 階層ごとの誤り率・コストは未測定。既定は経験則で、集計が溜まるまで見直せない
- 代償: Graphify の解析精度は言語と構文に依存する。影響範囲の見積りが外れると、S / M の出力が検査で落ちて昇格が増える（それでも検査が拾う設計）
- 代償: Graphify という特定ツール名を前提に書いている。同等の決定的コードグラフが出せるなら差し替えてよい（kernel が縛るのは「決定的・LLM なし・常時注入しない」の 3 点）

## 関連

- [PB-00024](../playbook/00024-choose-model-effort-context.md)
- [PB-00022](../playbook/00022-run-work-units-from-acceptance.md)
- [PB-00010](../playbook/00010-review-with-graph.md)
- [ADR-00010](00010-knowledge-graph-layers.md)
- [ADR-00025](00025-control-work-units-commits-prs.md)
