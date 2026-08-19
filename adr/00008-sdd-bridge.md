---
id: ADR-00008
title: SDD の spec 成果物と知識ベースを、双方向の受け渡しで接続する
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - sdd
  - spec
  - integration
related:
  - EVID-00011
  - ADR-00001
  - ADR-00006
  - EVID-00001
  - EVID-00007
tier: 2
---

## 文脈

本リポジトリはアプリコードを持たない（[AGENTS.md](../AGENTS.md)）。仕様駆動開発（SDD）の成果物 — requirements / design / tasks — は実装リポジトリ側にある。接続規則がないと、[EVID-00011](../evidence/00011-spec-first-reduces-rework.md) が示す片道の失敗が起きる。spec 側が既存の決定を読まずに再発明し、実装中の観測が evidence に上がらない。

## 決定

知識ベースと spec を**別々の権威**として保ち、次の対応と方向で受け渡す。仕様本文を KB にコピーしない。

### 対応表

| SDD 成果物 | KB 側の対応 | 関係 |
| --- | --- | --- |
| requirements（何を満たすか） | `evidence/` / `ledger/claims.md` | requirements は KB の主張を**引用**する。逆に requirements の検証結果は evidence になりうる |
| design（どう作るか） | `adr/` | プロジェクト横断で再利用される決定のみ ADR に**昇格**する |
| tasks（どう進めるか） | `playbook/` | 繰り返し現れる手順のみ playbook に昇格する |
| spec レビュー記録 | `reviews/` | KB 文書を対象にしたレビューのみ記録する |

### 方向 A: KB → spec（読む側の規則）

1. spec を書き始める前に Tier 0 と Tier 1（[ADR-00006](00006-context-tiers.md)）を読む。
2. requirements / design で前提にした KB 文書を、ID で明記する（例: `根拠: ADR-00004, EVID-00003`）。
3. KB の決定と矛盾する仕様を書く場合は、spec 側で完結させず [ledger/open-questions.md](../ledger/open-questions.md) に論点を残す。

### 方向 B: spec → KB（書く側の規則）

1. 実装で得た観測のうち、**そのプロジェクト固有でないもの**だけを evidence にする。
2. 昇格の判断は「他のプロジェクトでも同じ判断を繰り返すか」で行う。繰り返さないなら KB に入れない。
3. 受け渡しは [templates/sdd-handoff.md](../templates/sdd-handoff.md) を spec 側にコピーして記入し、KB 側はその要約と外部リンクのみを取り込む。
4. 昇格した文書は claims に錨を付ける（[CONVENTIONS.md](../CONVENTIONS.md)）。

### 境界（KB に入れないもの）

- 特定リポジトリのファイル構成・API 名・スキーマなど、実装固有の詳細
- spec 本文そのもの（リンクと ID のみを持つ）
- 未確定の設計案（確定するまでは open-questions）

## 根拠

- [EVID-00011](../evidence/00011-spec-first-reduces-rework.md): 仕様の空白は推測で埋められる
- [EVID-00001](../evidence/00001-agents-need-evidence.md): 出力と根拠を分離する必要がある
- [EVID-00007](../evidence/00007-ledger-is-index.md): 台帳は索引であり本文の代替ではない

## 結果・トレードオフ

- 利点: spec 側の決定が KB に届く経路と、届かせない境界が明文化される
- 利点: KB がプロジェクト固有の詳細で膨らまない
- 代償: 昇格の判断が人間の裁量に残る（機械検査できない）。判断のぶれは [PB-00008](../playbook/00008-bridge-sdd-spec.md) の質問リストで抑える
- 代償: spec 側リポジトリにテンプレートを配布する運用が必要になる

## 関連

- [PB-00008](../playbook/00008-bridge-sdd-spec.md)
- [templates/sdd-handoff.md](../templates/sdd-handoff.md)
- [ADR-00006](00006-context-tiers.md)
