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
  - ADR-00016
  - ADR-00018
  - ADR-00020
  - ADR-00024
  - ADR-00008
  - ADR-00019
---

## 文脈

PdO の設計を受け入れ例まで詰める工程は [ADR-00024](00024-refine-acceptance-with-bounded-review-rounds.md) で定めた。その先の実装で、タスクの切り方・担当の決め方・コミットの粒度・見出しの命名・PR の規模がばらつくと、レビューが効かず、並走する作業が衝突し、Jira と git の対応が取れなくなる。運用者はこれらを「完全にコントロール」したいと言っており、人の注意に頼る規約では足りない。タスク管理は Jira、設計原文は Confluence が主である。

## 決定

### 1. 単位 — 受け入れ例を基準にする

| 単位 | 定義 | Jira | git |
| --- | --- | --- | --- |
| 機能 | 受け入れ例シート 1 枚（`specs/<feature>/`） | Epic | ディレクトリ |
| タスク | シートの中で**外側テスト 1 つ**になる行グループ（代表例 1 行と、その境界・反例の行） | Story / Task（1 Issue） | 1 ブランチ = 1 PR |
| サブタスク（任意） | タスクを契約 / 振る舞い / 決定の別で縦に割ったもの（[ADR-00014](00014-implementation-spec-split.md)） | Sub-task | 同じ PR 内のコミット群、または先行 PR |
| コミット | TDD の 1 ステップ（red / green / refactor）か、1 つの文書・契約変更。**type を混ぜない** | — | 1 commit |

タスクの上限は「1 PR に収まる量」（§3）で決まる。収まらないなら行グループを分け、Story を分ける。機能をまたいで横に割らない。

### 2. 命名 — 正規表現で検査できる形に固定する

| 対象 | 形式 | 例 |
| --- | --- | --- |
| ブランチ | `<ISSUE-KEY>-<type>-<slug>` | `SHOP-123-feat-member-discount` |
| コミット見出し | [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) `type(scope): 要約`。要約は命令形・72 字以内・末尾句点なし | `feat(discount): 会員歴 6 か月以上に 10% を適用` |
| コミット footer | `Refs: <ISSUE-KEY>`（必須。複数なら 1 行ずつ） | `Refs: SHOP-123` |
| PR タイトル | `<ISSUE-KEY> type(scope): 要約`（squash 時の見出しになる） | `SHOP-123 feat(discount): 会員歴 6 か月以上に 10% を適用` |

type と TDD ステップの対応: `test:` = red（落ちるテストを足す）、`feat:` / `fix:` = green（通す）、`refactor:` = 整える、`docs:` = 受け入れ例・案件 ADR・README、`build:` / `ci:` / `chore:` = 道具。契約（OpenAPI / マイグレーション）は `feat(api):` / `feat(db):` のように scope で示す。

検査用の正規表現（既定。案件で上書き可）:

```text
見出し:   ^(feat|fix|test|refactor|docs|build|ci|chore|perf|revert)(\([a-z0-9./-]+\))?!?: \S.{0,70}$
footer:   ^Refs: [A-Z][A-Z0-9]+-[0-9]+$
PR 題名:  ^[A-Z][A-Z0-9]+-[0-9]+ (feat|fix|test|refactor|docs|build|ci|chore|perf|revert)(\([a-z0-9./-]+\))?!?: \S.{0,70}$
ブランチ: ^[A-Z][A-Z0-9]+-[0-9]+-(feat|fix|test|refactor|docs|build|ci|chore|perf|revert)-[a-z0-9-]+$
```

### 3. 規模 — 既定値を置き、超過は検査で止める

| 対象 | 既定の上限 | 超えたとき |
| --- | --- | --- |
| PR | 1 Issue。変更 400 行以内（生成物・lock・スナップショット・ベンダー配下を除く）。20 ファイル以内。レビュアー 1 人が 1 回で読める | 縦に割る（契約 → 振る舞い → 決定の順に別 PR）。横（機能）で割らない。例外は PR 本文に理由を書き、レビュアーが明示承認 |
| コミット | 1 type。`test:` だけの red コミットは許すが、**PR の先頭コミットは green** | squash で潰さず、コミットを分け直す |
| タスク | 1 PR に収まる量 | Story を分ける（行グループを分ける） |

数値は経験則であり、案件の `AGENTS.md` で上書きできる。ただし「1 Issue = 1 PR」「PR 先頭は green」「type を混ぜない」は上書きしない。

### 4. 担当 — タスク単位で、1 PR に責任者 1 人

