---
id: EVID-00031
title: 生成AIコーディングエージェントの主経路はファイル・シェル・ツール呼び出しである
status: draft
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - platform
  - agents
  - interface
related:
  - EVID-00015
  - EVID-00012
  - EVID-00008
  - ADR-00011
  - ADR-00020
  - ADR-00022
  - REV-00008
  - REV-00009
---

## 主張

Cursor / Claude Code / Codex などの生成AIコーディングエージェントは、人が見る GUI ではなく、リポジトリ上のファイル・シェルコマンド・ツール呼び出し（skills / MCP 等）を主経路として動く。PF が GUI 専用の操作面だけを第一世代にすると、これらのエージェントと並行に使えず、第二の操作正本になりやすい。

## 観測

- [EVID-00015](00015-agent-tools-read-different-paths.md) のとおり、3 ツールはいずれもプロジェクト内の Markdown（`AGENTS.md` / `CLAUDE.md`）と skill ディレクトリを探索して手順を発見する。共通しているのは「リポジトリ上のファイルを読む」ことであり、「製品 GUI を開く」ことではない。
- [EVID-00012](00012-skills-are-progressive-disclosure.md) のとおり、Agent Skills は起動時に `description` だけを読み、一致後に本文と `scripts/` 等を読む。エージェントはシェルやスクリプトを手順の一部として実行する前提が仕様側にある。
- 本リポジトリの品質ゲートと採番は既にシェルである（`check-staleness.sh` / `build-index.sh` / `check-id-collisions.sh --next`）。エージェントはこれらのコマンドをそのまま呼べる。GUI ラッパーが無くても主経路は閉じない。
- [ADR-00020](../adr/00020-platform-is-a-client.md) は PF を git KB のクライアントとし、正本を Markdown + PR に固定した（根拠 [EVID-00008](00008-pr-as-quality-gate.md)）。エージェントが PR まで出す経路は、既に git / `gh` / エディタ内蔵エージェントに存在する。
- [REV-00008](../reviews/00008-client-surface-adversarial-review.md) は、IDE 拡張を第一世代にし認証難題を Web に先送りする順序を批判し、エージェントと人間が共有できる操作面として CLI を候補に挙げた。
- Cursor / Claude Code は MCP（Model Context Protocol）で外部ツールをエージェントから呼ぶ経路を公式に持つ。CLI と同じ操作を MCP で晒せば、GUI を経由せずに PF 操作をエージェント経路へ載せられる（製品ドキュメント上の能力。本リポジトリでの実装検証は未実施）。

## 限界

- 「MCP が CLI より採用されやすいか」「どの操作を MCP に晒すべきか」は未測定（OQ-038）。
- IDE 拡張がエージェントの隣接 UI として摩擦を下げる効果は否定しない。ただしそれは主経路の代替ではない。
- 効果測定（OQ-017）が空のため、「エージェント可呼び面を先に作ると手戻りが減る」は、現行経路との整合からの推論であり現場 KPI ではない。

## 関連

- [EVID-00015](00015-agent-tools-read-different-paths.md)
- [EVID-00012](00012-skills-are-progressive-disclosure.md)
- [EVID-00008](00008-pr-as-quality-gate.md)
- [ADR-00011](../adr/00011-cross-tool-agent-integration.md)
- [ADR-00020](../adr/00020-platform-is-a-client.md)
- [REV-00008](../reviews/00008-client-surface-adversarial-review.md)
