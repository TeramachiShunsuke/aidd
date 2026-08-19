---
name: aidd-write-adr
description: AIDD 知識ベースに ADR（アーキテクチャ・運用上の決定）を書く。ユーザーが「ADR を書く」「決定を残す」「設計判断を記録する」「ADR-NNNNN」と言ったとき、または方針を確定して後から参照できるようにしたいときに使う。
metadata:
  aidd-playbook: PB-00002
  aidd-tier: "1"
---

# ADR を書く

## いつ使うか

- 複数の選択肢から方針を 1 つに確定するとき
- 既存の決定を置き換える必要があるとき（後継 ADR を作る）

## 先に読むもの

1. [AGENTS.md](../../../AGENTS.md)
2. [CONVENTIONS.md](../../../CONVENTIONS.md)
3. [PB-00002](../../../playbook/00002-write-adr.md) — 手順の正本

## 手順の要点

1. 既存 `adr/` を検索し、同じ論点の決定がないか確認する
2. [templates/adr.md](../../../templates/adr.md) をコピーし、`## 文脈` / `## 決定` / `## 根拠` / `## 結果・トレードオフ` / `## 関連` を埋める
3. `## 根拠` は evidence の ID で錨を付ける（根拠なしの決定を書かない）
4. 既存の `frozen` な決定を変えたい場合は改変せず、後継 ADR を作り旧を `deprecated` にする
5. `INDEX.md` を再生成し、`check-staleness.sh` を通す

## 禁止事項

- `status: frozen` の ADR を編集する
- evidence の錨がない `## 根拠`
- 手順の詳細をこのファイルに書き写す（正本は PB-00002）
