---
id: EVID-010
title: 手書き目次は腐るが、生成物なら差分で腐敗を検出できる
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - index
  - ci
related:
  - EVID-003
  - ADR-007
tier: 3
---

## 主張

目次を人手で維持すると、文書の追加・改名・status 変更に追随できず、実体と食い違う。目次を**生成物**にすれば、食い違いは CI の差分として機械的に検出できる。

## 観測

- 本リポジトリの入口は現状 [README.md](../README.md) のディレクトリ表と [ledger/claims.md](../ledger/claims.md) に分かれている。どちらも人手更新で、文書を 1 件追加しても更新が強制されない。
- `status` と `last_reviewed` は Frontmatter にあり機械可読（[ADR-002](../adr/002-frontmatter-schema.md)）。目次に必要な情報はすべて本文側に存在しており、目次は本来「導出できる」データである。
- 導出できるデータを人手で二重管理すると、片方だけが更新されて矛盾する。これは [EVID-003](003-doc-drift-is-regression.md) が扱う文書ドリフトと同じ構造の回帰である。
- 生成物を出力の一部として固定しておけば、「再生成して差分が出るか」で最新性を検査できる。検査を成立させるには出力が決定的である必要があり、生成日時のような実行ごとに変わる値を出力に含めてはならない。

## 限界

生成インデックスが保証するのは「一覧の網羅と最新性」までで、各文書の内容が正しいことは保証しない。内容の正しさは引き続き reviews と鮮度検査の担当である。

## 関連

- [ADR-007](../adr/007-generated-index.md)
- [PB-007](../playbook/007-rebuild-index.md)
- [EVID-003](003-doc-drift-is-regression.md)
