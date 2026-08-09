---
id: EVID-016
title: 警告のままの検査は劣化を検出できず、本文と related のズレが残る
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - graph
  - ci
  - review
related:
  - EVID-014
  - EVID-010
  - ADR-010
  - ADR-012
tier: 3
---

## 主張

構造グラフ（[ADR-010](../adr/010-knowledge-graph-layers.md)）が見ている「決定と根拠の紐づき」は、現時点で 100% 充足している。しかし充足を保つ力がない。ほぼすべての検査が警告に留まり CI を落とさないため、**100% から落ちても誰も気づかない**。さらに、決定が本文で依拠すると書いている根拠が `related` に載っていない例が 11 件中 7 件あり、グラフはその辺を知らない。

## 観測

2026-08-09、`build-graph.py` の収集結果（81 ノード / 363 辺）に対して集計した。対象は ADR 11 / playbook 10 / evidence 15 / claim 15。

### 紐づきの充足率

| 観点 | 未充足 |
| --- | --- |
| evidence の錨を持たない ADR | 0 / 11 |
| 実装する playbook を持たない ADR | 0 / 11 |
| どの ADR / claim からも使われない evidence | 0 / 15 |
| どの claim にも現れない ADR | 0 / 11 |
| ADR を指さない playbook | 0 / 10 |
| 根拠の `last_reviewed` が決定より新しい（追随漏れ） | 0 |

出ている警告は「入口のない手順」4 件（PB-004 / PB-005 / PB-006 / PB-009）のみで、これは発見性の問題であり紐づきの欠落ではない。

### 検査等級の内訳

CI を落とすのは 4 つ（参照の未解決、錨のない claim、リンク切れ、生成物の陳腐化）だけである。上の表の 6 観点はいずれも**警告**で、違反しても PR は緑のまま通る。つまり現在の 100% は運用の結果であり、機械が守っている値ではない。

### 本文と Frontmatter のズレ

各 ADR の `## 根拠` 節に書かれた ID と、Frontmatter の `related` を突き合わせた。11 件中 7 件でズレがあった。

| ADR | 根拠節にあるが `related` にない |
| --- | --- |
| ADR-002 | EVID-003 |
| ADR-006 | EVID-002 / EVID-012 |
| ADR-007 | EVID-003 |
| ADR-008 | EVID-001 / EVID-007 |
| ADR-009 | EVID-006 / EVID-009 |
| ADR-010 | EVID-009 / EVID-010 |
| ADR-011 | EVID-009 / EVID-012 |

人間が読めば「ADR-010 は EVID-009 に乗っている」と分かるが、グラフにはその辺が存在しない。結果として被参照数・ハブ・影響範囲がいずれも実際より小さく出る。ズレは本文リンクの追加時に `related` の更新を忘れることで生まれ、現在の検査では検出できない。

なお ADR-002 は `status: frozen` で本文も Frontmatter も改変できない（[ADR-003](../adr/003-frozen-immutability.md)）。したがってこの検査を機械化する場合、frozen 文書は対象外にする必要がある。

## 限界

集計対象は本リポジトリ 1 件・文書 51 件の時点であり、規模が増えたときに同じ充足率を保てるかは分からない。また「根拠節に書かれた ID」の抽出は見出し `## 根拠` に依存しており、節名を変えた文書では機能しない。ズレ 7 件がレビュー品質にどれだけ影響したか（見落とした欠陥があったか）は測っていない。

## 関連

- [ADR-012](../adr/012-check-grades.md)
- [EVID-014](014-reference-graph-from-metadata.md)
- [ADR-010](../adr/010-knowledge-graph-layers.md)
