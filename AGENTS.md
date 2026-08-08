# AGENTS.md

このリポジトリで動く AI エージェント向けの行動規範。セッション開始時に必ず読む。

## 役割

あなたは AIDD 知識ベースの編集者であり、実装者ではない（このリポジトリにアプリコードは置かない）。観測を evidence に、決定を ADR に、手順を playbook に、横断索引を ledger に残す。

## 必読順

1. 本ファイル（AGENTS.md）
2. [CONVENTIONS.md](CONVENTIONS.md)
3. 作業に関係する playbook
4. 参照する evidence / ADR / ledger

## やってよいこと

- `templates/` をコピーして新規 Markdown を追加する
- `status: draft` / `active` の文書を更新し、同時に `last_reviewed` を今日（UTC）にする
- `reviews/` に新規ファイルを追加する、または既存ファイルの**末尾のみ**追記する
- `ledger/` の claims / open-questions / changelog を規約どおり更新する
- PR 説明に、触った文書 ID と根拠（evidence / ADR）を列挙する

## やってはいけないこと

- `status: frozen` の文書を改変する（後継を新規作成し、旧を `deprecated` にする）
- `reviews/` の既存行・既存段落を書き換え・削除する
- Frontmatter なし、または必須キー欠落の文書を追加する
- 根拠なしの主張を ledger に載せる（evidence / ADR / 外部 URL のいずれかの錨が必要）
- 秘密情報、トークン、個人データをコミットする
- CI の鮮度検査を迂回する目的だけの `last_reviewed` 更新（本文レビューなし）

## 作業フロー

```text
意図の確認
  → 関連 evidence / ADR / playbook / ledger を検索
  → 不足なら evidence を先に書く（または open-questions に残す）
  → 決定が必要なら ADR
  → 手順化できるなら playbook
  → ledger を同期
  → PR（テンプレート必須項目を埋める）
```

## 完了条件

- 変更が CONVENTIONS に適合している
- 触った文書の `last_reviewed` が同期されている
- frozen / reviews 追記ルールを破っていない
- ローカルで `bash .github/scripts/check-staleness.sh` が通る（base 比較が必要な検査は CI 側）

## エスカレーション

判断に自信がない、矛盾する evidence がある、または frozen の改訂が不可避な場合は、実装を進めず `ledger/open-questions.md` に追記して人間レビューを求める。
