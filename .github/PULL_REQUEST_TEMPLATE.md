## 概要

<!-- 何をなぜ変えるか。1 段落。 -->

## 変更種別

- [ ] evidence
- [ ] adr
- [ ] playbook
- [ ] ledger
- [ ] reviews（追記のみ）
- [ ] templates / meta（README, AGENTS, CONVENTIONS, CI）

## 関連 ID

<!-- 例: EVID-003, ADR-004, PB-005, CLAIM-003, OQ-001 -->

-

## チェックリスト

- [ ] [CONVENTIONS.md](../CONVENTIONS.md) に適合している
- [ ] 本文を変えた文書の `last_reviewed` を今日（UTC）にした
- [ ] `status: frozen` の文書を改変していない（改訂は後継 ID）
- [ ] `reviews/` は末尾追記または新規追加のみ
- [ ] ledger（claims / open-questions / changelog）を必要なら同期した
- [ ] 秘密情報を含めていない

## 検証

```bash
bash .github/scripts/check-staleness.sh
```

- [ ] 上記がローカルまたは CI で PASSED
