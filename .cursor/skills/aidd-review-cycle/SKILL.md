---
name: aidd-review-cycle
description: AIDD 知識ベースの定期レビューを実施し、reviews/ に追記して last_reviewed を更新する。ユーザーが「レビューを回す」「鮮度を確認する」「staleness CI が赤い」「90 日超えを直す」と言ったときに使う。
metadata:
  aidd-playbook: PB-003
  aidd-tier: "1"
---

# レビューサイクルを回す

## いつ使うか

- 定期レビューの実施時
- `last_reviewed` の 90 日期限で CI が失敗しているとき

## 先に読むもの

1. [AGENTS.md](../../../AGENTS.md)
2. [CONVENTIONS.md](../../../CONVENTIONS.md)
3. [PB-003](../../../playbook/003-run-review-cycle.md) — 手順の正本
4. CI 失敗の切り分けは [PB-005](../../../playbook/005-fix-staleness-ci.md)

## 手順の要点

1. `bash .github/scripts/check-staleness.sh` で期限切れの文書を洗い出す
2. **本文を実際に読み直してから** `last_reviewed` を今日（UTC）にする
3. レビュー結果を `reviews/` に記録する（新規ファイル追加、または既存ファイル**末尾のみ**追記）
4. 見つかった未決は [ledger/open-questions.md](../../../ledger/open-questions.md) へ
5. `INDEX.md` を再生成する

## 禁止事項

- 本文を読まずに `last_reviewed` だけ進める（CI 迂回目的の更新）
- `reviews/` の既存行の書き換え・削除・リネーム
- 手順の詳細をこのファイルに書き写す（正本は PB-003）