| 規則 | 内容 |
| --- | --- |
| 割り振りの単位 | タスク（Story）。ファイルやレイヤ（フロント / バック）で割らない |
| 責任者 | 1 PR = 1 人（Jira の assignee）。エージェントが実装しても責任者は人 |
| エージェントに渡せる条件 | 受け入れ例が `approved`、契約が確定しているか同 PR 内で決められる、影響範囲が閉じている（[ADR-00027](00027-cost-and-context-per-task.md)）。3 つとも満たすとき |
| 人が持つもの | 決定（案件 ADR）、共有境界の契約設計、他者のレビュー、3 条件を満たさないタスク |
| 並走 | 影響範囲（[PB-00024](../playbook/00024-choose-model-effort-context.md) の影響集合）が交わらないタスクだけ同時に走らせる。交わるなら直列にするか、契約を先に固定する PR を先行させる（[ADR-00016](00016-shrink-conflict-surface.md)） |
| レビュアー | 実装者と別の人。エージェントの出力は必ず人がレビューする（[EVID-00008](../evidence/00008-pr-as-quality-gate.md)） |

### 5. Jira / Confluence / git の役割

| 置き場 | 正本とするもの | 置かないもの |
| --- | --- | --- |
| Confluence | PdO の設計原文 | 受け入れ例の写し |
| Jira | 状態（担当・進行・待ち・ブロック）。Issue 本文に spec のパス、受け入れ例の行番号、依拠 KB の ID | 受け入れ例・テスト・契約の本文 |
| git（spec / 実装リポ） | 内容（受け入れ例・テスト・契約・案件 ADR） | 状態 |
| kernel（本リポ） | 規約と手順 | 案件の Issue・値 |

spec リポは Confluence をリンクとページバージョンで指し、本文を転記しない（[ADR-00008](00008-sdd-bridge.md)）。git に状態を書かない方針は [ADR-00020](00020-platform-is-a-client.md) と同じ。Jira ↔ git の紐づけは Issue キー（§2）で行う。

### 6. 機械検査 — kernel は規則、ツールは案件

コミット見出し・footer・PR タイトル・ブランチ名・PR 規模を CI で検査する。ツール（commitlint、PR タイトル検査、差分行数の検査、Jira の開発情報連携）の選定は案件に委ね、kernel は §2 の正規表現と §3 の既定値だけを持つ。検査の導入は [PB-00021](../playbook/00021-embed-workflow-in-spec-repo.md)。

## 根拠

- [EVID-00033](../evidence/00033-work-units-align-to-acceptance-and-small-prs.md): 規約は機械可読（Conventional Commits / commitlint）、小さい PR はレビューが効く（Small CLs）、Issue キーで Jira が紐づく、本リポジトリも 1 意図 1 PR で運用している
- [EVID-00008](../evidence/00008-pr-as-quality-gate.md): PR は品質ゲートであり、読める大きさが前提
- [EVID-00018](../evidence/00018-tests-outlive-design-docs.md): 外側テスト 1 つは閉じた検証可能な単位

## 結果・トレードオフ

- 利点: 粒度・命名・規模が人の注意ではなく正規表現と行数で止まる。Jira と git が Issue キーで機械的に結ばれる
- 利点: タスクが受け入れ例の行グループに対応するため、「何を作ればよいか」と「何が終わりか」がタスクの時点で決まっている
- 利点: 担当とレビューの責任が PR 単位で 1 人に定まり、エージェントが書いても人が責任を持つ
- 代償: 既定値（400 行 / 20 ファイル / 72 字）は経験則で、案件によっては厳しすぎるか緩すぎる。上書き可とした分、案件間で差が出る
- 代償: 小さく切る分 PR の本数が増え、CI の実行回数とレビュー回数が増える
- 代償: Jira の階層（Epic / Story / Sub-task）に依存した表現になっている。別のトラッカーでは読み替えが要る
- 代償: red コミットを許すため、コミット単位で CI を回す運用とは両立しない（PR 単位で回す）

## 関連

- [PB-00022](../playbook/00022-run-work-units-from-acceptance.md)
- [PB-00021](../playbook/00021-embed-workflow-in-spec-repo.md)
- [PB-00024](../playbook/00024-choose-model-effort-context.md)
- [ADR-00024](00024-refine-acceptance-with-bounded-review-rounds.md)
- [ADR-00027](00027-cost-and-context-per-task.md)
- [templates/project-pr.md](../templates/project-pr.md)
