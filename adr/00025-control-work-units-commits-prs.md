---
id: ADR-00025
title: 開発の作業単位は受け入れ例に揃え、タスク分解・担当・コミット・命名・PR 規模を機械検査できる規約で統制する
status: draft
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - workflow
  - tdd
  - git
  - jira
related:
  - EVID-00033
  - EVID-00008
  - EVID-00018
  - ADR-00014
  - ADR-00016
  - ADR-00020
  - ADR-00024
  - ADR-00026
  - ADR-00027
  - ADR-00008
---

## 文脈

PdO の設計を受け入れ例まで詰める工程は [ADR-00024](00024-refine-acceptance-with-bounded-review-rounds.md) で定めた。その先の実装で、タスクの切り方・担当の決め方・コミットの粒度・見出しの命名・PR の規模がばらつくと、レビューが効かず、並走する作業が衝突し、Jira と git の対応が取れなくなる。運用者はこれらを「完全にコントロール」したいと言っており、人の注意に頼る規約では足りない。タスク管理は Jira、設計原文は Confluence が主である。

用語:

- **タスク** = Jira の **Story**（Issue 種別の Task は使わない。Sub-task は任意の補助）
- **行 ID** = 受け入れ例シートの表名と番号を `<表名>-<番号>` で書く（例 `代表例-1`、`境界-1`、`反例-1`、`制約-1`。正規形はこのハイフン形のみ）。ファイルの行番号は使わない（行を足すとずれる）
- **外側テスト** = 受け入れ例 **1 行 = 1 テスト**（[PB-00013](../playbook/00013-start-tdd-from-examples.md)、[ADR-00026](00026-fix-loop-shape-let-projects-pick-toolchains.md)）。Story はその**束**である

## 決定

### 1. 単位 — 受け入れ例を基準にする

| 単位 | 定義 | Jira | git |
| --- | --- | --- | --- |
| 機能 | 受け入れ例シート 1 枚（`specs/<feature>/`） | Epic | ディレクトリ |
| Story（タスク） | 外側テストの束。既定は **代表例 1 行と、それに付随する境界・反例の行**（会員割引なら「代表例-1 + 境界-1〜3 + 反例-1」で 1 Story）。付随関係はシートの `ルール` 列（付随行が指す代表例の行 ID）で示す。観測面（API / 画面 / バッチ）が複数あるなら観測面ごとに代表例の行を書き、束もそれに従って分ける | Story（1 Issue） | 1 ブランチ = 1 PR |
| Sub-task（任意） | Story を契約 / 振る舞い / 決定の別で縦に割ったもの（[ADR-00014](00014-implementation-spec-split.md)） | Sub-task | 同じ PR 内のコミット群。先行 PR にするなら Sub-task キーで**独立した Issue** として扱い（`Refs:` とブランチ名に Sub-task キー）、Story 本体は残る 1 PR |
| コミット | TDD の 1 ステップ（red / green / refactor）か、1 つの文書・契約変更。**type を混ぜない** | — | 1 commit |

Story の上限は「1 PR に収まる量」（§3）で決まる。収まらないなら、観測面ごとに代表例を分ける → 契約（expand）を先行させる → 境界・反例を別 Story にする、の順に分ける。機能をまたいで横に割らない。Story 本文には spec のパス・行 ID・依拠 KB・影響範囲の要約に加え、出荷制御がフラグならフラグ名と OFF 時の挙動を書く。

**出荷の単位は Epic**: Story を main に順次マージしても、Epic の全 Story が揃うまで利用者に見せない。手段（フィーチャーフラグ / デプロイ単位の分離 / リリースブランチ）は案件が `AGENTS.md` に**必ず**書く。これがないと「成立条件の Story」だけが本番に出る。

### 2. 命名 — 正規表現で検査できる形に固定する

| 対象 | 形式 | 例 |
| --- | --- | --- |
| ブランチ | `<ISSUE-KEY>-<slug>`。slug は英小文字・数字・ハイフン（Jira の「ブランチを作成」を使うなら Story 要約に英語 slug を併記する）。type を入れてもよい | `SHOP-123-member-discount` / `SHOP-123-feat-member-discount` |
| コミット見出し | [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) `type(scope): 要約`。要約は句点なし・**72 文字以内（目安 50）**。文字数は Unicode の文字で数える（正規表現の `\S.{0,71}` = 72 文字） | `feat(discount): 会員歴 6 か月以上に 10% を適用` |
| コミット footer | `Refs: <STORY-KEY>`（必須。Sub-task キーは任意の 2 行目）。Story 起票前の PR（受け入れ例の書き戻し・組み込み・案件 ADR）は **Epic キー** を使う | `Refs: SHOP-123` |
| PR タイトル | `<STORY-KEY> type(scope): 要約` | `SHOP-123 feat(discount): 会員歴 6 か月以上に 10% を適用` |
| squash 後の見出し | `type(scope): 要約`（PR タイトルから Issue キーを外す）。本文末尾に `Refs: <STORY-KEY>` を残す。GitHub なら squash 時に見出しを編集するか、マージ自動化で変換する。main 上でも commitlint を回す案件ではこの変換を必須にし、回さない案件では推奨 | `feat(discount): 会員歴 6 か月以上に 10% を適用` |

