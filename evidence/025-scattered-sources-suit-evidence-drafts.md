---
id: EVID-025
title: 散在ソースの集約は evidence の下書きに向くが、確定は観測の確認である
status: active
last_reviewed: 2026-08-13
owners:
  - TeramachiShunsuke
tags:
  - evidence
  - agents
  - intake
related:
  - EVID-001
  - ADR-017
  - PB-001
---

## 主張

Slack、会議の議事録、Confluence などに散らばった情報を、人が先に揃えてから evidence を書く必要はない。集約と引用の抜き出しはエージェントが下書きできる。ただし下書きは観測ではなく、出典付きの草案である。`active` にする確認は人間が行う。

## 観測

- 現行の [PB-001](../playbook/001-add-evidence.md) は「観測を書く」から始まり、ソースが複数の外部ツールに分かれている場合の取り込み手順を持たない。人が情報を揃える前提が、手順の入口に固定されている。
- 2026-08-13 の運用者の仮説: 今は観測点の記述を人が実施すると仮定している。Slack や Google Meet の議事録、Confluence などの散在情報を集約して evidence のドラフトを作るのは、エージェントの得意分野の一つではないか。
- [EVID-001](001-agents-need-evidence.md) のとおり、モデルは根拠が薄いときでも断定しやすい。散在ソースの要約は、発言の捏造・意見と事実の混同・欠けた出典を含みうる。だから「書けた」ことと「その発言があった」ことは分離する必要がある。
- [ADR-017](../adr/017-machines-record-facts-humans-decide-status.md) は機械の範囲を事実の記録・不整合の検出・前提条件の検査に限り、`status` の遷移は人間が行うと既に決めている。evidence を `draft` で起こし、観測を確認した人間が `active` にする流れは、この分界の延長である。
- 散在ソースは一次資料であり、知識ベースの本文ではない。転記して正本を増やすと [EVID-003](003-doc-drift-is-regression.md) と同じ二重管理になる。残すのは引用とリンクであり、スレッド全文ではない。

## 限界

Slack / Meet / Confluence から起こした下書きの、人手 evidence に対する精度・再現率は未測定。コネクタ（API / MCP）の可用性も本リポジトリでは検証していない。ここでは「下書きを起こしてよいか」「確定を機械に任せないか」までで、どのツールを先に繋ぐかは言えない。

## 関連

- [EVID-001](001-agents-need-evidence.md)
- [ADR-017](../adr/017-machines-record-facts-humans-decide-status.md)
- [PB-001](../playbook/001-add-evidence.md)
