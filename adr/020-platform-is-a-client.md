---
id: ADR-020
title: 主体・ACL・実行ワークフローは本 KB の文書モデルに埋め込まず、PF はクライアントとする
status: active
last_reviewed: 2026-08-13
owners:
  - TeramachiShunsuke
tags:
  - platform
  - acl
  - workflow
  - governance
related:
  - EVID-026
  - EVID-027
  - EVID-008
  - EVID-025
  - ADR-017
  - ADR-019
  - ADR-002
  - ADR-006
  - ADR-018
tier: 2
---

## 文脈

将来、AIDD をプラットフォームの UI の裏で動かし、ログインアカウントの内容を ACL 付きでワークフローに載せたい、という構想がある。現行モデルは共有 git の Markdown と PR であり、principal も文書 ACL も実行状態も持たない（[EVID-026](../evidence/026-no-principal-or-document-acl.md)）。アカウント連携の集約はソース側 ACL を共有正本へ越境させる（[EVID-027](../evidence/027-account-aggregation-crosses-acl.md)）。

構想を否定しない。ただし、このリポジトリの Frontmatter や playbook に認可と実行状態を足し始めると、[ADR-002](002-frontmatter-schema.md) の凍結スキーマ、[ADR-006](006-context-tiers.md) の全員向けロード、[ADR-017](017-machines-record-facts-humans-decide-status.md) の人間判断、[ADR-018](018-id-allocation.md) の直列採番と同時に壊れ、直す方法が一意でなくなる。

## 決定

### 1. 本リポジトリに PF を実装しない

UI、ログイン、ACL エンジン、OAuth コネクタ、実行状態機械は**別リポジトリ**に置く。[AGENTS.md](../AGENTS.md) の「アプリコードを置かない」を、構想が来ても維持する。

### 2. 文書の正本は git 上の Markdown + PR のまま

品質ゲートは [EVID-008](../evidence/008-pr-as-quality-gate.md) のまま PR である。将来の PF はクライアントであり、読み・下書きの提案・PR の作成までを行ってよい。PF 独自の文書ストアを第二の正本にしない。正本を移すときは後継 ADR が先である。

### 3. 文書モデルに認可を埋め込まない

Frontmatter に `acl` / `principal` / `tenant` を足さない。`owners` は連絡先であり、認可判定に使わない。認可が必要になったら git の外（PF 側）か、リポジトリをテナント単位に分けるかであり、その選択は OQ-030 / OQ-031 が閉じるまで延期する。

### 4. 共有生成物は全員に見える前提で書く

`INDEX.md` / `GRAPH.md` / `ledger/*` に、特定のログインにだけ見せる行を置かない。見えてはいけない観測は、commit しない。ビュー層のフィルタは PF の話であり、clone した git を秘密分割したことにはならない。

### 5. アカウント由来の原文は kernel に書かない

ログインアカウントで取得した Slack / Meet / Confluence の本文は、共有 kernel の `evidence/` に直接載せない。個人または案件の隔離された下書きに留め、共有へ昇格するときは人間が「ソース側 ACL の外側の読者に出してよいか」を確認する（[ADR-017](017-machines-record-facts-humans-decide-status.md) の確認を、観測の真偽だけでなく越境の可否にも使う）。

### 6. playbook は手順であり、実行ワークフローではない

`playbook/` は「どうやるか」の正本である。チケット状態、担当、待ち、リトライ、ACL ゲートは持たない。PF がワークフローを回すなら、実行状態は PF 側に置く。完了の記録（観測・決定・レビュー）だけが KB に残る。

## 根拠

- [EVID-026](../evidence/026-no-principal-or-document-acl.md): 現行モデルに principal も文書 ACL もない。`owners` と INDEX は認可ではない
- [EVID-027](../evidence/027-account-aggregation-crosses-acl.md): アカウント連携の集約はソース ACL を共有正本へ越境させる
- [EVID-008](../evidence/008-pr-as-quality-gate.md): 知識の品質ゲートは PR である
- [EVID-025](../evidence/025-scattered-sources-suit-evidence-drafts.md): 下書きは起こしてよいが、確定は観測の確認である

## 結果・トレードオフ

- 利点: 構想を OQ に残しつつ、今の git KB を認可システムの振りをした中途半端なスキーマに壊さない
- 利点: PF を別リポのクライアントに固定するので、この KB の CI（frozen / 追記専用 / 採番）と衝突する書き込み経路が増えない
- 代償: 「裏でアカウントを反映してワークフローを回す」体験は、このリポジトリだけでは届かない。届ける作業は PF 側の設計であり、OQ-030..033 が閉じるまで着工しない
- 代償: 共有 git を正本にする限り、文書単位 ACL は近似にしかならない。真の ACL が要るなら正本の置き場自体を後継 ADR でやり直す

## 関連

- [REV-007](../reviews/007-platform-acl-adversarial-review.md)
- [ADR-019](019-kernel-and-project-layers.md)
- [ADR-017](017-machines-record-facts-humans-decide-status.md)
- OQ-030 / OQ-031 / OQ-032 / OQ-033
