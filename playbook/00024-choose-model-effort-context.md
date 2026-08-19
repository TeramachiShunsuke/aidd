---
id: PB-00024
title: タスクごとにモデル階層・effort・文脈（影響範囲）を選ぶ
status: draft
last_reviewed: 2026-08-19
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
tier: 2
---

## いつ使うか

エージェントにタスクを渡す直前。「どのモデルで、どれだけ深く、何を読ませるか」を決めるとき。並走するタスクの影響範囲が交わらないかを確かめるとき。トークンや時間が膨らんできたとき。

既定は [ADR-00027](../adr/00027-cost-and-context-per-task.md) にある。本手順はその適用順である。

## 手順

### 1. 種別と階層を決める

1. タスクを [ADR-00027](../adr/00027-cost-and-context-per-task.md) §1 の 4 種別（機械的 / 入力が閉じた生成 / 判断・批評 / 人の決定）に当てる。迷ったら「出力の正誤を検査が決めるか」で切る。決めるなら機械的か生成、決めないなら判断
2. 案件 `AGENTS.md` の対応表で階層（S / M / L）を銘柄に読み替え、effort（low / medium / high）を付ける。人の決定はエージェントに渡さない

### 2. 文脈を影響範囲に絞る

3. コードリポなら、ローカルで決定的なコードグラフを出す（LLM なし。出力は commit しない）

   ```bash
   graphify extract . --code-only      # graphify-out/graph.json（.gitignore 済み）
   ```

4. 変更起点（受け入れ例の行が触る入口: エンドポイント、サービス、モジュール）を決め、グラフ上の近傍を影響範囲として列挙する。既定は `EXTRACTED` 辺のみ・深さ 1〜2。`INFERRED` / `AMBIGUOUS` の辺は人が確認したときだけ足す。KB のタスクなら `python3 .github/scripts/build-graph.py --impact <ID>`（[PB-00010](00010-review-with-graph.md)）
5. 渡す文脈を次に限る: 案件 `AGENTS.md`、対象の受け入れ例の行、影響範囲のファイル、関係する契約ファイル（OpenAPI / マイグレーション）、1 コマンドの品質ゲート。リポ全体・グラフ全体・常時注入の規則は渡さない
6. 並走させるタスク同士の影響範囲が交わらないことを確かめる。交わるなら [PB-00022](00022-run-work-units-from-acceptance.md) 手順 5 に従い直列化するか、共有部分の PR を先行させる

### 3. 渡す・昇格する・記録する

7. 指示に「種別・階層・effort・影響範囲・1 コマンド・コミット規約」を含めて渡す
8. 検査（1 コマンド / CI / レビュー）で落ちたら、同じ階層で 1 回だけ再試行し、再び落ちたら 1 つ上の階層へ。L でも落ちたら人に戻す。影響範囲の見積り漏れが原因なら、近傍の深さを 1 つ増やしてから再試行する
9. PR 本文に階層・effort・再試行回数を書く（任意。[templates/project-pr.md](../templates/project-pr.md)）。案件で集計し、既定の見直しは集計に基づいて行う

## 検証

- 各タスクに種別・階層・effort が付き、案件 `AGENTS.md` の対応表で銘柄に解決できる
- 渡した文脈がリポ全体ではなく、影響範囲と契約と受け入れ例の行に限られている
- `graphify-out/` が commit されておらず、always-apply の規則や Tier 0 にグラフ出力が注入されていない
- 昇格が検査の失敗に起因しており、最初から L を使ったタスクは「判断・批評」だけ
- 並走した PR が衝突していない

## 失敗時

- S / M で何度も落ちる → 種別の当てはめが間違っている（判断が混ざっている）か、影響範囲が狭すぎる。種別を見直すか深さを増やす。それでも落ちるなら人に戻す
- 影響範囲が巨大になる → 変更起点が大きすぎる。受け入れ例の行グループを分けてタスクを小さくする（[PB-00022](00022-run-work-units-from-acceptance.md) 手順 3）
- Graphify が言語に対応していない、または参照を取りこぼす → 言語の公式ツール（コンパイラの依存出力、`go list`、IDE の参照検索）で代替し、代替したことを案件 `AGENTS.md` に書く。kernel が縛るのは「決定的・LLM なし・常時注入しない」の 3 点
- グラフの常時注入を勧める設定が入っていた → 外す。必要なときに問い合わせる形に戻す（[EVID-00013](../evidence/00013-graphify-needs-llm-for-docs.md)）

## 関連

- [ADR-00027](../adr/00027-cost-and-context-per-task.md)
- [ADR-00025](../adr/00025-control-work-units-commits-prs.md)
- [ADR-00010](../adr/00010-knowledge-graph-layers.md)
- [PB-00010](00010-review-with-graph.md)
- [PB-00022](00022-run-work-units-from-acceptance.md)
- [EVID-00013](../evidence/00013-graphify-needs-llm-for-docs.md)
- [templates/project-pr.md](../templates/project-pr.md)
- skill: [aidd-cost-context](../.agents/skills/aidd-cost-context/SKILL.md)
