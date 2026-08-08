# CONVENTIONS.md

文書の形式・命名・Frontmatter・更新規則。機械検査の前提でもある。

## ディレクトリと ID

| ディレクトリ | ID 接頭辞 | ファイル名 |
| --- | --- | --- |
| `evidence/` | `EVID` | `NNN-short-slug.md` |
| `adr/` | `ADR` | `NNN-short-slug.md` |
| `playbook/` | `PB` | `NNN-short-slug.md` |
| `reviews/` | `REV` | `NNN-short-slug.md` |
| `ledger/` | （固定名） | `claims.md` / `open-questions.md` / `changelog.md` |
| `templates/` | — | 種別ごとの雛形（コピー元。CI 対象外のメタ扱い可） |

`NNN` はゼロ埋め 3 桁。slug は英小文字ケバブケース。

## Frontmatter（必須）

`evidence` / `adr` / `playbook` / `reviews` の各文書:

```yaml
---
id: EVID-001
title: 短い見出し
status: draft | active | frozen | deprecated
last_reviewed: YYYY-MM-DD
owners:
  - github-login-or-team
tags:
  - topic
---
```

追加で推奨:

| キー | 用途 |
| --- | --- |
| `related` | 関連文書 ID の配列 |
| `supersedes` | 置き換える旧 ID |
| `superseded_by` | 後継 ID（deprecated 時） |

`ledger/*` も同様に `id` / `title` / `status` / `last_reviewed` / `owners` を持つ。ledger の `status` は通常 `active`。

## 本文の最低構成

### evidence

1. `## 主張` — 1〜3 文
2. `## 観測` — 事実・引用・再現手順
3. `## 限界` — まだ言えないこと
4. `## 関連`

### adr

1. `## 文脈`
2. `## 決定`
3. `## 根拠`
4. `## 結果・トレードオフ`
5. `## 関連`

### playbook

1. `## いつ使うか`
2. `## 手順`（番号付き）
3. `## 検証`
4. `## 失敗時`
5. `## 関連`

### reviews

1. 冒頭にレビュー対象期間と範囲
2. 以降は**追記のみ**のセクション（日付見出し推奨）
3. 既存テキストの編集禁止

## ステータス意味

| status | 意味 | 変更 |
| --- | --- | --- |
| `draft` | 草案 | 自由（last_reviewed 同期必須） |
| `active` | 現行 | 自由（last_reviewed 同期必須） |
| `frozen` | 契約として固定 | **不可**。後継を新規作成 |
| `deprecated` | 廃止 | Frontmatter の後継リンク整備以外は原則触らない |

## last_reviewed

- タイムゾーンは **UTC 日付**（`YYYY-MM-DD`）
- 本文または意味のある Frontmatter を変えたら、必ず当日に更新する
- 「日付だけ進める」はレビュー実施時（reviews 追記とセット）に限る
- **90 日**を超えると CI が失敗する（`frozen` / `deprecated` も例外にしない。鮮度の説明責任は残す）

## reviews/ 追記ルール

許可:

- 新規 `reviews/NNN-*.md` の追加
- 既存ファイル末尾への追記（バイト列が旧内容の prefix であること）

禁止:

- 既存バイトの改変・削除
- ファイル削除・リネーム（必要な場合は人間が main で特例処理）

## ledger

- `claims.md` — 主張と錨（`evidence:` / `adr:` / `url:`）
- `open-questions.md` — 未決とブロッカー
- `changelog.md` — 知識ベース自体の注目すべき変更（追記主体）

claims の 1 行例:

```markdown
- [ ] CLAIM-001: frozen 文書は CI で不変 — evidence:EVID-004 adr:ADR-003
```

## PR

- [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md) を使う
- 関連 ID を明記する
- stale CI を緑にする

## 言語

- 文書本文は日本語を基本とする
- ID・ファイル名・タグ・Frontmatter キーは英語
