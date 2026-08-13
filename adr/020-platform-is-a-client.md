---
id: ADR-020
title: 認証は git の外の IdP、git は認証情報を使わず、PF は汎用クライアントとする
status: active
last_reviewed: 2026-08-13
owners:
  - TeramachiShunsuke
tags:
  - platform
  - acl
  - workflow
  - governance
  - identity
related:
  - EVID-026
  - EVID-027
  - EVID-028
  - EVID-029
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

[REV-007](../reviews/007-platform-acl-adversarial-review.md) の批判に対し、運用者はこれを認め、次を明示した。認証は git の外の IdP が行う（**今の利用は Okta**）。git では認証情報を利用しない（[EVID-028](../evidence/028-okta-auth-git-holds-no-credentials.md)）。話題の PF は今使おうとしている実装であり、kernel の契約は特定製品に固定せず汎用に保つ（[EVID-029](../evidence/029-keep-platform-contract-generic.md)）。

このリポジトリの Frontmatter や playbook に認可と実行状態を足し始めると、[ADR-002](002-frontmatter-schema.md) の凍結スキーマ、[ADR-006](006-context-tiers.md) の全員向けロード、[ADR-017](017-machines-record-facts-humans-decide-status.md) の人間判断、[ADR-018](018-id-allocation.md) の直列採番と同時に壊れ、直す方法が一意でなくなる。認証を git に戻すことも、IdP 名や PF 製品名を kernel の契約に焼き付けることも、同じ壊れ方をする。

## 決定

### 1. 本リポジトリに特定の PF を実装しない

UI、ログイン、ACL エンジン、コネクタ、実行状態機械は**別リポジトリ**に置く。[AGENTS.md](../AGENTS.md) の「アプリコードを置かない」を維持する。kernel は今使っている PF の製品名や画面を契約にしない。どの PF の前にも置ける働き方だけを書く。

### 2. 文書の正本は git 上の Markdown + PR のまま

品質ゲートは [EVID-008](../evidence/008-pr-as-quality-gate.md) のまま PR である。PF はクライアントであり、読み・下書きの提案・PR の作成までを行ってよい。PF 独自の文書ストアを第二の正本にしない。正本を移すときは後継 ADR が先である。

### 3. 認証は git の外の IdP。git は認証情報を使わない

- 人の主体（principal）は **git の外の IdP** である。GitHub アカウントでも、git の committer でもない
- **今の利用**は Okta である。契約は Okta という製品名ではなく、「IdP が認証し、git は認証情報を使わない」である。IdP を替えても kernel の ADR は書き直さない
- git は文書ストアである。IdP のトークン、セッション、ソースシステムへ委譲した認証情報を**持たない・読まない・commit しない**
- PF は IdP で人を認証し、そのセッションのあいだにソース ACL を加味して読む。知識ベースへ渡すのは、認証情報を含まない Markdown と PR だけである
- Frontmatter に `acl` / `principal` / `tenant` を足さない。`owners` は連絡先であり、認可判定に使わない。認可は git の外（IdP と PF）に置く

### 4. 共有生成物は全員に見える前提で書く

`INDEX.md` / `GRAPH.md` / `ledger/*` に、特定のログインにだけ見せる行を置かない。見えてはいけない観測は、commit しない。ビュー層のフィルタは PF の話であり、clone した git を秘密分割したことにはならない。

### 5. アカウント由来の原文は kernel に書かない

ログインアカウントで取得した Slack / Meet / Confluence の本文は、共有 kernel の `evidence/` に直接載せない。個人または案件の隔離された下書きに留め、共有へ昇格するときは人間が「ソース側 ACL の外側の読者に出してよいか」を確認する（[ADR-017](017-machines-record-facts-humans-decide-status.md) の確認を、観測の真偽だけでなく越境の可否にも使う）。

### 6. playbook は手順であり、実行ワークフローではない

`playbook/` は「どうやるか」の正本である。チケット状態、担当、待ち、リトライ、ACL ゲートは持たない。PF がワークフローを回すなら、実行状態は PF 側に置く。完了の記録（観測・決定・レビュー）だけが KB に残る。

## 根拠

- [EVID-029](../evidence/029-keep-platform-contract-generic.md): kernel の契約は汎用であり、今の PF / IdP 名に固定しない
- [EVID-028](../evidence/028-okta-auth-git-holds-no-credentials.md): 今の利用では認証は Okta。git は認証情報を使わない
- [EVID-026](../evidence/026-no-principal-or-document-acl.md): 現行モデルに principal も文書 ACL もない。`owners` と INDEX は認可ではない
- [EVID-027](../evidence/027-account-aggregation-crosses-acl.md): アカウント連携の集約はソース ACL を共有正本へ越境させる
- [EVID-008](../evidence/008-pr-as-quality-gate.md): 知識の品質ゲートは PR である
- [EVID-025](../evidence/025-scattered-sources-suit-evidence-drafts.md): 下書きは起こしてよいが、確定は観測の確認である

## 結果・トレードオフ

- 利点: 認証と文書ストアが分かれ、git KB を IdP の振りにしない。今の IdP が Okta でも、契約は汎用のまま
- 利点: PF を別リポのクライアントに固定するので、この KB の CI と衝突する書き込み経路が増えない。PF 製品を替えても kernel は残る
- 代償: このリポジトリだけを読んでも「今誰が作業しているか」は分からない。ログインが要る作業は PF 側
- 代償: 共有 git を正本にする限り、文書単位 ACL は PF のビューにしかならない。clone した git は認証後の公開面である
- 代償: PF が git に PR を出すときの GitHub 主体は未決（OQ-034）。IdP ユーザーと committer の対応を git に書き込まない前提で決める

## 関連

- [REV-007](../reviews/007-platform-acl-adversarial-review.md)
- [ADR-019](019-kernel-and-project-layers.md)
- [ADR-017](017-machines-record-facts-humans-decide-status.md)
- OQ-032 / OQ-033 / OQ-034
