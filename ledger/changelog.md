---
id: LEDGER-CHANGELOG
title: Knowledge base changelog
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - ledger
  - changelog
---

# Changelog

知識ベース自体の注目すべき変更。新しいエントリを上に追記する。

## 2026-08-19

- PdO 設計 → 受け入れ条件の AI ワークフローを定義: EVID-00032 / ADR-00024 / PB-00020（`status: draft`）。雛形 `templates/acceptance-refinement-log.md` を追加し、`templates/acceptance-examples.md` に `status` / `巡` / `出所` 列を追加。skill `aidd-refine-acceptance`。CLAIM-00034、OQ-00040（3 巡・観点の妥当性）/ OQ-00041（kernel skill の案件リポへの配布）を追加。批判レビュー 3 巡の指摘と対応は REV-00010
- ledger の整理: 5 桁移行（ADR-00022）のマージで `merge=union` が残した 3 桁 ID の重複行（CLAIM-001..029、OQ-001..034 と Resolved の重複）を削除。3 桁しかなかった CLAIM-031..033 / OQ-038 / Resolved OQ-035..037, 039 を 5 桁に直し、旧 `ADR-022`（PF 第一歩）への参照を現 ID `ADR-00023` に合わせた（changelog と reviews の履歴は書き換えない）

## 2026-08-15

- 運用者指示により EVID-031 / ADR-022 を `draft` → `active`。OQ-039 を Resolved。AGENTS / README / GUIDE の PF 一文を ADR-022 に同期。OQ-035..037 の草案依存注記を外す
- リポジトリ矛盾点検とブラッシュアップ: REV-009。確認した矛盾は (C1) draft 錨のまま Resolved/CLAIM 化した統治、(C2) REV-007「着工」と ADR-022「着手」の語の衝突、(C3) ADR-022 内の製品名と汎用契約の滲み。C2 は REV-007 末尾で「製品着工」と「クライアント第一歩」を分離。C3 と手順信号は ADR-022 を改訂（製品名は検証例、kernel に PF playbook を置かない）。T2 は EVID-028 に層分けを追記。C1 は OQ-035..037 に草案依存注記と OQ-039（人間の status 遷移）を追加。CLAIM-033 を追加。AGENTS/README の更新は ADR-022 `active` 後（OQ-039）

## 2026-08-14

- PF の第一歩を草案として固定: EVID-031 / ADR-022（`status: draft`）。共有クライアント契約 + エージェント可呼び面（CLI 正準、必要なら同型 MCP）。IDE 同時第一世代・フル Web・desktop は第一歩の外。OQ-035..037 を Resolved、OQ-038（CLI と MCP の配布順）と CLAIM-031..032 を追加。REV-008 末尾に取り込み節を追記
- PF クライアント表面（IDE 拡張 → アプリ / Web / CLI）構想の敵対レビュー: REV-008。ADR-020 の「クライアント」方針とは両立するが、VS Code + IntelliJ 同時第一世代と「認証難題を Web に先送り」する順序を批判。OQ-035（第一世代 surface）/ OQ-036（IDE 同時着手の可否）/ OQ-037（共有クライアント契約を先に固定するか）を追加

## 2026-08-13

