---
id: PB-019
title: 新しい参加者を二層のセットアップガイドへ乗せる
status: active
last_reviewed: 2026-08-13
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - onboarding
  - setup
related:
  - ADR-021
  - EVID-030
  - ADR-006
  - ADR-008
tier: 2
---

## いつ使うか

人が「セットアップ」「始め方」「使い方を教えて」「オンボーディング」と言ったとき。新しい参加者にこのワークフローを渡すとき。考え方への共感を先に求めそうになったとき。

## 手順

1. 対象の層を 1 つ選ぶ。共感の有無は問わない（[ADR-021](../adr/021-two-layer-setup-guide.md)）
   - **最低限**: ワークフローを無駄なく使いたい
   - **理解したら**: より効率的に使いたい、またはこのリポジトリを直したい
2. [SETUP.md](../SETUP.md) の該当節を読ませる（または一緒に辿る）。層 1 なら §0 と §1、層 2 ならそのあと §2
3. 今の作業が決まっているなら [INDEX.md](../INDEX.md) で playbook を 1 つ開き、SETUP のループで 1 周させる（探す → 書く → 再生成 → PR）
4. エージェントに作業を頼む段階になってから [AGENTS.md](../AGENTS.md) を渡す。人の最初の文書を AGENTS にしない
5. 案件リポの clone 手順や製品画面が尋ねられたら、kernel の SETUP には書かないと伝え、[ADR-008](../adr/008-sdd-bridge.md) の境界（繰り返す判断だけ）に戻す

## 検証

- 層 1 の人が、AGENTS / CONVENTIONS / GUIDE の全文を読まなくても PR の出し方まで辿れる
- 層 2 の人が、GUIDE と検査 3 種と改善用 playbook へリンクで届く
- SETUP に規範値（90 日、Tier 表の複製、ツール対応表）を書き足していない。正本は CONVENTIONS / ADR

## 失敗時

- 「全部読んで共感してから使って」と渡しそう → 手順 1 に戻り、層 1 だけを渡す
- README の CI 節や GUIDE の全文から始めた → SETUP §1 に戻す
- 案件の始め方と混ざった → 手順 5。kernel の SETUP を厚くしない
- 層が足りない（検査の直し方まで要る） → SETUP §2 を足す。新しい第 3 層は作らず、必要なら [ledger/open-questions.md](../ledger/open-questions.md) に残す

## 関連

- [SETUP.md](../SETUP.md)
- [ADR-021](../adr/021-two-layer-setup-guide.md)
- [GUIDE.md](../GUIDE.md)
- skill: [aidd-setup](../.agents/skills/aidd-setup/SKILL.md)
