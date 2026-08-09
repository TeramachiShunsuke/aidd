---
id: LEDGER-OQ
title: Open questions
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - ledger
  - open-questions
---

# Open questions

未決のみを置く。解決したら changelog に一行残して削除するか、末尾の Resolved へ移す。

## Open

- OQ-001: 90 日の鮮度窓をドメイン別に短縮する必要があるか？（初期は一律 90）
- OQ-002: frozen → deprecated 遷移を CI 例外としてどう安全に扱うか？（現状は owners 承認の明示 PR）
- OQ-004: Tier 0 / Tier 1 の総量に上限（行数またはトークン）を設けるか？（現状は上限なし。増やすときは ADR で合意）
- OQ-005: 生成物 `INDEX.md` をリポジトリに置き続けるか、CI 生成に切り替えるか？（現状は差分レビュー可能性を優先して commit する）
- OQ-007: SDD の「昇格するか」の判断を機械支援できるか？（現状は PB-008 の質問リストによる人間判断）
- OQ-008: `GRAPH.md` の警告（未使用の根拠・根拠なしの決定など）を、いつ CI エラーへ昇格させるか？（現状はすべて警告のまま）
- OQ-009: 意味グラフ（Graphify 等）を定期的に回して探索する運用を作るか？（現状は任意のローカル探索のみ。ADR-010）
- OQ-010: 構造グラフを `graph.json` としても出力し、外部ツール（Neo4j / Gephi / Obsidian）に渡せるようにするか？
- OQ-011: Windows で `core.symlinks` が無効な checkout では `.claude/skills/` の鏡がテキストファイルになる。Claude Code 側の `/import` に任せるか、複製へ切り替えるか？（現状は symlink 前提。adr:ADR-011）
- OQ-012: Codex / Claude Code での実動作を CI か手順で検証する手段を持つか？（現状は公式ドキュメント準拠の未検証前提。evidence:EVID-015）

## Resolved

- OQ-003: claims 錨のリンク切れを自動検知するか？ → **する**。`build-graph.py` が錨・`related`・文書間リンクの解決を検査し、CI を落とす（adr:ADR-010 evidence:EVID-014、2026-08-09）
- OQ-006: skills を `.cursor/skills/` 以外へ複製するか？ → **複製しない**。正本を `.agents/skills/`（Codex / Cursor が読む）に置き、Claude Code 用に `.claude/skills/<name>` の symlink だけを作る。対応関係は CI が検査する（adr:ADR-011 evidence:EVID-015、2026-08-09）
