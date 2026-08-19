---
id: ADR-00011
title: skills と規範をツール横断にし、正本を 1 か所に置く
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - skills
  - agents
  - portability
related:
  - EVID-00015
  - ADR-00009
  - ADR-00006
  - EVID-00009
  - EVID-00012
tier: 2
---

## 文脈

[ADR-00009](00009-skills-as-playbook-entrypoints.md) は skill の置き場所を `.cursor/skills/` と決めたが、これは Cursor だけを前提にしていた。実際の運用では Codex と Claude Code も同じ知識ベースを使う。[EVID-00015](../evidence/00015-agent-tools-read-different-paths.md) のとおり 3 者が共通で読む skill ディレクトリは存在せず、規範ファイル名も割れている。

## 決定

**正本は 1 か所**に置き、それを読まないツールにだけ橋を架ける。ツールごとに内容を複製しない。

### skills

| 役割 | パス | 読むツール |
| --- | --- | --- |
| 正本 | `.agents/skills/<name>/SKILL.md` | Codex / Cursor |
| 鏡 | `.claude/skills/<name>` → `../../.agents/skills/<name>` の symlink | Claude Code / Cursor |

- `.cursor/skills/` は使わない。Cursor は `.agents/skills/` を読むため不要
- 鏡は**必ず symlink**とし、ファイルを複製しない。中身の正本は常に `.agents/skills/`
- CI が「正本 1 件につき鏡 1 件、リンク先が正しい」ことと「対応する正本のない鏡がない」ことを検査する

### 規範ファイル

| 役割 | パス | 読むツール |
| --- | --- | --- |
| 正本 | `AGENTS.md` | Codex / Cursor |
| 橋 | `CLAUDE.md`（`@AGENTS.md` の 1 行のみ） | Claude Code |

- `CLAUDE.md` に規範を書かない。import 1 行だけを置く。Claude 固有の指示が必要になったら import の下に追記する
- symlink ではなく import 行を使う。Windows で symlink 作成に管理者権限が要るため（公式も import を推奨）
- `.cursor/rules/*.mdc` に規範を複製しない。`alwaysApply: true` のルールは [ADR-00006](00006-context-tiers.md) の Tier 0 を無断で消費する

### 変更しないこと

[ADR-00009](00009-skills-as-playbook-entrypoints.md) の他の規則は有効なまま。1 skill = 1 playbook、Frontmatter は Agent Skills 標準（`name` / `description` / `metadata`）のみ、本文は 4 節固定。置き場所の規則だけを本 ADR が置き換える。

## 根拠

- [EVID-00015](../evidence/00015-agent-tools-read-different-paths.md): 3 者の探索パスに共通集合がなく、Claude Code は symlink された skill エントリを追従すると公式に記載がある
- [EVID-00012](../evidence/00012-skills-are-progressive-disclosure.md): 標準キーだけを使えば実装差分の影響を抑えられる
- [EVID-00009](../evidence/00009-context-budget-is-finite.md): 常時適用のルールファイルは文脈予算を圧迫する

## 結果・トレードオフ

- 利点: skill の中身が 1 か所にしかなく、ツールを増やしても複製が生まれない
- 利点: 規範も `AGENTS.md` 単一で、Claude Code だけが 1 行の橋を通る
- 代償: symlink に依存する。Windows で `core.symlinks` が無効な checkout では鏡がテキストファイルになり Claude Code から読めない。回避は `/import` かローカルでの手動コピー（[OQ-00011](../ledger/open-questions.md)）
- 代償: Codex と Claude Code での実動作は未検証で、公式ドキュメントの記述を前提にしている（[EVID-00015](../evidence/00015-agent-tools-read-different-paths.md) の限界）
- 代償: リポジトリ直下のドット付きディレクトリが `.agents` `.claude` `.github` の 3 つになる

## 関連

- [PB-00009](../playbook/00009-add-skill.md)
- [GUIDE.md](../GUIDE.md)
- [Claude Code: CLAUDE.md](https://code.claude.com/docs/en/claude-md)
