---
id: EVID-00014
title: 知識ベースの参照グラフは既存メタデータから決定的に導出できる
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - graph
  - ci
related:
  - EVID-00010
  - ADR-00010
tier: 3
---

## 主張

本リポジトリの文書は、すでにグラフとして必要な辺を明示的に持っている。`related`、文書間リンク、ledger の錨、skill → playbook の 4 種類を読むだけで、LLM を使わず決定的に参照グラフを構築でき、参照切れと錨なし主張を機械的に検出できる。

## 観測

2026-08-09 に `.github/scripts/build-graph.py`（標準ライブラリのみ、API 呼び出しなし）を実装して実行した。

- 抽出結果: ノード 63（adr 9 / evidence 12 / playbook 9 / claim 12 / open-question 7 / ledger 3 / reviews 2 / root 3 / skill 5 / external 1）、辺 246（links 147 / related 71 / anchor 23 / entrypoint 5）。所要は 0.1 秒未満、LLM 呼び出しは 0 回。
- 同じ入力で 2 回実行した出力はバイト単位で一致した。生成日時を出力に含めないため、`--check` による最新性検査が成立する（[EVID-00010](00010-handwritten-index-rots.md) と同じ条件）。
- 意図的に壊した 4 パターンをすべて検出した。存在しない `related` ID、錨のない claim、存在しない ID を指す錨、リンク切れ。いずれも `ERROR` として非ゼロ終了した。
- 実データに対する初回の警告は「専用の skill 入口がない playbook」4 件（PB-00004 / PB-00005 / PB-00006 / PB-00009）のみだった。「未使用の evidence」「evidence の錨を持たない ADR」「孤立ノード」は 0 件で、[REV-00001](../reviews/00001-bootstrap-design-review.md) 以降の設計が構造的には破綻していないことを示す。
- 被参照数の上位は ADR-00006（19）、ADR-00007（13）、CONVENTIONS（12）だった。Tier の決定が最も多くの文書から参照されるハブになっており、ここを変更する影響範囲が大きいことが数値で見える。
- 設計上の注意として、`related` の片方向リンクを警告にすると 35 件出た。playbook が実装対象の ADR を指す一方で ADR が全 playbook を列挙しないのは正常な非対称であり、この検査は信号ではなくノイズだったため採用しなかった。

## 限界

このグラフが表すのは**明示された参照**だけで、「本来つながっているべきなのに誰もリンクを書いていない関係」は検出できない。意味的な近さや暗黙の依存は対象外であり、そこは人間のレビューか意味グラフ（[EVID-00013](00013-graphify-needs-llm-for-docs.md)）の領分である。また文書数 63 での計測であり、規模が 1 桁増えたときの可読性は未検証。

## 関連

- [ADR-00010](../adr/00010-knowledge-graph-layers.md)
- [PB-00010](../playbook/00010-review-with-graph.md)
- [GRAPH.md](../GRAPH.md)
