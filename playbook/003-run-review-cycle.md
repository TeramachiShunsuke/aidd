---
id: PB-003
title: レビューサイクルを回す
status: active
last_reviewed: 2026-08-08
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - reviews
related:
  - ADR-004
  - ADR-005
---

## いつ使うか

90 日接近・定期監査・大きな方針変更のあとで、文書群の鮮度を確認するとき。

## 手順

1. 対象一覧を出す（`last_reviewed` が古い順）
2. 各文書について「まだ正しいか」を確認し、必要なら本文を更新
3. 更新した文書の `last_reviewed` を今日にする
4. `reviews/` に新規ファイル、または既存レビュー末尾へ結果を追記する（改変禁止）
5. 問題があれば open-questions / 後継 ADR を起こす
6. PR を出し CI を通す。必要なら Actions の手動トリガーでも再検査

## 検証

- reviews が追記のみになっている
- 触った文書の日付が同期されている
- 90 日超が残っていない

## 失敗時

時間が足りない場合は、期限超過文書を優先し、残りは open-questions に「レビュー残」と期限を書く。

## 関連

- [templates/review.md](../templates/review.md)
- [PB-005](005-fix-staleness-ci.md)
