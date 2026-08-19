---
id: PB-00023
title: 言語ごとの TDD ループと 1 コマンドの品質ゲートを立ち上げる（Java / Python / TypeScript / JavaScript / Go）
status: draft
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - tdd
  - testing
  - toolchain
related:
  - ADR-00026
  - ADR-00025
  - PB-00013
  - PB-00022
  - PB-00021
tier: 2
---

## いつ使うか

案件リポジトリで最初の外側テストを書く前。言語が追加されたとき。「テスト・整形・lint をどう揃えるか」で迷ったとき。品質ゲートが複数コマンドに散らばっているとき。

ループの形は [ADR-00026](../adr/00026-fix-loop-shape-let-projects-pick-toolchains.md) で固定されている。本手順は言語ごとの既定候補と立ち上げ順である。

## 手順

### 1. 共通（全言語）

1. 品質ゲートを 1 コマンドにする（`make check` / `task check` / `npm run check` など案件で 1 つ）。中身は **整形検査 → 静的検査 → 単体テスト → 外側テスト** の順。どれか 1 つでも落ちれば失敗
2. 外側テストを内側と分けて走らせられるようにする（下表の「外側の分離」）。外側テストの名前かコメントに受け入れ例の**行 ID**（例: `acceptance-examples.md#境界-1`。spec リポが別なら `<spec リポ>/specs/<feature>/acceptance-examples.md#境界-1`。commit は書かない）を入れる。1 行 = 1 テスト（パラメタ化可）。`PdO 暫定` の行のテストには `暫定` の印（タグ / 名前）を付ける
3. 案件の `AGENTS.md` に「1 コマンド」「外側だけ走らせるコマンド」「採用した道具」を書く（[templates/spec-repo-agents.md](../templates/spec-repo-agents.md)）
4. CI は PR 単位で 1 コマンドを回す。red コミットを許す前提なので、コミット単位では回さない（[ADR-00025](../adr/00025-control-work-units-commits-prs.md) §3）

### 2. 言語別の既定候補

既定候補は 2026-08 時点の公式文書に基づく（[EVID-00034](../evidence/00034-language-toolchains-converge-loop-shape-is-shared.md)）。採用前に案件でバージョンを確認する。表にない道具を選んでもよいが、ゲートの 4 段は欠かさない。

| 言語 | 整形検査 | 静的検査 | 単体テスト | 外側の分離 | 1 コマンドの例 |
| --- | --- | --- | --- | --- | --- |
| Java | Spotless（`spotlessCheck`） | Checkstyle / Error Prone、アーキ規則は ArchUnit（テストとして走る） | JUnit 5 + AssertJ | `@Tag("acceptance")`。Gradle は JVM Test Suite プラグインで `acceptanceTest` を定義し `check.dependsOn` に足す（既定タスクではない）。Maven は Surefire（単体）/ Failsafe（外側、`<groups>acceptance</groups>`） | `./gradlew check` / `mvn -B verify` |
| Python | `ruff format --check` | `ruff check`、型は `mypy` か `pyright` | pytest | `@pytest.mark.acceptance` と `-m acceptance` / `-m "not acceptance"`。マーカーは `pyproject.toml` の `[tool.pytest.ini_options] markers` に登録し `--strict-markers` を付ける | `make check`（uv で固定した環境） |
| TypeScript | `prettier --check`（Biome なら `biome ci` が整形 + lint を 1 回で行う） | ESLint（typescript-eslint）または Biome、型は `tsc --noEmit` | Vitest（または Jest） | `tests/acceptance/` ディレクトリか Vitest の `projects` 分離。UI なら Playwright を外側に | `npm run check`（`format:check && lint && typecheck && test && test:acceptance`） |
| JavaScript | 同上 | 同上。型は JSDoc + `tsc --allowJs --checkJs --noEmit`（段階導入。`--noEmit` がないと出力で失敗する） | 同上 | 同上 | 同上 |
| Go | `gofmt -l` / `goimports -l` が空 | `go vet`、`staticcheck` または `golangci-lint` | `go test ./...`（テーブル駆動） | 既定は別パッケージ / ディレクトリ（例 `acceptance/`）。ビルドタグ `//go:build acceptance` を使うなら `go vet -tags acceptance ./...` と `go test -tags acceptance ./...` を並走させる（タグ付きファイルは無印の `go vet` / `go build` から外れる） | `make check` |

