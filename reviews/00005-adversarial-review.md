---
id: REV-00005
title: リポジトリ全体の敵対レビューと取り込み
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - reviews
  - staleness
  - lifecycle
  - governance
related:
  - EVID-00016
  - ADR-00004
  - ADR-00010
  - ADR-00011
---

# リポジトリ全体の敵対レビューと取り込み

- 期間: 2026-08-09 — 2026-08-09
- 範囲: リポジトリ全体（commit `c86ecd1`）。観点は長期運用可能性・CI の保証範囲・知識の証拠能力・検索可能性・ツール可搬性・テンプレート再利用性
- 実施者: 外部エージェント（Codex）による敵対レビュー。指摘は別セッションの Claude Code が全件をスクリプト・規約・CI 定義と突き合わせて再検証した

## きっかけ

構造検査（Index / Graph / Staleness の 3 CI）がすべて緑である状態に対し、「構造整合性は保証されても運用整合性は保証されているか」を外部視点で監査させた。レビュー原文は一時ファイルとして出力されたもので、リポジトリには取り込まず、本 review と [EVID-00016](../evidence/00016-lifecycle-rules-deadlock.md)、OQ-00013..017 に分割したうえで、原文全文は本取り込み PR のレビューコメントとして添付した。

## 指摘と再検証の結果

| # | 指摘 | 再検証 | 取り込み先 |
| --- | --- | --- | --- |
| P0-1 | frozen・90 日鮮度・reviews 追記の 3 規則が論理的にデッドロックする | **確認。指摘より深刻**: reviews への追記は 90 日を待たず翌日から不可能（日付同期と byte-prefix 検査が両立しない）。frozen 5 件は 2026-11-07 に修復不能な期限切れになる | EVID-00016 / OQ-00013 |
| P0-2 | staleness CI は「継続的な鮮度」を保証しない（schedule なし・未来日通過・日付のみ変更許可・base 欠落スキップ・push:main の空振り） | **確認**。補足: push:main でも 90 日検査だけは有効。また branch protection は未設定以前に private + Free プランでは機能自体が使えない（403 を確認） | EVID-00016 / OQ-00014 |
| P0-3 | 必須ローカル検査が macOS で動かない（GNU `date -d` / `mapfile`） | **確認**。GNU bash 3.2.57 / gdate なしの開発機で `date: illegal option -- d` を再現 | EVID-00016 / OQ-00014 |
| P1-1 | ツール横断は設計済みだが実証が宣言に追いつかない | 妥当。既存の OQ-00011 / OQ-00012 が自己申告済み。本取り込み作業で進展あり（下記「検証」） | OQ-00012 を更新 |
| P1-2 | status 列挙・ID/ファイル名整合・未来日などのスキーマ検査が不足 | **確認**。ただし「未知の status で frozen 検査を回避」は既存 frozen には不成立（判定は base 側 status）。実リスクは typo 等で保護が一度も発動しないサイレント不発。PB-00008 が指示する tags 絞り込みが INDEX に存在しない不整合も確認 | OQ-00014 |
| P1-3 / P1-4 | 参照グラフは支持・反証・単なる関連を区別せず、evidence が自己証明になりやすい | 妥当。[ADR-00010](../adr/00010-knowledge-graph-layers.md) の「辺は参照の存在のみ」という設計自体と整合する認識論的限界 | OQ-00015 |
| P1-5 | owner・固定日付・ライセンスが埋め込まれ、テンプレートとして初期化できない | 事実。ただし欠陥ではなく製品境界の判断（実体は「AIDD Knowledge Base Template」に近い） | OQ-00016 |
| P1-6 | 文書形式は測定しているが AIDD の開発成果を測定していない | 事実。ブートストラップ期として許容しつつ、測定なしの表現拡張は文書官僚制化の危険 | OQ-00017 |

## 検証

- 再検証はすべて commit `c86ecd1` に対して実施し、行番号つきの機械的根拠を [EVID-00016](../evidence/00016-lifecycle-rules-deadlock.md) に記録した
- レビュー実施の過程で、Codex が `.agents/skills/aidd-graph-review` を実機で発火させた（正本パスの Codex 経路を初確認）
- 本取り込み作業は Claude Code（macOS）で実施し、`CLAUDE.md` の `@AGENTS.md` import と `.claude/skills/aidd-add-evidence`（symlink の鏡）経由の skill 発火が実機で機能することを確認した（ADR-00011 の Claude Code 経路を初確認）
- これにより OQ-00012 の 3 ツール実機確認のうち Codex / Claude Code が済み、未確認は CI 化の手段のみになった（OQ-00011 の Windows symlink は未検証のまま）

## 対応方針

レビューが提案した段階計画のうち、次の順序を採る。

1. **ライフサイクル再設計が最優先**（OQ-00013 → ADR-00012 候補）。frozen 文書の期限 2026-11-07 が実在するため期限付き。方向性は「レビュー証跡（review event）を文書本体から分離し、frozen は触らず attestation で effective freshness を導出、後継 `supersedes` を正とする」
2. 検証器の統合（OQ-00014）。schedule 追加・未来日拒否・スキーマ検査・macOS 対応・fixture テスト。**schedule の追加はライフサイクル再設計の後**でなければ、誰の PR でもないのに main が赤くなるだけの状態を先に作ってしまう
3. 権限モデル（CODEOWNERS / required checks）は、private リポジトリのままでは branch protection が使えないため、公開化またはプラン変更の判断が先行条件になる
4. 証拠能力メタデータ（OQ-00015）・テンプレート初期化（OQ-00016）・効果測定（OQ-00017）は上記の後
5. 上記が終わるまで、新しい知識表現・意味グラフ・新規 frozen 文書は増やさない

## 未対応の判断

- GRAPH.md の「入口のない手順」警告 4 件（PB-00004 / PB-00005 / PB-00006 / PB-00009）は対応しない。頻用手順にだけ入口を足す方針を維持し、警告消しのための skill 追加はしない（OQ-00008 の範囲）
- 現行 frozen 文書はライフサイクル再設計まで一切変更しない。新規 frozen の追加も一時停止する
