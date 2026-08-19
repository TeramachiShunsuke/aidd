---
id: PB-00004
title: 文書を凍結する
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - frozen
related:
  - ADR-00003
  - ADR-00012
  - EVID-00004
---

## いつ使うか

合意が固まり、以降の黙改変を禁止したいとき（レイアウト契約、安全規則、コア ADR など）。

## 手順

1. 対象が `active` で内容が最終か確認する
2. PR で `status: frozen` に変更し、`last_reviewed` を今日にする
3. owners レビューを必須とする（自己マージしない）
4. merge 後は改変しない。変更が必要なら後継 ID を新規作成し、旧文書は別 PR で `deprecated` + `superseded_by` へ遷移する
5. 以降のレビューは本文ではなく `ledger/attestations.md` への追記で記録する。凍結後は日付を更新する手段が証跡しかない（[ADR-00012](../adr/00012-review-attestations.md)）

## 検証

- frozen 後の意図しない差分で CI が赤になることを確認（意図的に触るテストはブランチで）
- README / ledger の参照が旧 ID のままになっていないか確認
- 凍結した文書が 90 日以内に証跡で更新できることを確認（`MAX_AGE_DAYS=0` で走らせると、証跡のある文書だけが通る）

## 失敗時

議論が割れているなら凍結しない。`active` のまま議論を reviews / open-questions に残す。

## 関連

- [ADR-00003](../adr/00003-frozen-immutability.md)
- [ADR-00012](../adr/00012-review-attestations.md)
- [PB-00002](00002-write-adr.md)
- [PB-00003](00003-run-review-cycle.md)
