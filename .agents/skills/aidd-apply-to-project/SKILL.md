---
name: aidd-apply-to-project
description: 新しいリポジトリやプロジェクトに AIDD の働き方を適用し、kernel の ADR を案件の考え方と混ぜない。ユーザーが「新しいリポジトリ」「プロジェクトに適用」「ワークフローの ADR と混ざる」「可読性」「既存の ADR を残す」と言ったときに使う。
metadata:
  aidd-playbook: PB-017
  aidd-tier: "1"
---

# 新しいリポジトリへ kernel を適用する

## いつ使うか

- 新しいプロジェクトにこれまでの考察を載せるとき
- 働き方の ADR と案件の考え方が同じ一覧に混ざり、読みにくいとき
- 既存 ADR を残すべきか、コピーすべきか迷うとき

## 先に読むもの

1. [ADR-019](../../../adr/019-kernel-and-project-layers.md) — 二層の権威
2. [PB-017](../../../playbook/017-apply-kernel-to-project.md) — 手順の正本
3. [ADR-008](../../../adr/008-sdd-bridge.md) — 昇格の境界

## 手順の要点

1. kernel（本リポジトリ）と project（案件リポ）を別権威として宣言する
2. kernel の ADR は残し、案件の `adr/` にはコピーしない
3. 案件 `AGENTS.md` に kernel の URL と「この adr/ は製品の決定だけ」を書く
4. 繰り返す判断だけ PB-008 で kernel へ戻す
5. 散在ソースから根拠を起こすときは PB-018 へ

## 禁止事項

- kernel の ADR / evidence を案件の同じ一覧にコピーして混ぜる
- 案件限りの決定を kernel の `adr/` に書く
- 手順の詳細をこのファイルに書き写す（正本は PB-017）
