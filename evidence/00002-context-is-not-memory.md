---
id: EVID-00002
title: コンテキスト窓は作業記憶であり長期記憶ではない
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - agents
  - memory
related:
  - ADR-00001
  - EVID-00001
---

## 主張

セッション内コンテキストは揮発する。チームの長期記憶はリポジトリ上の構造化 Markdown に置く。

## 観測

- 長会話の後半で初期制約が脱落し、禁止事項が再違反される。
- 別セッション・別エージェントでは前会話の決定が共有されない。
- `AGENTS.md` のような短く安定した入口と、詳細文書へのリンク分離が再読込コストを下げる。

## 限界

各製品の自動メモリ機能の精度は製品依存。本リポジトリは製品メモリに依存しない設計とする。

## 関連

- [AGENTS.md](../AGENTS.md)
- [ADR-00001](../adr/00001-repository-layout.md)
