---
id: REV-00004
title: ツール横断の可搬性レビュー
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - reviews
  - skills
  - portability
related:
  - ADR-00011
  - EVID-00015
  - ADR-00009
---

# ツール横断の可搬性レビュー

- 期間: 2026-08-09 — 2026-08-09
- 範囲: skill の置き場所と規範ファイルの配布（[ADR-00011](../adr/00011-cross-tool-agent-integration.md) の導入時点）

## きっかけ

skills 導入時（[ADR-00009](../adr/00009-skills-as-playbook-entrypoints.md)）は Cursor だけを前提に `.cursor/skills/` と決めていた。運用対象を Codex と Claude Code に広げるにあたり、[OQ-00006](../ledger/open-questions.md)（複製するか）を決着させる必要が生じた。

## 調べたこと

各ツールの公式ドキュメントで、プロジェクトスコープの skill 探索パスと規範ファイル名を確認した（[EVID-00015](../evidence/00015-agent-tools-read-different-paths.md)）。3 者が共通で読むディレクトリは存在しなかった。

- `.agents/skills/` — Codex ○ / Cursor ○ / Claude Code ×
- `.claude/skills/` — Codex × / Cursor ○ / Claude Code ○
- `AGENTS.md` — Codex ○ / Cursor ○ / Claude Code ×（`CLAUDE.md` のみ読む）

決め手は 2 つの公式記述だった。Claude Code は skill エントリが symlink であれば追従してリンク先の `SKILL.md` を読む。`AGENTS.md` については `CLAUDE.md` からの `@AGENTS.md` import が公式に推奨されている。どちらも「複製せずに橋を架ける」形が成立する。

## 決めたこと

正本は `.agents/skills/` と `AGENTS.md` の 2 か所のみ。Claude Code 向けには symlink（skill）と 1 行 import（規範）だけを置く。複製案は、`SKILL.md` が 2 か所に存在して片方だけ更新される事故が避けられないため採らなかった。

## 検証

- 6 件の skill を `git mv` で移設し、`.claude/skills/<name>` を相対 symlink として作成した
- `build-index.sh` に鏡の検査を追加し、鏡を消す・リンク先を書き換える・対応する正本のない鏡を置く、の 3 パターンで FAILED になることを確認した
- `git ls-files` 上で symlink が mode 120000 のエントリとして記録され、`SKILL.md` の二重カウントが起きないことを確認した
- グラフ・索引を再生成し、skill 6 件と playbook の対応が維持されていることを確認した

## 未検証のまま残ること

Codex と Claude Code の実機での読み込みは確認していない。手元で動かせたのは Cursor のみで、他 2 つは公式ドキュメントの記述に依拠した前提である（[OQ-00012](../ledger/open-questions.md)）。Windows で `core.symlinks` が無効な checkout では鏡が機能しない（[OQ-00011](../ledger/open-questions.md)）。いずれも実際に各ツールで動かした人が結果を evidence に足すべき箇所である。

## 併せて実施

利用者が ID 体系と文書間の関係をたどれるよう、[GUIDE.md](../GUIDE.md) を追加した。規範は [CONVENTIONS.md](../CONVENTIONS.md) に残し、GUIDE には案内（コード体系表・リレーション・判断表・ライフサイクル・実例）だけを置いて、規範値の二重管理が起きないようにした。
