---
id: REV-00003
title: 参照グラフによる初回の構造レビュー
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - reviews
  - graph
related:
  - ADR-00010
  - PB-00010
  - EVID-00014
---

# 参照グラフによる初回の構造レビュー

- 期間: 2026-08-09 — 2026-08-09
- 範囲: `build-graph.py` 導入時点の知識ベース全体（[PB-00010](../playbook/00010-review-with-graph.md) の初回適用）

## 2026-08-09

### 実施者

- Cursor Cloud Agent（グラフ層の導入と初回レビュー）
- owners: TeramachiShunsuke

### 経緯

[graphify.com](https://graphify.com) を知識のグラフ化に使えるかという問いから始めた。実測の結果、コードを持たない本リポジトリでは Graphify のノードが全て LLM 由来になることが分かり（[EVID-00013](../evidence/00013-graphify-needs-llm-for-docs.md)）、決定的な構造グラフを自前で持つ方針に切り替えた（[ADR-00010](../adr/00010-knowledge-graph-layers.md)）。

### グラフの規模

- ノード 73 / 辺 297（links 184 / related 80 / anchor 27 / entrypoint 6）
- LLM 呼び出し 0 回、実行 0.1 秒未満、出力は 2 回実行でバイト一致

### 検出したエラー

- **0 件**。参照切れ、錨のない claim、リンク切れはいずれもなかった
- 検査の有効性は意図的に壊した 4 パターンで確認済み（[EVID-00014](../evidence/00014-reference-graph-from-metadata.md)）

### 警告と扱い

| 種別 | 対象 | 扱い |
| --- | --- | --- |
| 入口のない手順 | PB-00004 / PB-00005 / PB-00006 / PB-00009 | **据え置き**。頻度の低い手順で、skill を足すと Tier 1 の一覧が膨らむ。運用して呼び出し頻度が上がったものから [PB-00009](../playbook/00009-add-skill.md) で追加する |

- 「未使用の根拠」「evidence の錨を持たない決定」「孤立ノード」「草案・廃止に乗る決定」はいずれも 0 件だった

### ハブ

被参照の上位は ADR-00006（Tier）、ADR-00007（生成インデックス）、CONVENTIONS。Tier の決定が最大のハブであり、ここを変更する PR は影響範囲を明示する必要がある。

### 設計上の判断

- `related` の片方向リンクを警告にすると 35 件出たため、この検査は採用しなかった。playbook が実装対象の ADR を指し、ADR が全 playbook を列挙しないのは正常な非対称である。この点は [CONVENTIONS.md](../CONVENTIONS.md) に明記した
- 警告は CI を落とさない設計にした。昇格の是非は [OQ-00008](../ledger/open-questions.md) として残す

### 解決した未決

- OQ-00003（claims 錨のリンク切れを自動検知するか）→ 解決。Resolved へ移動した

### 残した未決

- OQ-00008: 警告を CI エラーへ昇格させる条件
- OQ-00009: 意味グラフを定期的に回す運用を作るか
- OQ-00010: `graph.json` を出力して外部ツールに渡すか

<!-- 以降は末尾にのみ追記すること。既存行の編集・削除は禁止。 -->
