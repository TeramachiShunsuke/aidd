---
name: <folder-name>
description: <何をするか>。<いつ使うか: ユーザーが言いそうな語を並べる>。
metadata:
  aidd-playbook: PB-NNN
  aidd-tier: "1"
---

<!--
コピー先は .agents/skills/<name>/SKILL.md（Claude Code 用に .claude/skills/<name> の symlink も作る）。
本文中の相対リンクはコピー先を基準にしているため、
この雛形の位置（templates/）からは解決しない。手順は PB-009 を参照。
-->

# <スキル名>

## いつ使うか

- （トリガー。description と重複してよい）

## 先に読むもの

1. [AGENTS.md](../../../AGENTS.md)
2. [CONVENTIONS.md](../../../CONVENTIONS.md)
3. [PB-NNN](../../../playbook/NNN-slug.md) — 手順の正本

## 手順の要点

<!-- 5 行以内。詳細は playbook 側に置き、ここには書き写さない。 -->

1. …
2. …

## 禁止事項

- `status: frozen` の文書を改変する
- `reviews/` の既存行を書き換える
- 手順の詳細をこのファイルに書き写す（正本は playbook）
