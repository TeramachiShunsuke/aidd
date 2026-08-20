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

受け入れ例シートの `承認:` が `PdO …` になり、実装に入るとき。Story の切り方・担当・コミット・PR の大きさで迷ったとき。並走する作業が衝突し始めたとき。Jira の Story と git の対応が取れなくなったとき。

規約の正本は [ADR-00025](../adr/00025-control-work-units-commits-prs.md)。用語（タスク = Jira Story、行 ID = 表名 + `#`、外側テスト = 1 行 = 1 テスト、Story = その束）も同 ADR に従う。本手順はその適用順である。

## 手順

### 1. Story に切る（Jira）

1. 承認済みの受け入れ例シートを開き、**代表例 1 行と、それに付随する境界・反例の行**を 1 束として Story を 1 つ起票する（会員割引なら「代表例 #1 + 境界 #1〜3 + 反例 #1」で 1 Story）。機能は Epic に対応させる。Epic の出荷制御（フラグ / デプロイ単位）が案件 `AGENTS.md` に書かれていることを確認する
2. Story 本文に次を書く。進行の状態以外の内容は git を指し、転記しない
   - spec のパス（`specs/<feature>/acceptance-examples.md`。実装リポが別なら spec リポの URL と commit）と対象の**行 ID**（`代表例-1`, `境界-1..3`, `反例-1`）
   - 依拠した KB の ID（シート冒頭の ID）
   - 契約の変更を伴うか（OpenAPI / マイグレーション。後方互換か）、案件 ADR が要るか
   - **影響範囲の要約**（手順 4 で責任者が出す）
   - 出荷制御がフラグなら、フラグ名と OFF 時の挙動
3. 1 PR（[ADR-00025](../adr/00025-control-work-units-commits-prs.md) §3: 400 行 / 20 ファイル、除外パターンは案件 `AGENTS.md`）に収まらないと見込むなら、束を分けて Story を分ける。契約（後方互換の expand）→ 振る舞い → 決定の順に縦に割る。機能をまたいで横に割らない

### 2. 担当を決める

4. 各 Story について、**責任者（assignee になる人）が起票時に** 3 条件を見る

   | 条件 | 満たす | 満たさない |
   | --- | --- | --- |
   | シートの `承認:` が `PdO …`（`未` でない） | ○ | [PB-00020](00020-refine-acceptance-from-design.md) に戻す |
   | 契約が確定、または同 PR 内で後方互換に決められる | ○ | 契約（expand）だけの PR を人が先行させる。contract は振る舞い着地後の別 Story |
   | 影響範囲が閉じている（[PB-00024](00024-choose-model-effort-context.md) 手順 3〜5・7 でコードグラフ + 共有ファイルを出して判定する） | ○ | 人が持つか、束を分ける |

   3 つとも満たす Story はエージェントに渡せる。1 つでも欠けるなら人が持つ。どちらの場合も Jira の assignee は人（責任者）
5. 同時に走らせる Story は、影響範囲（コード + マイグレーション連番・DI / ルーティング登録・lock・i18n・生成物）が交わらないものだけにする。交わるなら直列にするか、共有部分だけの PR を先に出す
6. レビューを決める。エージェントが実装する PR は責任者が一次レビューし、加えて別の人が承認する。人が実装する PR は別の人が承認する

### 3. ブランチとコミット

7. ブランチを `<STORY-KEY>-<slug>` で切る（例: `SHOP-123-member-discount`。Jira の「ブランチを作成」が作る名前でよい）。base は main
8. [PB-00013](00013-start-tdd-from-examples.md) のループを回し、ステップごとにコミットする。type を混ぜない

   | ステップ | type | 例 |
   | --- | --- | --- |
   | 落ちる外側テストを足す | `test:` | `test(discount): 会員歴 6 か月ちょうどは対象内（境界-1）` |
   | 通す | `feat:` / `fix:` | `feat(discount): 会員歴の境界を含む判定に直す` |
   | 整える | `refactor:` | `refactor(discount): 判定を DiscountPolicy に寄せる` |
   | 契約を変える（後方互換） | `feat(api/<feature>):` / `feat(db/<feature>):` | `feat(db/discount): members に joined_at を追加` |
   | 案件 ADR・README | `docs:` | `docs(discount): 割引計算の丸め方を ADR に` |
   | 道具 | `build:` / `ci:` / `chore:` | `ci: commitlint を追加` |

