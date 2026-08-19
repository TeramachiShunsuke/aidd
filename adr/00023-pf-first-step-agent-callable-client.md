---
id: ADR-00023
title: PF の第一歩は共有クライアント契約とエージェント可呼び面（CLI、必要なら MCP）とする
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - platform
  - client
  - agents
  - delivery
related:
  - EVID-00031
  - EVID-00008
  - EVID-00015
  - EVID-00029
  - EVID-00028
  - EVID-00012
  - ADR-00020
  - ADR-00011
  - ADR-00017
  - ADR-00009
  - ADR-00006
  - REV-00007
  - REV-00008
  - REV-00009
tier: 2
---

## 文脈

AIDD を開発プラットフォーム（PF）へ進めるとき、配信面として IDE 拡張・Web・デスクトップ・CLI が候補に上がった。[ADR-00020](00020-platform-is-a-client.md) は「PF はクライアント」「正本は git の Markdown + PR」「認証情報は git に置かない」を既に固定しているが、**何を第一歩の実装にするか**は未決だった。

[REV-00008](../reviews/00008-client-surface-adversarial-review.md) は複数 IDE 同時第一世代と「認証を Web に先送り」する順序を批判した。続けて、生成AIコーディングエージェント（検証に使っている例: Cursor / Claude Code / Codex）との相性が重要だと運用者が明示した。これらのエージェントの主経路はファイル・シェル・ツール呼び出しであり、GUI 専用面ではない（[EVID-00031](../evidence/00031-agents-primary-path-is-files-shell-tools.md)）。

本 ADR は、PF の**クライアント第一歩**だけを決める。[REV-00007](../reviews/00007-platform-acl-adversarial-review.md) の「製品着工」（ログイン / ACL / 実行 WF / 画面）とは別語である（[REV-00009](../reviews/00009-repo-consistency-adversarial-review.md)）。コネクタ・文書 ACL・実行ワークフローは製品着工側の未決（OQ-00029 / OQ-00032 / OQ-00033 / OQ-00034）に残す。

## 決定

### 1. クライアント第一歩の定義

クライアント第一歩は次の二つだけとする。

1. **共有クライアント契約**を実装リポジトリ側で固定する（本 ADR が契約の内容を書く。製品コードは本 KB に置かない — ADR-00020 §1）
2. その契約を、**エージェントが呼べる面**として出荷する。正準面は **コマンドラインインタフェース（CLI）**。エージェントが同じ操作をツールプロトコルで呼ぶ必要があるときだけ、**同じ操作の薄いアダプタ**（例: MCP）を足す

成功条件（検証例として Cursor / Claude Code / Codex のいずれかを用いる）: **PF 独自 GUI を開かずに**「KB を Tier 順に読む → draft を起こす → 検査を通す → PR を出す」まで完了できる。

### 2. 共有クライアント契約（v0）

クライアントがやってよいこと:

| 操作 | 意味 |
| --- | --- |
| 読む | Tier 0→1→必要なら 2→疑うとき 3（[ADR-00006](00006-context-tiers.md)）。INDEX / GRAPH / skill `description` を入口にする |
| 下書き | `templates/` に従い `status: draft` の文書を提案する。機械は status を `active` 以上へ遷移しない（[ADR-00017](00017-machines-record-facts-humans-decide-status.md)） |
| 検査 | 既存の staleness / index / graph / id 衝突チェックを呼ぶ |
| 採番 | `check-id-collisions.sh --next` 相当を権威ある手順で呼ぶ（[ADR-00018](00018-id-allocation.md)） |
| PR | 変更を branch に載せ、PR を作成する。品質ゲートは PR（[EVID-00008](../evidence/00008-pr-as-quality-gate.md)） |

クライアントがやってはいけないこと:

- 第二の文書ストアを正本にすること
- IdP トークン・ソース委譲認証情報を git に書く／エージェントに常時持たせること
- playbook 手順を GUI や拡張の system prompt に複製すること（[ADR-00009](00009-skills-as-playbook-entrypoints.md)）
- Frontmatter に `acl` / `principal` / `tenant` を足すこと（ADR-00020 §3）

### 3. 表面の優先順位（クライアント第一歩以降）

