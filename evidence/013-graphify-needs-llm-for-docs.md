---
id: EVID-013
title: Graphify は docs のみの知識ベースでは全ノードが LLM 由来になる
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - graph
  - tooling
related:
  - EVID-010
  - ADR-010
tier: 3
---

## 主張

[Graphify](https://graphify.com) はコードを tree-sitter でローカル・決定的に解析するが、Markdown はその経路に乗らない。本リポジトリのようにコードを持たない知識ベースでは、グラフの中身がすべて LLM の意味抽出に依存する。

## 観測

2026-08-09 に `graphifyy 0.9.37` を本リポジトリ（コミット時点で Markdown 53 件、シェルスクリプト 2 件）で実行した。

- `graphify extract . --code-only` の出力: `--code-only: skipping 53 non-code file(s) (53 docs, 0 papers, 0 images) — no LLM extraction` / `found 2 code, 0 docs` / `wrote graph.json: 22 nodes, 29 edges, 3 communities`。生成された 22 ノードはすべて `.github/scripts/*.sh` 由来で、**知識そのものは 1 ノードも入らなかった**。
- `graphify extract .`（キーなし）の出力: `error: no LLM API key found (53 doc/paper/image file(s) need semantic extraction)`。公式 README も "Code is extracted locally with no API calls (AST via tree-sitter). Everything else goes through your AI assistant's model API." と明記している。
- 出力 `graph.json` は `built_at_commit` キーを持つ。コミットごとに値が変わるため、ファイルをそのまま commit すると内容が同じでも差分が出る。
- README は `graphify-out/` を commit する運用を推奨する一方、Claude Code のプロンプトキャッシュを壊すため `.claudeignore` に入れる回避策も併記している。
- Cursor 向けインストール（`graphify cursor install`）は `.cursor/rules/graphify.mdc` を `alwaysApply: true` で書き込む。これは全会話に常時注入される設定で、[ADR-006](../adr/006-context-tiers.md) の Tier 0 に相当する枠を消費する。
- 一方で有用な性質もある。辺に `EXTRACTED` / `INFERRED` / `AMBIGUOUS` の確信度タグが付き、「読み取った関係」と「推論した関係」を区別できる。これは本リポジトリが evidence と主張を分ける方針（[EVID-001](001-agents-need-evidence.md)）と同じ発想である。
- README 内に矛盾がある。環境変数の表はクエリログを「既定オフ、オプトイン」と書き、Privacy 節は「全クエリが記録される、オプトアウトは `GRAPHIFY_QUERY_LOG_DISABLE=1`」と書いている。どちらが実装の挙動かは未検証。

## 限界

検証したのは本リポジトリ 1 件・バージョン 1 つのみで、LLM 経路を実際に走らせた出力（意味グラフの品質）は未評価である。API キーを与えれば有用なグラフが得られる可能性は否定していない。ここで示したのは「コストと非決定性がどこに発生するか」までである。ベンチマーク値は公式の自己申告で、独立検証していない。

## 関連

- [ADR-010](../adr/010-knowledge-graph-layers.md)
- [EVID-014](014-reference-graph-from-metadata.md)
- [Graphify README](https://github.com/Graphify-Labs/graphify)
