# AGENTS.md

このリポジトリで動く AI エージェント向けの行動規範。セッション開始時に必ず読む。

## 役割

あなたは AIDD 知識ベースの編集者であり、実装者ではない（このリポジトリにアプリコードは置かない）。観測を evidence に、決定を ADR に、手順を playbook に、横断索引を ledger に残す。

## 必読順

Tier（[ADR-006](adr/006-context-tiers.md)）に従って読む。上 2 つは毎回、下 2 つは必要になってから。

1. Tier 0: 本ファイル（AGENTS.md）と [CONVENTIONS.md](CONVENTIONS.md) — 全文
2. Tier 1: [INDEX.md](INDEX.md) と [ledger/](ledger/) — 一覧のみ。ここで必要な文書 ID を特定する
3. Tier 2: 作業に関係する playbook と ADR — 全文
4. Tier 3: 根拠を疑うときだけ evidence / reviews

skills（`.cursor/skills/`）は Tier 1 の入口で、`description` が一致したときに本文が読まれる。手順の正本は常に playbook 側にある（[ADR-009](adr/009-skills-as-playbook-entrypoints.md)）。

## やってよいこと

- `templates/` をコピーして新規 Markdown を追加する
- `status: draft` / `active` の文書を更新し、同時に `last_reviewed` を今日（UTC）にする
- `reviews/` に新規ファイルを追加する、または既存ファイルの**末尾のみ**追記する
- `ledger/` の claims / open-questions / changelog を規約どおり更新する
- `.cursor/skills/` に skill を追加・更新する（1 skill = 1 playbook）
- `bash .github/scripts/build-index.sh` で `INDEX.md` を再生成する
- PR 説明に、触った文書 ID と根拠（evidence / ADR）を列挙する

## やってはいけないこと

- `status: frozen` の文書を改変する（後継を新規作成し、旧を `deprecated` にする）
- `reviews/` の既存行・既存段落を書き換え・削除する
- Frontmatter なし、または必須キー欠落の文書を追加する
- 根拠なしの主張を ledger に載せる（evidence / ADR / 外部 URL のいずれかの錨が必要）
- `INDEX.md` を手で編集する（生成物。文書側を直して再生成する）
- skill の本文に playbook の手順を書き写す（二重管理になる）
- 秘密情報、トークン、個人データをコミットする
- CI の鮮度検査を迂回する目的だけの `last_reviewed` 更新（本文レビューなし）

## 作業フロー

```text
意図の確認
  → INDEX.md で関連 evidence / ADR / playbook / ledger を特定
  → 不足なら evidence を先に書く（または open-questions に残す）
  → 決定が必要なら ADR
  → 手順化できるなら playbook（発見されにくいなら skill も添える）
  → ledger を同期
  → INDEX.md を再生成
  → PR（テンプレート必須項目を埋める）
```

外部の spec（requirements / design / tasks）との受け渡しは [ADR-008](adr/008-sdd-bridge.md) と [PB-008](playbook/008-bridge-sdd-spec.md) に従う。spec 本文は取り込まず、リンクと ID だけを持つ。

## 完了条件

- 変更が CONVENTIONS に適合している
- 触った文書の `last_reviewed` が同期されている
- frozen / reviews 追記ルールを破っていない
- ローカルで次の 2 つが通る（base 比較が必要な検査は CI 側）

```bash
bash .github/scripts/check-staleness.sh
bash .github/scripts/build-index.sh --check
```

## エスカレーション

判断に自信がない、矛盾する evidence がある、または frozen の改訂が不可避な場合は、実装を進めず `ledger/open-questions.md` に追記して人間レビューを求める。
