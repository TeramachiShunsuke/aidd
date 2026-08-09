---
id: PB-011
title: グラフの警告をエラーへ昇格する
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - graph
  - ci
related:
  - ADR-013
  - PB-010
tier: 2
---

## いつ使うか

`GRAPH.md` の警告が長期間 0 件で安定したとき、または新しい構造検査を追加したいとき。逆に、エラーが厳しすぎて正当な作業を止めていると分かったときの降格にも使う。

## 手順

1. 対象の警告が [ADR-013](../adr/013-check-grades.md) の昇格基準を満たすか確認する

   - 現時点の違反が 0 件（`GRAPH.md` のレビュー信号に出ていない）
   - 違反したときの修正方法が一意（人が 2 択で迷わない）
   - `status: frozen` の文書を改変せずに直せる

2. 満たさない場合は昇格しない。違反が残っているならまず文書側を直す。frozen が障害なら、その文書を検査の対象外にする条件を先に決める
3. `.github/scripts/build-graph.py` の `validate()` で、該当箇所を `graph.warnings.append(...)` から `graph.errors.append(...)` へ移す。エラー文言は「どのファイルの何が、どうあるべきか」を 1 行で示す
4. 意図的に壊した状態を作り、`python3 .github/scripts/build-graph.py` が FAILED になることを確認してから元に戻す
5. [ADR-013](../adr/013-check-grades.md) の等級表に行を足し、`last_reviewed` を今日にする
6. 生成物を再生成する（グラフ → 索引）
7. 昇格の判断根拠（違反 0 件だった事実）を `reviews/` か [ledger/changelog.md](../ledger/changelog.md) に残す

## 検証

```bash
python3 .github/scripts/build-graph.py --check
bash .github/scripts/build-index.sh --check
```

- 両方 PASSED
- 昇格した検査が `GRAPH.md` のレビュー信号から消えている
- ADR-013 の等級表と実装が一致している

## 失敗時

- 昇格したら既存文書が大量に落ちた → 基準 1 を満たしていない。差し戻して警告に戻し、違反を先に潰す
- frozen 文書だけが落ちる → 検査から frozen を除外し、除外件数を `GRAPH.md` に出す（[ADR-013](../adr/013-check-grades.md) の扱いに合わせる）
- 正当な作業が止まる → 降格してよい。降格も同じ手順で、理由を changelog に残す

## 関連

- [ADR-013](../adr/013-check-grades.md)
- [PB-010](010-review-with-graph.md)
- [EVID-017](../evidence/017-warnings-do-not-ratchet.md)
