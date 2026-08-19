---
name: aidd-add-evidence
description: AIDD 知識ベースに evidence（観測・根拠）を追加する。ユーザーが「evidence を書く」「観測を残す」「根拠を記録する」「EVID-NNNNN を作る」と言ったとき、または調査・計測の結果をリポジトリに残したいときに使う。
metadata:
  aidd-playbook: PB-00001
  aidd-tier: "1"
---

# evidence を追加する

## いつ使うか

- 新しい観測・計測・引用を知識ベースに残すとき
- 既存の主張に反する事実が見つかったとき
- 観測文が既にあるとき（Slack / 議事録 / Confluence から下書きを起こすときは [aidd-draft-evidence](../aidd-draft-evidence/SKILL.md)）

## 先に読むもの

1. [AGENTS.md](../../../AGENTS.md)
2. [CONVENTIONS.md](../../../CONVENTIONS.md)
3. [PB-00001](../../../playbook/00001-add-evidence.md) — 手順の正本

## 手順の要点

1. `evidence/` の最大番号 +1 を採り、[templates/evidence.md](../../../templates/evidence.md) をコピーする
2. `## 主張` / `## 観測` / `## 限界` / `## 関連` を埋め、`last_reviewed` を今日（UTC）にする
3. 主張を残すなら [ledger/claims.md](../../../ledger/claims.md) に錨付きで追記する
4. `bash .github/scripts/build-index.sh` で `INDEX.md` を再生成する
5. `bash .github/scripts/check-staleness.sh` を通す

## 禁止事項

- 観測がないまま断定的な `## 主張` を書く（不足なら `ledger/open-questions.md` へ）
- `status: frozen` の文書を改変する
- 手順の詳細をこのファイルに書き写す（正本は PB-00001）
