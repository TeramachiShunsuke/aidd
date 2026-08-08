---
id: PB-002
title: ADR を書く
status: active
last_reviewed: 2026-08-08
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - adr
related:
  - ADR-001
  - EVID-007
---

## いつ使うか

方針・構造・ツール・運用ルールなど、後から「なぜ？」と問われる決定をするとき。

## 手順

1. 関連 evidence を先に読む。無ければ PB-001 で作るか open-questions に書く
2. `templates/adr.md` をコピーし次番号のファイルを作る
3. 文脈・決定・根拠・トレードオフを短く書く（決定は箇条書きで可）
4. 安定契約になったら別 PR で `frozen` を検討（PB-004）
5. `ledger/claims.md` と `ledger/changelog.md` を必要に応じ更新
6. PR テンプレの関連 ID を埋める

## 検証

- 決定文だけ読んでも行動できる
- 根拠が evidence ID または外部錨を持つ
- Frontmatter と `last_reviewed` が妥当

## 失敗時

選択肢が収束しない場合は ADR を無理に閉じず、open-questions に残して人間にエスカレーションする。

## 関連

- [templates/adr.md](../templates/adr.md)
- [PB-004](004-freeze-document.md)