- scope = `specs/<feature>` の feature 名（モノレポは `app/feature`）。契約は `api/<feature>` / `db/<feature>`（例 `feat(db/discount): members に joined_at を追加`）。案件 `AGENTS.md` に語彙を 1 行書く
- type と TDD ステップの対応: `test:` = red、`feat:` / `fix:` = green、`refactor:` = 整える、`docs:` = 受け入れ例・案件 ADR・README、`build:` / `ci:` / `chore:` = 道具、`perf:` / `revert:` は名のとおり。契約は scope `api/<feature>` / `db/<feature>` で示す
- `git revert` は見出しを `revert: <元の見出し>` に書き直す。GitHub の "Update branch" が作るマージコミットと bot（Dependabot / Renovate 等）の PR は**命名検査の対象外**（規模検査は適用）
- 検査対象は **squash 前の非マージコミット** と PR タイトル・ブランチ名

検査用の正規表現（既定。案件で上書き可）:

```text
見出し:   ^(feat|fix|test|refactor|docs|build|ci|chore|perf|revert)(\([a-z0-9./-]+\))?!?: \S.{0,71}$
footer:   ^Refs: [A-Z][A-Z0-9]+-[0-9]+$
PR 題名:  ^[A-Z][A-Z0-9]+-[0-9]+ (feat|fix|test|refactor|docs|build|ci|chore|perf|revert)(\([a-z0-9./-]+\))?!?: \S.{0,71}$
ブランチ: ^[A-Z][A-Z0-9]+-[0-9]+-[a-z0-9-]+$
```

### 3. 規模 — 既定値を置き、超過は検査で止める

| 対象 | 既定の上限 | 超えたとき |
| --- | --- | --- |
| PR | 1 Story。変更 400 行以内・20 ファイル以内（除外パターン — 生成物・lock・スナップショット・ベンダー配下・生成クライアント — は案件 `AGENTS.md` に glob で書く）。レビュアー 1 人が 1 回で読める | 縦に割る（契約 → 振る舞い → 決定の順に別 PR）。横（機能）で割らない。例外は PR 本文に理由を書き、レビュアーが明示承認 |
| コミット | 1 type。`test:` だけの red コミットは許すが、**PR の HEAD（マージ直前）のコミットは green** | 対話的 rebase で隠さず、コミットを分け直す |
| Story | 1 PR に収まる量 | 束を分ける |

- 契約を先行 PR にするのは**後方互換（expand のみ）** のときだけ。既存データや公開契約を狭める変更（contract）は振る舞いが着地した後の別 Story にする（マージ＝デプロイの案件で不可逆な DDL が先に出るのを防ぐ）
- `release/*` への backport は同じ Story キーで追加の PR を出してよい（タイトル末尾に `[backport]`）。「1 Story = 1 PR」の唯一の例外
- 実装中に受け入れ例を変える必要が出たら、その Story は止め、シートの改訂（[ADR-00024](00024-refine-acceptance-with-bounded-review-rounds.md) §6。`Refs:` は Epic キー）を別 PR で通してから再開する。Story の PR の中でシートを書き換えない
- 数値は経験則であり、案件の `AGENTS.md` で上書きできる。「1 Story = 1 PR」「PR の HEAD は green」「type を混ぜない」「Epic 単位の出荷」は上書きしない

### 4. 担当 — Story 単位で、1 PR に責任者 1 人

| 規則 | 内容 |
| --- | --- |
| 割り振りの単位 | Story。ファイルやレイヤ（フロント / バック）で割らない |
| 責任者 | 1 PR = 1 人（Jira の assignee）。エージェントが実装しても責任者は人 |
| エージェントに渡せる条件 | (a) シートの `承認:` が `PdO …`（`未` でない）、(b) 契約が確定しているか同 PR 内で後方互換に決められる、(c) 影響範囲が閉じている（定義は [ADR-00027](00027-cost-and-context-per-task.md) §3: 深さ 2 の近傍と共有ファイルが、その Story の行と契約ファイルの中に収まり、並走 Story の影響範囲と交わらない）。3 つとも満たすとき |
| 影響範囲の判定 | **Story 起票時に責任者が判定**し、Story 本文に影響範囲の要約を書く。コードはコードグラフ（[PB-00024](../playbook/00024-choose-model-effort-context.md)）、それに**非コードの共有ファイル**（マイグレーション連番、DI / ルーティング登録、lock、i18n 辞書、生成物）を手で足す |
| 人が持つもの | 決定（案件 ADR）、共有境界の契約設計、他者のレビュー、3 条件を満たさない Story |
| 並走 | 影響範囲（コード + 共有ファイル）が交わらない Story だけ同時に走らせる。交わるなら直列にするか、共有部分だけの PR を先行させる（[ADR-00016](00016-shrink-conflict-surface.md)）。マージ前に base 最新で 1 コマンドの品質ゲートを再実行する |
| レビュー | エージェントが実装した PR は、責任者が一次レビューし、**加えて別の人が承認**する。人が実装した PR は別の人が承認する（[EVID-00008](../evidence/00008-pr-as-quality-gate.md)） |

