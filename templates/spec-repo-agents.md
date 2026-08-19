<!--
SDD で運用中の spec / 実装リポジトリの AGENTS.md にコピーして使う雛形（PB-00021）。
kernel（aidd）の規範はコピーせず、URL で参照する（ADR-00019）。案件の値だけを埋める。
Claude Code を使うなら CLAUDE.md に `@AGENTS.md` の 1 行だけ置く（ADR-00011）。
-->

# AGENTS.md

このリポジトリは <製品名> の spec / 実装リポジトリである。働き方（文書の種類・Tier・検査・横断の判断・作業単位の規約）の正本は kernel にあり、ここにはコピーしない。

- Kernel: https://github.com/TeramachiShunsuke/aidd
- このリポジトリの `adr/` には、この製品の決定だけを置く。kernel の ADR をここへコピーしない
- 案件限りの ADR の置き場: `specs/<feature>/adr/`（または `adr/`。どちらかに決めて 1 行で書く）

## 入力と置き場

| もの | 置き場 | 正本 |
| --- | --- | --- |
| PdO の要件（ビジネススペック） | `specs/<feature>/requirements.md`（Confluence にあるならリンクとページバージョン。本文は転記しない） | Confluence または requirements.md |
| 受け入れ例 / ブラッシュアップ記録 | `specs/<feature>/acceptance-examples.md` / `acceptance-refinement-log.md` | git |
| 契約 | `openapi.yaml` / `migrations/`（Markdown に写さない） | git |
| 振る舞い | テスト | git |
| 状態（担当・進行・待ち） | Jira（Epic = 機能、Story = 外側テスト 1 つの行グループ） | Jira |

## 手順（kernel の playbook を URL で読む）

| やること | 手順 |
| --- | --- |
| 要件を受け入れ例まで詰める | https://github.com/TeramachiShunsuke/aidd/blob/main/playbook/00020-refine-acceptance-from-design.md |
| 受け入れ例からテストを起こす | https://github.com/TeramachiShunsuke/aidd/blob/main/playbook/00013-start-tdd-from-examples.md |
| タスク・担当・コミット・PR の規約 | https://github.com/TeramachiShunsuke/aidd/blob/main/playbook/00022-run-work-units-from-acceptance.md |
| モデル階層・effort・文脈の選び方 | https://github.com/TeramachiShunsuke/aidd/blob/main/playbook/00024-choose-model-effort-context.md |
| 言語別の TDD ループと品質ゲート | https://github.com/TeramachiShunsuke/aidd/blob/main/playbook/00023-set-up-language-tdd-loop.md |
| 実装スペックを書くか | https://github.com/TeramachiShunsuke/aidd/blob/main/playbook/00012-triage-implementation-spec.md |
| 知見を kernel に戻す | https://github.com/TeramachiShunsuke/aidd/blob/main/playbook/00008-bridge-sdd-spec.md |

## この案件の値（kernel の既定を上書きするものだけ書く）

| 項目 | 値 |
| --- | --- |
| 言語と 1 コマンドの品質ゲート | <例: TypeScript / `npm run check`（format:check, lint, typecheck, test, test:acceptance）> |
| 外側テストだけを走らせるコマンド | <例: `npm run test:acceptance`> |
| Jira プロジェクトキー | <例: SHOP> |
| PR の規模上限 | 既定（400 行 / 20 ファイル）または <上書き値と理由> |
| 受け入れ例の回答期限 | 既定（5 営業日）または <上書き値> |
| モデル階層の対応表 | S = <銘柄> / M = <銘柄> / L = <銘柄>（変わったらここだけ直す） |
| コードグラフ | `graphify extract . --code-only`（出力は commit しない。常時注入しない）または <代替ツール> |

## やってはいけないこと

- 要件に書かれていない業務値・閾値・挙動を推測で埋める（質問にする）
- URL のない PdO の回答・承認を書く
- `Refs: <ISSUE-KEY>` のないコミット、`<ISSUE-KEY> type(scope): 要約` でない PR タイトル
- 1 コミットに `test` と `feat` を混ぜる。1 PR に複数の Issue を入れる
- 契約の本文（DDL / JSON スキーマ）や画面の見た目を Markdown に写す
- kernel の ADR をこのリポジトリの `adr/` にコピーする
- `graphify-out/` を commit する。グラフ出力を常時注入の規則に入れる
