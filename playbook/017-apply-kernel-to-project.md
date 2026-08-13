---
id: PB-017
title: 新しいリポジトリへ kernel を適用し、案件の考え方と混ぜない
status: active
last_reviewed: 2026-08-13
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - adoption
related:
  - ADR-019
  - ADR-008
  - EVID-024
tier: 2
---

## いつ使うか

新しいリポジトリやプロジェクトに AIDD を載せるとき。既存の ADR を残すべきか、コピーすべきか迷うとき。ワークフローの決定と案件の考え方が同じ一覧に混ざって読みにくいとき。

## 手順

1. 二層を宣言する。**kernel**（本リポジトリ = 働き方）と **project**（案件リポ = この製品の考え方）は別の権威である（[ADR-019](../adr/019-kernel-and-project-layers.md)）
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
7. 日々の根拠は、散在ソースがあれば [PB-018](018-draft-evidence-from-sources.md) で `draft` を起こし、人が確認してから決定する。人が最初から書ける観測は [PB-001](001-add-evidence.md)
8. 他案件でも繰り返す判断だけ [PB-008](008-bridge-sdd-spec.md) で kernel へ戻す。案件の考え方を kernel の INDEX に混ぜない

## 検証

- 案件側の決定一覧に、ADR-001 から ADR-018 のような働き方文書が混ざっていない
- 案件 `AGENTS.md` から kernel の URL が辿れる
- kernel 側に、その製品の画面仕様・API 名・案件限りの選択が新規 ADR として増えていない
- 昇格した項目は「他プロジェクトでも繰り返すか」が Yes である

## 失敗時

- 「とりあえず全部コピーした」→ 手順 2 に戻り、案件 `adr/` から kernel 由来のファイルを除く。参照は URL にする
- どちらに書くか迷う → 「次の案件でも同じ判断か？」だけを問う。No なら案件側（[ADR-008](../adr/008-sdd-bridge.md)）
- kernel の URL が開けない → 案件作業を止めず、案件側の観測と決定は進める。働き方の改訂は kernel 側の PR にする
- 案件 ADR の体裁が割れる → CONVENTIONS を案件へコピーするか、kernel の雛形をリンクする。新規の文書種別は増やさない

## 関連

- [ADR-019](../adr/019-kernel-and-project-layers.md)
- [PB-018](018-draft-evidence-from-sources.md)
- [PB-008](008-bridge-sdd-spec.md)
- [templates/sdd-handoff.md](../templates/sdd-handoff.md)
- skill: [aidd-apply-to-project](../.agents/skills/aidd-apply-to-project/SKILL.md)