9. 各コミットの footer に `Refs: <STORY-KEY>` を書く（Story 起票前の docs / 組み込み PR は Epic キー）。見出しは 72 文字以内。**PR の HEAD（マージ直前）のコミットは green** にする。`git revert` は `revert: <元の見出し>` に書き直す

### 4. PR

10. タイトルを `<STORY-KEY> type(scope): 要約` にする。本文は [templates/project-pr.md](../templates/project-pr.md) を埋める（行 ID、契約変更、決定、規模、コミット、**モデル**（タスク種別 / 初回の階層と effort / 自動検査の初回合否 / 再試行回数 / 最終階層）、検証コマンド）
11. 規模検査（行数・ファイル数・1 Story）と命名検査（見出し・footer・タイトル・ブランチ）が通ることを確認する。超過の例外は本文に理由を書き、レビュアーが明示承認する。bot の PR と "Update branch" のマージコミットは命名検査の対象外
12. レビュー後、**base 最新で 1 コマンドの品質ゲートを再実行**してから squash マージする。squash の見出しは `type(scope): 要約`（PR タイトルから Issue キーを外す）、本文末尾に `Refs: <STORY-KEY>`。マージ後に Jira の状態を進める（自動連携があればそれに任せる。git には書かない）
13. `release/*` への backport は同じ Story キーで追加 PR（タイトル末尾 `[backport]`）

### 5. 還流

14. 同じ種類の超過・分割・衝突が複数の案件で繰り返されたら、既定値（400 行 / 20 ファイル）や縦割りの順、共有ファイルの一覧を見直す候補として [PB-00008](00008-bridge-sdd-spec.md) 方向 B で kernel に戻す

## 検証

- すべての Story が受け入れ例の行 ID と影響範囲の要約を持ち、1 Story = 1 PR になっている（backport を除く）
- ブランチ名・コミット見出し・footer・PR タイトルが [ADR-00025](../adr/00025-control-work-units-commits-prs.md) §2 の正規表現に一致する（bot とマージコミットを除く）
- PR の変更行数・ファイル数が既定値以内、または例外理由と承認がある
- 並走した PR 同士でマージ衝突が起きていない（起きたら手順 5 の影響範囲の切り方を疑う）
- エージェントが実装した PR に責任者の一次レビューと別の人の承認が付いている
- Epic の全 Story が揃うまで利用者に見えていない（フラグ等）

## 失敗時

- PR が 400 行を超えた → 先に契約（後方互換の expand）だけの PR を切り出し、振る舞いを残す。それでも超えるなら束を分ける
- 1 コミットに `test` と `feat` が混ざった → コミットを分け直す（`git reset` して 2 回に分ける）。対話的 rebase で隠さない
- 並走 PR が衝突した、または合流後に赤くなった → 影響範囲の見積りが外れている（共有ファイルの漏れが多い）。衝突した共有部分だけを先行 PR にし、残りを直列にする。手順 12 の再ゲートを省いていないか確認する
- Issue キーが無いコミットが main に入った → 検査（commitlint / PR タイトル検査）が CI に入っていない。[PB-00021](00021-embed-workflow-in-spec-repo.md) 手順に戻って入れる
- エージェントに渡した Story が途中で決定を要した → 止めて人に戻す。エージェントがその場で決めない（[PB-00013](00013-start-tdd-from-examples.md) 手順 5）
- 実装中に受け入れ例を直したくなった → Story を止め、シートの改訂（[PB-00020](00020-refine-acceptance-from-design.md) 手順 17）を別 PR（`Refs:` Epic）で通してから再開する。Story の PR でシートを書き換えない
- 部分状態が本番に出た → Epic 単位の出荷制御が無い。案件 `AGENTS.md` にフラグ / デプロイ単位を書いてから再開する

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
