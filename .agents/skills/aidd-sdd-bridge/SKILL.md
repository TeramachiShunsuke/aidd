---
name: aidd-sdd-bridge
description: 仕様駆動開発（SDD）の spec — requirements / design / tasks — と AIDD 知識ベースを橋渡しする。spec を書く前に前提となる ADR や evidence を集めたいとき、または実装で得た知見を KB に昇格させたいときに使う。「仕様」「spec」「requirements」「設計を書く」「知見を KB に戻す」で発火する。
metadata:
  aidd-playbook: PB-008
  aidd-tier: "1"
---

# SDD と知識ベースを橋渡しする

## いつ使うか

- 実装リポジトリで spec を書き始めるとき（方向 A: KB → spec）
- spec や実装が終わり、知見を KB に戻すとき（方向 B: spec → KB）

## 先に読むもの

1. [ADR-008](../../../adr/008-sdd-bridge.md) — 対応表と境界
2. [PB-008](../../../playbook/008-bridge-sdd-spec.md) — 手順の正本
3. [templates/sdd-handoff.md](../../../templates/sdd-handoff.md) — 受け渡しシート

## 手順の要点

1. 方向 A: [INDEX.md](../../../INDEX.md) の Tier 0/1 を読み、関係する ADR を全文読んでから spec を書く。前提にした ID を spec 冒頭に列挙する
2. 方向 B: 受け渡しシートを記入し、各項目に「他プロジェクトでも同じ判断を繰り返すか？」を問う
3. Yes のものだけを evidence / adr / playbook に昇格し、外部リンクと対象コミットを `## 関連` に残す
4. 判断できないものは `ledger/open-questions.md` に保留として残す
5. `INDEX.md` を再生成する

## 禁止事項

- spec 本文を知識ベースに転記する（リンクと ID のみ）
- 実装固有の識別子（内部 API 名・ファイルパス・スキーマ）を KB 文書に持ち込む
- 手順の詳細をこのファイルに書き写す（正本は PB-008）
