---
id: ADR-00027
title: タスク種別ごとにモデル階層と effort の既定を決め、文脈はコードグラフの影響範囲で絞る。昇格は自動検査の失敗で機械的に行う
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
  - EVID-00036
  - EVID-00009
  - EVID-00013
  - ADR-00010
  - ADR-00017
  - ADR-00024
  - ADR-00025
  - ADR-00026
---

## 文脈

運用者は、このワークフローの各タスクで使うモデルと effort を定義してコストを最適化したい。同時に、コード解析に Graphify（Python のグラフツール）を前提にして文脈を絞り、コストと作業速度の両方を意識したい。harness にはモデル階層と effort を指定する手段があり、コストは判断の難しさに偏り、階層間の価格は倍率で並ぶ（[EVID-00035](../evidence/00035-cost-follows-judgment-not-volume-context-is-scopeable.md)）。Graphify のコード経路は LLM なしで影響範囲を列挙できる（[EVID-00036](../evidence/00036-graphify-code-only-yields-impact-sets-in-five-languages.md)）。一方で [ADR-00010](00010-knowledge-graph-layers.md) は LLM 経路の意味グラフを KB の CI と既定運用に入れないと決めている。

## 決定

### 1. タスク種別と既定の階層・effort

モデルは銘柄でなく **階層** で指定する: **S**（速い・安い。検査で正誤が決まる作業）/ **M**（入力と検査がある生成）/ **L**（判断・批評）。effort（推論の深さ）は階層と**独立した軸**で `low` / `medium` / `high` の 3 値を使う（`max` は使わず、`L` + `high` で通らなければ人に戻す）。銘柄への対応表と、harness が effort を持たない場合の読み替えは案件 `AGENTS.md` に置く。kernel は銘柄を書かない。

| 種別 | 例 | 階層 | effort | 理由 |
| --- | --- | --- | --- | --- |
| 機械的（検査で正誤が決まる） | INDEX / GRAPH の再生成、ID 採番、整形、ledger への追記、雛形のコピー、コミットの分割、Issue キーの付与、L1（具体性の語の残存）/ L5（前提の明記）のような検査に近い観点の一次スクリーニング | スクリプト。モデルが要るなら S | low | 正誤は検査が決める。誤れば検査が落ちる |
| 入力が閉じた生成 | 要件 → 受け入れ例の初稿、外側テストの骨格、影響範囲が閉じた green（テストを通す実装）、コミットメッセージ、PR 本文 | M | medium | 入力と検査がある。誤りは外側テストとレビューが拾う |
| 判断・批評 | レビュー巡（L2〜L4・L6 と総合判断）、敵対レビュー、契約設計の**比較**（選択肢と却下理由の整理）、ADR の起草、未決の切り分け、衝突した影響範囲の整理 | L | high | 誤りが検査で拾えず、コストが大きい |
| 要件の決定・承認・共有境界の契約の**決定** | 値・境界・挙動・承認、他チームと合意する契約の確定 | 人 | — | モデルに任せない（[ADR-00017](00017-machines-record-facts-humans-decide-status.md)、[ADR-00024](00024-refine-acceptance-with-bounded-review-rounds.md)、[ADR-00025](00025-control-work-units-commits-prs.md) §4） |

種別の判定は 2 つの問いで行う: (1) 入力が閉じていて、誤りを自動検査かレビューが拾えるか（拾える → 機械的 / 生成。検査が一意に決めるなら機械的、レビューも要るなら生成）、(2) 検査やレビューが区別しない選択肢が複数あり、選ぶこと自体が成果物か（そう → 判断）。両方に当たる場合は判断を優先する。refactor は生成。

### 2. 昇格 — 自動検査の失敗だけが引き金

