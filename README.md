# aidd

AI-Driven Development（AIDD）の運用知識を、証拠・決定・手順・台帳として蓄積するリポジトリ。

エージェントはコードを書く前に、このリポジトリの規約と関連文書を読む。人間はレビューと凍結で権威を確定する。

## 構成

| パス | 役割 | 件数の目安 |
| --- | --- | --- |
| [AGENTS.md](AGENTS.md) | エージェントの行動規範（常に読む） | 1 |
| [CONVENTIONS.md](CONVENTIONS.md) | 文書形式・Frontmatter・命名規則 | 1 |
| [evidence/](evidence/) | 観測・根拠（主張の土台） | 増える |
| [adr/](adr/) | アーキテクチャ / 運用上の決定 | 増える |
| [playbook/](playbook/) | 繰り返し手順 | 増える |
| [ledger/](ledger/) | 主張・未決・変更の台帳 | 少数の定番ファイル |
| [templates/](templates/) | 新規文書の雛形 | 固定 |
| [reviews/](reviews/) | 定期レビュー記録（追記専用） | 増える |

## 信頼モデル

1. **evidence** が「何が分かっているか」を示す
2. **adr** が「何を決めたか」を固定する
3. **playbook** が「どうやるか」を再現可能にする
4. **ledger** が横断的な主張と未決を索引する
5. **reviews** が鮮度確認の監査証跡になる

`status: frozen` の文書は不変。変更が必要なら後継文書を作り、旧文書を `deprecated` にする。

## 鮮度ガード（CI）

`.github/workflows/staleness.yml` が次を検査する。

- **frozen 不変性** — `status: frozen` の本文改変を拒否
- **last_reviewed 同期** — 本文変更時は `last_reviewed` を更新
- **reviews/ 追記ガード** — 既存レビューの改変・削除を拒否（末尾追記と新規追加のみ）
- **90日期限** — `last_reviewed` から 90 日超は失敗
- **手動トリガー** — `workflow_dispatch` で随時実行可

## 使い方（最短）

1. [AGENTS.md](AGENTS.md) と [CONVENTIONS.md](CONVENTIONS.md) を読む
2. 作業種別に応じて [playbook/](playbook/) を選ぶ
3. 新規文書は [templates/](templates/) から作る
4. 主張は [ledger/claims.md](ledger/claims.md) に錨を付ける
5. PR ではテンプレートのチェックリストを埋める

## ライセンス

Private. リポジトリ所有者の利用に限定する。
