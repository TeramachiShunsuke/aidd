---
id: PB-007
title: INDEX.md を再生成する
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - index
related:
  - ADR-007
  - PB-005
tier: 2
---

## いつ使うか

文書を追加・改名・削除したとき、`status` / `title` / `tier` / `last_reviewed` を変えたとき、skill を追加・変更したとき。要するに **PR を出す直前は毎回**。

## 手順

1. 文書側の変更をすべて終える（`INDEX.md` を先に触らない）
2. リポジトリルートで再生成する

   ```bash
   bash .github/scripts/build-index.sh
   ```

3. `git diff INDEX.md` を読み、意図した差分だけが出ていることを確認する
4. 差分が意図と違う場合は `INDEX.md` を直さず、**生成元の Frontmatter を直して再生成**する
5. `INDEX.md` を同じコミットに含める

## 検証

```bash
bash .github/scripts/build-index.sh --check
bash .github/scripts/check-staleness.sh
```

- 両方が PASSED
- `INDEX.md` に手編集の痕跡がない（先頭の生成物ヘッダが残っている）

## 失敗時

- `--check` が差分を報告する → 再生成してコミットし忘れている。手順 2 に戻る
- `duplicate id` → 同じ `id` を 2 文書が持っている。新しい方の番号を採り直す
- `tier out of range` → `tier` は `0`〜`3` の整数のみ
- `skill name mismatch` / `unknown playbook` → [PB-009](009-add-skill.md) の検証節を見る
- 生成が壊れていると判断したら `INDEX.md` を手で直さず、[ledger/open-questions.md](../ledger/open-questions.md) に残してスクリプト側を修正する

## 関連

- [ADR-007](../adr/007-generated-index.md)
- [.github/scripts/build-index.sh](../.github/scripts/build-index.sh)
- [PB-005](005-fix-staleness-ci.md)
