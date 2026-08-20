---
id: PB-00024
title: タスクごとにモデル階層・effort・文脈（影響範囲）を選ぶ
status: active
last_reviewed: 2026-08-20
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - cost
  - context
  - graph
related:
  - ADR-00027
  - ADR-00025
  - ADR-00010
  - PB-00010
  - PB-00022
  - EVID-00013
  - EVID-00036
tier: 2
---

## いつ使うか

エージェントにタスクを渡す直前。「どのモデルで、どれだけ深く、何を読ませるか」を決めるとき。並走するタスクの影響範囲が交わらないかを確かめるとき。トークンや時間が膨らんできたとき。

既定は [ADR-00027](../adr/00027-cost-and-context-per-task.md) にある。本手順はその適用順である。

## 手順

### 1. 種別と階層を決める

1. タスクを [ADR-00027](../adr/00027-cost-and-context-per-task.md) §1 の 4 種別（機械的 / 入力が閉じた生成 / 判断・批評 / 人の決定）に当てる。迷ったら「出力の正誤を検査が決めるか」で切る。決めるなら機械的か生成、決めないなら判断
2. 案件 `AGENTS.md` の対応表で階層（S / M / L）を銘柄に読み替え、effort（low / medium / high。階層とは独立の軸）を付ける。迷ったら 2 つ目の問い「検査が区別しない選択肢が複数あるか」で、あるなら判断（L）。人の決定はエージェントに渡さない

### 2. 文脈を影響範囲に絞る

3. コードリポなら、ローカルで決定的なコードグラフを出す（LLM なし。出力は commit しない）

   ```bash
   pip install graphifyy                # PyPI 名は graphifyy（graphify ではない）
   graphify extract . --code-only      # AST 抽出のみ。graphify-out/graph.json（.gitignore 済み）。2 回目以降は差分だけ再抽出
   ```

   `graphify install`（エージェント設定への skill / 規則の書き込み）は使わない。常時注入になる（[EVID-00013](../evidence/00013-graphify-needs-llm-for-docs.md)）

4. 変更起点（受け入れ例の行が触る入口: エンドポイント、サービス、関数）を決め、逆方向の走査で影響範囲を列挙する（[EVID-00036](../evidence/00036-graphify-code-only-yields-impact-sets-in-five-languages.md)）

   ```bash
   graphify affected "discount_rate" --depth 2            # 既定の深さ 2。呼び出し元・import 元をファイル:行つきで列挙
   graphify affected "ts_discount_rate" --relation calls  # ラベルが衝突（TS の rate() と Go の Rate()）したらノード id で指定、辺の種類で絞る
   graphify god-nodes --top 10                             # ハブ（辺の多いノード）。ここを触るタスクは影響が広い
   ```

   既定は `EXTRACTED` の辺を信じ、`INFERRED`（例: Go の同一パッケージ別ファイルの呼び出し）は出力に含まれたら人が確認する。深さは 2 から始め、検査で落ちたら 3 にする。モノレポの workspace import（`@shop/shared` 等）が辺になるかは案件で 1 回確かめ、ならなければ共有パッケージを共有ファイル一覧（手順 5）に足す。KB のタスクなら `python3 .github/scripts/build-graph.py --impact <ID>`（[PB-00010](00010-review-with-graph.md)）
5. グラフに出ない**共有ファイル**を手で足す: マイグレーション連番、DI / ルーティング登録、lock、i18n 辞書、生成物（OpenAPI クライアント等）。コードグラフの近傍とこの一覧を合わせたものが**影響範囲**（[ADR-00027](../adr/00027-cost-and-context-per-task.md) §3）
6. **指示に渡す文脈**を次に限る: 案件 `AGENTS.md`、対象の受け入れ例の行、影響範囲のファイル、関係する契約ファイル（OpenAPI / マイグレーション）、1 コマンドの品質ゲート。リポ全体・グラフ全体・常時注入の規則は渡さない（作業中にエージェントが他を読むことは止めない。消費は手順 10 で測る）
7. 影響範囲が**閉じている**か（その Story の行と契約ファイルの中に収まり、並走 Story の影響範囲と交わらない）を責任者が判定し、Story 本文に要約を書く。交わるなら [PB-00022](00022-run-work-units-from-acceptance.md) 手順 5 に従い直列化するか、共有部分の PR を先行させる