### 5. Jira / Confluence / git の役割

| 置き場 | 正本とするもの | 置かないもの |
| --- | --- | --- |
| Confluence | PdO の設計原文 | 受け入れ例シート本文の写し（質問の提示と permalink は可） |
| Jira | 進行の状態（担当・進行・待ち・ブロック）。Epic は機能ごとに最初に起票する。Story 本文に spec のパス（別リポなら URL + commit）、行 ID、依拠 KB の ID、影響範囲の要約、フラグ名と OFF 時の挙動 | 受け入れ例・テスト・契約の本文 |
| git（spec / 実装リポ） | 内容（受け入れ例・テスト・契約・案件 ADR）。シートの `承認:` / `PdO 暫定` / 「決められていないこと」は**内容の記録**（URL 付きの事実）であり、進行の状態ではない。PdO にシートを見せるときは commit 固定の表示 URL（permalink）を使う。質問（Q-n と選択肢）を Jira / Confluence に貼るのは提示であり写しではない | 進行の状態。tasks.md のチェックボックス（使うならリンクだけ） |
| kernel（本リポ） | 規約と手順 | 案件の Issue・値 |

spec リポは Confluence をリンクとページバージョンで指し、本文を転記しない（[ADR-00008](00008-sdd-bridge.md)）。git に進行の状態を書かない方針は [ADR-00020](00020-platform-is-a-client.md) と同じ。Jira ↔ git の紐づけは Issue キー（§2）で行い、Jira からシートを参照する。

### 6. 機械検査 — kernel は規則、ツールは案件

コミット見出し・footer・PR タイトル・ブランチ名・PR 規模を CI で検査する（bot の PR と "Update branch" のマージコミットは命名検査の対象外、規模検査は適用）。ツール（commitlint、PR タイトル検査、差分行数の検査、Jira の開発情報連携）の選定は案件に委ね、kernel は §2 の正規表現と §3 の既定値だけを持つ。検査の導入は [PB-00021](../playbook/00021-embed-workflow-in-spec-repo.md)。

## 根拠

- [EVID-00033](../evidence/00033-work-units-align-to-acceptance-and-small-prs.md): 規約は機械可読（Conventional Commits / commitlint）、小さい PR はレビューが効く（Small CLs）、Issue キーで Jira が紐づく、本リポジトリも 1 意図 1 PR で運用している
- [EVID-00008](../evidence/00008-pr-as-quality-gate.md): PR は品質ゲートであり、読める大きさが前提
- [EVID-00018](../evidence/00018-tests-outlive-design-docs.md): テストを正本にできるのは例まで落ちた受け入れ条件だけ（「外側テスト 1 つが閉じた単位」は EVID-00033 側の推論）

## 結果・トレードオフ

- 利点: 粒度・命名・規模が人の注意ではなく正規表現と行数で止まる。Jira と git が Issue キーで機械的に結ばれる
- 利点: Story が受け入れ例の束に対応するため、「何を作ればよいか」と「何が終わりか」が起票の時点で決まっている
- 利点: 担当とレビューの責任が PR 単位で 1 人に定まり、エージェントが書いても人が責任を持つ
- 代償: 既定値（400 行 / 20 ファイル / 72 文字）は経験則で、案件によっては厳しすぎるか緩すぎる。上書き可とした分、案件間で差が出る
- 代償: 小さく切る分 PR の本数とレビュー回数が増える。エージェント PR に 2 人目の承認を求めるため、人のレビュー負荷が上がる（PR を小さく保つことで相殺する設計）
- 代償: Epic 単位の出荷制御（フラグ等）を案件に要求する。これがない案件では部分状態が本番に出る
- 代償: Jira の階層（Epic / Story / Sub-task）に依存した表現になっている。別のトラッカーでは読み替えが要る
- 代償: red コミットを許すため、コミット単位で CI を回す運用とは両立しない（PR 単位で回す）

## 関連

- [PB-00022](../playbook/00022-run-work-units-from-acceptance.md)
- [PB-00021](../playbook/00021-embed-workflow-in-spec-repo.md)
- [PB-00024](../playbook/00024-choose-model-effort-context.md)
- [ADR-00024](00024-refine-acceptance-with-bounded-review-rounds.md)
- [ADR-00026](00026-fix-loop-shape-let-projects-pick-toolchains.md)
- [ADR-00027](00027-cost-and-context-per-task.md)
- [templates/project-pr.md](../templates/project-pr.md)
