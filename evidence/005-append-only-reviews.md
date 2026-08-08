---
id: EVID-005
title: 追記専用ログは改ざん耐性を上げる
status: active
last_reviewed: 2026-08-08
owners:
  - TeramachiShunsuke
tags:
  - reviews
  - audit
related:
  - ADR-005
  - PB-003
---

## 主張

レビュー記録を上書き可能にすると履歴が消える。`reviews/` は追記専用にし、過去の判断を保存する。

## 観測

- Git 履歴でも復元は可能だが、読者が「現行ファイルを読めば足りる」と誤解しやすい。
- prefix 不変（旧内容が新内容の先頭一致）は CI で安価に検査できる。
- 日付見出しでの追記は、人間・エージェント双方のスキャンに耐える。

## 限界

巨大ファイル化した場合は年次で新規ファイルに切り替え、旧ファイルを frozen にする運用を取る。

## 関連

- [ADR-005](../adr/005-reviews-append-only.md)
- [reviews/001-bootstrap-design-review.md](../reviews/001-bootstrap-design-review.md)