### 3. 言語別の注意（ループの回し方は同じ）

| 言語 | 注意 |
| --- | --- |
| Java | 外側テストはアプリケーション層の入口（サービス / API）に対して書き、フレームワークの起動が要るものは `acceptanceTest` に寄せて単体から外す。ArchUnit の規則は「決定」（案件 ADR）の機械化として使う |
| Python | 型は段階導入でよいが、ゲートに入れたら緩めない。外側テストは I/O の境界（関数 / エンドポイント）に書き、モックは内側だけ |
| TypeScript / JavaScript | 外側テストを UI の E2E に寄せすぎない。ロジックの受け入れ例はコンポーネントや関数の境界で書き、E2E は画面状態の例（PB-00016 §5）に限る |
| Go | 標準 `testing` のテーブル駆動で受け入れ例の表をそのまま写せる（1 行 = 1 ケース）。パッケージの公開 API に対して外側を書き、内部は自由に変えられる状態を保つ |

### 4. エージェントに渡すとき

5. 1 コマンドと外側だけのコマンドを指示に含める。ループは「外側を 1 つ落とす → 内側で通す → 1 コマンドが通るまで止めない → コミットは type ごと」（[PB-00013](00013-start-tdd-from-examples.md)、[PB-00022](00022-run-work-units-from-acceptance.md)）
6. 道具の導入・設定変更は `build:` / `ci:` のコミットに分け、振る舞いの変更と混ぜない

## 検証

- 1 コマンドで整形検査・静的検査・単体・外側の 4 段が走り、どれかが落ちると全体が失敗する
- 外側テストだけを走らせるコマンドがあり、各外側テストが受け入れ例の行を指している
- 案件 `AGENTS.md` に 1 コマンドと採用道具が書かれ、既定候補からの変更理由が（あれば）添えてある
- 道具の導入コミットが `build:` / `ci:` で、`feat:` と混ざっていない

## 失敗時

- 道具の選定で止まる → 表の既定候補をそのまま採り、変えたくなったら案件 ADR に理由を残す（共有境界 / 不可逆 / 選択肢ありのどれか。[PB-00012](00012-triage-implementation-spec.md)）
- 1 コマンドが遅い → 外側を PR 単位、内側をローカルの既定にし、両方を CI で回す。外側の数が多いなら代表行だけ外側に（[PB-00013](00013-start-tdd-from-examples.md) 失敗時）
- 型検査が既存コードで大量に落ちる → 新規ファイルだけ対象にして段階導入。緩和は期限付きで案件 ADR に書く
- 既定候補が古い → 表を更新する PR を kernel に出す（[PB-00008](00008-bridge-sdd-spec.md) 方向 B）。案件側は先に進んでよい

## 関連

- [ADR-00026](../adr/00026-fix-loop-shape-let-projects-pick-toolchains.md)
- [ADR-00025](../adr/00025-control-work-units-commits-prs.md)
- [EVID-00034](../evidence/00034-language-toolchains-converge-loop-shape-is-shared.md)
- [PB-00013](00013-start-tdd-from-examples.md)
- [PB-00022](00022-run-work-units-from-acceptance.md)
- [PB-00021](00021-embed-workflow-in-spec-repo.md)
- [templates/spec-repo-agents.md](../templates/spec-repo-agents.md)
- skill: [aidd-language-loop](../.agents/skills/aidd-language-loop/SKILL.md)
