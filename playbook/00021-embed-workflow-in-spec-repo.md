---
id: PB-00021
title: 既存の SDD spec リポジトリに AIDD ワークフローを組み込む（Jira / Confluence と接続）
status: draft
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - adoption
  - sdd
  - jira
related:
  - ADR-00024
  - ADR-00025
  - ADR-00026
  - ADR-00027
  - ADR-00019
  - ADR-00008
  - PB-00017
  - PB-00020
  - PB-00022
  - PB-00023
  - PB-00024
tier: 2
---

## いつ使うか

SDD（requirements / design / tasks）で運用中の spec リポジトリ（実装リポを兼ねることも多い）に、「PdO の要件 → 受け入れ例 → TDD → Story / PR」のワークフローを AI 込みで組み込むとき。タスク管理が Jira、設計原文が Confluence にあるとき。[PB-00017](00017-apply-kernel-to-project.md) は kernel と案件の二層の一般則であり、本手順はその SDD リポ向けの具体化である。

## 手順

### 1. 棚卸し（半日以内）

1. 既存 spec の形を確認する: 機能ごとのディレクトリがあるか（なければ `specs/<feature>/` を新設する。製品全体の `docs/requirements.md` 1 本の構成なら、機能単位に分けてから始める）、requirements に受け入れ基準（EARS / Gherkin など）が既にあるか、design は誰が書いているか（PdO か開発か）、tasks.md が何を駆動しているか（チェックボックスで実行を駆動しているなら、Jira へのリンク化への移行を手順 9 で行う）
2. spec リポと実装リポが同じか別かを確認する。別なら、テストが持つ参照は `<spec リポ>/specs/<feature>/acceptance-examples.md#<表>-<#>`（行 ID のみ。commit は Story と PR だけが持つ）にする
3. Confluence に PdO の設計原文があるか（あるなら**要件の正本は Confluence か requirements.md のどちらか 1 つ**に決める）、Jira の階層（Epic / Story / Sub-task）とプロジェクトキー、言語とリポ構成（モノレポか）、CI の有無、エージェントの実行環境がネットワークに出られるか（harness ごとに）を書き出す。正本が Confluence でエージェントが読めない harness があるなら、**要件本文の取得経路**（MCP / 人が本文を貼る / エクスポートを commit しない読み取り用ファイルとして渡す）を決めて `AGENTS.md` に書く
4. 既に受け入れ基準が requirements にある場合、それは「ルール」として残し、受け入れ例シートは「例」に落とす場所と位置づける。二重管理にしないため、例の各行は `出所: 要件 REQ-n` でルールを指す（[ADR-00024](../adr/00024-refine-acceptance-with-bounded-review-rounds.md) §3）

### 2. 入口を 1 ファイル置く

5. [templates/spec-repo-agents.md](../templates/spec-repo-agents.md) を案件の `AGENTS.md` としてコピーし、案件の値（言語・1 コマンド・Jira キー・**Epic 単位の出荷制御**・scope 語彙・規模の除外パターン・階層の対応表（harness ごと）・共有ファイル一覧・要件本文の取得経路・参照する kernel の commit / tag）だけ埋める。kernel の規範はコピーせず URL で参照する（[ADR-00019](../adr/00019-kernel-and-project-layers.md)）。URL は raw（`raw.githubusercontent.com`）を書き、ネットワークのない harness ではワークスペース内に kernel を置く（submodule か multi-root で `<clone>/playbook/…` を同じ相対パスで読む）。Claude Code を使うなら `CLAUDE.md` に `@AGENTS.md` の 1 行
6. 案件限りの ADR の置き場（`specs/<feature>/adr/` か `adr/`）を 1 行で決めて書く。案件 `adr/` を置かないなら、この行は省いてよい
7. kernel の skill（`.agents/skills/aidd-*`）は案件リポへ**コピーしない**（配布方法は [OQ-00041](../ledger/open-questions.md)）。エージェントには `AGENTS.md` の URL 表から kernel の playbook を読ませる。案件リポが kernel の CI スクリプトを複製している場合、skill をコピーすると `aidd-playbook` の検査で ERROR になる

### 3. 機能ディレクトリに雛形を置く

8. 機能ごとのディレクトリに 2 つの雛形をコピーする。design の中には入れない

   ```text
   specs/<feature>/
     requirements.md               # PdO の要件（Confluence が正本ならリンクとバージョンだけ）
     design.md                     # 設計（PdO 記述の節は受け入れ例の参考。開発の技術設計は入力にしない）
     acceptance-examples.md        # templates/acceptance-examples.md
     acceptance-refinement-log.md  # templates/acceptance-refinement-log.md
     tasks.md                      # Jira Epic / Story へのリンクだけ。チェックボックス（状態）を持たない
     adr/                          # 案件限りの決定（置く場合）
   ```

9. `tasks.md` はリンクに留め、進行の状態は Jira だけが持つ（[ADR-00025](../adr/00025-control-work-units-commits-prs.md) §5）。受け入れ例が `承認: 未` の機能では実装の Story を起票しない。承認前の PR（受け入れ例の書き戻し・組み込み）は `Refs:` に Epic キーを使う

### 4. Jira と Confluence をつなぐ

