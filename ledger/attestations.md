---
id: LEDGER-ATTESTATIONS
title: Review attestations ledger
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - ledger
  - staleness
  - lifecycle
---

# Review attestations

「読み直して、現行の運用と一致することを確認した」という証跡を追記する台帳。鮮度は Frontmatter の `last_reviewed` とこの台帳の最新日のうち**新しい方**で判定する（[ADR-00012](../adr/00012-review-attestations.md)）。

このファイルは**追記専用**。既存行の書き換え・削除は CI が拒否する。Frontmatter も作成時のまま触らない（ログは日付同期・90 日検査の対象外）。

形式は 1 行 1 レビュー。区切りは半角スペース、説明の前は全角ダッシュ。

```text
- YYYY-MM-DD <文書 ID> <確認者> — <確認した内容>
```

読まずに行を足すのは、本文レビューなしに `last_reviewed` を書き換えるのと同じ規約違反。何を確認したかを具体的に書けないなら、証跡を足さずに [PB-00003](../playbook/00003-run-review-cycle.md) でレビューする。

## 証跡

- 2026-08-09 ADR-00001 TeramachiShunsuke — 5 ディレクトリ構成が現行のツリーと一致することを確認。`templates/` と生成物（INDEX / GRAPH）は本 ADR の列挙外だが、決定を否定しない追加であり改訂不要と判断
- 2026-08-09 ADR-00002 TeramachiShunsuke — 必須キー 5 種と status 列挙 4 種が現行の全文書と一致することを確認。`tier` は ADR-00006 が足した任意キーであり、本 ADR の「少なくとも」に反しない
- 2026-08-09 ADR-00003 TeramachiShunsuke — バイト単位の frozen 検査が現行スクリプトで有効なことを確認。ADR-00012 は検査の適用範囲のみを変え、不変性そのものは維持している
- 2026-08-09 ADR-00005 TeramachiShunsuke — 追記専用（旧内容が新内容の prefix）の判定が現行スクリプトで有効なことを確認。ADR-00012 で reviews を日付同期の対象外にしたため、本 ADR の意図どおり追記が可能になった
- 2026-08-09 EVID-00004 TeramachiShunsuke — 「凍結は編集禁止であり改訂禁止ではない」という主張が現行の運用と一致することを確認。ADR-00012 は後継文書による改訂経路を変えていない
