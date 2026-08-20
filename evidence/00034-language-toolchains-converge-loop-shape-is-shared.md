---
id: EVID-00034
title: 主要言語のテスト・整形・静的検査の道具は各エコシステムで収束しており、TDD ループの形は言語をまたいで同じである
status: active
last_reviewed: 2026-08-20
owners:
  - TeramachiShunsuke
tags:
  - tdd
  - testing
  - toolchain
related:
  - EVID-00018
  - EVID-00033
  - ADR-00014
  - ADR-00019
---

## 主張

Java / Python / TypeScript / JavaScript / Go のいずれも、テストランナー・整形・静的検査（lint / 型）には公式または事実上の標準となった道具があり、選択肢で迷う場面は少ない。一方で「外側のテストを 1 つ落とす → 内側を red / green / refactor で回す → 1 コマンドの品質ゲートを通す」というループの形は言語に依らない。したがって kernel が固定すべきはループの形と品質ゲートの構成であり、道具の銘柄は案件が選ぶ（既定候補だけ置く）のが妥当である。

## 観測

2026-08 時点で各言語の公式文書・広く参照されるプロジェクトから確認できる範囲:

| 言語 | テスト | 整形 | 静的検査（lint / 型） | 備考 |
| --- | --- | --- | --- | --- |
| Java | [JUnit](https://junit.org/)（Jupiter API。2026-08 時点の現行世代は JUnit 6） | [Spotless](https://github.com/diffplug/spotless)（google-java-format 等を適用） | Checkstyle / Error Prone、アーキテクチャ規則は [ArchUnit](https://www.archunit.org/) | ビルドは Maven か Gradle。アサーションは [AssertJ](https://assertj.github.io/doc/) が広く使われる |
| Python | [pytest](https://docs.pytest.org/) | [Ruff](https://docs.astral.sh/ruff/)（formatter を内蔵） | Ruff（lint）、型は [mypy](https://mypy.readthedocs.io/) または [Pyright](https://github.com/microsoft/pyright) | 環境・依存は [uv](https://docs.astral.sh/uv/) 等。性質テストは [Hypothesis](https://hypothesis.readthedocs.io/) |
| TypeScript | [Vitest](https://vitest.dev/)（または Jest） | [Prettier](https://prettier.io/) または [Biome](https://biomejs.dev/) | ESLint（typescript-eslint）または Biome、型は `tsc --noEmit` | E2E は [Playwright](https://playwright.dev/) |
| JavaScript | 同上 | 同上 | 同上。型ゲートは JSDoc + `tsc --allowJs --checkJs --noEmit`（[tsconfig checkJs](https://www.typescriptlang.org/tsconfig/#checkJs)）で代替できる | TS と道具を共有できる |
| Go | 標準 [testing](https://pkg.go.dev/testing)（`go test`、テーブル駆動） | `gofmt`（ツールチェーン同梱）/ [goimports](https://pkg.go.dev/golang.org/x/tools/cmd/goimports)（`golang.org/x/tools`） | `go vet`、[staticcheck](https://staticcheck.dev/)、[golangci-lint](https://golangci-lint.run/) | アサーションは標準で足りる。[testify](https://github.com/stretchr/testify) を使う例も多い |

- Go は整形器（gofmt）と `go vet` がツールチェーンに同梱され、選択の余地がほぼない（goimports は `x/tools` だが事実上の標準）。Python は Ruff が lint と整形を 1 つに束ねた。TS / JS は Prettier + ESLint か Biome の 2 択に収束している。Java はビルドツール（Maven / Gradle）の差があるが、テストは JUnit（Jupiter API）で一致する。
- 外側テスト（受け入れ例 1 行 = 1 テスト。パラメタ化可）と内側テストの分離は、どの言語でも「タグ / マーカー / ビルド制約 / ディレクトリ」で表現できる（JUnit の `@Tag`、pytest の `-m` マーカー、Vitest の `projects` やディレクトリ、Go のディレクトリ分離か `//go:build` 制約）。ただしビルド制約で外したファイルは無印の `go vet` / `go build` の対象から外れるため、静的検査も同じタグで回す必要がある。
- 本リポジトリの方針は「振る舞いはテスト、契約は定義ファイル、決定だけ文書」（[EVID-00018](00018-tests-outlive-design-docs.md)、[ADR-00014](../adr/00014-implementation-spec-split.md)）であり、言語によって変わらない。道具の銘柄は案件の考え方（[ADR-00019](../adr/00019-kernel-and-project-layers.md)）に属する。
- コミットの粒度を TDD のステップに合わせる規約（[EVID-00033](00033-work-units-align-to-acceptance-and-small-prs.md)）も、言語に依存しない。

## 限界

上の表は公式文書と広く参照される OSS の存在に基づく「既定候補」であり、利用率や性能を測定していない。道具のバージョンと推奨は変わるため、表は案件で確認のうえ採用する。エージェントが各言語で同じ精度で TDD を回せるかは未測定。組込み・モバイル・データ基盤など、ここに挙げた 5 言語以外や特殊な実行環境は対象外。

## 関連

- [ADR-00026](../adr/00026-fix-loop-shape-let-projects-pick-toolchains.md)
- [PB-00023](../playbook/00023-set-up-language-tdd-loop.md)
- [PB-00013](../playbook/00013-start-tdd-from-examples.md)
