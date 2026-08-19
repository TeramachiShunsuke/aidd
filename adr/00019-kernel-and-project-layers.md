---
id: ADR-00019
title: 働き方の kernel と案件の考え方を別権威にし、evidence は下書きから入る
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - adoption
  - workflow
  - evidence
related:
  - EVID-00024
  - EVID-00025
  - EVID-00001
  - EVID-00009
  - ADR-00008
  - ADR-00014
  - ADR-00017
  - ADR-00020
tier: 2
---

## 文脈

AIDD を新しいリポジトリへ適用するとき、既存の考察（働き方の ADR）は残したい。一方で、それを案件の考え方と同じ `adr/` にコピーすると、読み手が「どう働くか」と「この製品で何を選んだか」を区別できず、一覧の可読性が落ちる（[EVID-00024](../evidence/00024-kernel-and-project-adrs-mix-poorly.md)）。

[ADR-00008](00008-sdd-bridge.md) と [ADR-00014](00014-implementation-spec-split.md) は昇格の境界を決めたが、新しいリポジトリ側の置き場と、日々の根拠の入り方は決めていない。現行手順は人が観測を揃えてから evidence を書く前提であり、散在ソースの集約を入口にしていない（[EVID-00025](../evidence/00025-scattered-sources-suit-evidence-drafts.md)）。

## 決定

### 1. 二層の権威

| 層 | 権威 | 中身 | 置き場所 |
| --- | --- | --- | --- |
| **kernel** | 働き方 | 文書の種類、Tier、CI、横断で繰り返す判断と手順 | 本リポジトリ |
| **project** | 案件の考え方 | その製品・そのリリースの観測と決定、案件だけの手順 | 案件リポジトリ |

Kernel の ADR は捨てない。案件の `adr/` へコピーして混ぜない。案件側は kernel を URL（または同等の参照）で指し、必要なときだけ読む。

### 2. 案件リポに置くもの / 置かないもの

置く:

- その案件の `evidence/` / `adr/` / `playbook/` / `ledger/`（使う文書種別だけでもよい）
- 案件の `AGENTS.md`（kernel へのリンクと、「この `adr/` は製品の決定だけ」という一文）
- 任意で、品質ゲートをローカルに欲しいときの機械（`templates/`、CONVENTIONS、CI スクリプト）

置かない:

- kernel の ADR / evidence / reviews の本文コピー
- 働き方の説明を案件 ADR として書き直したもの

案件限りの ADR のディレクトリ名（トップレベル `adr/` か `specs/<feature>/adr/` か）は案件が決める。必須なのは **kernel の `adr/` に入れない**ことだけである。

### 3. 昇格は変えない

案件 → kernel の昇格条件は [ADR-00008](00008-sdd-bridge.md) のまま。「他プロジェクトでも同じ判断を繰り返すか」。繰り返さない決定は案件側に残す。

### 4. 根拠の入り口

日々の流れを次に固定する。

```text
散在ソース（Slack / 議事録 / Confluence / Issue 等）
  → エージェントが evidence を status: draft で起こす（出典必須）
  → 人間が観測を確認し、status を active にする
  → 決定が要れば案件 ADR
  → 繰り返す判断だけ kernel へ（PB-00008）
```

- エージェントが書いてよいのは `draft` まで。`active` / `frozen` への遷移は人間が行う（[ADR-00017](00017-machines-record-facts-humans-decide-status.md)）
- 観測の各箇条は出典（URL、日時、発言の引用）を持つ。出典のない文は主張にしない
- ソース全文を知識ベースに転記しない。引用とリンクだけを残す
- 秘密情報・個人データは取り込まない
- 人が最初から観測を書けるなら、下書き手順を通さず [PB-00001](../playbook/00001-add-evidence.md) でよい

### 5. 初期化スクリプトは作らない

owner・日付・ライセンスを書き換える cookiecutter は、この決定の範囲外とする。二層の参照規則があれば適用は手順で足りる。機械的な複製が必要になったら別途決める。

## 根拠

- [EVID-00024](../evidence/00024-kernel-and-project-adrs-mix-poorly.md): 働き方 ADR を残しつつ、案件 ADR と混ぜると読めなくなる
- [EVID-00025](../evidence/00025-scattered-sources-suit-evidence-drafts.md): 散在ソースの集約は下書きに向き、確定は観測の確認である
- [EVID-00009](../evidence/00009-context-budget-is-finite.md): 関係ない決定を案件の常時候補に入れると文脈を浪費する
- [EVID-00001](../evidence/00001-agents-need-evidence.md): 書けたことと根拠があることを分離する

## 結果・トレードオフ

- 利点: 案件の INDEX は製品の決定だけを並べられる。kernel の考察は残る
- 利点: 根拠の供給が「人が揃える」だけに閉じず、散在ソースから下書きを起こせる
- 利点: status の分界（[ADR-00017](00017-machines-record-facts-humans-decide-status.md)）を、intake にもそのまま使える
- 代償: 作業者は kernel と案件の 2 箇所を知る必要がある。案件 `AGENTS.md` のリンクが腐ると、働き方へ辿れない
- 代償: 下書きは幻覚を含みうる。`draft` のまま `active` 扱いすると、偽の観測が決定に乗る
- 代償: Slack / Meet へのコネクタは用意しない。ソース本文は人間が渡すか、案件側のツールに委ねる
- 代償: アカウント連携で得た原文を kernel に直接載せると、ソース側 ACL を越境する（[ADR-00020](00020-platform-is-a-client.md)）

## 関連

- [PB-00017](../playbook/00017-apply-kernel-to-project.md)
- [PB-00018](../playbook/00018-draft-evidence-from-sources.md)
- [ADR-00008](00008-sdd-bridge.md)
- [ADR-00014](00014-implementation-spec-split.md)
- [ADR-00017](00017-machines-record-facts-humans-decide-status.md)
- [ADR-00020](00020-platform-is-a-client.md)
