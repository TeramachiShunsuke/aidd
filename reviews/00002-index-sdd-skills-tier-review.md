---
id: REV-00002
title: Tier / 生成インデックス / SDD 接続 / skills 導入レビュー
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - reviews
  - tier
  - index
  - sdd
  - skills
related:
  - ADR-00006
  - ADR-00007
  - ADR-00008
  - ADR-00009
---

# Tier / 生成インデックス / SDD 接続 / skills 導入レビュー

- 期間: 2026-08-09 — 2026-08-09
- 範囲: 基盤一式（[REV-00001](00001-bootstrap-design-review.md) で導入済み）への追加層。Tier マッピング、生成インデックス、SDD 接続、skills

## 2026-08-09

### 実施者

- Cursor Cloud Agent（追加層の設計と投入）
- owners: TeramachiShunsuke

### 追加した文書

- evidence: EVID-00009（文脈予算）/ EVID-00010（生成索引）/ EVID-00011（SDD）/ EVID-00012（skills の段階的開示）
- adr: ADR-00006（Tier）/ ADR-00007（生成インデックス）/ ADR-00008（SDD 接続）/ ADR-00009（skills）
- playbook: PB-00006（Tier 割り当て）/ PB-00007（索引再生成）/ PB-00008（SDD 橋渡し）/ PB-00009（skill 追加）
- templates: `skill.md` / `sdd-handoff.md`
- skills: `aidd-add-evidence` / `aidd-write-adr` / `aidd-review-cycle` / `aidd-rebuild-index` / `aidd-sdd-bridge`
- 生成物: `INDEX.md`、生成器 `.github/scripts/build-index.sh`、ワークフロー `.github/workflows/index.yml`

### 既存文書の扱い

- `status: frozen`（ADR-00001 / ADR-00002 / ADR-00003 / ADR-00005 / EVID-00004）は**一切改変していない**。Tier は既定規則で解決し、`tier` の後付けを禁止規則として明文化した
- `evidence/001..008` と `playbook/001..005` も未改変。`last_reviewed` は据え置き
- 更新したのは ledger 3 件（claims / open-questions / changelog、`last_reviewed` を 2026-08-09 に同期）と、CI 対象外のメタ（README / AGENTS / CONVENTIONS / PR テンプレート）

### 検証

- `bash .github/scripts/check-staleness.sh` — PASSED
- `bash .github/scripts/build-index.sh --check` — PASSED
- 内訳（生成時点）: Tier 0 = 2 / Tier 1 = 4 + skills 5 / Tier 2 = 18 / Tier 3 = 13

### 残した未決

- OQ-00004: Tier 0 / 1 の総量上限
- OQ-00005: `INDEX.md` を commit し続けるか
- OQ-00006: skills を他ツールのディレクトリへ複製するか
- OQ-00007: SDD の昇格判断の機械支援

### 備考

- ADR-00006..009 はいずれも `status: active`。運用で 1 サイクル回すまで frozen にしない
- 索引の Tier 判定は既定規則に強く依存する。ディレクトリを追加した場合は `build-index.sh` の `default_tier` と ADR-00006 を同時に直す必要がある

<!-- 以降は末尾にのみ追記すること。既存行の編集・削除は禁止。 -->