- **1 試行** = エージェントが完了を宣言した後の 1 コマンドの品質ゲートの実行（または PR の CI）。TDD の途中で red になる実行は数えない。**自動検査**（1 コマンドの品質ゲート。外側テストを含むこと — [ADR-00026](00026-fix-loop-shape-let-projects-pick-toolchains.md) §1）で落ちたら、**検査の失敗出力を添えて同じ階層・同じ effort で 1 回**再試行する。再び落ちたら 1 つ上の階層（effort は種別の既定のまま）に渡す。`L` でも落ちたら人に戻す。1 タスクの自動試行は**起点から 2 階層分・各 2 回の最大 4 回**（S→S→M→M、または M→M→L→L）で、それを超えたら人に戻す。S 起点で M が 2 回落ちたら L に直行せず人に戻す（種別の当てはめが誤っている可能性が高い）
- **人のレビュー指摘**は昇格の引き金にしない。指摘を添えて同じ階層で直す（指摘という具体的な入力があるため）
- 最初から `L` を使うのは「判断・批評」だけ。検査が薄い案件（外側テストがない）では昇格が起きないので、先に [PB-00023](../playbook/00023-set-up-language-tdd-loop.md) で品質ゲートを整える
- 根拠となる価格比: 2026-08-19 時点の観測で階層間は S : M : L ≈ 1 : 2 : 5（[EVID-00035](../evidence/00035-cost-follows-judgment-not-volume-context-is-scopeable.md)）。「同階層で 1 回再試行」の追加コスト（+1 倍）は「1 段上に直行」（+1〜+3 倍）以下なので、再試行を先にする。比が変われば見直す

### 3. 文脈は影響範囲で絞る

- 1 タスクの**指示に渡す文脈**は、**案件の Tier 0（`AGENTS.md`）+ 対象の受け入れ例の行 + 影響範囲のファイル + 関係する契約ファイル + 1 コマンドの品質ゲート** に限る。リポ全体を渡さない。ファイルとシェルを持つエージェントが作業中に他を読むことは止めないが、初期文脈を絞る（実際の消費は §5 で測る）
- **影響範囲**（本 ADR と [ADR-00025](00025-control-work-units-commits-prs.md) で同じ語を使う）= (a) コードグラフで変更起点から `affected … --depth 2` の逆引きで得た近傍（`EXTRACTED` の辺を信じ、`INFERRED` は人が確認）+ (b) 非コードの共有ファイル（マイグレーション連番、DI / ルーティング登録、lock、i18n 辞書、生成物）を手で足したもの
- **閉じている** = 影響範囲の全ファイルがその Story の変更予定（受け入れ例の行を満たすために触るファイルと契約ファイル）に含まれ、並走する Story の影響範囲と交わらないこと。新規機能でグラフにノードがないときは、入口になる共有ファイル（ルーティング登録・DI・マイグレーション）で判定する。Story 起票時に責任者が判定する（[ADR-00025](00025-control-work-units-commits-prs.md) §4）
- コードグラフは **Graphify の `extract --code-only`（AST による決定的解析、LLM なし）** を既定とする（[EVID-00036](../evidence/00036-graphify-code-only-yields-impact-sets-in-five-languages.md): 5 言語で確認）。同等に決定的・LLM なしなら他のツール（言語のコンパイラ出力、`go list`、LSP の参照検索）で代替してよい。kernel が縛るのは「決定的・LLM なし・常時注入しない」の 3 点
- KB 側の影響範囲は `build-graph.py --impact <ID>`（被参照を辿り切る。方向と打ち切りが違う類似機能。[PB-00010](../playbook/00010-review-with-graph.md)）
- グラフの出力（`graphify-out/`）は commit しない。**常時注入しない**: always-apply の規則、Tier 0 / `CLAUDE.md` への挿入、フックや skill 経由の自動問い合わせ（`graphify install`）のいずれも使わず、必要なタスクのときだけ `affected` で問い合わせて一覧だけを渡す（[EVID-00013](../evidence/00013-graphify-needs-llm-for-docs.md) / [EVID-00036](../evidence/00036-graphify-code-only-yields-impact-sets-in-five-languages.md)）
- LLM 経路（docs の意味抽出）は案件でも既定にしない。使うなら人が確認したうえで evidence に昇格させる（[ADR-00010](00010-knowledge-graph-layers.md) を変えない。AST 経路は構造層として扱う）

