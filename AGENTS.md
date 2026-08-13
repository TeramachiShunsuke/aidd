# AGENTS.md

このリポジトリで動く AI エージェント向けの行動規範。セッション開始時に必ず読む。

## 役割

あなたは AIDD 知識ベースの編集者であり、実装者ではない（このリポジトリにアプリコードは置かない）。観測を evidence に、決定を ADR に、手順を playbook に、横断索引を ledger に残す。

## 必読順

Tier（[ADR-006](adr/006-context-tiers.md)）に従って読む。上 2 つは毎回、下 2 つは必要になってから。

1. Tier 0: 本ファイル（AGENTS.md）と [CONVENTIONS.md](CONVENTIONS.md) — 全文
2. Tier 1: [INDEX.md](INDEX.md) と [ledger/](ledger/) — 一覧のみ。ここで必要な文書 ID を特定する（構造を点検するときは [GRAPH.md](GRAPH.md)、ID 体系と関係が不明なときは [GUIDE.md](GUIDE.md)、人の始め方は [SETUP.md](SETUP.md)）
3. Tier 2: 作業に関係する playbook と ADR — 全文
4. Tier 3: 根拠を疑うときだけ evidence / reviews

skills（`.agents/skills/`）は Tier 1 の入口で、`description` が一致したときに本文が読まれる。手順の正本は常に playbook 側にある（[ADR-009](adr/009-skills-as-playbook-entrypoints.md)）。

## 動作するツール

このリポジトリは Codex / Cursor / Claude Code のいずれからでも同じ規範と skill で動く（[ADR-011](adr/011-cross-tool-agent-integration.md)）。

| | 規範 | skill |
| --- | --- | --- |
| Codex / Cursor | 本ファイル（`AGENTS.md`） | `.agents/skills/`（正本） |
| Claude Code | `CLAUDE.md` = `@AGENTS.md` の 1 行 | `.claude/skills/`（正本への symlink） |

`CLAUDE.md` に規範を書き足さない。ツール固有のルールファイル（`.cursor/rules/*.mdc` 等）にも複製しない。

## やってよいこと

- `templates/` をコピーして新規 Markdown を追加する
- `status: draft` / `active` の文書を更新し、同時に `last_reviewed` を今日（UTC）にする
- `reviews/` に新規ファイルを追加する、または既存ファイルの**末尾のみ**追記する
- `ledger/` の claims / open-questions / changelog を規約どおり更新する
- 読み直して直す必要がなかった文書について、`ledger/attestations.md` に証跡を**末尾追記**する（`frozen` 文書の唯一のレビュー手段。[ADR-012](adr/012-review-attestations.md)）
- `.agents/skills/` に skill を追加・更新し、`.claude/skills/` に symlink の鏡を作る（1 skill = 1 playbook）
- 生成物（`GRAPH.md` → `INDEX.md` の順）を再生成する
- PR 説明に、触った文書 ID と根拠（evidence / ADR）を列挙する

## やってはいけないこと

- `status: frozen` の文書を改変する（後継を新規作成し、旧を `deprecated` にする）
- `reviews/` と `ledger/attestations.md` の既存行・既存段落を書き換え・削除する（Frontmatter を含む。追記時に日付を触らない）
- Frontmatter なし、または必須キー欠落の文書を追加する
- 根拠なしの主張を ledger に載せる（evidence / ADR / 外部 URL のいずれかの錨が必要）
- `INDEX.md` / `GRAPH.md` を手で編集する（生成物。文書側を直して再生成する）
- skill の本文に playbook の手順を書き写す（二重管理になる）
- 意味グラフツールの出力（`graphify-out/` 等）を commit する
- 生成物の競合を手で解決する（`GRAPH.md` → `INDEX.md` の順に再生成する。[PB-015](playbook/015-resolve-conflicts.md)）
- 文書の `status` を CI やスクリプトから書き換える（遷移は人間の判断。[ADR-017](adr/017-machines-record-facts-humans-decide-status.md)）
- 番号を目視で数えて採番する（`--next` に聞く。下記「採番と PR の単位」）
- 1 セッションで複数の PR を積み上げる（base を別の PR にする。[ADR-018](adr/018-id-allocation.md)）
- 秘密情報、トークン、個人データをコミットする
- CI の鮮度検査を迂回する目的だけの `last_reviewed` 更新や証跡追記（本文レビューなし）

## 作業フロー

```text
意図の確認
  → INDEX.md で関連 evidence / ADR / playbook / ledger を特定
  → 不足なら evidence を先に書く（または open-questions に残す）
  → 決定が必要なら ADR
  → 手順化できるなら playbook（発見されにくいなら skill も添える）
  → ledger を同期
  → GRAPH.md と INDEX.md を再生成
  → PR（テンプレート必須項目を埋める）
```

外部の spec（requirements / design / tasks）との受け渡しは [ADR-008](adr/008-sdd-bridge.md) と [PB-008](playbook/008-bridge-sdd-spec.md) に従う。spec 本文は取り込まず、リンクと ID だけを持つ。

## 採番と PR の単位

新規文書を作る前に、番号を機械に聞く（[ADR-018](adr/018-id-allocation.md)）。目視で「最大が 022 だから 023」と数えない。開いている他のブランチが既にその番号を取っているかもしれない。

```bash
git fetch --no-tags --prune origin '+refs/heads/*:refs/remotes/origin/*'
bash .github/scripts/check-id-collisions.sh --next EVID   # ADR / PB / REV / CLAIM / OQ も可
```

PR の base は **main** とし、1 つの意図につき 1 本にまとめる。積み上げ PR は、親がマージされても子は main に届かないため、番号が確保されないまま滞留して衝突を招く（[REV-006](reviews/006-lifecycle-self-review.md) が実例）。

分割が必要なら、直列にする。文書を追加する PR を先に main へ着地させ、それを参照する PR を後から出す。

## 完了条件

- 変更が CONVENTIONS に適合している
- 触った文書の `last_reviewed` が同期されている（追記専用ログは除く）
- frozen / 追記専用ログのルールを破っていない
- ローカルで次の 3 つが通る（base 比較が必要な検査は CI 側）

```bash
bash .github/scripts/check-staleness.sh
bash .github/scripts/build-index.sh --check
python3 .github/scripts/build-graph.py --check
```

## エスカレーション

判断に自信がない、矛盾する evidence がある、または frozen の改訂が不可避な場合は、実装を進めず `ledger/open-questions.md` に追記して人間レビューを求める。
