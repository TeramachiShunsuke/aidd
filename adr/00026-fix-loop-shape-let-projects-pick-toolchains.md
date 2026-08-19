---
id: ADR-00026
title: TDD ループの形と品質ゲートの構成は言語横断で固定し、言語別のツールチェーンは案件が選ぶ（kernel は既定候補だけ持つ）
status: draft
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - tdd
  - testing
  - toolchain
related:
  - EVID-00034
  - EVID-00018
  - ADR-00014
  - ADR-00019
  - ADR-00025
  - ADR-00027
---

## 文脈

運用者は Java / Python / TypeScript / JavaScript / Go での開発を見込んでおり、言語ごとに「最適な開発ワークフロー」を検討したい。kernel が言語ごとに別の手順を持つと、手順が 5 倍に増え、道具の更新に追随できない。一方で各言語の道具は収束しており、ループの形は共通である（[EVID-00034](../evidence/00034-language-toolchains-converge-loop-shape-is-shared.md)）。

## 決定

### 1. kernel が固定するもの（言語に依らない）

1. **ループの形**: 受け入れ例 **1 行 → 外側テスト 1 つ**（パラメタ化してよい）→ 内側を red / green / refactor → 全体を 1 コマンドの品質ゲートに通す（[PB-00013](../playbook/00013-start-tdd-from-examples.md)）。作業単位（Story）は外側テストの**束**であり、その定義は [ADR-00025](00025-control-work-units-commits-prs.md) §1
2. **品質ゲートの構成**: 整形の検査 → 静的検査（lint と、あれば型）→ 単体テスト → 外側（受け入れ）テスト、の 4 段を 1 コマンド（例: `make check`）にまとめる。どれか 1 つでも落ちれば失敗。順序は fail-fast の推奨であり、道具が 2 段を束ねる（Biome の整形 + lint、Gradle の `check` の並列実行）ことは妨げない
3. **外側と内側の分離**: 外側テストは受け入れ例の行番号を名前かコメントに持ち、内側テストと別に選んで走らせられる（タグ / マーカー / ビルド制約 / ディレクトリ）
4. **コミットとの対応**: red は `test:`、green は `feat:` / `fix:`、refactor は `refactor:`（[ADR-00025](00025-control-work-units-commits-prs.md)）
5. **外側テストが品質ゲートの一部であること**: 昇格規則（[ADR-00027](00027-cost-and-context-per-task.md) §2）は外側テストの失敗を引き金にするため、外側テストのないゲートでは成立しない

### 2. 案件が選ぶもの（既定候補は kernel が持つ）

道具の銘柄とバージョンは案件が決め、案件の `AGENTS.md` に「1 コマンド」と道具を書く。kernel は [PB-00023](../playbook/00023-set-up-language-tdd-loop.md) に言語別の既定候補と選定基準を置く。既定候補は変わりうるため、採用前に案件で確認する。

### 3. 書かないもの

言語別の設計手法、フレームワークの選択、ディレクトリ構成。これらは案件の考え方（[ADR-00019](00019-kernel-and-project-layers.md)）。

## 根拠

- [EVID-00034](../evidence/00034-language-toolchains-converge-loop-shape-is-shared.md): 道具は各言語で収束し、ループの形は共通
- [EVID-00018](../evidence/00018-tests-outlive-design-docs.md): 振る舞いの正本はテストであり、言語に依らない

## 結果・トレードオフ

- 利点: 手順は 1 本で、言語が増えても PB-00023 の表に 1 行足すだけ
- 利点: 「1 コマンドの品質ゲート」が言語をまたいで同じ契約になり、エージェントへの指示（[PB-00024](../playbook/00024-choose-model-effort-context.md)）も共通化できる
- 代償: 既定候補は時間とともに古くなる。90 日鮮度の対象として見直す
- 代償: 言語固有の最適化（例: Go のテーブル駆動、Python の性質テスト）は既定候補の備考に留まり、深い手順は案件側に任せる

## 関連

- [PB-00023](../playbook/00023-set-up-language-tdd-loop.md)
- [PB-00013](../playbook/00013-start-tdd-from-examples.md)
- [ADR-00025](00025-control-work-units-commits-prs.md)
- [ADR-00014](00014-implementation-spec-split.md)
