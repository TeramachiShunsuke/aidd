---
id: EVID-003
title: 文書ドリフトは静かな回帰である
status: active
last_reviewed: 2026-08-08
owners:
  - TeramachiShunsuke
tags:
  - staleness
  - quality
related:
  - ADR-004
  - EVID-005
---

## 主張

実装や方針が変わっても文書が残ると、エージェントは古い正解を自信を持って再生する。ドリフトはテスト赤より検知が遅い。

## 観測

- `last_updated` だけでは「確認した」ことが分からない。レビュー日 `last_reviewed` が必要。
- 90 日を超えて未レビューの手順書は、依存ツールのデフォルト変更を取り込み損ねやすい。
- CI で機械的に落とさない限り、鮮度作業は後回しにされる。

## 限界

「90 日」は初期ヒューリスティック。ドメインごとに短縮・延長してよいが、例外は ADR で宣言する。

## 関連

- [ADR-004](../adr/004-staleness-policy.md)
- [PB-005](../playbook/005-fix-staleness-ci.md)
