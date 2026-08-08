---
id: PB-005
title: staleness CI の失敗を直す
status: active
last_reviewed: 2026-08-08
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - ci
related:
  - ADR-004
  - EVID-008
---

## いつ使うか

GitHub Actions の Staleness ワークフローが失敗したとき。

## 手順

1. ログの検査名を読む（frozen / last_reviewed / reviews / age90）
2. 原因別に対応する
   - **frozen**: 差分を戻す。どうしても変えるなら後継文書戦略へ切替
   - **last_reviewed 同期**: 本文変更に合わせて日付を今日（UTC）へ
   - **reviews 追記**: 途中改変を捨て、末尾追記または新規ファイルにする
   - **90 日**: 内容をレビューし日付更新。結果を reviews に追記
3. ローカルで `bash .github/scripts/check-staleness.sh` を再実行
4. 必要なら Actions の `workflow_dispatch` で main を再検査

## 検証

- 同じ PR で CI が緑
- 日付だけ進めて内容未確認、になっていない

## 失敗時

ルール自体が足かせなら、ADR 改訂案を draft で起こし、その場しのぎで検査を無効化しない。

## 関連

- [.github/workflows/staleness.yml](../.github/workflows/staleness.yml)
- [.github/scripts/check-staleness.sh](../.github/scripts/check-staleness.sh)
