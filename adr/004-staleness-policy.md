---
id: ADR-004
title: 鮮度は last_reviewed の 90 日と変更時同期で守る
status: active
last_reviewed: 2026-08-08
owners:
  - TeramachiShunsuke
tags:
  - staleness
  - ci
related:
  - EVID-003
  - EVID-008
---

## 文脈

更新日時だけでは「まだ正しい」が分からない。放置された文書はエージェントの回帰になる。

## 決定

1. 本文または意味のあるメタデータを変更する PR では、同じコミットで `last_reviewed` を今日（UTC）へ更新する
2. どの対象文書も `last_reviewed` から **90 日**を超えたら CI 失敗
3. ワークフローは `pull_request` / `push`（main）に加え `workflow_dispatch` を持つ

対象: `evidence/` `adr/` `playbook/` `ledger/` `reviews/` の Markdown。

## 根拠

- [EVID-003](../evidence/003-doc-drift-is-regression.md)
- [EVID-008](../evidence/008-pr-as-quality-gate.md)

## 結果・トレードオフ

- 利点: 定期レビューが強制される
- 代償: 安定文書も四半期近くで触る必要がある（レビュー追記で日付更新可）

## 関連

- [PB-003](../playbook/003-run-review-cycle.md)
- [PB-005](../playbook/005-fix-staleness-ci.md)
