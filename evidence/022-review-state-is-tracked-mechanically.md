---
id: EVID-022
title: レビュー状態の機械追跡には先行事例があり、いずれも事実の記録と判断の実行を分けている
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - reviews
  - lifecycle
  - ci
  - tooling
related:
  - EVID-016
  - EVID-003
  - ADR-012
tier: 3
---

## 主張

「レビューを通ったら文書の状態を機械的に更新する」という発想には成熟した先行事例がある。ただし観察できた実装は 2 系統に分かれ、**機械が書き込むのは事実だけ**（誰がいつ承認したか、親が変わったか）で、**status の遷移という判断は人間が行う**か、人間が押したラベルを引き金にしている。判断そのものを機械が下している例は見つからなかった。

## 観測

### 先行事例 1: Doorstop — レビュー済みの指紋と suspect link

[Doorstop](https://github.com/doorstop-dev/doorstop) は要求をファイルとしてバージョン管理し、次の 2 つを持つ。

- `reviewed`: 項目の**指紋**（UID・本文・参照・リンク先 UID から作る SHA-256）を、最後にレビューした時点の値として保存する。現在の指紋と一致しなければ「未レビューの変更あり」として警告する
- リンクは「親の UID」と「レビュー時点の親の指紋」の組で持つ。親が変わると子のリンクが **suspect（疑わしい）** として報告され、`doorstop clear` で解消する

つまり Doorstop の鮮度は日付ではなく**内容のハッシュ**で判定される。本リポジトリの `last_reviewed` は日付なので、本文を変えずに日付だけ進める操作を機械的に検出できない。逆に Doorstop は「内容が変わっていないのに時間だけ経った」ことは検出しない。両者は補い合う関係にある。

検査の等級も分かれている。ID が解決しない・参照先が見つからないは ERROR、未レビューの変更・suspect link・孤立項目は WARNING。[ADR-013](../adr/013-check-grades.md) と同じ線引きに独立に到達している。

### 先行事例 2: ADR の状態遷移の自動化

- [18F/adr-automation](https://github.com/18F/adr-automation): ADR を Issue として起案し、`ADR: accepted` ラベルを付けて閉じると、Action が Issue 本文を ADR 文書に変換し、番号と日付を振って**PR を開く**。main へ直接 commit はしない
- adr-sync: ADR ファイルと GitHub Discussions を双方向に同期し、status（Proposed / Accepted / Superseded）に応じて Discussion のラベルと開閉を更新する。更新されるのは Discussion 側であって、判断は文書側にある
- Structured MADR の GitHub Action: Frontmatter を JSON Schema で、本文を必須節の有無と順序で**検証するだけ**で、書き換えない。エラーは PR の該当行に注釈として出る。定期監査のために `schedule` 実行も推奨している

共通するのは、**引き金は人間の操作**（ラベル、Issue のクローズ、承認）であり、機械がやるのは変換・検証・通知に限られている点である。

### 本リポジトリの現状との差

- 「根拠が更新されたのに決定が再確認されていない」は、[ADR-013](../adr/013-check-grades.md) が日付の前後比較として警告に入れている。Doorstop の suspect link の弱い版にあたる。指紋を使えば、日付を触らない編集も捕まえられる
- status 遷移（`draft` → `active` → `frozen`）を検査する仕組みはない。`draft` のまま滞留している文書を知る手段もない
- 承認という事実は GitHub 側にしかなく、リポジトリの中には残らない。[ADR-012](../adr/012-review-attestations.md) の証跡は自己申告であり、誰かの approve と結びついていない

## 限界

- 4 例はいずれも公開ドキュメントとリポジトリの読解であり、実運用しての比較ではない
- Doorstop の指紋方式を本リポジトリに導入すると、Frontmatter に機械が書き込む値が増える。`frozen` 文書の指紋は本体に書けないため、[ADR-012](../adr/012-review-attestations.md) の証跡側に持つ設計が要る。移行コストは未見積もり
- 「承認を証跡に自動で書く」案は、GitHub Actions が main へ commit する権限を持つことを意味する。権限とレビュー証跡の意味（読んだのは誰か）を含めて別途判断が要る

## 関連

- [ADR-012](../adr/012-review-attestations.md) — 証跡による鮮度判定
- [ADR-013](../adr/013-check-grades.md) — 検査の等級。Doorstop と同じ線引き
- [EVID-003](003-doc-drift-is-regression.md) — 放置された文書は回帰である
- [Doorstop](https://github.com/doorstop-dev/doorstop) / [18F/adr-automation](https://github.com/18F/adr-automation) / [Structured MADR](https://smadr.dev/reference/github-action/)
