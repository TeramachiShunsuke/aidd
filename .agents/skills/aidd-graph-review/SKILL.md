---
name: aidd-graph-review
description: AIDD 知識ベースの参照グラフ GRAPH.md を再生成し、構造化レビューの信号（未使用の根拠、根拠なしの決定、参照切れ、ハブ文書）を読んで対処する。「グラフでレビューする」「参照切れを探す」「使われていない evidence を洗い出す」「影響範囲を知りたい」と言われたときに使う。
metadata:
  aidd-playbook: PB-00010
  aidd-tier: "1"
---

# グラフで構造化レビューする

## いつ使うか

- 定期レビューの冒頭で、知識ベース全体の構造を点検するとき
- 文書を大量に追加した直後や、変更の影響範囲を知りたいとき

## 先に読むもの

1. [ADR-00010](../../../adr/00010-knowledge-graph-layers.md) — 構造層と意味層の分離、CI が落とす 4 条件
2. [PB-00010](../../../playbook/00010-review-with-graph.md) — 手順の正本
3. 定期レビュー全体は [PB-00003](../../../playbook/00003-run-review-cycle.md)

## 手順の要点

1. `python3 .github/scripts/build-graph.py` → `bash .github/scripts/build-index.sh` の順に再生成する
2. [GRAPH.md](../../../GRAPH.md) の `## レビュー信号` を種別ごとに処理する（未使用の根拠 / 根拠なしの決定 / 手順のない決定 / 入口のない手順 / 草案に乗る決定 / 孤立）
3. `## ハブ` で被参照の多い文書を確認し、触るなら影響先を PR に書く
4. 決めきれない項目は `ledger/open-questions.md` に残す
5. 結果を `reviews/` に記録し、`--check` 3 種を通す

## 禁止事項

- `GRAPH.md` を手で編集する（生成物。直すのは文書側）
- 警告を消すためだけに `related` や錨を足す（参照は意味のあるものだけ）
- 意味グラフツールの出力（`graphify-out/` 等）を commit する
- 手順の詳細をこのファイルに書き写す（正本は PB-00010）
