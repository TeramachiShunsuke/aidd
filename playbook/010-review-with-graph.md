---
id: PB-010
title: グラフで構造化レビューする
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - graph
  - reviews
related:
  - ADR-010
  - PB-003
tier: 2
---

## いつ使うか

定期レビューのとき（[PB-003](003-run-review-cycle.md) の冒頭で使う）、文書を大量に追加した直後、または「この決定は何に支えられているか」「この根拠はどこで使われているか」を確認したいとき。

## 手順

1. 生成物を更新する。グラフ → 索引の順に実行する（索引は `GRAPH.md` の存在を拾うため）

   ```bash
   python3 .github/scripts/build-graph.py
   bash .github/scripts/build-index.sh
   ```

2. [GRAPH.md](../GRAPH.md) の `## レビュー信号` を上から読む。種別ごとに扱いを決める
   - **未使用の根拠** — その evidence を参照する ADR か claim を足すか、evidence 自体を `deprecated` にする
   - **手順のない決定** — 手順化できるなら playbook を追加する。できないなら放置してよい（すべての決定が手順になるわけではない）
   - **入口のない手順** — 発見されにくいだけで壊れてはいない。頻繁に使うものだけ [PB-009](009-add-skill.md) で skill を足す
   - **草案に乗る決定** — 根拠の status を確定させる
   - **追随していない決定** — 根拠が更新されたのに決定が再確認されていない。決定を読み直し、変わらないなら `last_reviewed` を今日にする。変わるなら ADR を改訂する
   - **孤立** — 参照も被参照もない。統合するか削除を検討する

   警告が 0 件で安定した種別は [PB-011](011-promote-check.md) でエラーに昇格させる。
3. `## ハブ` を見る。被参照が多い文書は変更の影響範囲が大きい。触る文書が決まったら波及先を出し、PR 説明に列挙する

   ```bash
   python3 .github/scripts/build-graph.py --impact ADR-006
   ```

4. `## 根拠グラフ` の mermaid で、決定と根拠のつながりに欠落がないか目視する
5. 扱いを決めた項目は該当文書を直し、決めきれない項目は [ledger/open-questions.md](../ledger/open-questions.md) に残す
6. 結果を `reviews/` に記録する（新規ファイル追加、または既存ファイル末尾への追記のみ）
7. 生成物を再生成し、同じコミットに含める

## 検証

```bash
python3 .github/scripts/build-graph.py --check
bash .github/scripts/build-index.sh --check
bash .github/scripts/check-staleness.sh
```

- 3 つとも PASSED
- 扱った警告が `GRAPH.md` から消えている、または open-questions に残っている

## 失敗時

- `does not resolve` → `related` か錨の ID が実在しない。ID を直すか、参照先の文書を作る
- `has no anchor` → claim に `evidence:` / `adr:` / `url:` のいずれかを足す。錨を書けないなら claim ではなく open-question にする
- `broken link` → リンク先のパスを直す。コピー先を基準にしたリンクを持つ雛形は `templates/` に置く（検査対象外）
- `cites X in '## 根拠' but 'related' does not list it` → 本文で根拠に挙げた ID を Frontmatter の `related` にも足す。挙げるほどの根拠でないなら本文から外す
- `has no evidence anchor` → 決定の前に [PB-001](001-add-evidence.md) で evidence を書き、`related` と `## 根拠` の両方に入れる
- `rests on deprecated` / `anchored to deprecated` → 後継の evidence / ADR へ錨を張り替える。張り替え先がないなら、その決定自体を見直す
- `has superseded_by but status is ...` → 置き換えられた文書の `status` を `deprecated` にする
- 警告が多すぎて扱えない場合は、1 回のレビューで全部を潰そうとせず、種別を 1 つ選んで [ledger/open-questions.md](../ledger/open-questions.md) に残りを記録する

## 関連

- [ADR-010](../adr/010-knowledge-graph-layers.md)
- [EVID-014](../evidence/014-reference-graph-from-metadata.md)
- [PB-003](003-run-review-cycle.md)
