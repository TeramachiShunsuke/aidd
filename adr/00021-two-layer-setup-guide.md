---
id: ADR-00021
title: 人の入口は二層の SETUP.md とし、考え方への全共感は成功条件にしない
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - onboarding
  - documentation
  - setup
  - tier
related:
  - EVID-00030
  - EVID-00002
  - EVID-00009
  - ADR-00006
  - ADR-00001
  - ADR-00008
tier: 2
---

## 文脈

エージェントの読み順は [ADR-00006](00006-context-tiers.md) で決まっている。人の始め方は決まっていない。入口は README の「使い方（最短）」と GUIDE の地図に分かれ、前者はエージェント向け、後者は ID の解説である。運用者はセットアップガイドを求め、考え方への共感は狙うが全員には届かないとした（[EVID-00030](../evidence/00030-human-entry-needs-two-layer-setup.md)）。

Tier 1 にルート文書を足すことは [OQ-00004](../ledger/open-questions.md) と [PB-00006](../playbook/00006-assign-tier.md) が ADR での合意を要求する。GUIDE と同じ「一覧のみ」の入口を 1 件足す。

## 決定

### 1. 人の入口は `SETUP.md`

リポジトリルートに [SETUP.md](../SETUP.md) を置く。役割は**始め方**である。規範は [AGENTS.md](../AGENTS.md) / [CONVENTIONS.md](../CONVENTIONS.md)、地図は [GUIDE.md](../GUIDE.md)、倉庫の説明と CI は [README.md](../README.md) に残す。3 ファイルへ手順をコピーしない。

### 2. 対象は二層。全共感は成功条件にしない

| 層 | できたと言える状態 |
| --- | --- |
| 最低限 | このワークフローの機能を、無駄な操作をせずに使える |
| 理解したら | より効率的に使え、このリポジトリを改善できる |

考え方や利用方法への共感は歓迎するが、層 1 の完了条件ではない。読めば動けることを優先する。

### 3. `SETUP.md` は Tier 1（一覧のみ）

エージェントは毎セッション、SETUP を全文読まない。INDEX の一覧に出し、人が「始め方」「セットアップ」と尋ねたとき、または [PB-00019](../playbook/00019-onboard-with-setup-guide.md) が発火したときに読む。既定規則に `SETUP.md` を加え、生成スクリプトとワークフローの監視パスに載せる。

### 4. 人は AGENTS.md から始めない

人が最初に読むのは SETUP の層 1 である。AGENTS.md はエージェントの規範であり、人のオンボーディング文書ではない。エージェントに作業を頼むときだけ、SETUP から AGENTS へ渡す。

### 5. 案件固有の始め方はここに書かない

製品リポジトリの clone 手順、IdP、PF の画面は kernel のセットアップに含めない。他プロジェクトでも繰り返す判断だけを書く（[ADR-00008](00008-sdd-bridge.md)）。案件への載せ方は、その案件の入口と既存 playbook に任せる。

## 根拠

- [EVID-00030](../evidence/00030-human-entry-needs-two-layer-setup.md): 現行入口は二層の人向けセットアップを担っていない。全共感は前提にできない
- [EVID-00002](../evidence/00002-context-is-not-memory.md): 入口を薄くし詳細を分ける
- [EVID-00009](../evidence/00009-context-budget-is-finite.md): 人にも常時ロード相当の束を渡すと劣化する

## 結果・トレードオフ

- 利点: 共感しない人でも、層 1 だけで観測 → 決定 → 手順 → PR に乗れる
- 利点: GUIDE / README / AGENTS の役割が割れない
- 代償: Tier 1 のルート文書が 1 件増える。SETUP を厚くすると GUIDE と同じ腐り方をする（値の正本は CONVENTIONS / ADR に残し、SETUP は道順だけにする）
- 代償: 層の境界は文章上の約束であり、読了を機械検査しない

## 関連

- [SETUP.md](../SETUP.md)
- [PB-00019](../playbook/00019-onboard-with-setup-guide.md)
- [GUIDE.md](../GUIDE.md)
- [README.md](../README.md)
