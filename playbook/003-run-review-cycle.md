---
id: PB-003
title: レビューサイクルを回す
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - reviews
related:
  - ADR-004
  - ADR-005
  - ADR-012
---

## いつ使うか

90 日接近・定期監査・大きな方針変更のあとで、文書群の鮮度を確認するとき。

## 手順

1. 対象一覧を出す（実効レビュー日が古い順）

   ```bash
   bash .github/scripts/check-staleness.sh | grep '^OK age' | sort -t' ' -k3 -rn | head -20
   ```

2. 各文書について「まだ正しいか」を確認する
3. 結果を書く場所を、文書の状態で選ぶ
   - **本文を直した**: その文書の `last_reviewed` を今日（UTC）にする
   - **読んだが直す必要がなかった**: `ledger/attestations.md` に 1 行追記する。何を確認したかを具体的に書く
   - **frozen で直せない**: 同じく証跡を追記する。本文は 1 バイトも触らない。改訂が要るなら後継文書（[PB-004](004-freeze-document.md)）
4. `reviews/` に新規ファイル、または既存レビュー末尾へ結果を追記する（改変禁止。日付は触らない）
5. 問題があれば open-questions / 後継 ADR を起こす
6. PR を出し CI を通す。必要なら Actions の手動トリガーでも再検査

## 検証

- reviews と `ledger/attestations.md` が追記のみになっている
- 本文を直した文書の日付が同期されている
- 90 日超が残っていない（実効レビュー日で判定される）
- 証跡の各行に「何を確認したか」が書いてある。書けないなら、それはレビューしていない

## 失敗時

時間が足りない場合は、期限超過文書を優先し、残りは open-questions に「レビュー残」と期限を書く。読まずに証跡を足して期限だけ延ばすのは、規約違反であり検知もされない。ここは人間のレビューが最後の砦になる。

## 関連

- [templates/review.md](../templates/review.md)
- [PB-005](005-fix-staleness-ci.md)
- [ADR-012](../adr/012-review-attestations.md)
- [ledger/attestations.md](../ledger/attestations.md)
