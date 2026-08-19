---
id: PB-00017
title: 新しいリポジトリへ kernel を適用し、案件の考え方と混ぜない
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - adoption
related:
  - ADR-00019
  - ADR-00008
  - EVID-00024
tier: 2
---

## いつ使うか

新しいリポジトリやプロジェクトに AIDD を載せるとき。AI 以前の既存プロジェクトに段階的に導入するとき。既存の ADR を残すべきか、コピーすべきか迷うとき。ワークフローの決定と案件の考え方が同じ一覧に混ざって読みにくいとき。

## 手順

1. 二層を宣言する。**kernel**（本リポジトリ = 働き方）と **project**（案件リポ = この製品の考え方）は別の権威である（[ADR-00019](../adr/00019-kernel-and-project-layers.md)）
2. kernel の ADR は残す。案件の `adr/` にコピーしない。必要な決定は ID と URL で参照する
3. 案件リポの入口を 1 ファイル書く。最低限次を含める

   ```markdown
   # AGENTS.md

   働き方（文書の種類・Tier・CI・横断の判断）の正本は kernel である。
   Kernel: https://github.com/TeramachiShunsuke/aidd

   このリポジトリの adr/ には、この製品の決定だけを置く。
   kernel の ADR をここへコピーしない。
   ```

4. 案件側に置く文書を選ぶ。観測が要るなら `evidence/`、決定が要るなら `adr/`、繰り返す案件手順があるなら `playbook/`。使わない種別は作らない
5. 品質ゲートを案件リポでも回したいときだけ、`templates/` と CONVENTIONS と CI スクリプトをコピーする。その場合も kernel の `adr/` と `evidence/` と `reviews/` はコピーしない
6. 案件限りの ADR の置き場所（トップレベル `adr/` か機能ディレクトリか）を 1 行で決めて、案件 `AGENTS.md` に書く。体裁は [CONVENTIONS.md](../CONVENTIONS.md) に合わせる
7. 日々の根拠は、散在ソースがあれば [PB-00018](00018-draft-evidence-from-sources.md) で `draft` を起こし、人が確認してから決定する。人が最初から書ける観測は [PB-00001](00001-add-evidence.md)
8. 他案件でも繰り返す判断だけ [PB-00008](00008-bridge-sdd-spec.md) で kernel へ戻す。案件の考え方を kernel の INDEX に混ぜない

### AI 以前の既存プロジェクトへ段階的に適用する場合

エージェントや skill が前提にない既存プロジェクトでは、上記の手順を一度に踏まず、段階的に導入する。

| 段階 | やること | 上記手順との対応 |
| --- | --- | --- |
| A. 根拠の後追い | 既に暗黙に決まっている技術選択・構成・運用ルールを `evidence/` に書く。散在ソースがあれば [PB-00018](00018-draft-evidence-from-sources.md) で拾う。次に変更が入りそうな箇所から | 手順 4 の一部 |
| B. ADR の後追い | evidence が揃った決定だけ `adr/` に起こす。「なぜこうなっているか」を書けないものは `ledger/open-questions.md` に残す | 手順 4 の一部 |
| C. playbook は属人化の解消から | デプロイ手順、障害対応、リリース判定など、特定の人しかできない手順を 1 つずつ | 手順 4 の一部 |
| D. 二層の宣言と入口 | 手順 1〜3・6 を実施し、kernel との参照関係を整える | 手順 1〜3, 6 |
| E. CI とエージェント | 品質ゲート（staleness / index / graph）を入れるのは文書が 5〜10 件を超えてから。エージェント連携は CI が安定してから | 手順 5 |

段階 A〜C では kernel の全体を必要とせず、`evidence/` と `adr/` の 2 ディレクトリだけでも成立する。

## 検証

- 案件側の決定一覧に、ADR-00001 から ADR-00018 のような働き方文書が混ざっていない
- 案件 `AGENTS.md` から kernel の URL が辿れる
- kernel 側に、その製品の画面仕様・API 名・案件限りの選択が新規 ADR として増えていない
- 昇格した項目は「他プロジェクトでも繰り返すか」が Yes である
- 既存プロジェクトの段階的適用では、evidence と ADR が先に存在してから playbook や CI を足している

## 失敗時

- 「とりあえず全部コピーした」→ 手順 2 に戻り、案件 `adr/` から kernel 由来のファイルを除く。参照は URL にする
- どちらに書くか迷う → 「次の案件でも同じ判断か？」だけを問う。No なら案件側（[ADR-00008](../adr/00008-sdd-bridge.md)）
- kernel の URL が開けない → 案件作業を止めず、案件側の観測と決定は進める。働き方の改訂は kernel 側の PR にする
- 案件 ADR の体裁が割れる → CONVENTIONS を案件へコピーするか、kernel の雛形をリンクする。新規の文書種別は増やさない
- 既存プロジェクトで段階 A〜C をスキップして D（二層の宣言）から始めた → 中身のない入口だけ作っても使われない。段階 A に戻り、次に変更が入る箇所の evidence を 1 つ書くところから

## 関連

- [ADR-00019](../adr/00019-kernel-and-project-layers.md)
- [PB-00018](00018-draft-evidence-from-sources.md)
- [PB-00008](00008-bridge-sdd-spec.md)
- [templates/sdd-handoff.md](../templates/sdd-handoff.md)
- skill: [aidd-apply-to-project](../.agents/skills/aidd-apply-to-project/SKILL.md)
