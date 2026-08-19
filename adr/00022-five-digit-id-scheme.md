---
id: ADR-00022
title: 全文書の ID とファイル名を5桁に統一する
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - conventions
  - id-allocation
related:
  - ADR-00018
  - ADR-00003
  - EVID-00023
tier: 2
---

## 文脈

現行の ID 体系は3桁（`EVID-001`、`ADR-001` 等）である。文書数が今後100件を大きく超えることが見込まれ、3桁では上限に達する。視認性と将来の拡張性のため、桁数を増やす判断が必要になった。

3桁と5桁が混在すると見づらいため、`status: frozen` や追記専用ログ（`reviews/`、`ledger/attestations.md`）も含めて全文書を5桁に統一する。frozen の不変性ルール（[ADR-00003](00003-frozen-immutability.md)）は本 ADR の移行に限り例外とし、移行完了後は再び不変とする。

## 決定

1. **新しい桁数は5桁**（`EVID-00001`、`ADR-00001` 等）とする
2. **frozen / active / draft / deprecated を含む全文書を5桁に振り直す**。3桁の番号はゼロ埋めして5桁にする
3. **追記専用ログ（`reviews/`、`ledger/attestations.md`）も5桁に統一する**。ID 統一のための既存行書き換えは本 ADR の移行に限り許可する
4. **新規採番は5桁から始める**。`check-id-collisions.sh --next` は5桁で返す
5. **CONVENTIONS.md の桁数記述を更新する**（「3桁」→「5桁」）
6. **CI の frozen 不変性チェックは、本移行 PR では frozen ファイルの変更を許容する**

## 根拠

- [EVID-00023](../evidence/00023-id-allocation-is-a-concurrency-problem.md): 採番は並行制御の問題。桁数の変更は採番時点で完結させる
- [ADR-00018](00018-id-allocation.md): 番号は main を権威として確保し、衝突は PR 側が譲る
- [ADR-00003](00003-frozen-immutability.md): frozen 文書はバイト不変。本 ADR の移行に限り例外を設ける

## 結果・トレードオフ

- 利点: 全文書が5桁で統一され、一覧性・検索性が向上する
- 利点: frozen / active の混在による3桁・5桁の読みにくさを排除できる
- 代償: frozen の不変性を一度だけ破る（ADR-00003 の例外）
- 代償: 追記専用ログの既存行を書き換える（ID 統一目的の一回限り）
- 代償: `check-id-collisions.sh` の `--next` 出力フォーマットを更新する必要がある

## 関連

- [ADR-00018](00018-id-allocation.md)
- [ADR-00003](00003-frozen-immutability.md)
- [CONVENTIONS.md](../CONVENTIONS.md)
