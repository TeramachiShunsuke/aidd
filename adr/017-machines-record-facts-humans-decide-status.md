---
id: ADR-017
title: 機械は事実の記録と検出に限り、status の遷移は人間が行う
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - lifecycle
  - reviews
  - ci
  - governance
related:
  - EVID-022
  - EVID-016
  - ADR-012
  - ADR-013
tier: 2
---

## 文脈

「レビューを通ったら文書の状態を自動で更新する CI があると便利」という要望がある。[EVID-022](../evidence/022-review-state-is-tracked-mechanically.md) が調べた先行事例では、Doorstop は指紋でレビュー済みかどうかを機械的に判定し、18F/adr-automation はラベルを引き金に文書を生成して PR を開く。ただしどの例でも、**status を上げるという判断そのものを機械が下してはいない**。人間の操作（ラベル、Issue のクローズ、承認）が引き金にある。

本リポジトリには追加の制約がある。[ADR-012](012-review-attestations.md) の証跡は「読み直して現行の運用と一致することを確認した」という主張であり、CI が代わりに主張することはできない。CI が status を書き換えれば、`frozen` の不変性（[ADR-003](003-frozen-immutability.md)）とも正面から衝突する。

## 決定

機械にやらせる範囲を、次の 3 つに限る。

1. **事実の記録**: 起きたことをそのまま書く。日付、承認者、PR 番号、指紋のような、観測すれば決まる値
2. **不整合の検出**: 規則に反している箇所を報告する（[ADR-013](013-check-grades.md) の等級に従う）
3. **前提条件の検査**: 遷移が起きたときに、その遷移が満たすべき条件を検査する

やらせないことを 2 つ決める。

- **status の書き換え**: `draft` → `active` → `frozen` の遷移は、意味の判断であり人間が PR で行う。CI は遷移後の状態を検査するだけで、遷移そのものを起こさない
- **証跡の代筆**: CI が `ledger/attestations.md` に行を足さない。読んだのは人間であり、読んでいない主体が読んだと書くことは、日付だけ進める行為と同じである

この決定の下で、次の検査を追加する。

| # | 検査 | 場所 | 等級 | 理由 |
| --- | --- | --- | --- | --- |
| 1 | `draft` のまま実効レビュー日から 30 日（`MAX_DRAFT_DAYS`）を超えた文書 | `check-staleness.sh` | 警告 | 決めていないことの可視化。`draft` を消すか `active` に上げるかは判断 |

`draft` の滞留は現時点で 0 件だが、[ADR-013](013-check-grades.md) の基準 2（修正方法が一意）を満たさないため error には上げない。

この検査を `GRAPH.md` に出さないのは意図的である。生成物に日付依存の行が入ると、**何も変えていないのにカレンダーだけで生成物が陳腐化**し、`build-graph.py --check` が誰の PR とも無関係に落ちる。[ADR-010](010-knowledge-graph-layers.md) が構造グラフを決定的に保つと決めた理由と同じで、時間に依存する判定は鮮度検査の側に置く。

Doorstop 相当の**指紋によるレビュー判定**は採用しない。日付ベースの現行方式では「本文を変えずに日付だけ進める」を検出できないという弱点があり、指紋はそれを塞ぐ。ただし `frozen` 文書は指紋を本体に書けず、証跡側に持つ設計が要る。移行コストが未見積もりのため OQ-025 に残す。

## 根拠

- [EVID-022](../evidence/022-review-state-is-tracked-mechanically.md): 先行 4 例がいずれも判断を人間に残していること、Doorstop の指紋と suspect link の仕組み
- [EVID-016](../evidence/016-lifecycle-rules-deadlock.md): 機械的な規則の組み合わせが運用不能を作った実例。自動書き込みを足す前に、規則の整合を保つ側に投資する

## 結果・トレードオフ

- 利点: CI が main へ書き込む権限を持たずに済む。bot コミットがレビュー証跡を汚さない
- 利点: 「誰が読んだか」が人間の署名として残り続ける
- 代償: status の更新は手作業のまま。承認したのに `draft` のままという取りこぼしは起きうる。検査 1 はその取りこぼしを 90 日後に見つけるだけで、即座には防げない
- 代償: 外部の spec リポジトリで status 自動更新を採る場合、本リポジトリとは方針が分かれる。spec 側の判断は spec 側の ADR に置く（[ADR-014](014-implementation-spec-split.md)）

## 関連

- [ADR-012](012-review-attestations.md) / [ADR-013](013-check-grades.md)
- [PB-003](../playbook/003-run-review-cycle.md)
- OQ-025（指紋方式への移行）
