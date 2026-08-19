<!--
SDD で運用中の spec / 実装リポジトリの AGENTS.md にコピーして使う雛形（PB-00021）。
kernel（aidd）の規範はコピーせず、URL で参照する（ADR-00019）。案件の値だけを埋める。
Claude Code を使うなら CLAUDE.md に `@AGENTS.md` の 1 行だけ置く（ADR-00011）。
-->

# AGENTS.md

このリポジトリは <製品名> の spec / 実装リポジトリである。働き方（文書の種類・Tier・検査・横断の判断・作業単位の規約）の正本は kernel にあり、ここにはコピーしない。

- Kernel: https://github.com/TeramachiShunsuke/aidd （エージェントが読むときは raw: https://raw.githubusercontent.com/TeramachiShunsuke/aidd/main/ 、ネットワークのない環境ではローカル clone `<例: ../aidd>` を読む）
- 案件限りの決定（ADR）の置き場: `<specs/<feature>/adr/ または adr/ のどちらか 1 つ>`。そこにはこの製品の決定だけを置き、kernel の ADR をコピーしない

## 入力と置き場

| もの | 置き場 | 正本 |
| --- | --- | --- |
| PdO の要件（ビジネススペック） | `specs/<feature>/requirements.md`（Confluence が正本ならリンクとページバージョン。本文は転記しない） | Confluence または requirements.md（どちらか 1 つ） |
| 受け入れ例 / ブラッシュアップ記録 | `specs/<feature>/acceptance-examples.md` / `acceptance-refinement-log.md` | git |
| 契約 | `openapi.yaml` / `migrations/`（Markdown に写さない） | git |
| 振る舞い | テスト（外側テストは受け入れ例の行 ID を持つ） | git |
| 進行の状態（担当・進行・待ち） | Jira（Epic = 機能、Story = 受け入れ例の束） | Jira（`tasks.md` はリンクのみ、チェックボックスを持たない） |

## 手順（kernel の playbook を読む）

| やること | 手順（raw URL） |
| --- | --- |
| 要件を受け入れ例まで詰める | https://raw.githubusercontent.com/TeramachiShunsuke/aidd/main/playbook/00020-refine-acceptance-from-design.md |
| 受け入れ例からテストを起こす | https://raw.githubusercontent.com/TeramachiShunsuke/aidd/main/playbook/00013-start-tdd-from-examples.md |
| Story・担当・コミット・PR の規約 | https://raw.githubusercontent.com/TeramachiShunsuke/aidd/main/playbook/00022-run-work-units-from-acceptance.md |
| モデル階層・effort・文脈の選び方 | https://raw.githubusercontent.com/TeramachiShunsuke/aidd/main/playbook/00024-choose-model-effort-context.md |
| 言語別の TDD ループと品質ゲート | https://raw.githubusercontent.com/TeramachiShunsuke/aidd/main/playbook/00023-set-up-language-tdd-loop.md |
| 実装スペックを書くか | https://raw.githubusercontent.com/TeramachiShunsuke/aidd/main/playbook/00012-triage-implementation-spec.md |
| 知見を kernel に戻す | https://raw.githubusercontent.com/TeramachiShunsuke/aidd/main/playbook/00008-bridge-sdd-spec.md |

禁止事項は各 playbook の「失敗時」と、ADR-00024 / ADR-00025 / ADR-00027 を正本とする。ここに書き写さない。

## この案件の値（kernel の既定を上書きする・埋める必要があるものだけ）

| 項目 | 値 |
| --- | --- |
| 言語と 1 コマンドの品質ゲート | <例: TypeScript / `npm run check`（format:check, lint, typecheck, test, test:acceptance）> |
| 外側テストだけを走らせるコマンド | <例: `npm run test:acceptance`> |
| Jira プロジェクトキー | <例: SHOP> |
| **Epic 単位の出荷制御**（必須） | <フィーチャーフラグ / デプロイ単位の分離 / リリースブランチ のどれか> |
| コミット scope の語彙 | 既定（`specs/<feature>` の feature 名。モノレポは `app/feature`）または <上書き> |
| PR の規模上限 | 既定（400 行 / 20 ファイル）または <上書き値と理由> |
| 規模検査の除外パターン | <glob。例: `**/*.lock`, `**/__snapshots__/**`, `gen/**`> |
| 受け入れ例の回答期限 | 既定（5 営業日）または <上書き値> |
| モデル階層の対応表 | S = <銘柄> / M = <銘柄> / L = <銘柄>。effort は low / medium / high（harness に無ければ読み替えを書く） |
| コードグラフ | `graphify extract . --code-only` と `graphify affected "<起点>" --depth 2`（出力は commit しない。`graphify install` は使わない）または <代替ツール> |
| 影響範囲に手で足す共有ファイル | <マイグレーション連番 / DI・ルーティング登録 / lock / i18n / 生成物 のパス> |