- 人向けセットアップ案内を二層で追加: SETUP.md / EVID-00030 / ADR-00021 / PB-00019 / skill `aidd-setup`。最低限でワークフローを無駄なく使える層と、理解したら効率よく使いこの KB を改善できる層。考え方への全共感は成功条件にしない。GUIDE は地図、README は倉庫と CI、AGENTS はエージェント規範のまま
- EVID-00028 の題を「認証の正本は Okta」から「今の利用では認証は Okta」へ直す。INDEX 上で製品名が契約に見えるのを避ける（契約は EVID-00029 / ADR-00020）
- 働き方の kernel と案件の考え方を分離: ADR-00019 / EVID-00024 / EVID-00025 / PB-00017 / PB-00018。既存 ADR は残して参照し、案件の `adr/` にコピーして混ぜない。散在ソース（Slack / 議事録 / Confluence）からは `draft` の evidence を起こし、観測の確定と status 遷移は人間が行う。skill `aidd-apply-to-project` / `aidd-draft-evidence` と `templates/evidence-intake.md` を追加。OQ-00016 / OQ-00021 を Resolved、OQ-00029 と CLAIM-00024..025 を追加
- PF・ログイン ACL・実行ワークフロー構想の敵対レビュー: REV-00007 / EVID-00026 / EVID-00027 / ADR-00020。現行モデルに principal も文書 ACL もなく、アカウント集約はソース ACL を越境させる。PF は別リポのクライアントとし、認可と実行状態を本 KB の文書モデルに埋め込まない。OQ-00030..033 と CLAIM-00026..028 を追加
- 批判レビューを Okta 仕様として取り込み: EVID-00028。認証の正本は Okta、git は認証情報を使わない。OQ-00030 / OQ-00031 を Resolved、OQ-00034 と CLAIM-00029 を追加。REV-00007 末尾に取り込み節を追記
- kernel の PF / IdP 契約を汎用に戻す: EVID-00029。今使おうとしている PF と Okta は実装例。契約は「IdP が認証、git は認証情報を使わない、PF はクライアント」。ADR-00020 を更新、REV-00007 に汎用性の節を追記

## 2026-08-09