| 順位 | surface（汎用名） | クライアント第一歩での扱い |
| --- | --- | --- |
| 1 | コマンドライン（正準） | **着手してよい**（製品着工ではない） |
| 1b | 同型のツールアダプタ（例: MCP） | 必要になったら足す。CLI と別の意味体系を持たない |
| 2 | Web（IdP・ACL ビュー・コネクタ） | **延期**。製品着工側。OQ-00029 / OQ-00032 / OQ-00033 が閉じるまで本体にしない |
| 3 | IDE 拡張（1 系だけ） | **延期**。人の摩擦低減用。認可と正本の本体にしない |
| — | 複数 IDE の同時第一世代 | **採らない** |
| — | デスクトップアプリ | **採らない**（Web より先に根拠が出るまで） |

検証や説明で特定の IDE / エージェント製品名を挙げてよいが、それらは**利用例**であり契約の一部ではない（[EVID-00029](../evidence/00029-keep-platform-contract-generic.md)）。

### 4. 人とエージェントの分界

- **エージェント可呼び**: 読む・下書き・検査・採番・PR 作成
- **人のみ**（第一歩の CLI に「確定」を埋め込まない）: `status` の遷移、ソース ACL を越える昇格の可否、凍結・廃止の判断（ADR-00017 / ADR-00020 §5）
- 人向け UI が後から付くときも、上記の可呼び操作は CLI / アダプタから消さない（同型化を維持）
- 認証付き経路（IdP セッションでソースを読む等）は [EVID-00028](../evidence/00028-okta-auth-git-holds-no-credentials.md) の層であり、本第一歩の非認証 CLI とは別である

### 5. kernel との境界と手順の置き場

- 本リポジトリ（kernel）には PF のアプリコードを置かない（ADR-00020 §1）
- kernel の契約語は「クライアント / IdP は git の外 / エージェント可呼びを先にする / 正準はコマンド面 / アダプタは同型」まで。CLI バイナリ名、MCP サーバ名、IDE 製品名、特定エージェント製品名を**契約として**焼き付けない（EVID-00029）
- **kernel に PF 製品用 playbook / skill を増やさない。** GRAPH の「手順のない決定」は、手順の正本を実装リポ側に置くことで意図的に満たす。実装リポが契約 v0 を破らない読み方を自分の playbook / README に書く
- 実装リポの README / ADR が製品チャネルを書いてよい。参照は URL

## 根拠

- [EVID-00031](../evidence/00031-agents-primary-path-is-files-shell-tools.md): エージェントの主経路はファイル・シェル・ツール呼び出し
- [EVID-00015](../evidence/00015-agent-tools-read-different-paths.md) / [ADR-00011](00011-cross-tool-agent-integration.md): ツール横断は正本 1・橋だけ
- [EVID-00012](../evidence/00012-skills-are-progressive-disclosure.md) / [ADR-00009](00009-skills-as-playbook-entrypoints.md): 手順を GUI に複製しない
- [EVID-00008](../evidence/00008-pr-as-quality-gate.md) / [ADR-00020](00020-platform-is-a-client.md): 正本と品質ゲートは git + PR。PF はクライアント
- [EVID-00029](../evidence/00029-keep-platform-contract-generic.md): 製品・チャネル名を kernel 契約にしない
- [EVID-00028](../evidence/00028-okta-auth-git-holds-no-credentials.md): 認証付き PF 経路は別層
- [REV-00008](../reviews/00008-client-surface-adversarial-review.md) / [REV-00009](../reviews/00009-repo-consistency-adversarial-review.md): 表面順序と矛盾点検

## 結果・トレードオフ

- 利点: 第一歩が「画面を増やす」ではなく「エージェントと同じ言葉で KB を操作する」になり、生成AIコーディングエージェントとの相性が製品の中心になる
- 利点: コマンド面を正準にすれば後続のツールアダプタ・Web / IDE は皮にでき、意味体系の分裂を抑えられる
- 利点: 認証・ACL・コネクタをクライアント第一歩から外すので、製品着工の未決を実装で先回りしない
- 代償: 人向けの「ログインしてソースを眺める」体験は第一歩に含まれない。デモ映えは弱い
- 代償: IDE 利用者へのリーチは後回し。エディタ内の発見性は skills / AGENTS.md に依存し続ける
- 代償: OQ-00017（効果測定）が空のままクライアント第一歩に入るため、成功条件は操作完了の可否に留め、事業効果は後で測る

## 関連

- [REV-00009](../reviews/00009-repo-consistency-adversarial-review.md)
- [REV-00008](../reviews/00008-client-surface-adversarial-review.md)
- [REV-00007](../reviews/00007-platform-acl-adversarial-review.md)
- OQ-00035 / OQ-00036 / OQ-00037 / OQ-00039（Resolved）
- OQ-00038
- OQ-00017 / OQ-00029 / OQ-00032 / OQ-00033 / OQ-00034（製品着工側）
