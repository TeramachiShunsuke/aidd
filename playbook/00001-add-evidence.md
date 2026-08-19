---
id: PB-00001
title: evidence を追加する
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - evidence
related:
  - EVID-00001
  - ADR-00002
  - PB-00018
---

## いつ使うか

新しい観測・根拠を知識ベースに入れるとき。観測文が既にあるとき。

Slack / 議事録 / Confluence などソースが散らばっていて、下書きから起こすときは [PB-00018](00018-draft-evidence-from-sources.md) を先に使う。

## 手順

1. `evidence/` の最大番号を確認し、次の `NNN` を決める（番号は `--next EVID` に聞く）
2. `templates/evidence.md` を `evidence/NNN-short-slug.md` にコピー
3. Frontmatter を埋める（`status: draft` から開始してよい）
4. `## 主張` `## 観測` `## 限界` `## 関連` を書く
5. 主張を ledger に載せるなら `ledger/claims.md` に錨付きで追記
6. `last_reviewed` を今日（UTC）にする
7. PR を開き、staleness CI を通す

## 検証

- ID・ファイル名が CONVENTIONS に一致
- Frontmatter 必須キーが揃っている
- `bash .github/scripts/check-staleness.sh` がローカルで致命的な欠落を報告しない

## 失敗時

観測が不足なら `ledger/open-questions.md` に移し、evidence は作らないか `draft` のまま PR に「未検証」と明記する。

## 関連

- [templates/evidence.md](../templates/evidence.md)
- [CONVENTIONS.md](../CONVENTIONS.md)
- [PB-00018](00018-draft-evidence-from-sources.md)
