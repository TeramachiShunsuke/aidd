---
id: PB-009
title: skill を追加・更新する
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - skills
related:
  - ADR-009
  - PB-007
tier: 2
---

## いつ使うか

既存 playbook が「エージェントに見つけてもらえていない」とき。新しい playbook を追加し、その入口が必要なとき。

## 手順

1. 入口を付けたい playbook を 1 つ決める（**1 skill = 1 playbook**）
2. `.cursor/skills/<name>/` を作る。`<name>` は英小文字・数字・ハイフンのみ
3. [templates/skill.md](../templates/skill.md) を `.cursor/skills/<name>/SKILL.md` にコピーする
4. Frontmatter を埋める
   - `name`: フォルダ名と**完全一致**させる
   - `description`: 「何をするか」＋「いつ使うか」。ユーザーが実際に使う語（例: 「evidence を書く」「ADR」「レビュー」）を含める
   - `metadata.aidd-playbook`: 対応する playbook ID
   - `metadata.aidd-tier`: `"1"`
5. 本文を 4 節（`## いつ使うか` / `## 先に読むもの` / `## 手順の要点` / `## 禁止事項`）で書く。手順の要点は 5 行以内に収め、詳細は playbook にリンクする
6. 対応する playbook 側の `## 関連` に skill へのリンクを足し、`last_reviewed` を今日にする
7. [PB-007](007-rebuild-index.md) で `INDEX.md` を再生成する

## 検証

- `bash .github/scripts/build-index.sh --check` が PASSED（`name` とフォルダ名の一致、playbook 参照の存在を検査する）
- `SKILL.md` の Frontmatter が `name` / `description` / `metadata` のみ（標準外キーを足さない）
- 手順本文が playbook と重複していない

## 失敗時

- `skill name mismatch` → `name` を親フォルダ名に合わせる（フォルダ名を変えるなら `git mv`）
- `unknown playbook` → `metadata.aidd-playbook` の ID を実在する `playbook/NNN-*.md` に直す
- skill が発火しない → 手順を増やすのではなく `description` のトリガー語を具体化する（[EVID-012](../evidence/012-skills-are-progressive-disclosure.md)）

## 関連

- [ADR-009](../adr/009-skills-as-playbook-entrypoints.md)
- [templates/skill.md](../templates/skill.md)
- [Cursor: Agent Skills](https://cursor.com/docs/skills)
