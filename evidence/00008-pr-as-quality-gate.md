---
id: EVID-00008
title: PR は知識の品質ゲートである
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - pr
  - ci
related:
  - ADR-00004
  - PB-00005
---

## 主張

知識ベースへの直接 push を避け、PR + 鮮度 CI + テンプレチェックで「読める変更」だけを main に入れる。

## 観測

- チェックリストなしの PR は関連 ID の記載漏れが多い。
- 機械検査（frozen / last_reviewed / reviews / 90 日）は議論前に形式違反を落とせる。
- 手動 `workflow_dispatch` があると、ドキュメント専任の定期監査がしやすい。

## 限界

レビュー品質（内容の正しさ）は CI では保証しない。人間または明示的な review playbook が必要。

## 関連

- [.github/PULL_REQUEST_TEMPLATE.md](../.github/PULL_REQUEST_TEMPLATE.md)
- [.github/workflows/staleness.yml](../.github/workflows/staleness.yml)
