---
id: LEDGER-CLAIMS
title: Claims ledger
status: active
last_reviewed: 2026-08-09
owners:
  - TeramachiShunsuke
tags:
  - ledger
  - claims
---

# Claims

主張は短く、錨を必須とする。形式:

```text
- [ ] CLAIM-NNN: <主張> — evidence:EVID-... adr:ADR-... url:https://...
```

完了・廃棄したら `[x]` にし、廃棄理由を末尾に書く。

## Active

- [ ] CLAIM-001: エージェント出力は根拠と分離して扱う — evidence:EVID-001
- [ ] CLAIM-002: 長期記憶はリポジトリ上の構造化 Markdown に置く — evidence:EVID-002 adr:ADR-001
- [ ] CLAIM-003: 文書ドリフトは回帰である — evidence:EVID-003 adr:ADR-004
- [ ] CLAIM-004: frozen はバイト不変 — evidence:EVID-004 adr:ADR-003
- [ ] CLAIM-005: reviews は追記専用 — evidence:EVID-005 adr:ADR-005
- [ ] CLAIM-006: テンプレートと Frontmatter で分散を抑える — evidence:EVID-006 adr:ADR-002
- [ ] CLAIM-007: ledger は索引であり本文の代替ではない — evidence:EVID-007
- [ ] CLAIM-008: PR + staleness CI が知識の品質ゲート — evidence:EVID-008 adr:ADR-004
- [ ] CLAIM-009: 文脈は有限予算であり、読む順序を Tier で固定する — evidence:EVID-009 adr:ADR-006
- [ ] CLAIM-010: 索引は生成物にして CI で最新性を強制する — evidence:EVID-010 adr:ADR-007
- [ ] CLAIM-011: spec と知識ベースは別権威で、昇格条件付きの双方向受け渡しにする — evidence:EVID-011 adr:ADR-008
- [ ] CLAIM-012: skill は playbook の入口であり手順の正本ではない — evidence:EVID-012 adr:ADR-009 url:https://cursor.com/docs/skills
