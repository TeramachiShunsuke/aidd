---
id: EVID-00012
title: skills は description だけを常時ロードする段階的開示である
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - skills
  - context
related:
  - EVID-00009
  - ADR-00009
tier: 3
---

## 主張

Agent Skills は「手順書を常に読ませる」仕組みではなく、`description` だけを起動時に読み、一致したときに本文を読む段階的開示の仕組みである。したがって skills は playbook の置き換えではなく、playbook への**入口**として設計するのが正しい。

## 観測

- [Cursor: Agent Skills](https://cursor.com/docs/skills) は、スキルを `SKILL.md` を含むフォルダとして定義し、`.agents/skills/` `.cursor/skills/`（プロジェクト）と `~/.agents/skills/` `~/.cursor/skills/`（ユーザー）から自動ロードすると記載している。互換として `.claude/skills/` `.codex/skills/` も読む。
- Frontmatter の必須キーは `name`（親フォルダ名と一致、英小文字・数字・ハイフン）と `description`（エージェントが関連性を判断する記述）。任意キーは `paths` / `disable-model-invocation` / `metadata`（任意のキー値マップ）。
- [Agent Skills の仕様](https://agentskills.io/specification)も必須キーを `name` / `description` とし、任意キーとして `license` / `compatibility` / `metadata` / `allowed-tools` を挙げる。仕様外のキーを足すと検証器が弾く実装がある。
- ロードは段階的で、起動時はメタデータのみ、一致時に `SKILL.md` 本文、実行時に `references/` や `scripts/` の出力が入る。つまり「本文に何でも書く」ほど起動時コストは増えないが、一致後のコストは増える。
- 起動時に効くのは `description` の具体性であり、H1 見出しやファイル名ではない。トリガーとなる語（何をするか・いつ使うか）を description 側に書く必要がある。

## 限界

上記は 2026-08-09 時点の公開ドキュメントの記述に基づく。ロードの実装詳細やキーのサポート範囲はツールと版で変わりうる。本リポジトリでは「必須 2 キー + `metadata`」という最小交差のみに依存して、実装差分の影響を抑える。

## 関連

- [ADR-00009](../adr/00009-skills-as-playbook-entrypoints.md)
- [PB-00009](../playbook/00009-add-skill.md)
- [EVID-00009](00009-context-budget-is-finite.md)
