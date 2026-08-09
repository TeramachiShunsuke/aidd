---
id: EVID-021
title: 共有台帳と連番 ID は並行ブランチで必ず衝突し、先行事例は競合面そのものを消している
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - conflicts
  - ledger
  - identifiers
  - tooling
related:
  - EVID-010
  - EVID-016
  - REV-006
tier: 3
---

## 主張

このリポジトリで実際に起きた競合は、すべて「1 つのファイルに全員が追記する」構造と「ブランチ内で連番を先に確定する」採番から出ている。どちらも既知の問題で、先行事例は競合の解決を上手くするのではなく、**競合が起きる面そのものを消す**方向で解いている。

## 観測

### 実際に起きた競合（2026-08-09）

PR #7 / #9 を main へ着地させる作業（[REV-006](../reviews/006-lifecycle-self-review.md)）で、`git merge` が競合したのは 5 ファイルだけで、内訳は 2 種類しかなかった。

| ファイル | 種類 | 性質 |
| --- | --- | --- |
| `ledger/claims.md` / `ledger/open-questions.md` / `ledger/changelog.md` | 共有台帳 | 両ブランチが末尾または同じ節に行を足した |
| `INDEX.md` / `GRAPH.md` | 生成物 | 内容の競合ではなく、再生成すれば消える |

evidence / adr / playbook の本文は 1 件も競合しなかった。文書ごとにファイルが分かれているためである。つまり競合は文書の書き方ではなく、**台帳という共有ファイルの形**から出ている。

さらに、競合として現れなかった、より厄介な衝突があった。両ブランチが `EVID-016` と `ADR-012` を**別々のファイル名で**使っていたため、Git は競合を報告しない。マージは成功し、ID の重複だけが残る。`build-index.sh` の重複検査は同じブランチに両方が存在して初めて働くので、マージするまで誰も気づけなかった。

### 先行事例 1: 台帳を断片ファイルに分ける

[towncrier](https://github.com/twisted/towncrier)（Twisted / Python 界隈）と Changesets（JavaScript 界隈）は、変更履歴を 1 つの `CHANGELOG` に直接書かせない。PR ごとに `newsfragments/<issue-id>.<type>` という**小さなファイルを 1 つ足す**だけにし、リリース時にまとめて結合する。towncrier の説明は「1 つのファイルを全開発者が編集して競合を生む代わりに」と、動機を競合回避に置いている。`towncrier check` は「この PR は断片を足したか」を CI で検査する。

### 先行事例 2: 採番をマージ時まで遅らせる

[Rust RFC](https://github.com/rust-lang/rfcs) は、投稿時のファイル名を `0000-my-feature.md` にして**番号を割り当てない**。受理時にメンテナが次の連番を振り、ファイル名を変えてマージする。Python PEP も編集者が採番する。Rust の議論では PR 番号をそのまま使う案も出ており、実際に採用している派生プロジェクトもある。共通しているのは、**採番の権限を 1 か所に集めるか、もともと一意な番号（PR 番号）を借りる**という発想で、ブランチ内で先に番号を決めることを避けている。

### 先行事例 3: Git 側の合流方法を指定する

Git には `.gitattributes` で指定できる組み込みの `union` マージドライバがある。両側の追加行を両方残す。行の順序と重複は保証されないが、追記専用の一覧では「両方残す」が正しい既定になる。カスタムのマージドライバと違い、`union` は組み込みなので各開発者のローカル設定を必要としない。

## 限界

- `union` は行を両方残すだけで、意味を見ない。同じ番号の CLAIM が 2 行残る事故は防げない。ただしその状態は `build-graph.py` の重複検査が落とすので、静かに壊れることはない
- towncrier 方式に寄せると、台帳を読むのに結合が必要になり、「1 ファイルを grep すれば全部わかる」という [EVID-007](007-ledger-is-index.md) の利点が薄れる。断片化するかどうかは、競合の頻度と読みやすさの取引になる
- 採番をマージ時に遅らせる方式は、文書同士が ID で参照し合う本リポジトリではそのまま使えない。`ADR-0000` を参照する `related` は解決できず、マージ時に全参照を書き換える必要がある
- ここで挙げた 3 例はいずれも公開情報の読解であり、本リポジトリで試した結果ではない

## 関連

- [EVID-010](010-handwritten-index-rots.md) — 生成物は手で直さず再生成する
- [EVID-016](016-lifecycle-rules-deadlock.md) — 規則の組み合わせが運用不能を作る同型の問題
- [REV-006](../reviews/006-lifecycle-self-review.md) — 競合と ID 衝突が実際に起きた記録
- [towncrier](https://github.com/twisted/towncrier) / [Rust RFC](https://github.com/rust-lang/rfcs)
