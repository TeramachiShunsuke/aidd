<!--
案件（spec / 実装）リポジトリの .github/PULL_REQUEST_TEMPLATE.md にコピーして使う。
kernel（aidd）自身の PR テンプレートではない（それは .github/PULL_REQUEST_TEMPLATE.md）。
規約は ADR-00025、手順は PB-00022。
-->

## Issue

- Jira: <ISSUE-KEY>（タイトルは `<ISSUE-KEY> type(scope): 要約` になっているか）
- 受け入れ例: `specs/<feature>/acceptance-examples.md` の行 <#…>

## 何を変えたか

<!-- 1 段落。1 Issue に閉じていること。 -->

## 契約の変更

- [ ] なし
- [ ] あり → 定義ファイル: <openapi.yaml / migrations/… のパス>（Markdown に本文を写さない）

## 決定

- [ ] なし
- [ ] 案件 ADR: <パス>（共有境界 / 不可逆 / 選択肢あり のどれか）

## 規模

- 変更行数（生成物・lock・スナップショット除く）: <n> / 既定 400
- ファイル数: <n> / 既定 20
- [ ] 既定内
- [ ] 超過 → 理由: <…>（レビュアーの明示承認が要る）

## コミット

- [ ] 各コミットが 1 type（test / feat / fix / refactor / docs / build / ci / chore）
- [ ] footer に `Refs: <ISSUE-KEY>`
- [ ] 先頭コミットは green

## 検証

```bash
# 案件で決めた 1 コマンド（PB-00023）
make check
```

- [ ] 上記が PASSED
