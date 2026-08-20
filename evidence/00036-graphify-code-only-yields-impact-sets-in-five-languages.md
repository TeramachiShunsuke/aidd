---
id: EVID-00036
title: Graphify の --code-only は Java / Python / TS / JS / Go のコードから LLM なしで参照グラフを出し、affected で変更起点の影響範囲を列挙できる
status: active
last_reviewed: 2026-08-20
owners:
  - TeramachiShunsuke
tags:
  - graph
  - context
  - toolchain
related:
  - EVID-00013
  - EVID-00035
  - ADR-00010
  - ADR-00027
---

## 主張

Graphify のコード経路（`extract --code-only`）は、5 言語の小さなサンプルで AST 由来のノードと `calls` / `imports` / `references` / `contains` の辺を決定的に出力した。`affected "<ノード>" --depth N` は逆方向の走査で「そのノードを変えると影響を受けるノード」をファイルと行番号つきで列挙する。つまり [ADR-00027](../adr/00027-cost-and-context-per-task.md) が前提にする「変更起点の近傍を機械的に出す」操作は、追加のスクリプトなしに既存コマンドで行える。ただし言語によって辺の確信度が変わり、ラベルが衝突すると一意に解決できない。

## 観測

2026-08-19 に `graphifyy 0.9.46`（PyPI）を、本リポジトリの外の使い捨てディレクトリで実行した。サンプルは「会員割引」の判定関数と、それを呼ぶ合計関数の 2〜3 ファイル。

- Python 3 ファイル（`pkg/discount.py` / `pkg/checkout.py` / `test_discount.py`）: `graphify extract . --code-only` → `AST extraction on 3 code files` / `wrote graphify-out/graph.json: 9 nodes, 21 edges, 2 communities`。LLM の呼び出しなし。
- `graph.json` の形: トップキーは `directed` / `multigraph` / `graph` / `nodes` / `links` / `hyperedges` / `built_at_commit`。ノードは `id` / `label` / `source_file` / `source_location`（例 `L4`）/ `community` / `_origin: "ast"`、辺は `relation`（`calls` / `imports` / `imports_from` / `references` / `contains` / `method`）/ `confidence`（`EXTRACTED` / `INFERRED`）/ `confidence_score` / `source_file` / `source_location`。
- `graphify affected "discount_rate" --depth 2` の出力（抜粋）: `apply_discount() [calls] pkg/discount.py:L16` / `test_boundary_six_months() [calls] test_discount.py:L4` / `total() [calls] pkg/checkout.py:L4` / `checkout.py [imports] pkg/checkout.py:L1`。既定の深さは 2、`--relation` で辺の種類を絞れ、`--depth 3` で呼び出し元の呼び出し元まで広がった。
- Go / TypeScript / Java の 6 ファイル（各 2 ファイル）を 1 ディレクトリで抽出: `22 nodes, 28 edges, 5 communities`。TS と Java のファイル間呼び出し（`total → rate`）は `calls … EXTRACTED`、Go の同一パッケージ別ファイルの呼び出し（`Total → Rate`）は `calls … INFERRED` だった。Java で定義のない型 `Member` への参照は、`source_file` が空のノードとして残った。
- JavaScript 2 ファイル（ESM）: `total → rate` / `rate → isEligible` が `calls … EXTRACTED`。`affected "rate()"` が呼び出し元と import を列挙した。
- ラベル解決: `affected` はラベルを大文字小文字を無視して照合する。同じディレクトリに TS の `rate()` と Go の `Rate()` があると `No unique node match for rate()` になり、ノード `id`（例 `ts_discount_rate` / `go_discount_rate`。パスとシンボルから機械的に作られる小文字の識別子）を渡すと解決した。
- 2 回目の `extract` は `incremental scan … 6 unchanged` と出て差分だけを再抽出した。`graphify update <path>` はコードだけを再抽出し LLM を使わない、と `--help` に明記されている。`god-nodes` は辺の多いノード（ハブ）を列挙した。
- `graphify install` はエージェント用の skill / 規則をプラットフォームの設定ディレクトリに書き込むコマンドであり（`--help`）、[EVID-00013](00013-graphify-needs-llm-for-docs.md) が観測した常時注入（Cursor の `alwaysApply: true`）はこの経路で入る。`extract` と `affected` を使うだけなら `install` は不要だった。

## 限界

サンプルは各言語 2〜3 ファイルの玩具で、フレームワーク・動的ディスパッチ・リフレクション・ジェネリクス・モノレポの依存解決は試していない。Go の `INFERRED` は 1 例で、他の構文でどう振る舞うかは未観測。実リポでの再現率（実際に変更が要ったファイルのうち `affected` が挙げた割合）は測っていない（ロードマップ 2-4）。バージョン 0.9.46 時点のコマンド体系であり、変わりうる。

## 関連

- [ADR-00027](../adr/00027-cost-and-context-per-task.md)
- [PB-00024](../playbook/00024-choose-model-effort-context.md)
- [EVID-00013](00013-graphify-needs-llm-for-docs.md)
- [EVID-00035](00035-cost-follows-judgment-not-volume-context-is-scopeable.md)
- [Graphify README](https://github.com/Graphify-Labs/graphify)
