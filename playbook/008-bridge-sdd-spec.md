---
id: PB-008
title: SDD の spec と知識ベースを橋渡しする
status: active
last_reviewed: 2026-08-13
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - sdd
related:
  - ADR-008
  - ADR-019
  - PB-001
  - PB-002
  - PB-017
tier: 2
---

## いつ使うか

実装リポジトリで spec（requirements / design / tasks）を書き始めるとき（方向 A）、または spec と実装が終わって知見を KB に戻すとき（方向 B）。

## 手順

### 方向 A: spec を書く前（KB → spec）

1. [INDEX.md](../INDEX.md) を開き、Tier 0 と Tier 1 を読む
2. 対象ドメインの `tags` で `adr/` を絞り、関係する決定を全文読む
3. requirements / design の冒頭に、前提にした KB 文書を ID で列挙する
4. KB の決定と矛盾する仕様が必要になったら、spec 側で決めきらず [ledger/open-questions.md](../ledger/open-questions.md) に `OQ-NNN` として論点を残す

### 方向 B: spec / 実装のあと（spec → KB）

1. [templates/sdd-handoff.md](../templates/sdd-handoff.md) を spec 側リポジトリにコピーして記入する
2. 各項目に「他プロジェクトでも同じ判断を繰り返すか？」を問い、**繰り返さないものは KB（kernel）に持ち込まない**。案件限りの決定は案件リポ側に置く（[ADR-019](../adr/019-kernel-and-project-layers.md)、[PB-017](017-apply-kernel-to-project.md)）
3. 繰り返すものを種別に振り分ける
   - 観測・計測結果 → [PB-001](001-add-evidence.md) で `evidence/`
   - 横断で再利用する決定 → [PB-002](002-write-adr.md) で `adr/`
   - 再現する手順 → `playbook/`（本テンプレートの手順欄を写す）
4. 取り込んだ文書に、spec への外部リンク（URL）と対象コミットを `## 関連` として書く。spec 本文は転記しない
5. 主張になるものは [ledger/claims.md](../ledger/claims.md) に錨付きで追記する
6. [PB-007](007-rebuild-index.md) で `INDEX.md` を再生成する

## 検証

- 取り込んだ文書に錨（evidence / adr / 外部 URL）が付いている
- 実装固有の識別子（内部 API 名・ファイルパス・スキーマ）が KB 側に混入していない
- `bash .github/scripts/check-staleness.sh` と `bash .github/scripts/build-index.sh --check` が PASSED

## 失敗時

昇格すべきか判断できない項目は、evidence にせず [ledger/open-questions.md](../ledger/open-questions.md) に「保留」として残す。矛盾する既存 ADR があり、かつそれが `frozen` の場合は改変せず、後継 ADR の要否を人間レビューに上げる（[AGENTS.md](../AGENTS.md) のエスカレーション）。

## 関連

- [ADR-008](../adr/008-sdd-bridge.md)
- [ADR-019](../adr/019-kernel-and-project-layers.md)
- [EVID-011](../evidence/011-spec-first-reduces-rework.md)
- [templates/sdd-handoff.md](../templates/sdd-handoff.md)
- [PB-017](017-apply-kernel-to-project.md)
