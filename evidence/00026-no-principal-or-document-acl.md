---
id: EVID-00026
title: 現行の知識ベースに principal はなく、owners も INDEX も認可ではない
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - acl
  - identity
  - platform
related:
  - ADR-00002
  - ADR-00006
  - ADR-00010
  - EVID-00008
---

## 主張

現行の知識ベースは「誰が読めるか／誰が遷移してよいか」を表現しない。Frontmatter の `owners` は連絡先であり認可ではない。`INDEX.md` と `GRAPH.md` はリポジトリ全体の共有索引で、ログイン主体ごとに欠けない。文書 ACL を加味したワークフローは、このモデルの延長では動かない。

## 観測

- [ADR-00002](../adr/00002-frontmatter-schema.md) が必須化するキーは `id` / `title` / `status` / `last_reviewed` / `owners` の 5 つである。`acl` / `principal` / `tenant` / `audience` はない。`status` の列挙は `draft | active | frozen | deprecated` だけで、確認者ロールや閲覧範囲を持たない。
- `.github/scripts/` と `.github/workflows/` を `owners` で検索すると一致は 0 件である。CI は `owners` を読みも検査もしない。認可の実装箇所が無い。
- [ADR-00006](../adr/00006-context-tiers.md) の Tier 1 は毎セッション `INDEX.md` と `GRAPH.md` と `ledger/*` を一覧する。主体（ログインアカウント）を引数に取らない。エージェントはリポジトリを clone した者として、見える文書の全体を候補にする。
- [ADR-00010](../adr/00010-knowledge-graph-layers.md) の構造グラフはリポジトリ内の明示メタデータから 1 枚を生成し、ルートの `GRAPH.md` に commit する。ノードの欠落は「その文書がリポジトリに無い」ときだけで、「この読者には見せない」ではない。
- [ADR-00001](../adr/00001-repository-layout.md) のトップレベルに認証・セッション・ACL ストアの置き場はない。検索・権限・CI を「種類別に制御できる」と書いてあるのは文書種別（evidence / adr / …）の話であり、人やテナントの権限ではない。
- [ADR-00017](../adr/00017-machines-record-facts-humans-decide-status.md) の人間は「PR を出す人」で、下書き者・確認者・凍結承認者を区別しない。[ledger/attestations.md](../ledger/attestations.md) の確認者欄は自由記述の github-login であり、署名でも ACL でもない。
- [REV-00005](../reviews/00005-adversarial-review.md) はリポジトリの CODEOWNERS / branch protection すら、private + Free プランでは使えないと既に記録している。リポ単位の ACL すら未整備のまま、文書単位の ACL を足す土台が無い。

## 限界

「PF の UI が git の前段でフィルタすれば足りる」かどうかは未検証。フィルタはビューの話であり、clone した git には全文が残る。ビュー層の ACL と git 正本の関係は、この観測だけでは決められない。

## 関連

- [ADR-00002](../adr/00002-frontmatter-schema.md)
- [ADR-00006](../adr/00006-context-tiers.md)
- [ADR-00010](../adr/00010-knowledge-graph-layers.md)
- [EVID-00008](00008-pr-as-quality-gate.md)
