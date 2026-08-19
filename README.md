# aidd

AI-Driven Development（AIDD）の運用知識を、証拠・決定・手順・台帳として蓄積するリポジトリ。

エージェントはコードを書く前に、このリポジトリの規約と関連文書を読む。人間はレビューと凍結で権威を確定する。

## 構成

| パス | 役割 | 件数の目安 |
| --- | --- | --- |
| [AGENTS.md](AGENTS.md) | エージェントの行動規範（常に読む） | 1 |
| [CONVENTIONS.md](CONVENTIONS.md) | 文書形式・Frontmatter・命名規則 | 1 |
| [GUIDE.md](GUIDE.md) | ID 体系と文書間リレーションの案内（地図） | 1 |
| [SETUP.md](SETUP.md) | 人向けの始め方（最低限の利用と、改善できる理解） | 1 |
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

各 ID の意味と文書同士のつながりは [GUIDE.md](GUIDE.md) にまとめてある。人の始め方は [SETUP.md](SETUP.md)。

## 信頼モデル

1. **evidence** が「何が分かっているか」を示す
2. **adr** が「何を決めたか」を固定する
3. **playbook** が「どうやるか」を再現可能にする
4. **ledger** が横断的な主張と未決を索引する
5. **reviews** が鮮度確認の監査証跡になる

`status: frozen` の文書は不変。変更が必要なら後継文書を作り、旧文書を `deprecated` にする。

## 読み込み階層（Tier）

全文書に Tier 0〜3 を割り当てる。Tier は**ロードのタイミング**であり、重要度の格付けではない（[ADR-00006](adr/00006-context-tiers.md)）。

| Tier | いつ読むか | 中身 |
| --- | --- | --- |
| 0 | 毎セッション、全文 | `AGENTS.md` / `CONVENTIONS.md` |
| 1 | 毎セッション、一覧のみ | `INDEX.md` / `GRAPH.md` / `GUIDE.md` / `SETUP.md` / `README.md` / `ledger/` / skills の `description` |
| 2 | 作業種別が決まったら | `adr/` / `playbook/` |
| 3 | 主張を疑うとき | `evidence/` / `reviews/` / 廃止文書 |

各文書の Tier は [INDEX.md](INDEX.md) に一覧される。

## 対応エージェント

Codex / Cursor / Claude Code のいずれからでも、同じ規範と同じ skill で動く。正本は 1 か所に置き、それを読まないツールにだけ橋を架ける（[ADR-00011](adr/00011-cross-tool-agent-integration.md)、根拠は [EVID-00015](evidence/00015-agent-tools-read-different-paths.md)）。

| ツール | 規範 | skill |
| --- | --- | --- |
| Codex | `AGENTS.md` | `.agents/skills/` |
| Cursor | `AGENTS.md` | `.agents/skills/` |
| Claude Code | `CLAUDE.md`（`@AGENTS.md` の 1 行） | `.claude/skills/` → 正本への symlink |

内容をツールごとに書き分けない。鏡が symlink であることは CI が検査する。Windows で `core.symlinks` が無効な環境だけは鏡が展開されないため、Claude Code 側で `/import` するか手動でコピーする（[OQ-00011](ledger/open-questions.md)）。

## 開発ループ（SDD → TDD）

このリポジトリの知識は「仕様を決めてからテストで固定する」開発ループを支える。

```text
evidence → ADR → spec(SDD) → 受け入れ例 → テスト(TDD) → 実装 → 知見を KB に戻す
```

- **SDD フェーズ**: evidence を根拠に ADR で決定し、spec（requirements / design / tasks）を書く。KB との受け渡しは [PB-00008](playbook/00008-bridge-sdd-spec.md)
- **受け入れ例**: PdO の要件をエージェントが問い、PdO が決める往復で具体値・境界・反例まで詰める（[PB-00020](playbook/00020-refine-acceptance-from-design.md)、`draft`）。成果物は案件リポに置く
- **TDD フェーズ**: 受け入れ例から外側のテストを起こし（[PB-00013](playbook/00013-start-tdd-from-examples.md)）、失敗→実装→整えるを回す。タスク・担当・コミット・PR の規約は [PB-00022](playbook/00022-run-work-units-from-acceptance.md)、言語別の品質ゲートは [PB-00023](playbook/00023-set-up-language-tdd-loop.md)、モデル階層と文脈は [PB-00024](playbook/00024-choose-model-effort-context.md)（いずれも `draft`）
- **還流**: 実装中に得た知見のうち、他案件でも繰り返すものだけ evidence / ADR として kernel に戻す

spec 本文は KB に取り込まない。リンクと ID のみを持つ（[ADR-00008](adr/00008-sdd-bridge.md)）。

## 他プロジェクトへの適用

このリポジトリは働き方の **kernel** である。新しい案件へ載せるときは、既存 ADR を残して参照し、案件の考え方と同じ `adr/` にコピーしない（[ADR-00019](adr/00019-kernel-and-project-layers.md)、手順は [PB-00017](playbook/00017-apply-kernel-to-project.md)）。SDD で運用中の spec リポジトリに Jira / Confluence ごと組み込む具体手順は [PB-00021](playbook/00021-embed-workflow-in-spec-repo.md)（`draft`）。kernel 自体の進め方は [ledger/roadmap.md](ledger/roadmap.md)。

