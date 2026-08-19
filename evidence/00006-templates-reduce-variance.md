---
id: EVID-00006
title: テンプレート欠落は形式ばらつきを増やす
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - templates
  - conventions
related:
  - ADR-00002
  - PB-00001
---

## 主張

Frontmatter キーや見出し構成が揃っていないと、検索・CI・エージェント読解が一気に脆くなる。雛形必須が最小コストの予防になる。

## 観測

- 自由記述のみの知識ベースでは、必須メタデータ欠落率が時間とともに上がる。
- 「コピーして埋める」手順は、説明文だけより遵守率が高い。
- CI は形式の最終防衛線であり、入口（templates）と二重化する。

## 限界

テンプレートが肥大すると逆にスキップされる。必須は薄く、推奨は CONVENTIONS に分離する。

## 関連

- [templates/](../templates/)
- [CONVENTIONS.md](../CONVENTIONS.md)
