<!--
案件（spec / 実装）リポジトリの .github/PULL_REQUEST_TEMPLATE.md にコピーして使う。
kernel（aidd）自身の PR テンプレートではない（それは .github/PULL_REQUEST_TEMPLATE.md）。
規約は ADR-00025、手順は PB-00022、モデル節は ADR-00027 §5。
-->

## Story

- Jira: <STORY-KEY>（タイトルは `<STORY-KEY> type(scope): 要約` になっているか）
- 受け入れ例: `specs/<feature>/acceptance-examples.md` の行 ID <代表例-1, 境界-1..3, 反例-1>（spec リポが別なら URL + commit）

## 何を変えたか

<!-- 1 段落。1 Story に閉じていること。 -->

## 契約の変更

- [ ] なし
- [ ] あり（後方互換 / expand） → 定義ファイル: <openapi.yaml / migrations/… のパス>（Markdown に本文を写さない）

## 決定

- [ ] なし
- [ ] 案件 ADR: <パス>（共有境界 / 不可逆 / 選択肢あり のどれか）

## 規模

- 変更行数（案件 AGENTS.md の除外パターン適用後）: <n> / 既定 400
- ファイル数: <n> / 既定 20
- [ ] 既定内
- [ ] 超過 → 理由: <…>（レビュアーの明示承認が要る）

## コミット

- [ ] 各コミットが 1 type（feat / fix / test / refactor / docs / build / ci / chore / perf / revert）
- [ ] footer に `Refs: <STORY-KEY>`
- [ ] HEAD（マージ直前）のコミットは green

## モデル（必須。人が全部書いた場合は「人のみ」）

| タスク種別 | 初回の階層 / effort | 自動検査の初回合否 | 再試行回数 | 最終階層 |
| --- | --- | --- | --- | --- |
| <機械的 / 生成 / 判断> | <S / M / L> / <low / medium / high> | <合 / 否> | <n> | <S / M / L / 人> |

（任意）トークン数・所要時間: <…>

## 検証

```bash
# 案件で決めた 1 コマンド（PB-00023）。base 最新で再実行してからマージ
make check
```

- [ ] 上記が PASSED
