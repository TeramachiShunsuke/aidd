---
name: aidd-draft-evidence
description: Slack、Google Meet の議事録、Confluence、Issue など散らばった情報から evidence のドラフトを起こす。ユーザーが「エビデンスのドラフト」「議事録から根拠」「Slack を集約」「Confluence をまとめる」「観測点を AI に書かせる」と言ったときに使う。
metadata:
  aidd-playbook: PB-018
  aidd-tier: "1"
---

# 散在ソースから evidence の下書きを起こす

## いつ使うか

- 観測がチャット・議事録・Wiki に散らばっているとき
- 人が情報を揃えてから evidence を書く代わりに、下書きを起こさせたいとき

## 先に読むもの

1. [ADR-019](../../../adr/019-kernel-and-project-layers.md) — 下書きから入る流れ
2. [PB-018](../../../playbook/018-draft-evidence-from-sources.md) — 手順の正本
3. [templates/evidence-intake.md](../../../templates/evidence-intake.md) — ソース一覧

## 手順の要点

1. 人間がソース（URL / 日時）を渡し、秘密情報は渡さない
2. 引用可能な事実だけを抜き、出典付きで `status: draft` の evidence を書く
3. 矛盾は両方残す。推測で穴を埋めない
4. `active` への遷移は人間が観測を確認してから行う
5. 人が既に観測文を持っているなら PB-001 へ

## 禁止事項

- 出典のない文を `## 観測` に書く
- エージェントが `status` を `active` に上げる
- ソース全文を知識ベースに転記する
- 手順の詳細をこのファイルに書き写す（正本は PB-018）
