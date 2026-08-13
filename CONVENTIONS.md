# CONVENTIONS.md

文書の形式・命名・Frontmatter・更新規則。機械検査の前提でもある。

## ディレクトリと ID

| ディレクトリ | ID 接頭辞 | ファイル名 |
| --- | --- | --- |
| `evidence/` | `EVID` | `NNN-short-slug.md` |
| `adr/` | `ADR` | `NNN-short-slug.md` |
| `playbook/` | `PB` | `NNN-short-slug.md` |
| `reviews/` | `REV` | `NNN-short-slug.md` |
| `ledger/` | （固定名） | `claims.md` / `open-questions.md` / `changelog.md` / `attestations.md` |
| `templates/` | — | 種別ごとの雛形（コピー元。CI 対象外のメタ扱い可） |
| `.agents/skills/` | （skill 名） | `<name>/SKILL.md`（playbook への入口。正本） |
| `.claude/skills/` | （skill 名） | 正本への symlink（Claude Code 用の鏡） |
| `INDEX.md` | — | 生成物。手で編集しない |
| `GRAPH.md` | — | 生成物。参照グラフとレビュー信号 |
| `GUIDE.md` | — | ID 体系とリレーションの案内（人向け。規範は本ファイル） |
| `CLAUDE.md` | — | `@AGENTS.md` の 1 行のみ。規範を書かない |

`NNN` はゼロ埋め 3 桁。slug は英小文字ケバブケース。ID の意味と文書同士のつながりの解説は [GUIDE.md](GUIDE.md) にある（本ファイルは規範、GUIDE は案内）。

### 採番

番号は自分で数えず、main と開いている全ブランチを走査して取る（[ADR-018](adr/018-id-allocation.md)）。

```bash
bash .github/scripts/check-id-collisions.sh --next EVID
```

ID は一度公開したら変えない。ただし**マージ前に base ブランチと衝突していた場合は、必ず自分の側が振り直す**（main は過去を書き換えない）。未着地のブランチ同士の衝突は警告に留まり、先に main へ着地した方が番号を保持する。手順は [PB-015](playbook/015-resolve-conflicts.md)。

PR の base は main を既定とする。積み上げ PR は、親がマージされても子は main に届かないため、番号が確保されないまま滞留し衝突の温床になる。

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
| `related` | 関連文書 ID の配列。**非対称でよい**（相手側に書き返す義務はない） |
| `supersedes` | 置き換える旧 ID |
| `superseded_by` | 後継 ID（deprecated 時） |
| `tier` | ロード階層 `0`〜`3`。既定と変えたいときだけ書く（[ADR-006](adr/006-context-tiers.md)） |

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

## last_reviewed と実効レビュー日

- タイムゾーンは **UTC 日付**（`YYYY-MM-DD`）
- 本文または意味のある Frontmatter を変えたら、必ず当日に更新する
- 未来日は書けない（CI が拒否する）
- 鮮度は**実効レビュー日** = `max(last_reviewed, ledger/attestations.md にあるその ID の最新日)` で測る（[ADR-012](adr/012-review-attestations.md)）
- **90 日**を超えると CI が失敗する（`frozen` / `deprecated` も例外にしない。鮮度の説明責任は残す）
- 読み直して直す必要がなかった場合は、本文を触らず `ledger/attestations.md` に証跡を 1 行追記する。`frozen` 文書のレビュー手段はこれだけ
- 追記専用ログ（`reviews/**` と `ledger/attestations.md`）は 90 日検査と日付同期の対象外。履歴は古くて正しい

## Tier マッピング

Tier はロードのタイミングであり、重要度の格付けではない。定義は [ADR-006](adr/006-context-tiers.md)。

| Tier | いつ読むか | 既定で入るもの |
| --- | --- | --- |
| 0 | 毎セッション、全文 | `AGENTS.md` / `CONVENTIONS.md` |
| 1 | 毎セッション、一覧のみ | `INDEX.md` / `GRAPH.md` / `GUIDE.md` / `README.md` / `ledger/*` / `.agents/skills/*` |
| 2 | 作業種別が決まったら全文 | `adr/*` / `playbook/*` |
| 3 | 主張を疑うとき・監査時 | `evidence/*` / `reviews/*` / `deprecated` 全般 |

- 既定で妥当なら `tier` は**書かない**
- `status: frozen` に `tier` を後付けしない（不変のため）
- `status: deprecated` は `tier` を持たない（常に Tier 3）
- 違反は `build-index.sh` が検出する

## 生成インデックス（INDEX.md）

- 生成: `bash .github/scripts/build-index.sh`
- 検査: `bash .github/scripts/build-index.sh --check`（CI で実行）
- 出力は決定的。生成日時など実行ごとに変わる値を入れない
- 手で編集しない。直すのは生成元の Frontmatter
- 検査内容: 必須キーの欠落、`id` 重複、`tier` の範囲、skill の `name` とフォルダ名の一致、skill が参照する playbook の存在
- 詳細は [ADR-007](adr/007-generated-index.md) と [PB-007](playbook/007-rebuild-index.md)

## 参照グラフ（GRAPH.md）