- 大規模マルチ機能リリースの適用イメージを追加: PB-00016。権限管理・棚卸・ユーザーグループ・中間サーバーを例に、KB / 案件リポ / Figma / 契約 / テストの置き場を図にした。UI デザイン専用 ADR の要否を OQ-00028 に残し、GUIDE の判断表へ行を追加
- 採番の権威を main に置いた: ADR-00018 / EVID-00023 / CLAIM-00023。`check-id-collisions.sh` に `--next <PREFIX>`（main と全ブランチを走査して空き番号を返す）を追加し、base ブランチとの衝突を error、未着地ブランチ同士を warning に等級分けした。ファイル名変更を衝突と誤検出しないよう merge-base で判定する。PR の base は main を既定とし、積み上げ PR を禁止した（AGENTS / CONVENTIONS / PB-00015）
- 競合面を減らす: ADR-00016 / EVID-00021 / PB-00015 / skill `aidd-resolve-conflict`。`.gitattributes` で `ledger/*.md` と `reviews/*.md` を `merge=union` にし、生成物は再生成で解決すると決めた。`check-id-collisions.sh` が他ブランチとの ID 衝突を警告する（Index CI）。`merge=union` が残しうる Frontmatter キーの二重定義を error として検出する
- 機械と人間の分界を定義: ADR-00017 / EVID-00022 / CLAIM-00021..022。CI は事実の記録・不整合の検出・前提条件の検査に限り、`status` の遷移と証跡の代筆はしない。`draft` の 30 日滞留を鮮度検査の警告として追加（生成物に日付依存の行を入れないため `GRAPH.md` には出さない）。OQ-00024（台帳の断片化）と OQ-00025（指紋方式）を追加
- 実装スペックの扱いを定義: ADR-00014 / EVID-00018 / EVID-00019 / PB-00012 / PB-00013。契約・決定・振る舞いに分割し、文書に残すのは共有境界・不可逆・選択肢ありの決定だけとした
- DB / インフラの文脈を定義: ADR-00015 / EVID-00020 / PB-00014。制約・契約・状態の 3 層に分け、状態は文書化せず取得コマンドで渡す
- skill 3 件（aidd-spec-triage / aidd-tdd-start / aidd-infra-context）と `templates/acceptance-examples.md` を追加
- 検査を等級分け: ADR-00013 / EVID-00017 / PB-00011。決定の系譜（`## 根拠` と `related` の突き合わせ）・evidence 錨の必須化・deprecated 参照・`superseded_by` の一貫性を CI エラーへ昇格
- 昇格で検出したズレを修正: ADR-00006/007/008/009/010/011 の `related` に、本文で根拠に挙げていた evidence を追加（計 11 辺）
- `build-graph.py --impact <ID>` を追加し、変更の波及先を照会できるようにした
- OQ-00008 を Resolved へ移動。OQ-00020..023 を追加、claims に CLAIM-00017..020 を追加。PR #7 / #9 が main に届いていなかったため、EVID / ADR / CLAIM / OQ の番号を採番し直して着地させた（REV-00006）
- ライフサイクル矛盾を解消: ADR-00012 / `ledger/attestations.md` / CLAIM-00016 / REV-00006。鮮度を実効レビュー日（`last_reviewed` と証跡の最新日の新しい方）で測るようにし、frozen 文書を改変せずレビューできるようにした。`reviews/**` と証跡台帳を追記専用ログとして期限・日付同期の対象外に変更。未来日拒否・証跡 ID 解決・週次 `schedule` を追加し、`check-staleness.sh` から GNU 依存（`date -d` / `mapfile`）を除去して macOS で動くようにした。OQ-00013 を Resolved、OQ-00014 を縮小
- 敵対レビューを取り込み: REV-00005 / EVID-00016。ライフサイクル矛盾（frozen×90 日鮮度×reviews 追記、2026-11-07 期限）と staleness CI の保証範囲・macOS 非対応を記録。OQ-00013..017 を追加、OQ-00012 に Codex / Claude Code の実機確認を追記。ライフサイクル再設計（ADR-00012 候補）まで新規 frozen を凍結
- エージェント連携をツール横断化: ADR-00011 / EVID-00015。skill の正本を `.cursor/skills/` から `.agents/skills/` へ移し、`.claude/skills/` に symlink の鏡を作成。`CLAUDE.md` は `@AGENTS.md` の 1 行のみ。鏡の対応関係を Index CI が検査する
- 利用者向けに `GUIDE.md` を追加（ID コード体系・文書間リレーション・書き分け・ライフサイクル・実例）。Tier 1 に配置
- OQ-00006（skills の複製）を Resolved へ移動。OQ-00011..012 を追加、claims に CLAIM-00015 を追加
- 参照グラフを導入: ADR-00010 / EVID-00013 / EVID-00014 / PB-00010。`GRAPH.md` と `.github/scripts/build-graph.py`、Graph ワークフロー、skill `aidd-graph-review`
- Graphify（意味グラフ）を評価し、CI には入れない判断を記録（EVID-00013）。`graphify-out/` を `.gitignore` に追加
- OQ-00003（claims 錨のリンク切れ自動検知）を Resolved へ移動。OQ-00008..010 を追加、claims に CLAIM-00013..014 を追加
- Tier モデルを導入: ADR-00006 / EVID-00009 / PB-00006。Frontmatter の任意キー `tier` と既定規則（frozen 文書を書き換えずに導入）
- 生成インデックスを導入: ADR-00007 / EVID-00010 / PB-00007。`INDEX.md` と `.github/scripts/build-index.sh`、Index ワークフロー
- SDD 接続を定義: ADR-00008 / EVID-00011 / PB-00008 と `templates/sdd-handoff.md`（対応表・双方向の受け渡し・境界）
- skills を導入: ADR-00009 / EVID-00012 / PB-00009 と `templates/skill.md`。skill 5 件（PB-00001 / PB-00002 / PB-00003 / PB-00007 / PB-00008 の入口。置き場所は同日 ADR-00011 で `.agents/skills/` に変更）
- claims に CLAIM-00009..012、open-questions に OQ-00004..007 を追加
- README / AGENTS / CONVENTIONS / PR テンプレートを Tier・索引・skills・SDD に合わせて更新

## 2026-08-08

- 初回設計一式を追加: README / AGENTS / CONVENTIONS / evidence×8 / adr×5 / playbook×5 / ledger×3 / templates×4 / reviews×1 / staleness CI
- ADR-00001/002/003/005 と EVID-00004 を frozen として固定
