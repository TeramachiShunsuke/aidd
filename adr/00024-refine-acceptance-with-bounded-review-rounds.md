---
id: ADR-00024
title: PdO の設計から受け入れ条件へのブラッシュアップは、案件リポで、エージェントが問い PdO が決める有限回のレビュー往復として回す
status: draft
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - sdd
  - tdd
  - spec
  - acceptance
  - workflow
related:
  - EVID-00032
  - EVID-00011
  - EVID-00018
  - ADR-00008
  - ADR-00014
  - ADR-00017
  - ADR-00019
---

## 文脈

開発ループは `spec(SDD) → 受け入れ例 → テスト(TDD)` と置いているが（[README](../README.md)、[GUIDE](../GUIDE.md) §4）、手順があるのは「受け入れ例 → テスト」（[PB-00013](../playbook/00013-start-tdd-from-examples.md)）だけで、「PdO の設計 → 受け入れ例」の区間には担い手も終了条件もない（[EVID-00032](../evidence/00032-acceptance-examples-need-questions-provenance-bounded-rounds.md)）。[ADR-00014](00014-implementation-spec-split.md) は「ビジネススペックは受け入れ例まで落とす」と決め、PdO の負荷が上がることを代償として認めたが、負荷を受け止める工程は未定義である。

この区間にエージェントを入れ、SDD で運用中の spec リポジトリ（requirements / design / tasks を持つ）に組み込みたい。エージェントは値を推測で埋める（[EVID-00011](../evidence/00011-spec-first-reduces-rework.md)）ため、そのまま「例を書かせる」と、PdO が決めていない業務値が例の形で実装に流れる。

## 決定

### 1. 置き場所 — 成果物は案件リポ、手順は kernel

| もの | 置き場所 | 理由 |
| --- | --- | --- |
| 受け入れ例シート、ブラッシュアップ記録 | 案件（spec）リポ。機能ごとのディレクトリに requirements / design と並べる | 案件固有の値であり kernel に入れない（[ADR-00008](00008-sdd-bridge.md)、[ADR-00019](00019-kernel-and-project-layers.md)） |
| 手順・雛形・skill | kernel（本リポ） | 他案件でも同じ工程を繰り返す |
| 案件横断で効く発見 | kernel へ昇格（[PB-00008](../playbook/00008-bridge-sdd-spec.md) 方向 B） | 昇格条件は変えない |

[ADR-00008](00008-sdd-bridge.md) の対応表において、受け入れ例は **requirements の精緻化**であり、design（どう作るか）には入れない。

### 2. 役割 — エージェントは問い、PdO が決める

| 役割 | すること | しないこと |
| --- | --- | --- |
| エージェント | 設計に明記された値を例に落とす。欠落を**質問**に変える。固定観点でレビューし指摘を等級付きで出す。回答を反映する | 業務値を発明する。未確認の例を承認済みにする。設計や実装を書く |
| PdO | 質問に答える（値・境界・反例を決める）。承認する | 例の体裁を整える作業を抱える |
| 開発 | 最終巡でテスト可能性を確認する | 例の値を決める |

承認は人の操作であり、エージェントは行わない（[ADR-00017](00017-machines-record-facts-humans-decide-status.md) と同じ分界）。

### 3. 出所 — 各例の行に値の由来を持つ

受け入れ例の各行に `出所` を持たせ、次のいずれかを書く。

| 出所 | 意味 | 実装に渡せるか |
| --- | --- | --- |
| `設計 §…` | PdO の設計本文に明記されている | 渡せる |
| `PdO YYYY-MM-DD` | 質問への回答として PdO が決めた | 渡せる |
| `提案` | エージェントの候補。PdO 未確認 | **渡せない**。承認前に `PdO …` に変わるか、削除されるか、未決へ移る |

### 4. 有限回 — レビュー→修正は既定 3 巡で止める

各巡は「固定観点でのレビュー（指摘表）→ PdO の回答 → 反映 → 記録」の 1 往復とする。

固定観点:

