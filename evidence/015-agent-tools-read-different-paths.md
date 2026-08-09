---
id: EVID-015
title: エージェントツールごとに skill と規範ファイルの探索パスが違う
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - skills
  - agents
  - portability
related:
  - EVID-012
  - ADR-011
tier: 3
---

## 主張

Cursor / Codex / Claude Code は同じ `SKILL.md` 形式を読むが、**探索するディレクトリと規範ファイル名が一致しない**。3 者が共通で読む単一のパスは存在しないため、正本を 1 か所に置き、読まないツールにだけ橋を架ける必要がある。

## 観測

2026-08-09 時点の各公式ドキュメント。

| ツール | プロジェクトの skill | 規範ファイル |
| --- | --- | --- |
| Codex | `$REPO_ROOT/.agents/skills`（CWD から repo root まで走査） | `AGENTS.md`（repo root と各サブディレクトリ） |
| Cursor | `.agents/skills/` と `.cursor/skills/`。互換で `.claude/skills/` `.codex/skills/` も読む | `AGENTS.md`（project root とサブディレクトリ）または `.cursor/rules/*.mdc` |
| Claude Code | `.claude/skills/` のみ | `CLAUDE.md` のみ |

- [Codex: Build skills](https://developers.openai.com/codex/skills) は skill scope の表で `REPO` を `$CWD/.agents/skills` と `$REPO_ROOT/.agents/skills`、`USER` を `$HOME/.agents/skills` と定義する。「Codex supports symlinked skill folders and follows the symlink target when scanning these locations.」とも記載する。
- [Cursor: Agent Skills](https://cursor.com/docs/skills) は `.agents/skills/` と `.cursor/skills/` をプロジェクトスコープとして挙げ、「For compatibility, Cursor also loads skills from Claude and Codex directories: `.claude/skills/`, `.codex/skills/`…」と続ける。
- [Cursor: Rules](https://cursor.com/docs/context/rules) は「Cursor supports AGENTS.md in the project root and subdirectories.」と明記する。
- [Claude Code: Skills](https://code.claude.com/docs/en/skills) のスコープ表はプロジェクトを `.claude/skills/<name>/SKILL.md` のみとし、`.agents/skills/` を挙げない。ただし「A `<skill>` entry in the enterprise, personal, or project locations **can be a symlink** to a directory elsewhere on disk. Claude Code follows the symlink and reads `SKILL.md` from the target directory」と記載する。
- [Claude Code: CLAUDE.md](https://code.claude.com/docs/en/claude-md) は「Claude Code reads `CLAUDE.md`, not `AGENTS.md`.」と述べ、既に `AGENTS.md` を持つリポジトリには `@AGENTS.md` の 1 行 import を推奨する。symlink でも動くが「On Windows, creating a symlink requires Administrator privileges or Developer Mode, so use the `@AGENTS.md` import instead」と注意している。
- 3 者の交差を取ると、skill の共通パスは**存在しない**。`.agents/skills/` は Codex と Cursor が読み、Claude Code は読まない。`.claude/skills/` は Claude Code と Cursor が読み、Codex は読まない。

## 限界

本リポジトリで実機検証したのは Cursor 上の動作のみで、Codex と Claude Code での読み込みは公式ドキュメントの記述に基づく未検証の前提である。特に「`.claude/skills/<name>` をディレクトリへの symlink にしたとき Claude Code が実際に読むか」は未確認で、Windows で `core.symlinks` が無効な checkout では symlink がテキストファイルとして展開されるため機能しない。Gemini CLI など他ツールの探索パスは調べていない。

## 関連

- [ADR-011](../adr/011-cross-tool-agent-integration.md)
- [EVID-012](012-skills-are-progressive-disclosure.md)
- [ADR-009](../adr/009-skills-as-playbook-entrypoints.md)
