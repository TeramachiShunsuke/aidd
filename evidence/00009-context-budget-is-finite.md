---
id: EVID-00009
title: 文脈は有限予算であり、常時ロードは劣化を招く
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - context
  - tier
related:
  - EVID-00002
  - ADR-00006
tier: 3
---

## 主張

エージェントに渡せる文脈は有限で、しかも「入れたら入れただけ良くなる」わけではない。知識ベースは全件を常時ロードする前提ではなく、**何を常に読み、何を必要時に読むか**を階層として設計する必要がある。

## 観測

- 本リポジトリの全 Markdown を素朴に連結すると、規範（AGENTS / CONVENTIONS）より根拠（evidence）と監査記録（reviews）の分量が先に膨らむ。文書が増えるほど、常時ロード方式では規範の相対的な重みが下がる。
- Agent Skills の実装は、起動時に `name` と `description` だけを読み、本文は一致したときに初めて読む三段階のロードを採用している（[Cursor: Agent Skills](https://cursor.com/docs/skills) の "Progressive — Skills load resources on demand, keeping context usage efficient"）。既存ツールが同じ問題を段階的開示で解いている。
- [EVID-00002](00002-context-is-not-memory.md) のとおり、文脈は記憶ではない。毎セッション読み直すコストがかかる以上、「読む順序」と「読まない判断」自体が設計対象になる。
- 逆向きの失敗も観測される。索引を持たないと、エージェントは必要な決定文書に到達できず、根拠なしで補完する（[EVID-00001](00001-agents-need-evidence.md)）。削るだけでは解決しない。

## 限界

「何トークンまでなら劣化しないか」はモデル世代・実装・タスクに依存し、本リポジトリでは測定していない。ここで言えるのは順序と階層の必要性までで、具体的な予算配分（Tier ごとの割合）は運用しながら見直す仮説である。

## 関連

- [ADR-00006](../adr/00006-context-tiers.md)
- [EVID-00002](00002-context-is-not-memory.md)
- [PB-00006](../playbook/00006-assign-tier.md)
