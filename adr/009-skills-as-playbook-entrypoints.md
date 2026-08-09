---
id: ADR-009
title: skills は playbook の入口とし、手順を二重に持たない
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - skills
  - agents
related:
  - EVID-012
  - ADR-006
  - ADR-007
tier: 2
---

## 文脈

playbook は手順の正本だが、エージェントは「どの playbook を使うべきか」を自分で見つけなければならない。Agent Skills は `description` の一致で本文をロードする仕組みを持ち（[EVID-012](../evidence/012-skills-are-progressive-disclosure.md)）、この発見問題をちょうど埋める。ただし SKILL.md に手順を書き写すと、playbook と skill の二重管理になる。

## 決定

1. skill は **`.cursor/skills/<name>/SKILL.md`** に置く。プロジェクト単位で自動ロードされ、バージョン管理下に入るため。
2. **1 skill = 1 playbook**。SKILL.md は手順を再定義せず、対応する playbook を読ませることを主目的とする。手順の正本は常に `playbook/`。
3. Frontmatter は Agent Skills 標準の範囲に限る。`name`（親フォルダ名と一致）と `description` を必須とし、任意キーは `metadata` のみ使う。
   - `metadata.aidd-playbook`: 対応する playbook ID（例: `PB-001`）
   - `metadata.aidd-tier`: 常に `"1"`（skills は Tier 1）
4. `description` には「何をするか」と「いつ使うか」の両方を書く。起動時に読まれるのはこの行だけである。
5. SKILL.md 本文は次の 4 節に固定する。`## いつ使うか` / `## 先に読むもの` / `## 手順の要点` / `## 禁止事項`。手順の要点は 5 行以内の要約に留め、詳細は playbook へのリンクにする。
6. CI（[ADR-007](007-generated-index.md)）が `name` とフォルダ名の一致、および `metadata.aidd-playbook` の参照先の存在を検査する。

## 根拠

- [EVID-012](../evidence/012-skills-are-progressive-disclosure.md): 起動時コストは description のみ、本文は一致後にロードされる
- [EVID-006](../evidence/006-templates-reduce-variance.md): 構造を固定すると出力の分散が下がる
- [EVID-009](../evidence/009-context-budget-is-finite.md): 常時ロードを増やさずに発見性だけを足す必要がある

## 結果・トレードオフ

- 利点: 手順の正本が 1 か所（playbook）に残り、skill は薄い入口に留まる
- 利点: 標準キーのみ使うため、`.claude/skills/` などへ複製しても壊れにくい
- 代償: skill と playbook の 2 ファイルを同時に更新する場面がある（CI が参照切れのみ検出する）
- 代償: `.cursor/` 配下に置くため、他ツールでは複製またはシンボリックリンクが必要になる（[OQ-006](../ledger/open-questions.md)）

## 関連

- [PB-009](../playbook/009-add-skill.md)
- [templates/skill.md](../templates/skill.md)
- [Cursor: Agent Skills](https://cursor.com/docs/skills)
