---
id: REV-00010
title: PdO 設計 → 受け入れ条件ワークフロー（ADR-00024 / PB-00020）の批判レビュー 3 巡
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - reviews
  - adversarial
  - sdd
  - tdd
  - acceptance
related:
  - ADR-00024
  - PB-00020
  - EVID-00032
  - ADR-00014
  - ADR-00008
  - PB-00013
  - REV-00009
---

# PdO 設計 → 受け入れ条件ワークフロー（ADR-00024 / PB-00020）の批判レビュー 3 巡

- 期間: 2026-08-19 — 2026-08-19
- 範囲: 新規の EVID-00032 / ADR-00024 / PB-00020 / `templates/acceptance-examples.md` / `templates/acceptance-refinement-log.md` / skill `aidd-refine-acceptance`、およびそれらが触る AGENTS / README / GUIDE / PB-00013 / ADR-00014 / ledger
- 実施者: 同一セッションのエージェント。各巡は、文脈を共有しない別エージェントに「反証せよ」と依頼して指摘を集め、本セッションが再検証（確認 / 却下）して対応した
- 目的: 運用者の依頼「SDD で稼働中の spec リポジトリに組み込み、PdO の設計を TDD の受け入れ条件までブラッシュアップできる AI ワークフローを確立する。批判レビュー → 修正を 3 巡回し、指摘と対応が分かるように残す」

## 読み方

各巡は「指摘」表と「対応」表からなる。等級は ADR-00024 §4 と同じ（P0 = このままでは解釈が入る・矛盾、P1 = 運用に落ちない、P2 = 体裁）。「再検証」は本セッションの判断で、**却下**した指摘も理由つきで残す。

## 第 0 巡 — 2026-08-19（v1 を書く前に見つけた前提の欠陥）

| # | 等級 | 指摘 | 再検証 | 対応 |
| --- | --- | --- | --- | --- |
| 0-1 | P0 | 開発ループ `spec → 受け入れ例 → テスト` のうち「PdO 設計 → 受け入れ例」だけ手順がない。PB-00013 手順 2 の「PdO に確認」に担い手・終了条件がない | 確認 | EVID-00032 / ADR-00024 / PB-00020 を新設 |
| 0-2 | P1 | `ledger/claims.md` と `ledger/open-questions.md` に、5 桁移行（ADR-00022）のマージで `merge=union` が残した 3 桁 ID の重複行がある。CLAIM-031..033 / OQ-038 / Resolved OQ-035..037, 039 は 3 桁のみで、`build-graph.py` の `\d{5}` 検査の対象外。旧 `ADR-022`（PF 第一歩）は現 ID では ADR-00023 | 確認 | 重複を削除、3 桁のみの行を 5 桁に直し `ADR-00023` に合わせた。reviews / changelog の履歴は書き換えない（changelog に整理を 1 行追記） |
