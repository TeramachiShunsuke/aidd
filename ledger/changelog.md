---
id: LEDGER-CHANGELOG
title: Knowledge base changelog
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - ledger
  - changelog
---

# Changelog

知識ベース自体の注目すべき変更。新しいエントリを上に追記する。

## 2026-08-09

- Tier モデルを導入: ADR-006 / EVID-009 / PB-006。Frontmatter の任意キー `tier` と既定規則（frozen 文書を書き換えずに導入）
- 生成インデックスを導入: ADR-007 / EVID-010 / PB-007。`INDEX.md` と `.github/scripts/build-index.sh`、Index ワークフロー
- SDD 接続を定義: ADR-008 / EVID-011 / PB-008 と `templates/sdd-handoff.md`（対応表・双方向の受け渡し・境界）
- skills を導入: ADR-009 / EVID-012 / PB-009 と `templates/skill.md`。`.cursor/skills/` に 5 件（PB-001 / PB-002 / PB-003 / PB-007 / PB-008 の入口）
- claims に CLAIM-009..012、open-questions に OQ-004..007 を追加
- README / AGENTS / CONVENTIONS / PR テンプレートを Tier・索引・skills・SDD に合わせて更新

## 2026-08-08

- 初回設計一式を追加: README / AGENTS / CONVENTIONS / evidence×8 / adr×5 / playbook×5 / ledger×3 / templates×4 / reviews×1 / staleness CI
- ADR-001/002/003/005 と EVID-004 を frozen として固定
