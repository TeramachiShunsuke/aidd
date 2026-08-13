---
id: PB-018
title: 散在ソースから evidence の下書きを起こす
status: active
last_reviewed: 2026-08-13
owners:
  - TeramachiShunsuke
tags:
  - playbook
  - evidence
  - intake
related:
  - ADR-019
  - ADR-017
  - ADR-020
  - EVID-025
  - EVID-028
  - EVID-001
  - PB-001
tier: 2
---

## いつ使うか

観測が Slack、Google Meet の議事録、Confluence、Issue コメントなどに散らばっているとき。人が情報を揃えてから evidence を書く代わりに、エージェントにドラフトを起こさせたいとき。

人が既に観測文を持っているなら、この手順は使わず [PB-001](001-add-evidence.md) へ進む。

## 手順

1. 人間がソースを渡す。各ソースに識別子を付ける（URL、ページ名、会議の日時）。秘密・トークン・個人データ・Okta セッションは渡さない。アクセスできないソースは「未取得」と書き、内容を推測しない。ソース側で限られた読者だけが見える本文は、共有 kernel の `evidence/` に載せない（[ADR-020](../adr/020-platform-is-a-client.md)）
2. [templates/evidence-intake.md](../templates/evidence-intake.md) にソース一覧を書く。案件リポの作業メモでも、PR 本文でもよい。知識ベースの正本にはしない
3. エージェントはソースから**引用可能な事実**だけを抜く。意見・希望・未決は観測に混ぜず、`## 限界` か [ledger/open-questions.md](../ledger/open-questions.md) へ回す
4. [templates/evidence.md](../templates/evidence.md) をコピーし、`status: draft` で evidence を作る。番号は `--next EVID` に聞く
5. `## 観測` の各箇条に出典を付ける。形式は `出典: <URL または「Meet 2026-08-13: …」> — 「引用」`。出典のない文は書かない
6. ソース同士が矛盾したら、両方を観測に残す。都合のよい側だけ残して整えない
7. `## 主張` は観測から一段だけ抽象化する。観測にない断定は書かない（[EVID-001](../evidence/001-agents-need-evidence.md)）
8. PR を開く。`status` は `draft` のまま。人間が「この発言・この数字はあった」と確認してから `active` にする（[ADR-017](../adr/017-machines-record-facts-humans-decide-status.md)）。確認できない条は削除するか限界へ移す
9. `active` にした主張を残すなら [ledger/claims.md](../ledger/claims.md) へ錨を付ける。決定が要るなら案件 ADR（[PB-017](017-apply-kernel-to-project.md)）。繰り返す判断なら [PB-008](008-bridge-sdd-spec.md)

## 検証

- Frontmatter の `status` が、人間の確認前は `draft` である
- `## 観測` の各箇条に出典がある
- ソース全文の転記がない（引用は短く、リンクが辿れる）
- 秘密情報が含まれていない
- Okta やソースシステムの認証情報が git に含まれていない
- ソース側で限られた読者だけが見える本文が、共有 kernel に載っていない
- エージェントが `status` を `active` に上げていない

## 失敗時

- ソースを開けない → 人間に該当箇所の貼り付けを求める。未取得の内容を補完して書かない
- 私室・社外秘など、ソース側 ACL の外側の読者に出せない → kernel の evidence にしない。案件の隔離された下書きか、open-questions に「出せない」と残す（[ADR-020](../adr/020-platform-is-a-client.md)）
- 下書きが「たぶんこう」ばかり → evidence を捨て、open-questions に「何が分かっていないか」を書く
- 意見と事実が分離できない → 発言者の引用として観測に残し、採用するかどうかは ADR 側の判断にする
- `draft` のまま 30 日を超える → 鮮度検査が警告する。確認するか、棄てるかは人間が決める

## 関連

- [ADR-019](../adr/019-kernel-and-project-layers.md)
- [ADR-017](../adr/017-machines-record-facts-humans-decide-status.md)
- [ADR-020](../adr/020-platform-is-a-client.md)
- [templates/evidence-intake.md](../templates/evidence-intake.md)
- [templates/evidence.md](../templates/evidence.md)
- [PB-001](001-add-evidence.md)
- [PB-017](017-apply-kernel-to-project.md)
- skill: [aidd-draft-evidence](../.agents/skills/aidd-draft-evidence/SKILL.md)
