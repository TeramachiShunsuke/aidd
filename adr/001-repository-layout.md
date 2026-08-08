---
id: ADR-001
title: リポジトリを evidence / adr / playbook / ledger / reviews に分割する
status: frozen
last_reviewed: 2026-08-08
owners:
  - TeramachiShunsuke
tags:
  - architecture
  - layout
related:
  - EVID-002
  - EVID-007
---

## 文脈

AIDD の知識を単一の docs フォルダに雑多に置くと、エージェントが「何を先に読むべきか」を誤る。種類ごとの目錄が必要。

## 決定

次のトップレベル構成を採用する。

- `evidence/` — 観測と根拠
- `adr/` — 決定
- `playbook/` — 手順
- `ledger/` — 横断台帳（claims / open-questions / changelog）
- `templates/` — 雛形
- `reviews/` — 追記専用レビュー
- ルートに `README.md` / `AGENTS.md` / `CONVENTIONS.md`

## 根拠

- [EVID-002](../evidence/002-context-is-not-memory.md): 入口を薄くし詳細を分ける
- [EVID-007](../evidence/007-ledger-is-index.md): 台帳と本文を分離

## 結果・トレードオフ

- 利点: 検索・権限・CI 対象を種類別に制御できる
- 代償: 新規参加者は目錄地図を一度学ぶ必要がある（README で吸収）

## 関連

- [README.md](../README.md)
- [ADR-002](002-frontmatter-schema.md)
