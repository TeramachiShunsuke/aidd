---
id: EVID-028
title: 認証の正本は Okta であり、git は認証情報を使わない
status: active
last_reviewed: 2026-08-13
owners:
  - TeramachiShunsuke
tags:
  - identity
  - okta
  - git
  - platform
related:
  - EVID-026
  - EVID-029
  - ADR-020
  - ADR-017
---

## 主張

人の認証は Okta が行う。git は文書の置き場であり、認証情報を持たず、認可判定にも使わない。PF がログイン主体を知る経路と、知識ベースが文書を保存する経路は分離する。

## 観測

- 2026-08-13、運用者は敵対レビュー（[REV-007](../reviews/007-platform-acl-adversarial-review.md)）の批判を認めたうえで、現行仕様を明示した。**認証は Okta で行う。git では認証情報を利用しない。**
- この仕様は [EVID-026](026-no-principal-or-document-acl.md) と矛盾しない。現行 KB の Frontmatter と CI に principal が無いのは欠陥ではなく、認証を git に置かないという境界の帰結である。`owners` が認可に使われていないことも、同じ境界と一致する。
- [AGENTS.md](../AGENTS.md) は既にトークンと個人データの commit を禁じている。Okta のセッション、リフレッシュトークン、ソースシステムへ委譲したトークンは、その禁止の対象である。git の clone / push に使う GitHub 側の鍵も、このリポジトリの本文へは書かない。
- git が認証を知らない以上、エージェントがこのリポジトリだけを読んで「今ログインしている人」を復元することはできない。ログイン主体が要る作業（ソース ACL の加味、ワークフローの担当）は PF 側で、Okta セッションがあるあいだに行う。

## 限界

Okta のテナント構成、グループと案件の対応、SCIM、MFA、どの IdP 属性を PF が読むかは、本リポジトリでは観測していない。GitHub へ PR を出すときの git 主体も未決である。運用者は直後に、Okta は今の利用例であり kernel の契約は汎用に保つと訂正した（[EVID-029](029-keep-platform-contract-generic.md)）。この文書が言えるのは「その時点で Okta を使うと言った」「git は認証情報を使わない」までである。

## 関連

- [REV-007](../reviews/007-platform-acl-adversarial-review.md)
- [ADR-020](../adr/020-platform-is-a-client.md)
- [EVID-026](026-no-principal-or-document-acl.md)
- [EVID-029](029-keep-platform-contract-generic.md)
