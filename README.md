# aidd

AI-Driven Development（AIDD）の運用知識を、証拠・決定・手順・台帳として蓄積するリポジトリ。

エージェントはコードを書く前に、このリポジトリの規約と関連文書を読む。人間はレビューと凍結で権威を確定する。

## 構成

| パス | 役割 | 件数の目安 |
| --- | --- | --- |
| [AGENTS.md](AGENTS.md) | エージェントの行動規範（常に読む） | 1 |
| [CONVENTIONS.md](CONVENTIONS.md) | 文書形式・Frontmatter・命名規則 | 1 |
| [INDEX.md](INDEX.md) | 全文書の生成インデックス（手で編集しない） | 1 |
| [evidence/](evidence/) | 観測・根拠（主張の土台） | 増える |
| [adr/](adr/) | アーキテクチャ / 運用上の決定 | 増える |
| [playbook/](playbook/) | 繰り返し手順 | 増える |
| [ledger/](ledger/) | 主張・未決・変更の台帳 | 少数の定番ファイル |
| [templates/](templates/) | 新規文書の雛形 | 固定 |
| [reviews/](reviews/) | 定期レビュー記録（追記専用） | 増える |
| `.cursor/skills/` | playbook への入口となる Agent Skills | 増える |

## 信頼モデル

1. **evidence** が「何が分かっているか」を示す
2. **adr** が「何を決めたか」を固定する
3. **playbook** が「どうやるか」を再現可能にする
4. **ledger** が横断的な主張と未決を索引する
5. **reviews** が鮮度確認の監査証跡になる

`status: frozen` の文書は不変。変更が必要なら後継文書を作り、旧文書を `deprecated` にする。

## 読み込み階層（Tier）

全文書に Tier 0〜3 を割り当てる。Tier は**ロードのタイミング**であり、重要度の格付けではない（[ADR-006](adr/006-context-tiers.md)）。

| Tier | いつ読むか | 中身 |
| --- | --- | --- |
| 0 | 毎セッション、全文 | `AGENTS.md` / `CONVENTIONS.md` |
| 1 | 毎セッション、一覧のみ | `INDEX.md` / `README.md` / `ledger/` / skills の `description` |
| 2 | 作業種別が決まったら | `adr/` / `playbook/` |
| 3 | 主張を疑うとき | `evidence/` / `reviews/` / 廃止文書 |

各文書の Tier は [INDEX.md](INDEX.md) に一覧される。

## 外部 spec との接続（SDD）

このリポジトリはコードを持たない。仕様駆動開発の成果物は実装リポジトリ側にあり、受け渡し規則を [ADR-008](adr/008-sdd-bridge.md) で定める。requirements は evidence / claims を引用し、横断で再利用する design だけが ADR に、繰り返す tasks だけが playbook に昇格する。spec 本文は取り込まず、リンクと ID のみを持つ。

## 鮮度ガード（CI）

`.github/workflows/staleness.yml` が次を検査する。

- **frozen 不変性** — `status: frozen` の本文改変を拒否
- **last_reviewed 同期** — 本文変更時は `last_reviewed` を更新
- **reviews/ 追記ガード** — 既存レビューの改変・削除を拒否（末尾追記と新規追加のみ）
- **90日期限** — `last_reviewed` から 90 日超は失敗
- **手動トリガー** — `workflow_dispatch` で随時実行可

`.github/workflows/index.yml` が [INDEX.md](INDEX.md) の最新性を検査する。

- **索引の最新性** — 再生成して差分が出たら失敗
- **Frontmatter 妥当性** — 必須キー欠落・`id` 重複・`tier` の範囲外を拒否
- **skill 整合性** — `name` とフォルダ名の不一致、参照先 playbook の不在を拒否

## 使い方（最短）

1. [AGENTS.md](AGENTS.md) と [CONVENTIONS.md](CONVENTIONS.md) を読む（Tier 0）
2. [INDEX.md](INDEX.md) で関係する文書 ID を特定する（Tier 1）
3. 作業種別に応じて [playbook/](playbook/) を選ぶ
4. 新規文書は [templates/](templates/) から作る
5. 主張は [ledger/claims.md](ledger/claims.md) に錨を付ける
6. `bash .github/scripts/build-index.sh` で索引を再生成する
7. PR ではテンプレートのチェックリストを埋める

## ライセンス

Private. リポジトリ所有者の利用に限定する。