- 生成: `python3 .github/scripts/build-graph.py`
- 検査: `python3 .github/scripts/build-graph.py --check`（CI で実行）
- 生成物の更新順は **グラフ → 索引**（索引が `GRAPH.md` を拾うため）
- 辺は明示メタデータのみ。`related` / `supersedes` / `superseded_by`、文書間リンク、claims の錨、skill の `metadata.aidd-playbook`。**推論した辺は持たない**
- 影響範囲の照会: `python3 .github/scripts/build-graph.py --impact <ID>`
- CI が落ちる検査（[ADR-013](adr/013-check-grades.md)）
  1. 参照の未解決 / 錨のない claim / リンク切れ / `GRAPH.md` の陳腐化
  2. ADR の `## 根拠` 節に挙げた ID が `related` にない（`frozen` は対象外）
  3. ADR が evidence の錨を持たない
  4. 決定・主張が `deprecated` な根拠に乗っている
  5. `superseded_by` を持つのに `status: deprecated` でない
- 残り（未使用の根拠、手順のない決定、入口のない手順、草案に乗る決定、追随していない決定、孤立）は**警告**で、レビュー候補として `GRAPH.md` に出る
- 昇格は違反 0 件・修正方法が一意・frozen を壊さない、の 3 条件を満たすときのみ（[PB-011](playbook/011-promote-check.md)）
- 意味グラフ（LLM ベース）は CI に入れない。詳細は [ADR-010](adr/010-knowledge-graph-layers.md)、読み方は [PB-010](playbook/010-review-with-graph.md)

## skills

- 置き場所: 正本は `.agents/skills/<name>/SKILL.md`、Claude Code 用の鏡は `.claude/skills/<name>`（symlink）。詳細は [ADR-011](adr/011-cross-tool-agent-integration.md)
- **1 skill = 1 playbook**。手順の正本は `playbook/` にあり、SKILL.md には要点（5 行以内）とリンクのみ置く
- Frontmatter は Agent Skills 標準の範囲に限る

  ```yaml
  ---
  name: <フォルダ名と一致>
  description: <何をするか>。<いつ使うか>。
  metadata:
    aidd-playbook: PB-NNN
    aidd-tier: "1"
  ---
  ```

- 本文は `## いつ使うか` / `## 先に読むもの` / `## 手順の要点` / `## 禁止事項` の 4 節
- 鏡は必ず symlink（`../../.agents/skills/<name>`）。ファイルを複製しない。CI が対応関係とリンク先を検査する
- 雛形は [templates/skill.md](templates/skill.md)、手順は [PB-009](playbook/009-add-skill.md)

## エージェント連携

規範と skill の正本は 1 か所に置き、それを読まないツールにだけ橋を架ける（[ADR-011](adr/011-cross-tool-agent-integration.md)）。

| ツール | 規範 | skill |
| --- | --- | --- |
| Codex / Cursor | `AGENTS.md` | `.agents/skills/` |
| Claude Code | `CLAUDE.md`（`@AGENTS.md` の 1 行） | `.claude/skills/`（symlink） |

- `CLAUDE.md` に規範を書かない。Claude 固有の指示が要る場合のみ import 行の下に足す
- `.cursor/rules/*.mdc` など、ツール固有のルールファイルに規範を複製しない

## SDD 接続

外部の仕様駆動開発（requirements / design / tasks）との受け渡し規則は [ADR-008](adr/008-sdd-bridge.md)。

| SDD 成果物 | KB 側 |
| --- | --- |
| requirements | `evidence/` / `ledger/claims.md` |
| design | `adr/`（横断で再利用する決定のみ） |
| tasks | `playbook/`（繰り返す手順のみ） |

- spec 本文を KB に転記しない（リンクと ID のみ）
- 実装固有の識別子を KB 文書に持ち込まない
- 昇格の判断基準は「他プロジェクトでも同じ判断を繰り返すか」
- 本リポジトリは働き方の **kernel** である。案件の考え方は案件リポ側に置き、kernel の `adr/` に混ぜない（[ADR-019](adr/019-kernel-and-project-layers.md)、手順は [PB-017](playbook/017-apply-kernel-to-project.md)）
- 受け渡しシートは [templates/sdd-handoff.md](templates/sdd-handoff.md)、手順は [PB-008](playbook/008-bridge-sdd-spec.md)

## 追記専用ログの規則

対象は `reviews/**` と `ledger/attestations.md`。

許可:

- 新規 `reviews/NNN-*.md` の追加
- 既存ファイル末尾への追記（バイト列が旧内容の prefix であること）

禁止:

- 既存バイトの改変・削除（Frontmatter を含む。だから追記時に `last_reviewed` を触ってはいけない）
- ファイル削除・リネーム（必要な場合は人間が main で特例処理）

## ledger

- `claims.md` — 主張と錨（`evidence:` / `adr:` / `url:`）
- `open-questions.md` — 未決とブロッカー
- `changelog.md` — 知識ベース自体の注目すべき変更（追記主体）
- `attestations.md` — レビュー証跡（追記専用ログ）。形式は `- YYYY-MM-DD <文書 ID> <確認者> — <確認した内容>`。ID が実在しない行と未来日は CI が拒否する

`ledger/*.md` と `reviews/*.md` は `.gitattributes` で `merge=union` を指定してある（[ADR-016](adr/016-shrink-conflict-surface.md)）。競合の代わりに両側の行が残るので、マージ後は重複 ID を検査で確認する。手順は [PB-015](playbook/015-resolve-conflicts.md)。

claims の 1 行例:

```markdown
- [ ] CLAIM-001: frozen 文書は CI で不変 — evidence:EVID-004 adr:ADR-003
```

## PR

- [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md) を使う
- 関連 ID を明記する
- `GRAPH.md` と `INDEX.md` を再生成して同じコミットに含める
- Staleness / Index / Graph の 3 CI を緑にする

## 言語

- 文書本文は日本語を基本とする
- ID・ファイル名・タグ・Frontmatter キーは英語
