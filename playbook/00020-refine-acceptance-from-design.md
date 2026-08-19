---
id: PB-00020
title: PdO の設計を受け入れ条件までブラッシュアップする
status: draft
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - sdd
  - tdd
  - acceptance
related:
  - ADR-00024
  - ADR-00014
  - ADR-00008
  - ADR-00019
  - PB-00013
  - PB-00012
  - PB-00008
  - PB-00017
tier: 2
---

## いつ使うか

PdO が書いた設計（requirements / design、ビジネススペック）を受け取り、TDD（[PB-00013](00013-start-tdd-from-examples.md)）に渡せる受け入れ例まで詰めるとき。SDD で運用中の spec リポジトリに、この工程を AI ワークフローとして組み込むとき。開発側が「例が足りない」と差し戻した項目を、まとめて上流で解消したいとき。

成果物は spec リポジトリに置く。kernel には手順と雛形だけがある（[ADR-00024](../adr/00024-refine-acceptance-with-bounded-review-rounds.md)）。

## 手順

### 0. 組み込み（spec リポジトリごとに 1 回）

1. 二層を宣言する（[PB-00017](00017-apply-kernel-to-project.md) 手順 1〜3）。spec リポの `AGENTS.md` に kernel の URL と、本手順（PB-00020）への参照を 1 行書く
2. 機能ごとのディレクトリを決め、requirements / design と並べて 2 つの雛形をコピーする。design の中には入れない（受け入れ例は requirements の精緻化。[ADR-00008](../adr/00008-sdd-bridge.md)）

   ```text
   specs/<feature>/
     requirements.md            # SDD 側の既存成果物
     design.md                  # PdO の設計（入力）
     acceptance-examples.md     # templates/acceptance-examples.md のコピー
     acceptance-refinement-log.md  # templates/acceptance-refinement-log.md のコピー
     tasks.md
   ```

3. spec リポのエージェントが本手順を読める状態にする。最小は `AGENTS.md` に kernel の PB-00020 の URL を書くこと。skill として発火させたい場合は kernel の `.agents/skills/aidd-refine-acceptance/SKILL.md` をコピーし、「先に読むもの」のリンクを kernel の URL に書き換える。手順本文は書き写さない（[ADR-00009](../adr/00009-skills-as-playbook-entrypoints.md)）

### 1. 入力を揃える

4. PdO の設計と、設計が依拠した KB の ID（[PB-00008](00008-bridge-sdd-spec.md) 方向 A）を受け入れ例シートの冒頭に書く。依拠 ID が空なら、設計のドメインに近い `adr/` を `tags` で絞って PdO と一緒に列挙する
5. シートの `status` は `draft` のまま、`巡` を 0 にする

### 2. 初稿（エージェント）

6. 設計に**明記された**値だけを代表例・境界・反例の行に落とす。各行の `出所` に `設計 §…` を書く
7. 明記されていない閾値・境界・不成立時の挙動は、行を空欄にせず「決められていないこと」に**質問**として書く。質問は選択肢付きにする（「6 か月ちょうどは対象内か、対象外か」「退会済みはエラーか、割引なしで通すか」）。値を埋めてはいけない
8. どうしても候補を置きたい場合だけ `出所: 提案` で行を置く。提案の行は承認前に必ず `PdO …` に変わるか、削除されるか、未決へ移る

### 3. レビュー巡（既定 3 巡）

各巡で 9〜12 を行う。

9. エージェントが固定観点 L1〜L6（[ADR-00024](../adr/00024-refine-acceptance-with-bounded-review-rounds.md) §4）で受け入れ例シートを読み、指摘を等級（P0 / P1 / P2）付きで記録の「指摘」表に追記する。指摘には対象行番号を付ける
10. PdO が P0 / P1 に答える。答えは値・境界・挙動のいずれかで、質問の選択肢から選ぶか新しい値を書く。答えられないものは「未決」と答える
11. エージェントが回答を反映する。反映した行の `出所` を `PdO YYYY-MM-DD` にする。「未決」は「決められていないこと」に残す。却下した指摘は理由を書く
12. 記録の「対応」表に、指摘番号ごとの対応（反映 / 未決へ / 却下）、決めた人、残りの P0 / P1 / P2 件数を追記する。シートの `巡` を進める

13. P0 と P1 が 0 件になったら終える。3 巡で残った P0 / P1 は「決められていないこと」に移し、その項目に触れる実装を始めない。4 巡目に進まない（続けたいなら機能を分割して手順 2 からやり直す）

### 4. 承認と引き渡し

14. 開発がテスト可能性（L5）を最終確認する。1 行 1 結果になっていない行は P1 として差し戻す
15. PdO がシートの `status` を `approved` に書き換える。エージェントは書き換えない
16. `出所: 提案` の行が残っていないこと、「決められていないこと」が空か実装対象外として明示されていることを確認し、[PB-00013](00013-start-tdd-from-examples.md) へ渡す。実装スペックの要否は [PB-00012](00012-triage-implementation-spec.md)

### 5. 還流

17. 複数の機能・案件で同じ指摘が繰り返されたら（例: 「境界の 1 つ手前が常に抜ける」）、観点や雛形の改訂候補として [PB-00008](00008-bridge-sdd-spec.md) 方向 B で kernel に戻す。案件の業務値は戻さない

## 検証

- 受け入れ例の全行に `出所` があり、`approved` のシートに `提案` の行がない
- 閾値ごとに境界の行（ちょうど / 1 つ手前）があり、ルールごとに反例の行がある
- 記録に巡ごとの指摘表と対応表があり、各指摘に対応と決めた人が付いている
- 制約（性能・可用性・データ量）が例の表ではなく制約表にある
- KB の決定と矛盾する項目が、シートの中で決着されずに [ledger/open-questions.md](../ledger/open-questions.md) か案件側の未決に出ている
- 4 巡目が存在しない

## 失敗時

- PdO が質問に答えられない → 要件が決まっていない。シートを `draft` のまま止め、未決を spec 側に残す。エージェントが代わりに決めない
- 3 巡で P0 が減らない → 設計の粒度が大きすぎる。機能を分割し、分割後の単位で手順 2 からやり直す
- `出所` のない行、`提案` のまま承認された行が見つかった → 承認を取り消し、該当行を質問に戻す
- 例が多すぎてテストが遅くなりそう → 代表例だけを外側に置き、組み合わせは内側に降ろす（[PB-00013](00013-start-tdd-from-examples.md) 失敗時）
- 指摘が毎回同じ観点に偏る → 観点の定義が設計の種類に合っていない。案件側で観点を足すのはよいが、kernel の観点を減らさない。繰り返すなら手順 17 で kernel へ
- spec リポのエージェントが kernel を読めない → 案件作業は止めず、手順 0-3 のコピーを置く。働き方の改訂は kernel 側の PR にする

## 関連

- [ADR-00024](../adr/00024-refine-acceptance-with-bounded-review-rounds.md)
- [ADR-00014](../adr/00014-implementation-spec-split.md)
- [ADR-00008](../adr/00008-sdd-bridge.md)
- [PB-00013](00013-start-tdd-from-examples.md)
- [PB-00012](00012-triage-implementation-spec.md)
- [PB-00008](00008-bridge-sdd-spec.md)
- [PB-00017](00017-apply-kernel-to-project.md)
- [templates/acceptance-examples.md](../templates/acceptance-examples.md)
- [templates/acceptance-refinement-log.md](../templates/acceptance-refinement-log.md)
- skill: [aidd-refine-acceptance](../.agents/skills/aidd-refine-acceptance/SKILL.md)
