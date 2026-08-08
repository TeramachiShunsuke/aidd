---
id: EVID-004
title: 凍結は編集禁止であり改訂禁止ではない
status: frozen
last_reviewed: 2026-08-08
owners:
  - TeramachiShunsuke
tags:
  - frozen
  - immutability
related:
  - ADR-003
  - PB-004
---

## 主張

`frozen` は「もう考えない」ではなく「この版は契約として動かさない」。改訂は後継文書で行う。

## 観測

- 合意済みの境界・安全規則をその場編集すると、参照側の理解が断裂する。
- 不変オブジェクト＋新バージョン方式は、監査とロールバックが容易。
- CI でバイト差を拒否すると、意図しないフォーマット修正も防げる。

## 限界

誤字レベルの訂正を一律拒否するコストはある。必要なら人間が main で特例を記録し、reviews に残す。

## 関連

- [ADR-003](../adr/003-frozen-immutability.md)
- [PB-004](../playbook/004-freeze-document.md)
