---
id: ADR-00005
title: reviews ディレクトリは追記専用とする
status: frozen
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - reviews
  - audit
related:
  - EVID-00005
  - PB-00003
---

## 文脈

レビュー結果を後日きれいに書き換えると、当時の判断根拠が消える。

## 決定

`reviews/**/*.md` について:

- 新規ファイル追加は可
- 既存ファイルは「旧内容が新内容の prefix」である場合のみ可（末尾追記）
- 削除・リネーム・途中改変は不可

CI で base ブランチのファイル内容と比較して強制する。

## 根拠

- [EVID-00005](../evidence/00005-append-only-reviews.md)

## 結果・トレードオフ

- 利点: 監査証跡がファイルを読むだけで追える
- 代償: 誤記は取り消し線や訂正追記で対応する

## 関連

- [reviews/00001-bootstrap-design-review.md](../reviews/00001-bootstrap-design-review.md)
- [.github/scripts/check-staleness.sh](../.github/scripts/check-staleness.sh)
