---
id: PB-00022
title: 受け入れ例からタスク・担当・コミット・PR を規約どおりに回す
status: draft
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - workflow
  - tdd
  - git
  - jira
related:
  - ADR-00025
  - ADR-00024
  - ADR-00027
  - PB-00013
  - PB-00020
  - PB-00024
  - PB-00021
tier: 2
---

## いつ使うか

受け入れ例シートが `approved` になり、実装に入るとき。タスクの切り方・担当・コミット・PR の大きさで迷ったとき。並走する作業が衝突し始めたとき。Jira の Issue と git の対応が取れなくなったとき。

規約の正本は [ADR-00025](../adr/00025-control-work-units-commits-prs.md)。本手順はその適用順である。

## 手順

### 1. タスクに切る（Jira）

1. `approved` の受け入れ例シートを開き、**外側テスト 1 つ**になる行グループ（代表例 1 行と、その境界・反例の行）ごとに Story を 1 つ起票する。機能は Epic に対応させる
2. Story 本文に次を書く。状態以外の内容は git を指し、転記しない
   - spec のパス（`specs/<feature>/acceptance-examples.md`）と対象の行番号
   - 依拠した KB の ID（シート冒頭の ID）
   - 契約の変更を伴うか（OpenAPI / マイグレーション）、案件 ADR が要るか
3. 1 PR（[ADR-00025](../adr/00025-control-work-units-commits-prs.md) §3: 400 行 / 20 ファイル）に収まらないと見込むなら、行グループを分けて Story を分ける。契約 → 振る舞い → 決定の順に縦に割る。機能をまたいで横に割らない

### 2. 担当を決める

4. 各 Story について次の 3 条件を見る

   | 条件 | 満たす | 満たさない |
   | --- | --- | --- |
   | 受け入れ例が `approved` | ○ | PB-00020 に戻す |
   | 契約が確定、または同 PR 内で決められる | ○ | 契約を先に固定する PR を人が先行させる |
   | 影響範囲が閉じている（[PB-00024](00024-choose-model-effort-context.md) で影響集合を出す） | ○ | 人が持つか、分割する |

   3 つとも満たす Story はエージェントに渡せる。1 つでも欠けるなら人が持つ。どちらの場合も Jira の assignee は人（責任者）
5. 同時に走らせる Story は、影響集合が交わらないものだけにする。交わるなら直列にするか、共有部分（契約・共通モジュール）だけの PR を先に出す
6. レビュアーを実装者と別の人に決める。エージェントが実装した PR は必ず人がレビューする

### 3. ブランチとコミット

7. ブランチを `<ISSUE-KEY>-<type>-<slug>` で切る（例: `SHOP-123-feat-member-discount`）。base は main
8. [PB-00013](00013-start-tdd-from-examples.md) のループを回し、ステップごとにコミットする。type を混ぜない

   | ステップ | type | 例 |
   | --- | --- | --- |
   | 落ちる外側テストを足す | `test:` | `test(discount): 会員歴 6 か月ちょうどは対象内` |
   | 通す | `feat:` / `fix:` | `feat(discount): 会員歴の境界を含む判定に直す` |
   | 整える | `refactor:` | `refactor(discount): 判定を DiscountPolicy に寄せる` |
   | 契約を変える | `feat(api):` / `feat(db):` | `feat(db): members に joined_at を追加` |
   | 受け入れ例・案件 ADR | `docs:` | `docs(discount): 退会済みの反例を追加` |

9. 各コミットの footer に `Refs: <ISSUE-KEY>` を書く。見出しは 72 字以内・命令形。PR の先頭コミット（マージ直前の HEAD）は green にする

### 4. PR

10. タイトルを `<ISSUE-KEY> type(scope): 要約` にする。本文は [templates/project-pr.md](../templates/project-pr.md) を埋める（受け入れ例の行、契約変更、決定、規模チェック、検証コマンド）
11. 規模検査（行数・ファイル数・1 Issue）と命名検査（見出し・footer・タイトル・ブランチ）が通ることを確認する。超過の例外は本文に理由を書き、レビュアーが明示承認する
12. レビュー後、PR タイトルを見出しにして squash マージする。マージ後に Jira の状態を進める（自動連携があればそれに任せる。git には書かない）

### 5. 還流

13. 同じ種類の超過・分割が複数の案件で繰り返されたら、既定値（400 行 / 20 ファイル）や縦割りの順を見直す候補として [PB-00008](00008-bridge-sdd-spec.md) 方向 B で kernel に戻す

## 検証

- すべての Story が受け入れ例の行番号を持ち、1 Story = 1 PR になっている
- ブランチ名・コミット見出し・footer・PR タイトルが [ADR-00025](../adr/00025-control-work-units-commits-prs.md) §2 の正規表現に一致する
- PR の変更行数・ファイル数が既定値以内、または例外理由と承認がある
- 並走した PR 同士でマージ衝突が起きていない（起きたら手順 5 の影響集合の切り方を疑う）
- エージェントが実装した PR に人のレビューが付いている

## 失敗時

- PR が 400 行を超えた → 先に契約（OpenAPI / マイグレーション）だけの PR を切り出し、振る舞いを残す。それでも超えるなら Story を分ける
- 1 コミットに `test` と `feat` が混ざった → コミットを分け直す（`git reset` して 2 回に分ける）。squash で隠さない
- 並走 PR が衝突した → 影響集合の見積りが外れている。衝突した共有部分だけを先行 PR にし、残りを直列にする
- Issue キーが無いコミットが main に入った → 検査（commitlint / PR タイトル検査）が CI に入っていない。[PB-00021](00021-embed-workflow-in-spec-repo.md) 手順に戻って入れる
- エージェントに渡した Story が途中で決定を要した → 止めて人に戻す。エージェントがその場で決めない（[PB-00013](00013-start-tdd-from-examples.md) 手順 5）

## 関連

- [ADR-00025](../adr/00025-control-work-units-commits-prs.md)
- [ADR-00024](../adr/00024-refine-acceptance-with-bounded-review-rounds.md)
- [ADR-00027](../adr/00027-cost-and-context-per-task.md)
- [PB-00013](00013-start-tdd-from-examples.md)
- [PB-00020](00020-refine-acceptance-from-design.md)
- [PB-00024](00024-choose-model-effort-context.md)
- [PB-00021](00021-embed-workflow-in-spec-repo.md)
- [templates/project-pr.md](../templates/project-pr.md)
- skill: [aidd-work-units](../.agents/skills/aidd-work-units/SKILL.md)
