---
id: EVID-016
title: frozen・reviews・90 日鮮度の規則は同時に満たせず、期限付きで CI が修復不能になる
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - staleness
  - lifecycle
  - ci
related:
  - ADR-003
  - ADR-004
  - ADR-005
  - ADR-012
  - PB-003
  - PB-005
  - REV-005
tier: 3
---

## 主張

現行の 3 規則 — (1) frozen 文書は 1 バイトも変更不可、(2) reviews は既存バイトの prefix を保つ追記のみ、(3) 全対象文書は `last_reviewed` 90 日以内 — は同時に満たせない。規約に従う限り、2026-11-07 以降 frozen 文書と過去の review が順に期限切れになり、main の staleness CI は修復不能に赤くなる。また staleness CI の保証範囲は「イベント時点の一部形式検査」に留まり、必須ローカル検査は macOS 標準環境で実行できない。

## 観測

すべて commit `c86ecd1`（2026-08-09 時点の main）の静的読解と実機再現による。

### ライフサイクルの矛盾

- 90 日検査は status を問わず全対象文書に適用される（`check-staleness.sh:91-116`。[CONVENTIONS.md](../CONVENTIONS.md) も「`frozen` / `deprecated` も例外にしない」と明記）
- frozen 不変性検査は base（origin/main）との**バイト単位の差分**で判定するため（`check-staleness.sh:138`）、frozen 文書の `last_reviewed` だけを進める変更も「content changed」で失敗する
- reviews への追記はさらに強い矛盾を持つ。本文追記は内容変更なので `last_reviewed` を当日へ更新する必要があるが（`check-staleness.sh:174-175`）、Frontmatter はファイル先頭にあるため日付を書き換えた時点で「旧内容が新内容の byte prefix」でなくなり append-only 検査（`check-staleness.sh:203-206`）に失敗する。日付を更新しなければ sync 検査に失敗する。つまり**既存 review へ追記できるのは作成当日（UTC）だけ**で、以後は事実上 immutable のまま 90 日で期限切れになる
- 期限は実在する。frozen 5 件（ADR-001/002/003/005、EVID-004）と REV-001 は `last_reviewed: 2026-08-08` であり、2026-11-07 に 91 日となって失敗する。REV-002..004（2026-08-09 付）は 2026-11-08 に続く。規約準拠の修復手段は存在しない

### staleness CI の保証範囲

- `staleness.yml` に `schedule` トリガーがなく、時間経過だけでは検査が起動しない（pull_request / push:main / workflow_dispatch のみ）。上記の期限切れは「その日以降に誰かが対象パスへ PR を出したとき」に初めて顕在化する
- `last_reviewed` が未来日の場合、経過日数が負になり `> 90` を満たさず通過する（`check-staleness.sh:110-111`。未来日を拒否する検査はない）
- 日付のみの変更はスクリプトが明示的に許可する（`check-staleness.sh:169-171`）。「レビュー実施時に限る」という規約（CONVENTIONS）は機械検査されない
- base ref が見つからない場合、frozen / append / sync の 3 検査は警告のみでスキップされる（`check-staleness.sh:26`）
- `push: main` イベントでは fetch 後の `origin/main` が HEAD と一致するため、diff 依存の 3 検査は空振りになる（90 日検査のみ有効に動く）
- branch protection は未設定である以前に、**private リポジトリの Free プランでは機能自体が使えない**（2026-08-09、`gh api repos/TeramachiShunsuke/aidd/branches/main/protection` が HTTP 403 "Upgrade to GitHub Pro or make this repository public" を返すことを確認）。required checks や CODEOWNERS 強制を前提とする運用は、公開化またはプラン変更なしには成立しない
- 新規ファイルは `last_reviewed` が実行日と完全一致することを要求される（`check-staleness.sh:160-161`）ため、UTC 日付をまたいだ PR は追加変更なしでも失敗する（同族の摩擦）

### macOS でのローカル検査不能

- `check-staleness.sh` は GNU 専用の `date -u -d`（`:104-105`）と Bash 4 以降の `mapfile`（`:120-121`）に依存する
- 本リポジトリの開発機（macOS / GNU bash 3.2.57 / `gdate` なし）で 2026-08-09 に実行し、`date: illegal option -- d` で失敗することを再現した。[AGENTS.md](../AGENTS.md) の完了条件に含まれるローカル検査が、macOS 標準環境では完了できない

## 限界

- 2026-11-07 の CI 失敗は規則とスクリプトからの導出であり、実際に 91 日経過した CI 実行はまだ観測していない（`workflow_dispatch` の `TODAY` 環境変数で前倒し再現は可能）
- GNU 環境（CI の ubuntu-latest）では日付処理・mapfile とも正常に動作しており、検査ロジック自体の欠陥は 90 日・未来日・base 欠落の扱いに限る
- 解消方式（レビュー証跡の分離、effective freshness の導出、後継優先など）はここでは主張しない。設計判断は ADR を要する（OQ-013）

## 関連

- [ADR-003](../adr/003-frozen-immutability.md) — frozen 不変性の決定
- [ADR-004](../adr/004-staleness-policy.md) — 90 日鮮度ポリシーの決定
- [ADR-005](../adr/005-reviews-append-only.md) — reviews 追記のみの決定
- [ADR-012](../adr/012-review-attestations.md) — 本観測を受けた解消（レビュー証跡の分離・実効レビュー日・未来日拒否・週次実行・macOS 対応）
- [PB-003](../playbook/003-run-review-cycle.md) / [PB-005](../playbook/005-fix-staleness-ci.md) — 影響を受ける手順
- [REV-005](../reviews/005-adversarial-review.md) — 本観測の出所となった敵対レビュー
- OQ-013 / OQ-014（ledger/open-questions.md）
