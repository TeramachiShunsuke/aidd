---
id: EVID-00030
title: 人の入口は、全共感ではなく二層のセットアップ案内を必要としている
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - onboarding
  - documentation
  - setup
related:
  - EVID-00002
  - EVID-00009
  - EVID-00010
  - ADR-00001
  - ADR-00006
  - ADR-00021
---

## 主張

このリポジトリの人向け入口は、考え方への全共感を前提にしてはいけない。最低限でワークフローを無駄なく使える層と、理解したら効率よく使いこの KB を改善できる層の、二層のセットアップ案内が要る。

## 観測

- 2026-08-13、運用者はセットアップガイドが必要だと述べた。ターゲットは考え方・利用方法への共感だが、**全員には届かない**前提である。構成は次の 2 層とした。(1) 最低限わかっていたらこのワークフローの機能を無駄なく使える。(2) 理解していたらより効率的な開発や利用ができ、このリポジトリの改善ができる。
- 現行の人向け入口は役割が分かれている。[README.md](../README.md) の「使い方（最短）」はエージェントセッションの読み順（先に `AGENTS.md` と `CONVENTIONS.md`）である。[GUIDE.md](../GUIDE.md) は ID 体系とリレーションの地図であり、導入そのものではない（[REV-00004](../reviews/00004-cross-tool-portability.md)）。どちらも「共感しなくても最低限使える」道筋を書いていない。
- [ADR-00001](../adr/00001-repository-layout.md) の代償は「新規参加者は目錄地図を一度学ぶ必要がある（README で吸収）」だった。README はその後、構成・Tier・ツール対応・CI の説明まで抱えており、セットアップの最短路ではない。
- [EVID-00002](00002-context-is-not-memory.md) は入口を薄くし詳細を分ける。[EVID-00009](00009-context-budget-is-finite.md) は常時ロードの劣化を示す。人に AGENTS / CONVENTIONS / GUIDE / README の CI 節を一度に読ませるのは、同じ劣化を人側で起こす。

## 限界

二層に分けたときに、実際の新規参加者が層 1 で止まれるか、層 2 まで読むかは測定していない（効果測定は [OQ-00017](../ledger/open-questions.md)）。セットアップを PF の UI に載せる話は、本観測の範囲外である。

## 関連

- [ADR-00021](../adr/00021-two-layer-setup-guide.md)
- [SETUP.md](../SETUP.md)
- [README.md](../README.md)
- [GUIDE.md](../GUIDE.md)
