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
- OQ-006: skills を `.cursor/skills/` 以外（`.agents/skills/` や `.claude/skills/`）へ複製するか？（複製すると二重管理、しないと他ツールで発火しない）
- OQ-007: SDD の「昇格するか」の判断を機械支援できるか？（現状は PB-008 の質問リストによる人間判断）
- OQ-008: `GRAPH.md` の警告（未使用の根拠・根拠なしの決定など）を、いつ CI エラーへ昇格させるか？（現状はすべて警告のまま）
- OQ-009: 意味グラフ（Graphify 等）を定期的に回して探索する運用を作るか？（現状は任意のローカル探索のみ。ADR-010）
- OQ-010: 構造グラフを `graph.json` としても出力し、外部ツール（Neo4j / Gephi / Obsidian）に渡せるようにするか？

## Resolved

- OQ-003: claims 錨のリンク切れを自動検知するか？ → **する**。`build-graph.py` が錨・`related`・文書間リンクの解決を検査し、CI を落とす（adr:ADR-010 evidence:EVID-014、2026-08-09）
