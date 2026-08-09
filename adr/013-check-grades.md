---
id: ADR-013
title: 検査を error と warning に等級分けし、充足しているものから機械で固定する
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - graph
  - ci
  - review
related:
  - EVID-017
  - EVID-014
  - EVID-010
  - ADR-010
  - ADR-003
  - EVID-013
tier: 2
---

## 文脈

[ADR-010](010-knowledge-graph-layers.md) で構造グラフを CI に載せたが、落とすのは 4 つだけで、決定と根拠の紐づきに関する検査はすべて警告のままだった。[EVID-017](../evidence/017-warnings-do-not-ratchet.md) の集計では紐づきの充足率が 100% である一方、それを保つ機械的な力がなく、さらに本文の `## 根拠` と Frontmatter の `related` のズレが 11 件中 7 件あった。

機械的なレビュー品質を上げる手として、意味グラフ（LLM）の採用も検討した。しかし [EVID-013](../evidence/013-graphify-needs-llm-for-docs.md) のとおり出力が非決定的で、ゲートには使えない。上げるべきは構造層である。

## 決定

### 1. 検査を 2 等級に分ける

**error（CI を落とす）** は、構造が壊れていて、かつ**修正方法が一意に決まる**ものに限る。

| # | 検査 | 状態 |
| --- | --- | --- |
| 1 | `related` / 錨の ID が解決しない | 既存 |
| 2 | 錨を 1 つも持たない claim | 既存 |
| 3 | 文書間リンクの切れ | 既存 |
| 4 | 生成物（`GRAPH.md`）の陳腐化 | 既存 |
| 5 | ADR の `## 根拠` 節にある ID が `related` にない | 新規 |
| 6 | ADR が evidence の錨を 1 つも持たない | 警告から昇格 |
| 7 | 決定・主張が `deprecated` な根拠に乗っている | 警告から昇格 |
| 8 | `superseded_by` を持つのに `status: deprecated` でない | 新規 |

**warning（レビュー候補。CI は落とさない）** は、正解が機械的に決まらず人間の判断が要るもの。

- どの決定・主張からも使われていない evidence
- 専用の skill 入口がない playbook
- 参照も被参照もない孤立文書
- `draft` の根拠に乗っている決定
- 根拠の `last_reviewed` が決定より新しい（根拠が動いたのに決定が再確認されていない）※新規

### 2. 昇格の基準

警告を error へ上げてよいのは、次の 3 つを同時に満たすときに限る。

1. 現時点の違反が **0 件**である（既存の借金を新しい規則で不合格にしない）
2. 違反したときの修正方法が一意である（「どちらを直すべきか」を人が選ばない）
3. `status: frozen` の文書を改変せずに直せる

3 を満たせないため、**frozen 文書は検査 5 の対象外**とする（[ADR-003](003-frozen-immutability.md) の不変性が優先する）。対象外にした件数は `GRAPH.md` に出す。

新規に error を足す場合は基準 1 の読み替えが要る。**同じ PR で違反を 0 件にできること**（修正が機械的で、frozen を壊さない）を条件に、最初から error として入れてよい。検査 5 はこの経路で入れた。導入時点で 11 件中 7 件がズレていたため、本文で根拠に挙げていた evidence を `related` に補って 0 件にしたうえで有効化している。既存の借金を残したまま error を足すことだけを禁じている。

この基準により、充足しているものだけが順に固定されていく。逆戻りしないことが目的であり、網羅そのものは目的ではない。

### 3. 影響範囲の照会

`build-graph.py --impact <ID>` で、その文書を（再帰的に）参照している文書を列挙する。ハブを触る PR で影響先を示すために使う。出力は生成物に含めず、標準出力のみ。

### 4. 意味層（LLM）の位置づけ

意味グラフを CI に入れない方針は [ADR-010](010-knowledge-graph-layers.md) のまま変えない。ただし使い方を 1 つ足す。**LLM は検査ではなく提案に使い、採用した関係は `related` に書いて構造層へ焼き込む。**

- LLM が「ADR-010 は EVID-009 にも乗っているのでは」と示す
- 人が妥当性を判断する
- 妥当なら `related` に追記する。この時点で辺は決定的なメタデータになり、以後は検査 5 が守る
- ツールの出力そのもの（`graphify-out/` 等）は commit しない

非決定性は入口の 1 回だけに閉じ、リポジトリと CI は決定的なまま保たれる。

## 根拠

- [EVID-017](../evidence/017-warnings-do-not-ratchet.md): 紐づきは 100% 充足だが警告のみで守られておらず、本文と `related` のズレが 7/11 で存在した
- [EVID-014](../evidence/014-reference-graph-from-metadata.md): 明示メタデータからの検査は決定的で、破損を実際に検出できる
- [EVID-013](../evidence/013-graphify-needs-llm-for-docs.md): LLM 由来のグラフは非決定的で、ゲートには使えない
- [EVID-010](../evidence/010-handwritten-index-rots.md): 検査されない規約は守られなくなる
- [ADR-003](003-frozen-immutability.md): frozen 文書は改変できないため、新しい検査を無条件に適用できない

## 結果・トレードオフ

- 利点: 「決定が根拠に紐づいているか」が運用の心がけではなく CI の条件になる
- 利点: 本文とメタデータのズレが生まれた時点で落ちるため、グラフの被参照数・ハブ・影響範囲が実態とずれない
- 利点: 昇格基準が明文化され、警告をいつ上げるかの判断（[OQ-008](../ledger/open-questions.md)）が再現可能になる
- 代償: ADR を書くとき、本文の `## 根拠` に ID を足したら `related` にも足す手間が増える。CI が具体的な差分を示すため機械的に直せるが、往復は増える
- 代償: frozen 文書が検査の穴として残る。ADR-002 のズレ（EVID-003）は後継 ADR を作るまで直せない
- 代償: 検査 7 を error にしたため、根拠を `deprecated` にする作業がそれ単体では通らなくなる。依存する決定の錨を同じ PR で張り替える必要がある

## 関連

- [PB-010](../playbook/010-review-with-graph.md)
- [ADR-010](010-knowledge-graph-layers.md)
- [.github/scripts/build-graph.py](../.github/scripts/build-graph.py)