### 3. 渡す・昇格する・記録する

8. 指示に「種別・階層・effort・影響範囲・1 コマンド・コミット規約」を含めて渡す
9. **1 試行** = エージェントが完了を宣言した後の 1 コマンド実行（または PR の CI）。TDD 途中の red は数えない。**自動検査**（1 コマンド / CI）で落ちたら、失敗出力を添えて同じ階層・同じ effort で 1 回だけ再試行し、再び落ちたら 1 つ上の階層へ。`L` でも落ちたら人に戻す。自動試行は 1 タスク最大 4 回。影響範囲の見積り漏れが原因なら、`--depth 3` にしてから再試行する。**人のレビュー指摘**は昇格させず、指摘を添えて同じ階層で直す
10. PR 本文の「モデル」節（必須）に、タスク種別・初回の階層 / effort・自動検査の初回合否・再試行回数・最終階層を書く（[templates/project-pr.md](../templates/project-pr.md)）。案件で集計し、既定の見直しは集計に基づいて行う

## 検証

- 各タスクに種別・階層・effort が付き、案件 `AGENTS.md` の対応表で銘柄に解決できる
- 指示に渡した文脈がリポ全体ではなく、影響範囲（コード + 共有ファイル）と契約と受け入れ例の行に限られている
- `graphify-out/` が commit されておらず、always-apply の規則・Tier 0・フックや skill 経由の自動問い合わせ（`graphify install`）が入っていない
- 昇格が自動検査の失敗に起因しており、最初から L を使ったタスクは「判断・批評」だけ。1 タスクの自動試行が 4 回以内
- PR 本文の「モデル」節が埋まっている
- 並走した PR が衝突していない

## 失敗時

- S / M で何度も落ちる → 種別の当てはめが間違っている（判断が混ざっている）か、影響範囲が狭すぎる。種別を見直すか深さを増やす。それでも落ちるなら人に戻す
- 影響範囲が巨大になる → 変更起点が大きすぎる。Story の束を分けて小さくする（[PB-00022](00022-run-work-units-from-acceptance.md) 手順 3）
- Graphify が言語に対応していない、または参照を取りこぼす → 言語の公式ツール（コンパイラの依存出力、`go list`、IDE の参照検索）で代替し、代替したことを案件 `AGENTS.md` に書く。kernel が縛るのは「決定的・LLM なし・常時注入しない」の 3 点
- グラフの常時注入を勧める設定（`graphify install` が書く規則・skill・フック）が入っていた → 外す。必要なときに `affected` で問い合わせる形に戻す（[EVID-00013](../evidence/00013-graphify-needs-llm-for-docs.md)）
- 新規機能でグラフにノードがなく影響範囲が空になる → 「閉じている」と判定しない。変更起点になる入口（ルーティング登録、DI、マイグレーション）を共有ファイルとして手で列挙し、それで判定する

## 関連

- [ADR-00027](../adr/00027-cost-and-context-per-task.md)
- [ADR-00025](../adr/00025-control-work-units-commits-prs.md)
- [ADR-00010](../adr/00010-knowledge-graph-layers.md)
- [PB-00010](00010-review-with-graph.md)
- [PB-00022](00022-run-work-units-from-acceptance.md)
- [EVID-00013](../evidence/00013-graphify-needs-llm-for-docs.md)
- [EVID-00036](../evidence/00036-graphify-code-only-yields-impact-sets-in-five-languages.md)
- [templates/project-pr.md](../templates/project-pr.md)
- skill: [aidd-cost-context](../.agents/skills/aidd-cost-context/SKILL.md)
