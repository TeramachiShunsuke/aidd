---
id: EVID-00032
title: 設計から受け入れ例への落とし込みは、欠落を質問に変え、値の出所を記録し、有限回で止めないと成立しない
status: draft
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - sdd
  - tdd
  - spec
  - acceptance
related:
  - EVID-00011
  - EVID-00018
  - EVID-00001
  - ADR-00014
  - ADR-00017
  - REV-00009
---

## 主張

PdO の設計（ビジネススペック）を TDD の入力になる受け入れ例まで落とす工程には、現状の手順に担い手と終了条件がない。エージェントをここに入れるなら、(1) 欠落した値を推測で埋めず**質問**に変えること、(2) 各例の値が要件に明記されたのか・PdO が答えたのか・エージェントの提案なのかという**出所**を行ごとに残すこと、(3) レビュー→修正の往復を**有限回**で止めて残りを未決として外に出すこと、の 3 つが要る。これは次の観測からの推論である: 受け入れ例は具体値の表なので、エージェントが補完した値は PdO が決めた値と同じ形で並び、出所がなければ承認者は見分けられない。

## 観測

- 本リポジトリの現行手順は、抽象条件を例に変える作業を「次の 3 つ（代表例・境界・反例）を PdO に確認して例に変換する」の一文で扱っている（[PB-00013](../playbook/00013-start-tdd-from-examples.md) 手順 2）。変換先の形は 3 つ定義されているが、誰がいつどの場所で確認し、どこまで詰めれば終わりかは書かれていない。[ADR-00014](../adr/00014-implementation-spec-split.md) は「PdO の負荷が上がる」を代償として認めているが、負荷を受け止める手順は置いていない。[templates/acceptance-examples.md](../templates/acceptance-examples.md) には「決められていないこと」欄があり「実装前にここを空にする」とあるが、空にする工程は手順として存在しなかった（本 evidence 執筆時点、commit `beb72a2`）。
- エージェントは根拠が薄くても断定的に出力する（[EVID-00001](00001-agents-need-evidence.md)）。仕様の空白は質問ではなく補完として消費される（[EVID-00011](00011-spec-first-reduces-rework.md)）。
- 振る舞いの正本をテストに置けるのは、受け入れ条件が具体例まで落ちている場合に限る、と [EVID-00018](00018-tests-outlive-design-docs.md) は限定している。
- 外部の方法論。Example Mapping（[Matt Wynne, 2015](https://cucumber.io/blog/bdd/example-mapping-introduction/)）は、ルール・例・**質問**を別のカードとして扱い、答えられない質問を赤いカードとして残したまま、セッションを時間（25 分）で区切る。Specification by Example は、例を仕様として扱い自動実行することで生きた文書にする手法として整理されている（[Martin Fowler の bliki](https://martinfowler.com/bliki/SpecificationByExample.html)。同名の Gojko Adzic の書籍（Manning, 2011）は、例を共同で書き精緻化する工程をプロセスパターンとして挙げる）。Example Mapping が「欠落は質問として外に出す」「終わりを時間で区切る」点を明示している。
- 本リポジトリの敵対レビュー（[REV-00005](../reviews/00005-adversarial-review.md) / [REV-00007](../reviews/00007-platform-acl-adversarial-review.md) / [REV-00008](../reviews/00008-client-surface-adversarial-review.md) / [REV-00009](../reviews/00009-repo-consistency-adversarial-review.md)）は、いずれも「指摘を等級付きの表にし、各行に再検証の結果と取り込み（対応）を並べる」形式で記録され、1〜2 巡で収束している。指摘と対応が同じ表に並ぶため、後から「何が指摘され何を直したか」を読める。
- status の遷移は人間が行い、機械は事実の記録と検出に限る（[ADR-00017](../adr/00017-machines-record-facts-humans-decide-status.md)）。[REV-00009](../reviews/00009-repo-consistency-adversarial-review.md) C1 は、草案の錨を確定扱いにした統治欠陥を P0 と判定した。受け入れ例の「承認」も同じ性質の判断である。

## 限界

設計から例への変換にエージェントを入れた場合の手戻り削減や所要時間は、本リポジトリで測定していない。外部資料は方法論の主張であり、対照実験ではない。往復回数の適正値（3 巡が多いか少ないか）も未測定で、運用で調整する必要がある（[OQ-00040](../ledger/open-questions.md)）。PdO が例を書く文化のない組織で、質問の形にしても回答が得られるかは観測していない。「補完した値と決めた値が見分けられない」は表の形からの推論であり、実際に誤承認が起きた事例を観測したわけではない。

## 関連

- [ADR-00024](../adr/00024-refine-acceptance-with-bounded-review-rounds.md)
- [PB-00020](../playbook/00020-refine-acceptance-from-design.md)
- [PB-00013](../playbook/00013-start-tdd-from-examples.md)
- [ADR-00014](../adr/00014-implementation-spec-split.md)
- [templates/acceptance-examples.md](../templates/acceptance-examples.md)
- [templates/acceptance-refinement-log.md](../templates/acceptance-refinement-log.md)
