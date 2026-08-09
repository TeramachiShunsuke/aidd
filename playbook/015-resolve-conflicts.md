---
id: PB-015
title: 競合と ID 衝突を解決する
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - conflicts
  - ci
related:
  - ADR-016
  - EVID-021
  - ADR-007
tier: 2
---

## いつ使うか

`git merge` / `git rebase` が競合したとき、または `build-index.sh --check` が ID の重複を報告したとき。

## 手順

競合したファイルを種類で分ける。**種類ごとに解決方法が決まっているので、中身を読んで悩まない**（[ADR-016](../adr/016-shrink-conflict-surface.md)）。

### 1. 生成物（`INDEX.md` / `GRAPH.md`）

読まない。どちらかを取って再生成する。

```bash
git checkout --ours INDEX.md GRAPH.md
python3 .github/scripts/build-graph.py && bash .github/scripts/build-index.sh
git add INDEX.md GRAPH.md
```

### 2. 追記専用の台帳（`ledger/*.md` / `reviews/**`）

`.gitattributes` の `merge=union` により、通常は競合せず両側の行が残る。競合した場合と、union が通った場合の両方で**重複 ID を確認する**。

```bash
python3 .github/scripts/build-graph.py --check   # CLAIM の重複を検出する
bash .github/scripts/build-index.sh --check      # 文書 id の重複を検出する
```

重複していたら、後から作った方を振り直す（手順 4）。順序が入れ替わっていたら読める順に直す。`reviews/**` は追記専用なので、**両側の追記を時系列で並べ、既存行には触らない**。

### 3. 文書本文（`evidence/` / `adr/` / `playbook/`）

ここが競合するのは、同じ文書を 2 人が同時に直したときだけ。意味を読んで解決する。片方が `frozen` なら frozen 側を必ず残す。

### 4. ID の衝突（Git が競合として報告しないもの）

別々のファイル名で同じ ID を使っている場合、Git は競合を報告せずマージが成功する。`check-id-collisions.sh` の警告か、マージ後の重複検査で気づく。

```bash
bash .github/scripts/check-id-collisions.sh   # 他ブランチとの衝突を事前に見る
```

振り直す側を決める（**先に main へ着地した方が番号を保持する**）。振り直しは 3 段階で行う。

1. ファイル名を変える（降順に処理して玉突きを避ける）
2. 文書内の `id:` と、他文書からの `related` / 本文リンクを置換する
3. `ledger/` の CLAIM / OQ / changelog の該当行を直す

置換の取りこぼしは検査に任せる。`build-graph.py --check` は `related` と本文リンクの ID がすべて解決することを要求し、`build-index.sh --check` は `id` の重複とファイル名の対応を見る。**両方が緑になるまで振り直しは終わっていない**。

### 5. 仕上げ

```bash
python3 .github/scripts/build-graph.py && bash .github/scripts/build-index.sh
bash .github/scripts/check-staleness.sh
```

## 検証

- 生成物を手で編集していない
- `frozen` 文書が 1 バイトも変わっていない
- `reviews/**` と `ledger/attestations.md` で、既存行が消えていない（旧内容が新内容の prefix である）
- 3 つの `--check` がすべて緑
- 振り直した場合、旧 ID がリポジトリのどこにも残っていない（`rg` で確認する）

## 失敗時

振り直しの範囲が広くて自信が持てないときは、**マージせずに片方の PR を先に着地させ、もう片方を作り直す**。中途半端に混ざった状態で main へ入れると、どの ID がどの文書かを後から復元できない。

積み上げ PR（PR の base を別の PR にする）は ID 衝突の温床になる。親がマージされても子は main に届かないため、その間に第三の PR が同じ番号を取る。[REV-006](../reviews/006-lifecycle-self-review.md) の実例を読むこと。

## 関連

- [ADR-016](../adr/016-shrink-conflict-surface.md) — 競合面を減らす決定
- [EVID-021](../evidence/021-shared-ledgers-and-serial-ids-collide.md) — 競合の内訳と先行事例
- [PB-007](007-rebuild-index.md) / [PB-010](010-review-with-graph.md)