10. Jira: 機能ごとに **Epic を先に起票**する（承認前の書き戻し・組み込み PR の `Refs:` に使う）。Story = 受け入れ例の束（代表例 1 行 + 付随する境界・反例）。Story 本文に spec のパス（別リポなら URL + commit）・行 ID・依拠 KB の ID・影響範囲の要約・フラグ名と OFF 時の挙動を書く。進行の状態は Jira だけが持ち、git には書かない
11. Confluence: PdO の設計原文はページのまま。spec リポはリンクとページバージョンで指し、本文を転記しない（[ADR-00008](../adr/00008-sdd-bridge.md)）。要件の正本が Confluence なら、回答の書き戻し先は PdO が更新する Confluence ページであり、出所には更新後のページバージョンを書く（[PB-00020](00020-refine-acceptance-from-design.md) 手順 11）。PdO の回答・承認は Confluence か Jira のコメントでもよく、その URL を出所に書く（インラインコメントは解決で非表示になるため引用も残す）
12. Issue キーでの紐づけを有効にする（GitHub と Jira の連携設定は案件の管理者が行う。kernel は規約だけ）

### 5. 品質ゲートと規約の機械検査

13. 言語ごとの 1 コマンドの品質ゲートを作る（[PB-00023](00023-set-up-language-tdd-loop.md)）。外側テストを含める。PR 単位の CI で回す（コミット単位では回さない）
14. 作業単位の規約を CI に入れる（[ADR-00025](../adr/00025-control-work-units-commits-prs.md) §2 の正規表現と §3 の既定値）: コミット見出しと footer（commitlint 等。squash 前の非マージコミットが対象、bot は除外）、PR タイトル、ブランチ名、PR の変更行数 / ファイル数（除外パターン適用後）。ツールは案件が選ぶ。案件の PR テンプレートは [templates/project-pr.md](../templates/project-pr.md)
15. コードグラフをローカルで出せるようにする（`pip install graphifyy` — PyPI 名は `graphifyy`。`graphify extract . --code-only`）。`graphify-out/` を `.gitignore` に入れる。`graphify install`（規則・skill・フックの書き込み）は使わない（[PB-00024](00024-choose-model-effort-context.md)）。モノレポなら workspace import が辺になるかを 1 回 `affected` で確かめ、ならなければ共有パッケージを共有ファイル一覧に足す

### 6. 1 機能で試走し、調整する

16. 1 機能を選び、[PB-00020](00020-refine-acceptance-from-design.md)（要件 → 例）→ [PB-00013](00013-start-tdd-from-examples.md)（例 → テスト）→ [PB-00022](00022-run-work-units-from-acceptance.md)（Story → PR）を通して 1 PR をマージする
17. ブラッシュアップ記録と PR の集計（巡数・残 P0・PR 規模・モデル節の 5 項目）を見て、案件 `AGENTS.md` の上書き値（回答期限・PR 規模・階層対応表・共有ファイル一覧）を決める。kernel の既定を変える根拠になるものは [PB-00008](00008-bridge-sdd-spec.md) 方向 B で戻す

## 検証

- 案件 `AGENTS.md` から kernel の raw URL（またはローカル clone）と PB-00020 / 00022 / 00023 / 00024 が辿れ、kernel の規範本文がコピーされていない。Epic 単位の出荷制御が書かれている
- 機能ディレクトリに受け入れ例シートと記録があり、design の中にない。`tasks.md` にチェックボックスがない
- Jira の Story が spec のパスと行 ID と影響範囲の要約を持ち、git に進行の状態が書かれていない
- CI で 1 コマンドの品質ゲート（外側テスト込み）と、コミット / PR の命名・規模検査が回る
- `graphify-out/` が `.gitignore` にあり、常時注入の規則・skill・フックがない
- 1 機能の試走で PR が 1 本マージされ、記録に巡ごとの指摘と対応、PR にモデル節がある

## 失敗時

- requirements の受け入れ基準とシートが二重管理になった → 基準は「ルール」、シートは「例」。例の出所を `要件 REQ-n` にし、回答はルール側（requirements.md か Confluence のどちらか 1 つ）に書き戻す
- PdO が git も Jira も使わない → Confluence のコメント URL（と引用）を出所にし、エージェントが記録する（[ADR-00024](../adr/00024-refine-acceptance-with-bounded-review-rounds.md) §2）
- エージェントが kernel の URL を読めない → ローカル clone のパスを `AGENTS.md` に書く。それもできない環境では、必要な playbook の該当手順だけを Story 本文に引用する（規範のコピーではなく、その Story のための抜粋）
- モノレポで言語が複数 → 言語ごとに 1 コマンドを分け、ルートで束ねる。規約（命名・規模）は共通
- CI を複製したら skill の検査で落ちた → skill をコピーしない（手順 7）
- 「全部 Markdown に書いている」状態に戻った → [PB-00016](00016-large-project-usage-map.md) の置き場表に戻し、契約・振る舞い・決定・見た目に分けて正本へ移す
- kernel の URL が開けない → 案件作業は止めず、案件の観測と決定は進める。働き方の改訂は kernel 側の PR

## 関連

- [PB-00017](00017-apply-kernel-to-project.md)
- [PB-00020](00020-refine-acceptance-from-design.md)
- [PB-00022](00022-run-work-units-from-acceptance.md)
- [PB-00023](00023-set-up-language-tdd-loop.md)
- [PB-00024](00024-choose-model-effort-context.md)
- [ADR-00024](../adr/00024-refine-acceptance-with-bounded-review-rounds.md)
- [ADR-00025](../adr/00025-control-work-units-commits-prs.md)
- [ADR-00027](../adr/00027-cost-and-context-per-task.md)
- [templates/spec-repo-agents.md](../templates/spec-repo-agents.md)
- [templates/project-pr.md](../templates/project-pr.md)
- skill: [aidd-embed-spec-repo](../.agents/skills/aidd-embed-spec-repo/SKILL.md)
