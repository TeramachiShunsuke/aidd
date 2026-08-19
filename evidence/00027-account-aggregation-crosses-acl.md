---
id: EVID-00027
title: アカウント連携の集約は、ソース側 ACL を共有正本へ越境させる
status: active
last_reviewed: 2026-08-19
owners:
  - TeramachiShunsuke
tags:
  - acl
  - intake
  - platform
  - privacy
related:
  - EVID-00025
  - EVID-00003
  - ADR-00019
  - ADR-00020
---

## 主張

ログインしたアカウントの Slack / Meet / Confluence を「裏で反映」すると、ソース側では見えていた範囲の情報が、共有知識ベースでは別の読者に見える。集約そのものが ACL 境界の横断である。コネクタの有無より先に、書き込み先の層（個人下書き / 案件 / kernel）を決めないと、漏洩が手順に固定される。

## 観測

- [AGENTS.md](../AGENTS.md) は「秘密情報、トークン、個人データをコミットする」を禁止している。[ADR-00019](../adr/00019-kernel-and-project-layers.md) と [PB-00018](../playbook/00018-draft-evidence-from-sources.md) も、ソースを渡すときに秘密・個人データを渡さず、知識ベースに取り込まないと書く。
- 一方、運用者の構想（2026-08-13）は「ログインしたアカウントの内容をもとに反映させ、ACL を加味しながらワークフローを回す」である。アカウントの Slack 私室や社外秘 Confluence は、まさに個人データとアクセス制御付き本文を含む。現行手順の禁止と、構想の入力が正面から衝突する。
- [PB-00018](../playbook/00018-draft-evidence-from-sources.md) は出典付き引用を `evidence/` に残す。`evidence/` は共有 git に commit され、[INDEX.md](../INDEX.md) の Tier 3 に載る。引用が短くても、私室の発言が kernel の観測になると、ソース側 ACL の外側の clone 者・CI・将来のエージェントが読める。
- エージェントが「ログイン中のユーザーとして」ソースを読む場合、ユーザーが見える範囲と、書き込み先（共有 kernel）の読者範囲は一致しない。これは Confused Deputy と同じ形である。ユーザーが貼り付けた本文でも、貼った本人が見えることと、リポジトリの全員が見てよいことは別である。
- [EVID-00003](00003-doc-drift-is-regression.md) のとおり、正本を増やすとドリフトする。ソースシステム（Slack 等）と KB の二重正本に、ACL の差が乗ると、削除や権限剥奪が KB 側に伝わらない。

## 限界

実際の Slack / Meet / Confluence の ACL モデル（ワークスペース、チャンネル、スペース権限）は本リポジトリでは未測定。漏洩の定量（何件の私室が共有 evidence に混入しうるか）も無い。ここでは越境が構造的に起きることまでで、どの隔離（別リポ、別ブランチ、git 外ストア）が十分かは言えない。

## 関連

- [EVID-00025](00025-scattered-sources-suit-evidence-drafts.md)
- [PB-00018](../playbook/00018-draft-evidence-from-sources.md)
- [ADR-00019](../adr/00019-kernel-and-project-layers.md)
- [AGENTS.md](../AGENTS.md)
