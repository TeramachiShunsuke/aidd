# aidd

AI-Driven Development（AIDD）の運用知識を、証拠・決定・手順・台帳として蓄積するリポジトリ。

エージェントはコードを書く前に、このリポジトリの規約と関連文書を読む。人間はレビューと凍結で権威を確定する。

## 構成

| パス | 役割 | 件数の目安 |
| --- | --- | --- |
| [AGENTS.md](AGENTS.md) | エージェントの行動規範（常に読む） | 1 |
| [CONVENTIONS.md](CONVENTIONS.md) | 文書形式・Frontmatter・命名規則 | 1 |
| [GUIDE.md](GUIDE.md) | ID 体系と文書間リレーションの案内（人向けの入口） | 1 |
| [INDEX.md](INDEX.md) | 全文書の生成インデックス（手で編集しない） | 1 |
| [GRAPH.md](GRAPH.md) | 参照グラフとレビュー信号（手で編集しない） | 1 |
| [evidence/](evidence/) | 観測・根拠（主張の土台） | 増える |
| [adr/](adr/) | アーキテクチャ / 運用上の決定 | 増える |
| [playbook/](playbook/) | 繰り返し手順 | 増える |
| [ledger/](ledger/) | 主張・未決・変更・レビュー証跡の台帳 | 少数の定番ファイル |
| [templates/](templates/) | 新規文書の雛形 | 固定 |
| [reviews/](reviews/) | 定期レビュー記録（追記専用） | 増える |
| `.agents/skills/` | playbook への入口となる Agent Skills（正本） | 増える |
| `.claude/skills/` | Claude Code 用の鏡（正本への symlink） | 正本と同数 |

各 ID の意味と文書同士のつながりは [GUIDE.md](GUIDE.md) にまとめてある。

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
| 1 | 毎セッション、一覧のみ | `INDEX.md` / `GRAPH.md` / `GUIDE.md` / `README.md` / `ledger/` / skills の `description` |
| 2 | 作業種別が決まったら | `adr/` / `playbook/` |
| 3 | 主張を疑うとき | `evidence/` / `reviews/` / 廃止文書 |

各文書の Tier は [INDEX.md](INDEX.md) に一覧される。

## 対応エージェント

Codex / Cursor / Claude Code のいずれからでも、同じ規範と同じ skill で動く。正本は 1 か所に置き、それを読まないツールにだけ橋を架ける（[ADR-011](adr/011-cross-tool-agent-integration.md)、根拠は [EVID-015](evidence/015-agent-tools-read-different-paths.md)）。

| ツール | 規範 | skill |
| --- | --- | --- |
| Codex | `AGENTS.md` | `.agents/skills/` |
| Cursor | `AGENTS.md` | `.agents/skills/` |
| Claude Code | `CLAUDE.md`（`@AGENTS.md` の 1 行） | `.claude/skills/` → 正本への symlink |

内容をツールごとに書き分けない。鏡が symlink であることは CI が検査する。Windows で `core.symlinks` が無効な環境だけは鏡が展開されないため、Claude Code 側で `/import` するか手動でコピーする（[OQ-011](ledger/open-questions.md)）。

## 外部 spec との接続（SDD）

このリポジトリはコードを持たない。仕様駆動開発の成果物は実装リポジトリ側にあり、受け渡し規則を [ADR-008](adr/008-sdd-bridge.md) で定める。requirements は evidence / claims を引用し、横断で再利用する design だけが ADR に、繰り返す tasks だけが playbook に昇格する。spec 本文は取り込まず、リンクと ID のみを持つ。

## 鮮度ガード（CI）

`.github/workflows/staleness.yml` が次を検査する。

- **frozen 不変性** — `status: frozen` の本文改変を拒否
- **last_reviewed 同期** — 本文変更時は `last_reviewed` を更新（追記専用ログは対象外）
- **追記専用ログのガード** — `reviews/**` と `ledger/attestations.md` の改変・削除を拒否（末尾追記と新規追加のみ）
- **90日期限** — 実効レビュー日（`last_reviewed` と証跡の最新日のうち新しい方）から 90 日超は失敗
- **証跡の妥当性** — 実在しない ID を指す証跡、未来日の日付を拒否
- **草案の滞留** — `draft` のまま 30 日を超えた文書を警告する（遷移は人間が決めるので落とさない）
- **週次実行と手動トリガー** — 期限超過は PR と無関係に起きるため `schedule`（週次）で検査し、`workflow_dispatch` でも随時実行できる

`frozen` 文書は本文を触れないため、レビューは [ledger/attestations.md](ledger/attestations.md) への 1 行追記で記録する（[ADR-012](adr/012-review-attestations.md)）。

`.github/workflows/index.yml` が [INDEX.md](INDEX.md) の最新性を検査する。

- **索引の最新性** — 再生成して差分が出たら失敗
- **Frontmatter 妥当性** — 必須キー欠落・`id` 重複・`tier` の範囲外を拒否
- **skill 整合性** — `name` とフォルダ名の不一致、参照先 playbook の不在、Claude 用 symlink の欠落・誤リンクを拒否
- **Frontmatter キーの重複** — `merge=union` が残しうる二重定義を拒否
- **ID 衝突の走査** — 同じ ID を別ファイル名で使っているブランチを報告する。base ブランチとの衝突は失敗（譲るのは必ず PR 側）、未着地のブランチ同士は警告（先に着地した方が保持する）。新規採番は `check-id-collisions.sh --next EVID` に聞く（[ADR-018](adr/018-id-allocation.md)）

`.github/workflows/graph.yml` が [GRAPH.md](GRAPH.md) の参照グラフを検査する。

- **参照の解決** — `related` と ledger の錨が実在する ID を指すこと
- **錨のある主張** — 錨を 1 つも持たない claim を拒否
- **リンク切れ** — 文書間の相対リンクが解決すること
- **決定の系譜** — ADR が evidence の錨を持ち、本文の `## 根拠` に挙げた ID が `related` にも載っていること（`frozen` は対象外）
- **廃止の巻き添え** — `deprecated` な根拠に乗る決定・主張を拒否
- **置き換えの一貫性** — `superseded_by` を持つ文書が `deprecated` であること
- **グラフの最新性** — 再生成して差分が出たら失敗

グラフは推論を含まず、辺はすべてファイル内の明示的な記述に遡れる（[ADR-010](adr/010-knowledge-graph-layers.md)）。未使用の根拠や入口のない手順といった**レビュー信号**は `GRAPH.md` に出るが CI は落とさない。エラーにするか警告に留めるかの基準は [ADR-013](adr/013-check-grades.md) にあり、違反 0 件で安定した検査から順にエラーへ上げる。

変更の影響範囲は次で照会できる。

```bash
python3 .github/scripts/build-graph.py --impact ADR-006
```

## 使い方（最短）

1. [AGENTS.md](AGENTS.md) と [CONVENTIONS.md](CONVENTIONS.md) を読む（Tier 0）。ID 体系が初見なら [GUIDE.md](GUIDE.md)
2. [INDEX.md](INDEX.md) で関係する文書 ID を特定する（Tier 1）
3. 作業種別に応じて [playbook/](playbook/) を選ぶ
4. 新規文書は [templates/](templates/) から作る
5. 主張は [ledger/claims.md](ledger/claims.md) に錨を付ける
6. 生成物を再生成する（グラフ → 索引の順）

```bash
python3 .github/scripts/build-graph.py
bash .github/scripts/build-index.sh
```

7. PR ではテンプレートのチェックリストを埋める

## ライセンス

Private. リポジトリ所有者の利用に限定する。
