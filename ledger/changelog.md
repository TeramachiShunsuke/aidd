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

- 大規模マルチ機能リリースの適用イメージを追加: PB-016。権限管理・棚卸・ユーザーグループ・中間サーバーを例に、KB / 案件リポ / Figma / 契約 / テストの置き場を図にした。UI デザイン専用 ADR の要否を OQ-028 に残し、GUIDE の判断表へ行を追加
- 採番の権威を main に置いた: ADR-018 / EVID-023 / CLAIM-023。`check-id-collisions.sh` に `--next <PREFIX>`（main と全ブランチを走査して空き番号を返す）を追加し、base ブランチとの衝突を error、未着地ブランチ同士を warning に等級分けした。ファイル名変更を衝突と誤検出しないよう merge-base で判定する。PR の base は main を既定とし、積み上げ PR を禁止した（AGENTS / CONVENTIONS / PB-015）
- 競合面を減らす: ADR-016 / EVID-021 / PB-015 / skill `aidd-resolve-conflict`。`.gitattributes` で `ledger/*.md` と `reviews/*.md` を `merge=union` にし、生成物は再生成で解決すると決めた。`check-id-collisions.sh` が他ブランチとの ID 衝突を警告する（Index CI）。`merge=union` が残しうる Frontmatter キーの二重定義を error として検出する
- 機械と人間の分界を定義: ADR-017 / EVID-022 / CLAIM-021..022。CI は事実の記録・不整合の検出・前提条件の検査に限り、`status` の遷移と証跡の代筆はしない。`draft` の 30 日滞留を鮮度検査の警告として追加（生成物に日付依存の行を入れないため `GRAPH.md` には出さない）。OQ-024（台帳の断片化）と OQ-025（指紋方式）を追加
- 実装スペックの扱いを定義: ADR-014 / EVID-018 / EVID-019 / PB-012 / PB-013。契約・決定・振る舞いに分割し、文書に残すのは共有境界・不可逆・選択肢ありの決定だけとした
- DB / インフラの文脈を定義: ADR-015 / EVID-020 / PB-014。制約・契約・状態の 3 層に分け、状態は文書化せず取得コマンドで渡す
- skill 3 件（aidd-spec-triage / aidd-tdd-start / aidd-infra-context）と `templates/acceptance-examples.md` を追加
- 検査を等級分け: ADR-013 / EVID-017 / PB-011。決定の系譜（`## 根拠` と `related` の突き合わせ）・evidence 錨の必須化・deprecated 参照・`superseded_by` の一貫性を CI エラーへ昇格
- 昇格で検出したズレを修正: ADR-006/007/008/009/010/011 の `related` に、本文で根拠に挙げていた evidence を追加（計 11 辺）
- `build-graph.py --impact <ID>` を追加し、変更の波及先を照会できるようにした
- OQ-008 を Resolved へ移動。OQ-020..023 を追加、claims に CLAIM-017..020 を追加。PR #7 / #9 が main に届いていなかったため、EVID / ADR / CLAIM / OQ の番号を採番し直して着地させた（REV-006）
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
