---
id: ADR-016
title: 競合は解決を上手くするのではなく、競合面を減らして扱う
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - conflicts
  - ledger
  - identifiers
  - ci
related:
  - EVID-021
  - EVID-010
  - ADR-007
  - ADR-013
tier: 2
---

## 文脈

[EVID-021](../evidence/021-shared-ledgers-and-serial-ids-collide.md) のとおり、このリポジトリで実際に起きた競合は 2 種類（共有台帳と生成物）しかなく、加えて Git が競合として報告しない ID 衝突があった。先行事例（towncrier / Rust RFC）はいずれも、競合の解決手順を磨くのではなく競合面そのものを消している。

一方で、手順が要らなくなるわけではない。生成物の競合や ID の振り直しは、どう直すかが決まっているのに毎回考え直している。

## 決定

競合を 3 つに分類し、それぞれ別の扱いをする。

### 1. 生成物（`INDEX.md` / `GRAPH.md`）— 解決しない

競合しても中身を読まない。どちらかを取って**再生成し直す**。[ADR-007](007-generated-index.md) のとおり生成物は手で編集しないので、競合の解決も手で行わない。

```bash
git checkout --ours INDEX.md GRAPH.md
python3 .github/scripts/build-graph.py && bash .github/scripts/build-index.sh
```

### 2. 追記専用の台帳 — Git に両方残させる

`ledger/*.md` と `reviews/**` に `.gitattributes` で `merge=union` を指定する。両側の追加行が両方残るため、行単位の競合が消える。

`union` は意味を見ないので、同じ番号の CLAIM が 2 行残る事故は起こりうる。それは `build-graph.py` の重複検査が落とすので、静かには壊れない。**競合を CI の失敗に置き換える**のがこの決定の狙いであり、競合をなくすことではない。

towncrier 方式（台帳を断片ファイルに分割し結合する）は採らない。台帳が 4 ファイルで収まっているうちは、1 ファイルを grep すれば全部わかる利点（[EVID-007](../evidence/007-ledger-is-index.md)）の方が大きい。頻度が上がったら再考する（OQ-024）。

### 3. ID の衝突 — 早期に見えるようにする

連番 ID は維持する。Rust RFC 方式（マージ時に採番）は、文書同士が ID で参照し合う本リポジトリでは `related` が解決できなくなるため採れない。

代わりに、`.github/scripts/check-id-collisions.sh` を追加し、**リモートの全ブランチを走査して、同じ ID を別のファイル名で使っているブランチがあれば報告する**。等級は警告とする（[ADR-013](013-check-grades.md) の基準 2 を満たさない。どちらのブランチが番号を譲るべきかは機械には決まらない）。

## 根拠

- [EVID-021](../evidence/021-shared-ledgers-and-serial-ids-collide.md): 実際の競合が 2 種類しかないこと、先行 3 事例の解き方
- [EVID-010](../evidence/010-handwritten-index-rots.md): 生成物は手で直さず再生成する
- [ADR-013](013-check-grades.md): 修正方法が一意でないものは警告に留める

## 結果・トレードオフ

- 利点: 台帳の行単位の競合が消え、残るのは意味の衝突だけになる
- 利点: ID の衝突が、マージするまで見えない状態から、PR の時点で見える状態になる
- 代償: `union` は重複行を作りうる。CI が落ちるので気づけるが、直すのは人間
- 代償: 全ブランチ走査はブランチ数に比例して遅くなる。数十本を超えたら対象を絞る必要がある
- 代償: `.gitattributes` の `merge=union` は Git の合流にしか効かない。GitHub 上での競合表示は変わるが、Web UI での解決経路までは保証しない

## 関連

- [PB-015](../playbook/015-resolve-conflicts.md) — 手順の正本
- [ADR-007](007-generated-index.md) / [ADR-012](012-review-attestations.md)
- [REV-006](../reviews/006-lifecycle-self-review.md)