### 4. Story の 3 条件と種別の対応

| Story の状態（[ADR-00025](00025-control-work-units-commits-prs.md) §4） | 種別 | 誰が |
| --- | --- | --- |
| 3 条件を満たす（承認済み・契約確定 or 後方互換・閉じている） | 入力が閉じた生成 | M（昇格あり） |
| 契約が未確定（共有境界） | 契約設計の比較は判断・批評、確定は人の決定 | L が比較、人が決める |
| 影響範囲が交わる | 衝突した影響範囲の整理は判断・批評 | L または人 |

### 5. 計測

PR 本文（[templates/project-pr.md](../templates/project-pr.md) の「モデル」節、**必須**。エージェントを使わなかった PR は「人のみ」と書く）に次の 5 項目を書く: タスク種別、初回の階層と effort、自動検査の初回合否、再試行回数、最終階層。案件で集計し、階層の既定を見直す根拠はこの集計であり、推測で変えない（[OQ-00043](../ledger/open-questions.md)）。トークン数と所要時間は harness が出せる範囲で任意に添える。

## 根拠

- [EVID-00035](../evidence/00035-cost-follows-judgment-not-volume-context-is-scopeable.md): 階層と effort は harness にあり（Claude Code で観測）、階層間の価格は 1 : 2 : 5 の倍率、コストは判断の難しさに偏る（仮説として）
- [EVID-00036](../evidence/00036-graphify-code-only-yields-impact-sets-in-five-languages.md): 5 言語のサンプルで `--code-only` と `affected` が影響範囲を出した。Go の一部は `INFERRED`、ラベル衝突は id で解決
- [EVID-00009](../evidence/00009-context-budget-is-finite.md): 文脈は有限予算
- [EVID-00013](../evidence/00013-graphify-needs-llm-for-docs.md): Graphify のコード経路は決定的、常時注入は文脈を消費する

## 結果・トレードオフ

- 利点: 階層と effort の既定がタスク種別で決まり、人が毎回選ばない。昇格は自動検査の失敗で機械的に起きる
- 利点: 文脈が影響範囲に絞られ、トークンと時間が減る。並走の衝突判定にも同じ影響範囲を使える
- 利点: 銘柄は案件の表にだけあり、モデルの更新で kernel を直さない
- 代償: 階層ごとの誤り率・コストは未測定。既定は経験則で、集計が溜まるまで見直せない。effort の語彙は Claude Code で観測したもので、他の harness では読み替えが要る
- 代償: Graphify の解析精度は言語と構文に依存する（玩具サンプルでは Go のファイル間呼び出しが `INFERRED`。実リポの再現率は未測定）。影響範囲の見積りが外れると S / M の出力が検査で落ちて昇格が増える。ただし**並走先への波及は自タスクの検査では拾えない**ため、共有ファイルの手動追加とマージ前の再ゲート（[ADR-00025](00025-control-work-units-commits-prs.md) §4）で補う
- 代償: Graphify という特定ツール名を既定に書いている。同等の決定的コードグラフが出せるなら差し替えてよい

## 関連

- [PB-00024](../playbook/00024-choose-model-effort-context.md)
- [PB-00022](../playbook/00022-run-work-units-from-acceptance.md)
- [PB-00023](../playbook/00023-set-up-language-tdd-loop.md)
- [PB-00010](../playbook/00010-review-with-graph.md)
- [ADR-00010](00010-knowledge-graph-layers.md)
- [ADR-00025](00025-control-work-units-commits-prs.md)
- [ADR-00026](00026-fix-loop-shape-let-projects-pick-toolchains.md)
