---
id: ADR-00012
title: レビュー証跡を文書から分離し、実効レビュー日で鮮度を判定する
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - staleness
  - lifecycle
  - frozen
  - ci
related:
  - EVID-00016
  - EVID-00003
  - ADR-00003
  - ADR-00004
  - ADR-00005
---

## 文脈

鮮度（ADR-00004）・frozen 不変（ADR-00003）・reviews 追記専用（ADR-00005）の 3 規則は、単独では正しいが組み合わせると出口のない状態を作る。[EVID-00016](../evidence/00016-lifecycle-rules-deadlock.md) が commit `c86ecd1` で機械的に確認した。

- frozen 文書は 1 バイトも変えられないため `last_reviewed` を更新できない。90 日検査は status を見ないので、frozen 5 件は 2026-11-07 に**修復手段のない CI 失敗**になる
- reviews への追記は本文変更として日付同期を要求するが、日付は Frontmatter にあり追記専用検査（旧内容が新内容の prefix）に反する。つまり追記は作成翌日から不可能

原因は共通で、「レビューした」という**出来事**を、レビュー対象の**文書本体**に書き込んでいることにある。文書が不変または追記専用であるほど、出来事を書き込む場所がなくなる。

## 決定

レビュー証跡（attestation）を文書本体から分離し、鮮度は実効レビュー日で判定する。

1. **証跡台帳**: `ledger/attestations.md` を追加し、1 行 1 レビューで追記する

   ```text
   - YYYY-MM-DD <文書 ID> <確認者> — <確認した内容>
   ```

2. **実効レビュー日** = `max(Frontmatter の last_reviewed, その ID に対する証跡の最新日)`。90 日検査はこの値で行う。frozen 文書は本体を触らずに証跡だけで鮮度を保てる

3. **追記専用ログの分類**: `reviews/**` と `ledger/attestations.md` を「ログ」とする。ログは
   - 追記専用検査の対象（既存バイトの改変・削除は失敗）
   - 日付同期検査の**対象外**（追記時に `last_reviewed` を触らない）
   - 90 日検査の**対象外**（履歴は古くて正しい）

4. **未来日の拒否**: `last_reviewed` と証跡の日付が今日（UTC）より後なら失敗させる。前借りで検査を無効化できないようにする

5. **証跡 ID の解決**: 証跡が指す ID が実在しなければ失敗させる。台帳が対象不明のまま増えるのを防ぐ

6. **定期実行**: 鮮度ワークフローに `schedule`（週次）を追加する。90 日超過は誰かの PR とは無関係に起きるため、PR 契機だけでは検知できない

証跡は「読み直して現行の運用と一致することを確認した」という主張であり、AGENTS.md が禁じる「本文レビューなしの日付更新」の代替手段ではない。読まずに証跡を足す行為は、日付だけ書き換える行為と同じく規約違反である。

## 根拠

- [EVID-00016](../evidence/00016-lifecycle-rules-deadlock.md): 3 規則のデッドロックと期限 2026-11-07 の機械的確認
- [EVID-00003](../evidence/00003-doc-drift-is-regression.md): 放置された文書は回帰であり、鮮度検査そのものは維持すべき

## 結果・トレードオフ

- 利点: frozen 文書を改変せずにレビュー可能になり、ADR-00003 と ADR-00004 が両立する
- 利点: reviews への追記が本来の意図どおり機能する
- 利点: 証跡が 1 ファイルに時系列で並ぶため、「いつ誰が何を確認したか」が grep で追える
- 代償: 鮮度の判定材料が 2 か所（Frontmatter と証跡台帳）に分かれる。単独の文書を読むだけでは実効レビュー日が分からず、検査スクリプトか `INDEX.md` を見る必要がある
- 代償: 証跡は自己申告であり、読んだことを機械的には検証できない。証跡の質は PR レビューで担保する

## 関連

- [ADR-00004](00004-staleness-policy.md): 決定 2（90 日）と対象範囲を本 ADR が改訂する。日付同期（決定 1）と `workflow_dispatch`（決定 3）は維持
- [ADR-00003](00003-frozen-immutability.md) / [ADR-00005](00005-reviews-append-only.md): どちらも改変しない。本 ADR は検査の適用範囲だけを変える
- [PB-00003](../playbook/00003-run-review-cycle.md) / [PB-00005](../playbook/00005-fix-staleness-ci.md)
- [ledger/attestations.md](../ledger/attestations.md)
