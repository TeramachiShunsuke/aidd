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

- ライフサイクル矛盾を解消: ADR-012 / `ledger/attestations.md` / CLAIM-016 / REV-006。鮮度を実効レビュー日（`last_reviewed` と証跡の最新日の新しい方）で測るようにし、frozen 文書を改変せずレビューできるようにした。`reviews/**` と証跡台帳を追記専用ログとして期限・日付同期の対象外に変更。未来日拒否・証跡 ID 解決・週次 `schedule` を追加し、`check-staleness.sh` から GNU 依存（`date -d` / `mapfile`）を除去して macOS で動くようにした。OQ-013 を Resolved、OQ-014 を縮小
- 敵対レビューを取り込み: REV-005 / EVID-016。ライフサイクル矛盾（frozen×90 日鮮度×reviews 追記、2026-11-07 期限）と staleness CI の保証範囲・macOS 非対応を記録。OQ-013..017 を追加、OQ-012 に Codex / Claude Code の実機確認を追記。ライフサイクル再設計（ADR-012 候補）まで新規 frozen を凍結
- エージェント連携をツール横断化: ADR-011 / EVID-015。skill の正本を `.cursor/skills/` から `.agents/skills/` へ移し、`.claude/skills/` に symlink の鏡を作成。`CLAUDE.md` は `@AGENTS.md` の 1 行のみ。鏡の対応関係を Index CI が検査する
- 利用者向けに `GUIDE.md` を追加（ID コード体系・文書間リレーション・書き分け・ライフサイクル・実例）。Tier 1 に配置
- OQ-006（skills の複製）を Resolved へ移動。OQ-011..012 を追加、claims に CLAIM-015 を追加
- 参照グラフを導入: ADR-010 / EVID-013 / EVID-014 / PB-010。`GRAPH.md` と `.github/scripts/build-graph.py`、Graph ワークフロー、skill `aidd-graph-review`
- Graphify（意味グラフ）を評価し、CI には入れない判断を記録（EVID-013）。`graphify-out/` を `.gitignore` に追加
- OQ-003（claims 錨のリンク切れ自動検知）を Resolved へ移動。OQ-008..010 を追加、claims に CLAIM-013..014 を追加
- Tier モデルを導入: ADR-006 / EVID-009 / PB-006。Frontmatter の任意キー `tier` と既定規則（frozen 文書を書き換えずに導入）
- 生成インデックスを導入: ADR-007 / EVID-010 / PB-007。`INDEX.md` と `.github/scripts/build-index.sh`、Index ワークフロー
- SDD 接続を定義: ADR-008 / EVID-011 / PB-008 と `templates/sdd-handoff.md`（対応表・双方向の受け渡し・境界）
- skills を導入: ADR-009 / EVID-012 / PB-009 と `templates/skill.md`。skill 5 件（PB-001 / PB-002 / PB-003 / PB-007 / PB-008 の入口。置き場所は同日 ADR-011 で `.agents/skills/` に変更）
- claims に CLAIM-009..012、open-questions に OQ-004..007 を追加
- README / AGENTS / CONVENTIONS / PR テンプレートを Tier・索引・skills・SDD に合わせて更新

## 2026-08-08

- 初回設計一式を追加: README / AGENTS / CONVENTIONS / evidence×8 / adr×5 / playbook×5 / ledger×3 / templates×4 / reviews×1 / staleness CI
- ADR-001/002/003/005 と EVID-004 を frozen として固定