| 観点 | 問い |
| --- | --- |
| L1 具体性 | 入力と期待結果が具体値か。「適切に」「など」「正しく」が残っていないか |
| L2 境界 | 閾値ごとに「ちょうど」「1 つ手前」が対象内 / 外で書かれているか |
| L3 反例 | ルールごとに不成立の入力と、そのときの挙動（エラー / 無視 / 既定値）があるか |
| L4 無矛盾 | 例同士、設計本文、依拠した KB の決定と矛盾しないか |
| L5 テスト可能性 | 1 行が 1 つの観測可能な結果か。内部構造に触れていないか。前提状態が明記されているか |
| L6 分離 | 性能・可用性・データ量は制約表へ、見た目は Figma 等へのリンクへ分けられているか（[PB-00016](../playbook/00016-large-project-usage-map.md)） |

等級: **P0** = このままでは実装時に解釈が入る（欠落・矛盾）、**P1** = テストに落ちない（曖昧値・複合結果）、**P2** = 体裁。

停止条件: P0 と P1 が 0 件になった巡で終える。3 巡で残った P0 / P1 は「決められていないこと」に移し、その項目に触れる実装を始めない。巡回数の既定 3 は測定して見直す（[OQ-00040](../ledger/open-questions.md)）。

### 5. 可視化 — 指摘と対応を同じ表に残す

各巡の指摘（等級・観点・内容・対象行）と対応（何をしたか・誰が決めたか・反映 / 未決へ / 却下）を、ブラッシュアップ記録（[templates/acceptance-refinement-log.md](../templates/acceptance-refinement-log.md)）に**追記**する。記録は受け入れ例と同じディレクトリに置き、後から「何が指摘され、何を直し、何を決められなかったか」が巡ごとに読めるようにする。

### 6. 引き渡し

PdO が承認し、「決められていないこと」が空（または実装対象外として明示）になったら [PB-00013](../playbook/00013-start-tdd-from-examples.md) へ渡す。実装スペックの要否は [PB-00012](../playbook/00012-triage-implementation-spec.md)。

## 根拠

- [EVID-00032](../evidence/00032-acceptance-examples-need-questions-provenance-bounded-rounds.md): 欠落は質問に、値は出所付きに、往復は有限回に。外部の方法論（Example Mapping / Specification by Example）と本リポジトリのレビュー記録が同じ構造を持つ
- [EVID-00011](../evidence/00011-spec-first-reduces-rework.md): 仕様の空白はエージェントの推測で埋まる
- [EVID-00018](../evidence/00018-tests-outlive-design-docs.md): テストを正本にできるのは例まで落ちた受け入れ条件だけ

## 結果・トレードオフ

- 利点: 「設計 → 例」の区間に担い手・観点・終了条件が付き、[ADR-00014](00014-implementation-spec-split.md) の分解が上流で成立する
- 利点: PdO の負荷が「例を全部書く」から「質問に答える・承認する」に変わる
- 利点: 出所列により、承認者はどの値を自分が決めたかを表から読める。提案のまま実装に流れない
- 利点: 記録が巡ごとに残るため、レビューの指摘と対応が後から監査できる
- 代償: PdO の回答待ちが工程のボトルネックになる。回答がなければ止まる（止まるのが正しい）
- 代償: 巡回数 3 と観点 6 つは経験則であり、未測定。多すぎれば形式化、少なすぎれば解釈が残る
- 代償: 案件リポに雛形を 2 つ置く運用が増える。kernel の skill を案件リポのエージェントへどう届けるかは [OQ-00041](../ledger/open-questions.md)

## 関連

- [PB-00020](../playbook/00020-refine-acceptance-from-design.md)
- [PB-00013](../playbook/00013-start-tdd-from-examples.md)
- [PB-00012](../playbook/00012-triage-implementation-spec.md)
- [PB-00008](../playbook/00008-bridge-sdd-spec.md)
- [PB-00017](../playbook/00017-apply-kernel-to-project.md)
- [ADR-00014](00014-implementation-spec-split.md)
- [templates/acceptance-examples.md](../templates/acceptance-examples.md)
- [templates/acceptance-refinement-log.md](../templates/acceptance-refinement-log.md)
