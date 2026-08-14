---
id: ADR-022
title: PF の第一歩は共有クライアント契約とエージェント可呼び面（CLI、必要なら MCP）とする
status: draft
last_reviewed: 2026-08-14
owners:
  - TeramachiShunsuke
tags:
  - platform
  - client
  - agents
  - delivery
related:
  - EVID-031
  - EVID-008
  - EVID-015
  - EVID-029
  - EVID-012
  - ADR-020
  - ADR-011
  - ADR-017
  - ADR-009
  - ADR-006
  - REV-007
  - REV-008
tier: 2
---

## 文脈

AIDD を開発プラットフォーム（PF）へ進めるとき、配信面として IDE 拡張・Web・デスクトップ・CLI が候補に上がった。[ADR-020](020-platform-is-a-client.md) は「PF はクライアント」「正本は git の Markdown + PR」「認証情報は git に置かない」を既に固定しているが、**何を第一歩の実装にするか**は未決だった。

[REV-008](../reviews/008-client-surface-adversarial-review.md) は VS Code + IntelliJ 同時第一世代と「認証を Web に先送り」する順序を批判した。続けて、Cursor / Claude Code / Codex との相性が重要だと運用者が明示した。これらのエージェントの主経路はファイル・シェル・ツール呼び出しであり、GUI 専用面ではない（[EVID-031](../evidence/031-agents-primary-path-is-files-shell-tools.md)）。

本 ADR は、PF の**ファーストステップ**だけを決める。コネクタ・文書 ACL・実行ワークフローの中身は [REV-007](../reviews/007-platform-acl-adversarial-review.md) の未決（OQ-029 / OQ-032 / OQ-033 / OQ-034）に残す。

## 決定

### 1. 第一歩の定義

PF の第一歩は次の二つだけとする。

1. **共有クライアント契約**を実装リポジトリ側で固定する（本 ADR が契約の内容を書く。製品コードは本 KB に置かない — ADR-020 §1）
2. その契約を、**エージェントが呼べる面**として出荷する。正準面は **CLI**。Cursor / Claude Code が同じ操作をツールとして使う必要があるときだけ、**同じ操作の MCP アダプタ**を足す

第一歩の成功条件: Cursor / Claude Code / Codex のいずれか（できれば複数）が、**PF 独自 GUI を開かずに**「KB を Tier 順に読む → draft を起こす → 検査を通す → PR を出す」まで完了できる。

### 2. 共有クライアント契約（v0）

クライアントがやってよいこと:

| 操作 | 意味 |
| --- | --- |
| 読む | Tier 0→1→必要なら 2→疑うとき 3（[ADR-006](006-context-tiers.md)）。INDEX / GRAPH / skill `description` を入口にする |
| 下書き | `templates/` に従い `status: draft` の文書を提案する。機械は status を `active` 以上へ遷移しない（[ADR-017](017-machines-record-facts-humans-decide-status.md)） |
| 検査 | 既存の staleness / index / graph / id 衝突チェックを呼ぶ |
| 採番 | `check-id-collisions.sh --next` 相当を権威ある手順で呼ぶ（[ADR-018](018-id-allocation.md)） |
| PR | 変更を branch に載せ、PR を作成する。品質ゲートは PR（[EVID-008](../evidence/008-pr-as-quality-gate.md)） |

クライアントがやってはいけないこと:

- 第二の文書ストアを正本にすること
- IdP トークン・ソース委譲認証情報を git に書く／エージェントに常時持たせること
- playbook 手順を GUI や拡張の system prompt に複製すること（[ADR-009](009-skills-as-playbook-entrypoints.md)）
- Frontmatter に `acl` / `principal` / `tenant` を足すこと（ADR-020 §3）

### 3. 表面の優先順位（第一歩以降）

| 順位 | surface | 第一歩での扱い |
| --- | --- | --- |
| 1 | CLI（正準） | **着手する** |
| 1b | MCP（CLI と同型の薄いアダプタ） | 必要になったら足す。CLI と別の意味体系を持たない |
| 2 | Web（IdP・ACL ビュー・コネクタ） | **延期**。OQ-029 / OQ-032 / OQ-033 が閉じるまで本体にしない |
| 3 | IDE 拡張（1 系だけ） | **延期**。人の摩擦低減用。認可と正本の本体にしない |
| — | VS Code と IntelliJ の同時第一世代 | **採らない** |
| — | デスクトップアプリ | **採らない**（Web より先に根拠が出るまで） |

### 4. 人とエージェントの分界

- **エージェント可呼び**: 読む・下書き・検査・採番・PR 作成
- **人のみ**（第一歩の CLI に「確定」を埋め込まない）: `status` の遷移、ソース ACL を越える昇格の可否、凍結・廃止の判断（ADR-017 / ADR-020 §5）
- 人向け UI が後から付くときも、上記の可呼び操作は CLI / MCP から消さない（同型化を維持）

### 5. kernel との境界

- 本リポジトリ（kernel）には PF のアプリコードを置かない（ADR-020 §1）
- kernel の契約は「クライアント / IdP は git の外 / エージェント可呼びを先にする」まで。CLI 名・MCP サーバ名・IDE 製品名を kernel に焼き付けない（[EVID-029](../evidence/029-keep-platform-contract-generic.md)）
- 実装リポの README / ADR が製品チャネルを書いてよい。参照は URL

## 根拠

- [EVID-031](../evidence/031-agents-primary-path-is-files-shell-tools.md): エージェントの主経路はファイル・シェル・ツール呼び出し
- [EVID-015](../evidence/015-agent-tools-read-different-paths.md) / [ADR-011](011-cross-tool-agent-integration.md): ツール横断は正本 1・橋だけ
- [EVID-012](../evidence/012-skills-are-progressive-disclosure.md) / [ADR-009](009-skills-as-playbook-entrypoints.md): 手順を GUI に複製しない
- [EVID-008](../evidence/008-pr-as-quality-gate.md) / [ADR-020](020-platform-is-a-client.md): 正本と品質ゲートは git + PR。PF はクライアント
- [EVID-029](../evidence/029-keep-platform-contract-generic.md): 製品・チャネル名を kernel 契約にしない
- [REV-008](../reviews/008-client-surface-adversarial-review.md): IDE 同時第一世代と認証先送り順序への批判

## 結果・トレードオフ

- 利点: 第一歩が「画面を増やす」ではなく「エージェントと同じ言葉で KB を操作する」になり、Cursor / Claude Code / Codex との相性が製品の中心になる
- 利点: CLI を正準にすれば MCP・後続 Web / IDE はアダプタにでき、意味体系の分裂を抑えられる（OQ-037 を契約側で閉じる）
- 利点: 認証・ACL・コネクタを第一歩から外すので、REV-007 の未決を実装で先回りしない
- 代償: 人向けの「ログインしてソースを眺める」体験は第一歩に含まれない。デモ映えは弱い
- 代償: IDE 利用者へのリーチは後回し。エディタ内の発見性は skills / AGENTS.md に依存し続ける
- 代償: OQ-017（効果測定）が空のまま着手するため、第一歩の成功条件は操作完了の可否に留め、事業効果は後で測る

## 関連

- [REV-008](../reviews/008-client-surface-adversarial-review.md)
- [REV-007](../reviews/007-platform-acl-adversarial-review.md)
- OQ-035 / OQ-036 / OQ-037（本 ADR で Resolved へ）
- OQ-038（CLI と MCP のどちらを先に配るかの残件）
- OQ-017 / OQ-029 / OQ-032 / OQ-033 / OQ-034（第一歩の外）
