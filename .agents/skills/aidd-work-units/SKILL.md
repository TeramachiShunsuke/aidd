---
name: aidd-work-units
description: 承認済みの受け入れ例から Jira Story を切り、担当を決め、ブランチ・コミット・PR を規約（Conventional Commits + Issue キー、1 Story = 1 PR、規模上限）どおりに回す。「タスクに分解する」「コミットの粒度」「担当をどう割り振るか」と言われたときに使う。
metadata:
  aidd-playbook: PB-00022
  aidd-tier: "1"
---

# 受け入れ例からタスク・担当・コミット・PR を回す

## いつ使うか

- 受け入れ例が承認され、実装に入るとき
- タスクの切り方・担当・コミット・PR の大きさで迷ったとき、並走が衝突し始めたとき

## 先に読むもの

1. 案件リポの `AGENTS.md`（上書き値がある）
2. [PB-00022](../../../playbook/00022-run-work-units-from-acceptance.md) — 手順の正本
3. [ADR-00025](../../../adr/00025-control-work-units-commits-prs.md) — 単位・命名・規模・担当・Jira / Confluence の規約
4. [templates/project-pr.md](../../../templates/project-pr.md) — 案件 PR 本文

## 手順の要点

1. 代表例 1 行と付随する境界・反例を 1 束 = 1 Story として起票し、本文に spec のパス・行 ID・KB ID・影響範囲の要約を書く。1 PR に収まらないなら束を分けるか縦に割る
2. 3 条件（`承認:` が `PdO …`・契約確定か後方互換・影響範囲が閉じている）を満たす Story だけエージェントへ。責任者は人。並走は影響範囲（コード + 共有ファイル）が交わらないものだけ
3. ブランチ `<KEY>-<slug>`、コミットは TDD のステップごとに 1 type、footer `Refs: <KEY>`、PR タイトル `<KEY> type(scope): 要約`、squash 見出しはキーを外す
4. 規模（400 行 / 20 ファイル）と命名の検査を通し、人がレビュー（エージェント PR は責任者 + 別の人）し、base 最新で再ゲートしてから squash マージ。Epic が揃うまで出荷しない

## 禁止事項

- 1 コミットに複数の type を混ぜる。1 PR に複数の Issue を入れる。機能をまたいで横に割る
- 状態（担当・進行）を git に書く
- 承認されていない受け入れ例からタスクを起票する
- 手順の詳細をこのファイルに書き写す（正本は PB-00022）
