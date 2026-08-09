---
id: ADR-018
title: 番号は main を権威として確保し、衝突は PR の側が譲る
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - identifiers
  - process
  - ci
related:
  - EVID-023
  - EVID-021
  - ADR-013
  - ADR-017
tier: 2
---

## 文脈

ID の衝突が 2 回起きた（[REV-006](../reviews/006-lifecycle-self-review.md)）。[EVID-023](../evidence/023-id-allocation-is-a-concurrency-problem.md) のとおり、これは注意の問題ではなく、共有資源（番号）を調整なしに並行確保していることから出る構造的な問題で、チームで並行作業すれば同じ形で起きる。

対策の 4 系統のうち、スラッグ化は `frozen` 文書の不変性が塞ぎ、PR 番号の流用は 1 PR で複数文書を作る運用と噛み合わない。「マージ直前に CI が採番する」案は技術的には可能だが、GitHub にマージ時に内容を書き換える正規のフックがなく、レビュー済みの内容を承認後に書き換えることになり、[ADR-017](017-machines-record-facts-humans-decide-status.md) の線引きとも衝突する。

## 決定

連番は維持する。そのうえで、**採番の権威を main に置き、衝突の解決順序を規約で一意にする**。

### 1. 作業の既定は「main を base に 1 本ずつ」

PR の base は main とする。積み上げ PR（base を別の PR にする）は、親がマージされても子は main に届かないため、番号が確保されないまま長く滞留する。既定では使わない。

やむを得ず積み上げる場合は、親がマージされた直後に子の base を main へ付け替え、その時点で衝突を検査する。

### 2. 番号は main に対して確保する

新規文書の番号は、**main と、開いている全ブランチ**を見て空いているものを取る。次の番号は機械に聞く。

```bash
bash .github/scripts/check-id-collisions.sh --next EVID
```

### 3. 衝突は PR の側が譲る

| 相手 | 等級 | 譲る側 |
| --- | --- | --- |
| main が同じ ID を別ファイルで持っている | **error** | 必ず PR。main は過去を書き換えない |
| 未着地の他ブランチと衝突している | warning | 先に main へ着地した方が保持する |

main との衝突を error にできるのは、修正方法が一意だからである（[ADR-013](013-check-grades.md) の基準 2）。ブランチ同士の衝突はどちらが譲るべきかが機械に決まらないため警告に留める。ただし片方が着地した瞬間に、もう片方は error に変わる。**衝突は放置しても必ず表面化する**。

### 4. CI は検査だけを行う

採番も振り直しも機械には行わせない（[ADR-017](017-machines-record-facts-humans-decide-status.md)）。振り直しの手順は [PB-015](../playbook/015-resolve-conflicts.md) にある。

## 根拠

- [EVID-023](../evidence/023-id-allocation-is-a-concurrency-problem.md): 発生条件の 3 点、対策 4 系統の比較、main を権威にすれば片方が機械的に決まること
- [EVID-021](../evidence/021-shared-ledgers-and-serial-ids-collide.md): 連番が並行ブランチで衝突する先行事例（Rust RFC / PEP）
- [ADR-013](013-check-grades.md): 修正方法が一意なものだけを error にする基準

## 結果・トレードオフ

- 利点: 番号の確保に会議も台帳も要らない。main という既にある権威を使う
- 利点: 衝突が最長でも「相手が着地するまで」で必ず表面化し、静かに残らない
- 代償: 未着地の PR 同士の衝突は依然として人間が決める。並行度が上がれば振り直しの回数は増える
- 代償: `--next` は開いている全ブランチを走査するため、ブランチ数に比例して遅くなる
- 代償: 1 本ずつの直列運用は、大きな変更を分割しにくい。分割するなら文書の追加を含む PR を先に着地させ、それを参照する PR を後から出す

## 関連

- [PB-015](../playbook/015-resolve-conflicts.md) — 振り直しの手順
- [ADR-016](016-shrink-conflict-surface.md) — 競合面を減らす決定
- [REV-006](../reviews/006-lifecycle-self-review.md)
