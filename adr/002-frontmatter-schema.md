---
id: ADR-002
title: YAML Frontmatter で status と last_reviewed を機械可読にする
status: frozen
last_reviewed: 2026-08-08
owners:
  - TeramachiShunsuke
tags:
  - frontmatter
  - schema
related:
  - EVID-006
  - ADR-004
---

## 文脈

本文中の「Status: Accepted」表記はパースが不安定で CI が壊れやすい。

## 決定

全本文書（evidence / adr / playbook / reviews / ledger）に YAML Frontmatter を必須化し、少なくとも次を置く。

- `id`, `title`, `status`, `last_reviewed`, `owners`

`status` の列挙は `draft | active | frozen | deprecated`。

日付は UTC の `YYYY-MM-DD`。

## 根拠

- [EVID-006](../evidence/006-templates-reduce-variance.md)
- [EVID-003](../evidence/003-doc-drift-is-regression.md)

## 結果・トレードオフ

- 利点: staleness CI が単純な行マッチ / 軽いパーサで実装できる
- 代償: Frontmatter を壊す編集が即 CI 赤になる（望ましい失敗）

## 関連

- [CONVENTIONS.md](../CONVENTIONS.md)
- [templates/](../templates/)
