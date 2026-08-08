---
id: EVID-007
title: 台帳は横断索引であり本文の置き換えではない
status: active
last_reviewed: 2026-08-08
owners:
  - TeramachiShunsuke
tags:
  - ledger
  - claims
related:
  - ADR-001
  - PB-002
---

## 主張

claims / open-questions / changelog は、詳細文書を要約・索引するための薄い層である。ここに長文の決定を抱え込まない。

## 観測

- 単一の大きな wiki ページは衝突と陳腐化が同時に起きる。
- 「主張 → 錨（evidence/ADR）」の行形式は検証可能。
- 未決を open-questions に隔離すると、ADR の決定セクションが汚れない。

## 限界

錨先が deprecated になったときの自動検知は将来課題。当面はレビュー時に手で確認する。

## 関連

- [ledger/claims.md](../ledger/claims.md)
- [ledger/open-questions.md](../ledger/open-questions.md)
