---
id: EVID-00033
title: 作業単位は、受け入れ例に揃えて小さく切り、Issue キーで台帳と結ぶと機械で統制できる
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
  - EVID-00008
  - EVID-00018
  - EVID-00021
  - ADR-00016
  - ADR-00018
  - ADR-00020
  - ADR-00024
---

## 主張

開発の作業単位（タスク・コミット・PR）は、受け入れ例の行グループ（外側テスト 1 つ）を基準に切ると上限が自然に決まる。コミットの見出しは機械可読な規約（Conventional Commits）に、PR は小さく、Issue キーでタスク管理（Jira）と結べば、粒度・命名・規模は人の注意ではなく検査で統制できる。

## 観測

- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) は見出しを `type(scope): description` と定め、`BREAKING CHANGE` や任意の footer を機械可読にしている。[commitlint](https://github.com/conventional-changelog/commitlint) のように、この形式を CI で検査するツールが存在する。形式が決まっているため、違反は人が読まなくても検出できる。
- Google のコードレビュー指針 [Small CLs](https://google.github.io/eng-practices/review/developer/small-cls.html) は、小さな変更はレビューが速く・見落としが減り・マージ衝突が減ると述べ、「1 つの自己完結した変更」を単位に挙げている。同指針は行数の絶対値ではなく、1 つの意図に閉じていることを基準にしている。
- Jira は、ブランチ名・コミットメッセージ・PR タイトルに含まれる Issue キー（例 `PROJ-123`）で開発情報を Issue（work item）に結びつける（Atlassian「[Reference work items in your development spaces](https://support.atlassian.com/jira-software-cloud/docs/reference-issues-in-your-development-work/)」）。キーが一か所にでも入っていれば紐づくため、命名規約にキーの位置を固定すれば欠落を機械で検出できる。
- 本リポジトリ自身が同じ構造で運用されている。[AGENTS.md](../AGENTS.md) は「1 つの意図につき PR 1 本」「積み上げ PR をしない」と定め（[ADR-00018](../adr/00018-id-allocation.md)）、[ADR-00016](../adr/00016-shrink-conflict-surface.md) は衝突を上手く解くのではなく衝突面を減らす方針を採る。並行ブランチが同じ行を触ると必ず衝突する（[EVID-00021](00021-shared-ledgers-and-serial-ids-collide.md)）。作業単位を互いに交わらない影響範囲で切ることは、この方針をコード側へ延ばしたものである。
- 振る舞いの正本はテストであり（[EVID-00018](00018-tests-outlive-design-docs.md)）、受け入れ例の 1 行は外側テスト 1 つに対応する（[PB-00013](../playbook/00013-start-tdd-from-examples.md) 検証「例と外側のテストが 1 対 1」）。代表例 1 行とそれに付随する境界・反例の行は同じルールを検証するため、その束は内容が閉じていて検証可能な最小の作業単位になる（束を単位にするのは [ADR-00025](../adr/00025-control-work-units-commits-prs.md) の決定であり、PB-00013 の主張ではない）。TDD の red → green → refactor はそれぞれ別の意図（落ちるテストを足す / 通す / 整える）であり、コミットの境界として自然に使える（[Test Driven Development](https://martinfowler.com/bliki/TestDrivenDevelopment.html)）。
- PR は知識とコードの品質ゲートである（[EVID-00008](00008-pr-as-quality-gate.md)）。ゲートが機能するには、レビュアーが 1 回で読み切れる大きさであることが前提で、大きさを規約で縛らない限り PR は膨らむ。
- 実行ワークフローの状態（担当・待ち・ゲート）を playbook や git に持たせない方針が kernel にある（[ADR-00020](../adr/00020-platform-is-a-client.md) 結果・トレードオフ。kernel 側の置き場は [OQ-00033](../ledger/open-questions.md) で未決）。案件側で Jira を進行状態の正本、git を内容の正本、Confluence を設計原文の置き場と分ければ、同じ情報を 3 か所に持たずに済む。

## 限界

PR の行数上限（例: 400 行）や 1 タスクの大きさは組織の経験則で、本リポジトリで効果を測定していない。Conventional Commits の type を TDD のステップに対応づける運用は [ADR-00025](../adr/00025-control-work-units-commits-prs.md) の提案であり、外部の標準ではない。Jira の紐づけ挙動はクラウド版ドキュメントに基づき、Data Center 版や設定差は未確認。

## 関連

- [ADR-00025](../adr/00025-control-work-units-commits-prs.md)
- [PB-00022](../playbook/00022-run-work-units-from-acceptance.md)
- [ADR-00024](../adr/00024-refine-acceptance-with-bounded-review-rounds.md)
- [PB-00013](../playbook/00013-start-tdd-from-examples.md)
