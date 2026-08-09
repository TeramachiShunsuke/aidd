---
id: EVID-011
title: 仕様を先に固定しないエージェント実装は手戻りする
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - sdd
  - spec
related:
  - EVID-001
  - ADR-008
tier: 3
---

## 主張

要件・設計・タスクを明示せずにエージェントへ実装を任せると、モデルは欠落を推測で埋め、後から仕様と食い違って手戻りする。仕様駆動開発（SDD）はこの推測を前倒しで潰す枠組みであり、知識ベースはその入力と出力の両方に接続する。

## 観測

- [EVID-001](001-agents-need-evidence.md) のとおり、エージェントは根拠が薄くても断定的に進む。仕様の空白は「質問」ではなく「補完」として消費される。
- SDD 系のワークフロー（requirements → design → tasks → implementation）は、実装前に各段の合意を人間が確定させる点が共通している。段の境界がレビュー点になるため、補完が混入した箇所を実装前に発見できる。
- 本リポジトリはアプリコードを持たない（[AGENTS.md](../AGENTS.md)）。したがって spec 成果物は実装リポジトリ側に置かれ、知識ベースとは別リポジトリに分散する。接続を明示しないと、spec 側の決定が KB に届かず、KB 側の決定が spec に読まれない。
- 実際に観測される片道の失敗は 2 種類ある。(1) spec を書くときに既存 ADR を読まず、決定済みの論点を再発明する。(2) 実装中に得た観測が spec のコメントに埋もれ、evidence に昇格しない。

## 限界

SDD の効果を定量比較した実験は本リポジトリでは行っていない。また、どの粒度の仕様まで KB に引き上げるべきか（プロジェクト固有か横断か）の線引きは運用で調整する必要がある。

## 関連

- [ADR-008](../adr/008-sdd-bridge.md)
- [PB-008](../playbook/008-bridge-sdd-spec.md)
- [templates/sdd-handoff.md](../templates/sdd-handoff.md)
