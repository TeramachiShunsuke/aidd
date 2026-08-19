---
id: ADR-00003
title: frozen 文書はバイトレベルで不変とする
status: frozen
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - frozen
  - ci
related:
  - EVID-00004
  - PB-00004
---

## 文脈

「内容の意味が同じなら編集可」はレビューコストが高く、エージェントには判定不能に近い。

## 決定

base 参照（PR では `origin/main`）と比較して、`status: frozen` のファイルに 1 バイトでも差分があれば CI を失敗させる。

改訂手順:

1. 後継文書を新規 ID で作成（`supersedes` を記入）
2. 旧文書を `deprecated` にし `superseded_by` を記入（この瞬間に frozen を外す変更は、deprecated への遷移として別 PR ポリシーで許可するか、最初から後継のみ追加して旧は別コミットで人間が遷移する）
3. 運用上の既定: **frozen のままでは何も変えない**。状態遷移が必要なら owners が明示承認した PR で `deprecated` へ変更し、その PR では frozen 検査を owners 承認で上書きしない（遷移専用手順は playbook 参照）

初期実装の CI は単純化のため、frozen ファイルのあらゆる差分を拒否する。状態遷移は owners レビュー後に一時的に status を変更する専用 PR とする。

## 根拠

- [EVID-00004](../evidence/00004-frozen-means-immutable.md)

## 結果・トレードオフ

- 利点: 実装が単純で抜け道が少ない
- 代償: 誤字修正も後継または特例が必要

## 関連

- [PB-00004](../playbook/00004-freeze-document.md)
- [.github/scripts/check-staleness.sh](../.github/scripts/check-staleness.sh)
