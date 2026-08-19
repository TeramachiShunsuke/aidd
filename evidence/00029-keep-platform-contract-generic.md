---
id: EVID-00029
title: kernel の契約は汎用であり、特定の PF 製品や IdP 名に固定しない
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - platform
  - identity
  - adoption
related:
  - EVID-00028
  - ADR-00020
  - ADR-00008
---

## 主張

今使おうとしている PF や IdP（例: Okta）は、その時点の実装である。知識ベースの決定は、特定製品に固定せず、どの PF / どの IdP の前にも置ける契約に留める。

## 観測

- 2026-08-13、運用者は「認証は Okta、git は認証情報を使わない」と述べた（[EVID-00028](00028-okta-auth-git-holds-no-credentials.md)）。続けて、話題にしている PF は**今利用しようとしているもの**であり、**あくまで汎用的でありたい**と明示した。
- [ADR-00008](../adr/00008-sdd-bridge.md) の昇格条件は「他プロジェクトでも同じ判断を繰り返すか」である。IdP を Okta に固定する判断は、IdP を替えた案件では繰り返せない。繰り返せるのは「認証は git の外の IdP、git は認証情報を使わない」までである。
- [ADR-00019](../adr/00019-kernel-and-project-layers.md) の kernel は働き方である。特定 PF の画面名・API・テナント設定を kernel の ADR に書くと、案件の考え方と同じ混在が IdP / 製品名でも起きる。

## 限界

今利用しようとしている PF の製品名、契約条件、Okta 以外の IdP への移行計画は、本リポジトリでは観測していない。汎用契約がどの IdP プロトコル（OIDC / SAML）までを含むかも、ここでは言えない。

## 関連

- [EVID-00028](00028-okta-auth-git-holds-no-credentials.md)
- [ADR-00020](../adr/00020-platform-is-a-client.md)
- [ADR-00008](../adr/00008-sdd-bridge.md)
