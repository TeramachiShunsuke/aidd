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

PdO の設計（ビジネススペック）を TDD の入力になる受け入れ例まで落とす工程には、現状の手順に担い手がいない。エージェントをここに入れるなら、(1) 欠落した値を推測で埋めず**質問**に変えること、(2) 各例の値が設計に明記されたのか・PdO が答えたのか・エージェントの提案なのかという**出所**を行ごとに残すこと、(3) レビュー→修正の往復を**有限回**で止めて残りを未決として外に出すこと、の 3 つがないと、例の形をした推測が実装に流れる。

## 観測

- 本リポジトリの現行手順は、抽象条件を例に変える作業を「PdO に確認する」の一文で扱っている（[PB-00013](../playbook/00013-start-tdd-from-examples.md) 手順 2）。誰がいつどの形で確認し、どこまで詰めれば終わりかは書かれていない。[ADR-00014](../adr/00014-implementation-spec-split.md) は「PdO の負荷が上がる」を代償として認めているが、負荷を受け止める手順は置いていない。[templates/acceptance-examples.md](../templates/acceptance-examples.md) には「決められていないこと」欄があり「実装前にここを空にする」とあるが、空にする工程が手順として存在しない。
- エージェントは根拠が薄くても断定的に出力する（[EVID-00001](00001-agents-need-evidence.md)）。仕様の空白は質問ではなく補完として消費される（[EVID-00011](00011-spec-first-reduces-rework.md)）。受け入れ例は「会員歴 6 か月・購入 3 回なら 10%」のように具体値の表であるため、エージェントが補完した値は PdO が決めた値と**同じ形**で表に並び、見分けがつかない。出所を行に持たせない限り、承認者は「どの値を自分が決めたか」を表から読めない。
- 「どう動くのが正しいか」の正本はテストに置き、文書に二重に持たない（[EVID-00018](00018-tests-outlive-design-docs.md)）。この前提が成り立つのは受け入れ条件が具体例まで落ちている場合に限る、と同 evidence は限定している。つまり「設計 → 例」の工程が弱いと、[ADR-00014](../adr/00014-implementation-spec-split.md) の分解そのものが崩れ、開発側が解釈を「実装スペック」として書き足す状態に戻る。
- 外部の方法論も同じ構造を持つ。Example Mapping（[Matt Wynne, 2015](https://cucumber.io/blog/bdd/example-mapping-introduction/)）は、ルール・例・**質問**を別のカードとして扱い、答えられない質問を赤いカードとして残したままセッションを時間で区切る。Specification by Example（[Martin Fowler](https://martinfowler.com/bliki/SpecificationByExample.html)）は、例を共同で書き、例を精緻化する工程を明示の作業として置く。いずれも「例の欠落は質問として外に出す」「終わりを時間や回数で区切る」点が共通しており、値を書き手の裁量で埋めることを避けている。
- 本リポジトリの敵対レビュー（[REV-00005](../reviews/00005-adversarial-review.md) / [REV-00007](../reviews/00007-platform-acl-adversarial-review.md) / [REV-00008](../reviews/00008-client-surface-adversarial-review.md) / [REV-00009](../reviews/00009-repo-consistency-adversarial-review.md)）は、いずれも「指摘を等級付きの表にし、各行に再検証の結果と取り込み（対応）を並べる」形式で記録され、1〜2 巡で収束している。指摘と対応が同じ表に並ぶため、後から「何が指摘され何を直したか」を読める。往復を記録なしで続けた例は本リポジトリにない。
- status の遷移は人間が行い、機械は事実の記録と検出に限る（[ADR-00017](../adr/00017-machines-record-facts-humans-decide-status.md)）。受け入れ例の「承認」も同じ性質の判断であり、エージェントが自分の提案を承認済みにできる構造は、[REV-00009](../reviews/00009-repo-consistency-adversarial-review.md) C1（草案の錨を確定扱いにした統治欠陥）と同型になる。

## 限界

設計から例への変換にエージェントを入れた場合の手戻り削減や所要時間は、本リポジトリで測定していない。外部資料は方法論の主張であり、対照実験ではない。往復回数の適正値（3 巡が多いか少ないか）も未測定で、運用で調整する必要がある（[OQ-00022](../ledger/open-questions.md)）。PdO が例を書く文化のない組織で、質問の形にしても回答が得られるかは観測していない。

## 関連

- [ADR-00024](../adr/00024-refine-acceptance-with-bounded-review-rounds.md)
- [PB-00020](../playbook/00020-refine-acceptance-from-design.md)
- [PB-00013](../playbook/00013-start-tdd-from-examples.md)
- [ADR-00014](../adr/00014-implementation-spec-split.md)
- [templates/acceptance-examples.md](../templates/acceptance-examples.md)
- [templates/acceptance-refinement-log.md](../templates/acceptance-refinement-log.md)
