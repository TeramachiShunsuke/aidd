## 概要

<!-- 何をなぜ変えるか。1 段落。 -->

## 変更種別

- [ ] evidence
- [ ] adr
- [ ] playbook
- [ ] ledger
- [ ] reviews（追記のみ）
- [ ] skills（`.agents/skills/`）
- [ ] templates / meta（README, AGENTS, CONVENTIONS, CI）

## 関連 ID

<!-- 例: EVID-00003, ADR-00004, PB-00005, CLAIM-00003, OQ-00001 -->

-

## チェックリスト

- [ ] [CONVENTIONS.md](../CONVENTIONS.md) に適合している
- [ ] 本文を変えた文書の `last_reviewed` を今日（UTC）にした
- [ ] `status: frozen` の文書を改変していない（改訂は後継 ID）
- [ ] `reviews/` は末尾追記または新規追加のみ
- [ ] ledger（claims / open-questions / changelog）を必要なら同期した
- [ ] `GRAPH.md` と `INDEX.md` を再生成して同じ PR に含めた（グラフ → 索引の順）
- [ ] skill を足したなら 1 skill = 1 playbook で、手順を書き写していない
- [ ] 秘密情報を含めていない

## 検証

```bash
bash .github/scripts/check-staleness.sh
python3 .github/scripts/build-graph.py --check
bash .github/scripts/build-index.sh --check
```

- [ ] 上記がローカルまたは CI で PASSED