AI 前提のプロジェクトなら、[PB-00017](playbook/00017-apply-kernel-to-project.md) で kernel を接続し、skill と CI を最初から有効にする。AI 以前の既存プロジェクトでも段階的に載せられる。evidence → ADR → playbook の順に、属人化や暗黙知の多い箇所から後追いで文書化し、CI やエージェントは文書が安定してから足す。詳細は [PB-00017](playbook/00017-apply-kernel-to-project.md) の段階的適用の節、始め方は [SETUP.md](SETUP.md) を参照。

根拠の入口は、人が観測を書く [PB-00001](playbook/00001-add-evidence.md) だけではない。Slack / 議事録 / Confluence など散在ソースからは、エージェントが `status: draft` の evidence を起こし、人間が観測を確認してから `active` にする（[PB-00018](playbook/00018-draft-evidence-from-sources.md)）。ログインアカウントを ACL 付きでワークフローに載せる PF は、このリポジトリの外のクライアントである。認証は git の外の IdP、git は認証情報を使わない。今の利用例を契約にしない（[ADR-00020](adr/00020-platform-is-a-client.md)）。

## 鮮度ガード（CI）

`.github/workflows/staleness.yml` が次を検査する。

- **frozen 不変性** — `status: frozen` の本文改変を拒否
- **last_reviewed 同期** — 本文変更時は `last_reviewed` を更新（追記専用ログは対象外）
- **追記専用ログのガード** — `reviews/**` と `ledger/attestations.md` の改変・削除を拒否（末尾追記と新規追加のみ）
- **90日期限** — 実効レビュー日（`last_reviewed` と証跡の最新日のうち新しい方）から 90 日超は失敗
- **証跡の妥当性** — 実在しない ID を指す証跡、未来日の日付を拒否
- **草案の滞留** — `draft` のまま 30 日を超えた文書を警告する（遷移は人間が決めるので落とさない）
- **週次実行と手動トリガー** — 期限超過は PR と無関係に起きるため `schedule`（週次）で検査し、`workflow_dispatch` でも随時実行できる

`frozen` 文書は本文を触れないため、レビューは [ledger/attestations.md](ledger/attestations.md) への 1 行追記で記録する（[ADR-00012](adr/00012-review-attestations.md)）。

`.github/workflows/index.yml` が [INDEX.md](INDEX.md) の最新性を検査する。

- **索引の最新性** — 再生成して差分が出たら失敗
- **Frontmatter 妥当性** — 必須キー欠落・`id` 重複・`tier` の範囲外を拒否
- **skill 整合性** — `name` とフォルダ名の不一致、参照先 playbook の不在、Claude 用 symlink の欠落・誤リンクを拒否
- **Frontmatter キーの重複** — `merge=union` が残しうる二重定義を拒否
- **ID 衝突の走査** — 同じ ID を別ファイル名で使っているブランチを報告する。base ブランチとの衝突は失敗（譲るのは必ず PR 側）、未着地のブランチ同士は警告（先に着地した方が保持する）。新規採番は `check-id-collisions.sh --next EVID` に聞く（[ADR-00018](adr/00018-id-allocation.md)）

`.github/workflows/graph.yml` が [GRAPH.md](GRAPH.md) の参照グラフを検査する。

- **参照の解決** — `related` と ledger の錨が実在する ID を指すこと
- **錨のある主張** — 錨を 1 つも持たない claim を拒否
- **リンク切れ** — 文書間の相対リンクが解決すること
- **決定の系譜** — ADR が evidence の錨を持ち、本文の `## 根拠` に挙げた ID が `related` にも載っていること（`frozen` は対象外）
- **廃止の巻き添え** — `deprecated` な根拠に乗る決定・主張を拒否
- **置き換えの一貫性** — `superseded_by` を持つ文書が `deprecated` であること
- **グラフの最新性** — 再生成して差分が出たら失敗

グラフは推論を含まず、辺はすべてファイル内の明示的な記述に遡れる（[ADR-00010](adr/00010-knowledge-graph-layers.md)）。未使用の根拠や入口のない手順といった**レビュー信号**は `GRAPH.md` に出るが CI は落とさない。エラーにするか警告に留めるかの基準は [ADR-00013](adr/00013-check-grades.md) にあり、違反 0 件で安定した検査から順にエラーへ上げる。

変更の影響範囲は次で照会できる。

```bash
python3 .github/scripts/build-graph.py --impact ADR-00006
```

## 使い方

人は [SETUP.md](SETUP.md) から始める。層は 2 つあり、考え方への共感は必須ではない。

1. **最低限** — ワークフローを無駄なく使う（SETUP §1）
2. **理解したら** — より効率的に使い、このリポジトリを改善する（SETUP §2）

エージェントの読み順は SETUP ではなく本 README の Tier 表と [AGENTS.md](AGENTS.md) である。新しい参加者を乗せる手順は [PB-00019](playbook/00019-onboard-with-setup-guide.md)。

## ライセンス

Private. リポジトリ所有者の利用に限定する。
