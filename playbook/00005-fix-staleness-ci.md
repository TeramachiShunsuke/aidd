---
id: PB-00005
title: staleness CI の失敗を直す
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - ci
related:
  - ADR-00004
  - ADR-00012
  - EVID-00008
---

## いつ使うか

GitHub Actions の Staleness ワークフローが失敗したとき。週次 `schedule` 実行では、誰の PR とも無関係に main が失敗しうる（期限超過の通知そのもの）。

## 手順

1. ログの検査名を読む（frozen / last_reviewed / append-only logs / expiry / attestation）
2. 原因別に対応する
   - **frozen**: 差分を戻す。どうしても変えるなら後継文書戦略へ切替
   - **last_reviewed 同期**: 本文変更に合わせて日付を今日（UTC）へ
   - **append-only logs**: 途中改変を捨て、末尾追記または新規ファイルにする。`reviews/` と `ledger/attestations.md` が対象
   - **expiry（90 日）**: 内容をレビューする。本文を直したら日付更新、直す必要がなければ `ledger/attestations.md` に証跡を追記
   - **attestation**: ID の綴りを直す（実在しない ID は失敗）。未来日は使えない
   - **future date**: 前借りした日付を今日以前に戻す
3. ローカルで `bash .github/scripts/check-staleness.sh` を再実行
4. 必要なら Actions の `workflow_dispatch` で main を再検査

## 検証

- 同じ PR で CI が緑
- 日付だけ進めて内容未確認、になっていない
- 証跡を足した場合、その行に確認内容が書かれている

## 失敗時

ルール自体が足かせなら、ADR 改訂案を draft で起こし、その場しのぎで検査を無効化しない。

## 関連

- [.github/workflows/staleness.yml](../.github/workflows/staleness.yml)
- [.github/scripts/check-staleness.sh](../.github/scripts/check-staleness.sh)
- [ADR-00012](../adr/00012-review-attestations.md)
- [PB-00003](00003-run-review-cycle.md)
