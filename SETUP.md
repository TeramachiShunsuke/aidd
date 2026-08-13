# SETUP — 最低限の利用と、改善できる理解

このリポジトリの**人向けの始め方**。考え方や使い方への共感は歓迎するが、必須ではない。読めば動けることを先にする。

規範は [AGENTS.md](AGENTS.md) と [CONVENTIONS.md](CONVENTIONS.md)、ID の地図は [GUIDE.md](GUIDE.md)、倉庫の説明と CI の一覧は [README.md](README.md) が正本である。ここは道順だけを書く。

| 層 | 対象 | できたと言える状態 |
| --- | --- | --- |
| [1. 最低限](#1-最低限わかっていたら無駄なく使える) | まず使う人 | このワークフローの機能を、無駄な操作をせずに使える |
| [2. 理解したら](#2-理解したらより効率的に使えこのリポジトリを改善できる) | 使い込み、直す人 | より効率的に使え、このリポジトリを改善できる |

層 1 だけで作業してよい。層 2 は必要になってから読む。

## 0. 環境（アプリの install はない）

このリポジトリに動かすアプリコードはない。次ができれば層 1 に足りる。

1. git で clone する（または GitHub 上で読む）
2. 変更は **Pull Request** で出す（品質ゲートは PR。[EVID-008](evidence/008-pr-as-quality-gate.md)）
3. 検査をローカルで回すなら `bash` と `python3`（追加パッケージは不要）
4. エージェントは任意。Codex / Cursor / Claude Code のどれでも同じ規範で動く（[ADR-011](adr/011-cross-tool-agent-integration.md)）

## 1. 最低限わかっていたら無駄なく使える

### 何をする場所か

観測を **evidence** に、決めたことを **ADR** に、繰り返すやり方を **playbook** に残す。主張の索引は `ledger/`、点検の記録は `reviews/`。エージェントはここを読んでから文書を足す。人はレビューと `status` の確定で権威を置く。

読み方は「何が分かっているか → 何を決めたか → どうやるか」。詳細なコード体系は層 2 の [GUIDE.md](GUIDE.md) に任せる。

### 日常のループ

1. [INDEX.md](INDEX.md) で、同じ話が既にないか ID を探す
2. 手元のものに合わせて書く。迷ったら [GUIDE.md](GUIDE.md) の判断表
   - 観測・引用 → `evidence/`（[PB-001](playbook/001-add-evidence.md)）
   - 選択肢から 1 つに決めた → `adr/`（[PB-002](playbook/002-write-adr.md)）。**根拠の evidence が先**
   - 繰り返す作業 → `playbook/`。見つけてもらえないときだけ skill（[PB-009](playbook/009-add-skill.md)）
   - 決められない → `ledger/open-questions.md`
3. 新規ファイルは [templates/](templates/) をコピーする
4. 番号は目視で数えず、機械に聞く（[ADR-018](adr/018-id-allocation.md)）

   ```bash
   git fetch --no-tags --prune origin '+refs/heads/*:refs/remotes/origin/*'
   bash .github/scripts/check-id-collisions.sh --next EVID
   ```

5. 生成物を **グラフ → 索引** の順に再生成する

   ```bash
   python3 .github/scripts/build-graph.py
   bash .github/scripts/build-index.sh
   ```

6. PR を **main** 向けに 1 意図で 1 本出す。テンプレートの関連 ID を埋める

### 無駄になる操作（やらない）

ここを守れば、層 1 でも機能を空回りさせない。

- 根拠のない決定を書かない（先に evidence。無ければ open-questions）
- このリポジトリ固有でない判断だけを残す。案件の API 名・画面・スキーマは入れない（[ADR-008](adr/008-sdd-bridge.md)）。働き方の ADR を案件の `adr/` にコピーして混ぜない（[ADR-019](adr/019-kernel-and-project-layers.md)）
- `INDEX.md` / `GRAPH.md` を手で編集しない
- `status: frozen` の本文を改変しない。直すなら後継 ID
- `reviews/` と `ledger/attestations.md` の既存行を書き換えない（末尾追記のみ）
- 秘密情報・トークン・個人データを commit しない
- 文書の `status` を「とりあえず」やスクリプトで進めない。遷移は人間（[ADR-017](adr/017-machines-record-facts-humans-decide-status.md)）
- PR を別 PR の上に積まない。番号を目視で採らない

### エージェントに頼むとき

人は SETUP のこの節まで読んだうえで作業を頼む。エージェントには [AGENTS.md](AGENTS.md) を読ませる（毎セッションの規範）。人が確認するのは、観測が本当かと、`draft` を `active` にしてよいか、の 2 点である。

## 2. 理解したらより効率的に使え、このリポジトリを改善できる

層 1 でループが回る人向け。地図と検査と改善の入口を持つ。

### 地図を持つ

[GUIDE.md](GUIDE.md) を通読する。ID の接頭辞、`related` と錨、lifecycle、Tier（ロードのタイミングであって重要度ではない。[ADR-006](adr/006-context-tiers.md)）が分かる。現在の一覧は [INDEX.md](INDEX.md)、参照と警告は [GRAPH.md](GRAPH.md)。

### このリポジトリを直す

改善も層 1 と同じループである。足すのは「他の案件でも繰り返す判断」だけ（[ADR-008](adr/008-sdd-bridge.md)）。手順の入口は次で足りることが多い。

| やりたいこと | 手順 |
| --- | --- |
| evidence / ADR / playbook を足す | [PB-001](playbook/001-add-evidence.md) / [PB-002](playbook/002-write-adr.md) / [CONVENTIONS.md](CONVENTIONS.md) |
| skill を足す（1 skill = 1 playbook） | [PB-009](playbook/009-add-skill.md) |
| 鮮度を回す・90 日を直す | [PB-003](playbook/003-run-review-cycle.md) / [PB-005](playbook/005-fix-staleness-ci.md) |
| frozen にする | [PB-004](playbook/004-freeze-document.md) |
| グラフの信号を読む | [PB-010](playbook/010-review-with-graph.md) |
| 競合・番号の衝突 | [PB-015](playbook/015-resolve-conflicts.md) |
| spec と KB の受け渡し | [PB-008](playbook/008-bridge-sdd-spec.md) |
| 新しい案件へ載せる | [PB-017](playbook/017-apply-kernel-to-project.md)（kernel の ADR を案件にコピーしない） |
| 散在ソースから evidence の下書き | [PB-018](playbook/018-draft-evidence-from-sources.md)（`draft` まで。確定は人間） |
| 大規模リリースの置き場 | [PB-016](playbook/016-large-project-usage-map.md) |

検査は PR 前にローカルで 3 つ。意味は [README.md](README.md) の鮮度ガード節。

```bash
bash .github/scripts/check-staleness.sh
python3 .github/scripts/build-graph.py --check
bash .github/scripts/build-index.sh --check
```

`frozen` を読み直して直す必要がなかったときは、本文を触らず [ledger/attestations.md](ledger/attestations.md) に 1 行追記する（[ADR-012](adr/012-review-attestations.md)）。エージェントは証跡を代筆しない。

### 効率の足し方

- 作業が決まるまで ADR / playbook の全文を開かない（Tier 2）
- 主張を疑うときだけ evidence / reviews を開く（Tier 3）
- 変更の波及は `python3 .github/scripts/build-graph.py --impact <ID>`
- 迷ったら open-questions に残す。決めきれないまま ADR を閉じない

## 3. 次に読むもの

- 層 1 の次: [INDEX.md](INDEX.md) で今の作業の playbook を 1 つ開く。ID で詰まったら [GUIDE.md](GUIDE.md) の §2 だけ
- 層 2 の次: [GUIDE.md](GUIDE.md) 全文 → 今直したい箇所の ADR → [GRAPH.md](GRAPH.md) のレビュー信号
- エージェントの規範が要るときだけ [AGENTS.md](AGENTS.md)
