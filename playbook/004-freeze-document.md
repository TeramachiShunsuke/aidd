---
id: PB-004
title: 文書を凍結する
status: active
last_reviewed: 2026-08-08
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - frozen
related:
  - ADR-003
  - EVID-004
---

## いつ使うか

合意が固まり、以降の黙改変を禁止したいとき（レイアウト契約、安全規則、コア ADR など）。

## 手順

1. 対象が `active` で内容が最終か確認する
2. PR で `status: frozen` に変更し、`last_reviewed` を今日にする
3. owners レビューを必須とする（自己マージしない）
4. merge 後は改変しない。変更が必要なら後継 ID を新規作成し、旧文書は別 PR で `deprecated` + `superseded_by` へ遷移する

## 検証

- frozen 後の意図しない差分で CI が赤になることを確認（意図的に触るテストはブランチで）
- README / ledger の参照が旧 ID のままになっていないか確認

## 失敗時

議論が割れているなら凍結しない。`active` のまま議論を reviews / open-questions に残す。

## 関連

- [ADR-003](../adr/003-frozen-immutability.md)
- [PB-002](002-write-adr.md)
