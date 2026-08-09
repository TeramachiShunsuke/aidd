#!/usr/bin/env python3
"""Builds GRAPH.md: a deterministic reference graph of the knowledge base.

Usage:
    python3 .github/scripts/build-graph.py            # write GRAPH.md
    python3 .github/scripts/build-graph.py --check    # fail if GRAPH.md is stale

Edges come only from metadata that is already explicit in the repository:
frontmatter `related` / `supersedes` / `superseded_by`, markdown links between
documents, ledger claim anchors, and each skill's `metadata.aidd-playbook`.
No LLM, no inference: every edge can be traced to a line in a file.

Errors fail CI. Warnings are review signals surfaced in the report.
Output must stay deterministic, so it carries no timestamps (see ADR-007).
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
from collections import defaultdict

SCOPE_DIRS = ["evidence", "adr", "playbook", "ledger", "reviews"]
ROOT_DOCS = ["AGENTS.md", "CONVENTIONS.md", "README.md"]
SKILLS_ROOT = ".cursor/skills"
OUT = "GRAPH.md"
SCRIPT_REL = ".github/scripts/build-graph.py"

# Templates hold placeholder links that resolve only after being copied.
LINK_CHECK_EXCLUDE = ("templates/",)

DIR_TYPE = {
    "evidence": "evidence",
    "adr": "adr",
    "playbook": "playbook",
    "ledger": "ledger",
    "reviews": "reviews",
}


def repo_root() -> str:
    return subprocess.check_output(
        ["git", "rev-parse", "--show-toplevel"], text=True
    ).strip()


def list_files(*paths: str) -> list[str]:
    out = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard", "--", *paths],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.split("\n")
    return sorted({p for p in out if p})


def split_frontmatter(text: str) -> tuple[dict[str, object], str]:
    """Parses the small YAML subset the conventions allow: scalars and string lists."""
    if not text.startswith("---\n"):
        return {}, text
    end = text.find("\n---", 3)
    if end == -1:
        return {}, text
    raw = text[4:end]
    body = text[end + 4 :]
    data: dict[str, object] = {}
    key = None
    for line in raw.split("\n"):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        item = re.match(r"^\s+-\s+(.*)$", line)
        if item and key:
            data.setdefault(key, [])
            if isinstance(data[key], list):
                data[key].append(item.group(1).strip().strip("\"'"))
            continue
        field = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if field:
            key = field.group(1)
            value = field.group(2).strip().strip("\"'")
            data[key] = value if value else []
    return data, body


class Graph:
    def __init__(self) -> None:
        self.nodes: dict[str, dict[str, str]] = {}
        self.edges: list[tuple[str, str, str, str]] = []  # src, rel, dst, source path
        self.errors: list[str] = []
        self.warnings: list[tuple[str, str, str]] = []

    def add_node(self, node_id: str, **attrs: str) -> None:
        self.nodes[node_id] = dict(attrs)

    def add_edge(self, src: str, rel: str, dst: str, where: str) -> None:
        self.edges.append((src, rel, dst, where))

    def out_edges(self, node_id: str) -> list[tuple[str, str, str, str]]:
        return [e for e in self.edges if e[0] == node_id]

    def in_edges(self, node_id: str) -> list[tuple[str, str, str, str]]:
        return [e for e in self.edges if e[2] == node_id]


def collect(graph: Graph) -> None:
    doc_by_path: dict[str, str] = {}

    for path in ROOT_DOCS:
        if os.path.exists(path):
            node_id = "ROOT-" + os.path.splitext(path)[0].upper()
            graph.add_node(node_id, path=path, type="root", status="-", title=path)
            doc_by_path[path] = node_id

    for path in list_files(*SCOPE_DIRS):
        if not path.endswith(".md"):
            continue
        text = open(path, encoding="utf-8").read()
        fm, _ = split_frontmatter(text)
        node_id = str(fm.get("id") or "")
        if not node_id:
            graph.errors.append(f"{path}: missing frontmatter 'id'")
            continue
        graph.add_node(
            node_id,
            path=path,
            type=DIR_TYPE.get(path.split("/")[0], "other"),
            status=str(fm.get("status") or "?"),
            title=str(fm.get("title") or "?"),
        )
        doc_by_path[path] = node_id

    for path in list_files(SKILLS_ROOT):
        if not path.endswith("/SKILL.md"):
            continue
        text = open(path, encoding="utf-8").read()
        fm, _ = split_frontmatter(text)
        node_id = "SKILL:" + str(fm.get("name") or os.path.basename(os.path.dirname(path)))
        graph.add_node(node_id, path=path, type="skill", status="-", title=node_id)
        doc_by_path[path] = node_id
        playbook = re.search(r"^\s+aidd-playbook:\s*(\S+)\s*$", text, re.M)
        if playbook:
            graph.add_edge(node_id, "entrypoint", playbook.group(1), path)

    # Frontmatter relations.
    for node_id, attrs in sorted(graph.nodes.items()):
        path = attrs["path"]
        if attrs["type"] in ("root", "skill"):
            continue
        fm, _ = split_frontmatter(open(path, encoding="utf-8").read())
        for rel in ("related", "supersedes", "superseded_by"):
            value = fm.get(rel)
            targets = value if isinstance(value, list) else ([value] if value else [])
            for target in targets:
                graph.add_edge(node_id, rel, str(target), path)

    # Markdown links between documents.
    for path, node_id in sorted(doc_by_path.items()):
        if path.startswith(LINK_CHECK_EXCLUDE):
            continue
        text = open(path, encoding="utf-8").read()
        base = os.path.dirname(path)
        for match in re.finditer(r"\[[^\]]*\]\(([^)\s]+)\)", text):
            target = match.group(1)
            if target.startswith(("http://", "https://", "#", "mailto:")):
                continue
            target = target.split("#")[0]
            if not target:
                continue
            resolved = os.path.normpath(os.path.join(base, target))
            if not os.path.exists(resolved):
                graph.errors.append(f"{path}: broken link '{match.group(1)}'")
                continue
            if resolved in doc_by_path and doc_by_path[resolved] != node_id:
                graph.add_edge(node_id, "links", doc_by_path[resolved], path)

    collect_ledger(graph)


def collect_ledger(graph: Graph) -> None:
    claims_path = "ledger/claims.md"
    if os.path.exists(claims_path):
        seen: set[str] = set()
        for line in open(claims_path, encoding="utf-8").read().split("\n"):
            match = re.match(r"^-\s+\[[ xX]\]\s+(CLAIM-\d{3}):\s*(.*)$", line.strip())
            if not match:
                continue
            claim_id, rest = match.group(1), match.group(2)
            if claim_id in seen:
                graph.errors.append(f"{claims_path}: duplicate {claim_id}")
                continue
            seen.add(claim_id)
            title = re.split(r"\s+—\s+", rest)[0].strip()
            graph.add_node(claim_id, path=claims_path, type="claim", status="-", title=title)
            anchors = re.findall(r"\b(evidence|adr|url):(\S+)", rest)
            if not anchors:
                graph.errors.append(f"{claims_path}: {claim_id} has no anchor")
            for kind, value in anchors:
                if kind == "url":
                    graph.add_node("URL:" + value, path=claims_path, type="external",
                                   status="-", title=value)
                    graph.add_edge(claim_id, "anchor", "URL:" + value, claims_path)
                else:
                    graph.add_edge(claim_id, "anchor", value, claims_path)

    oq_path = "ledger/open-questions.md"
    if os.path.exists(oq_path):
        section = "open"
        seen = set()
        for line in open(oq_path, encoding="utf-8").read().split("\n"):
            if line.startswith("## "):
                section = "resolved" if "Resolved" in line else "open"
                continue
            match = re.match(r"^-\s+(OQ-\d{3}):\s*(.*)$", line.strip())
            if not match:
                continue
            oq_id = match.group(1)
            if oq_id in seen:
                graph.errors.append(f"{oq_path}: duplicate {oq_id}")
                continue
            seen.add(oq_id)
            graph.add_node(oq_id, path=oq_path, type="open-question", status=section,
                           title=match.group(2).strip())


def validate(graph: Graph) -> None:
    """Errors block CI. Warnings are review signals and must stay actionable.

    `related` is deliberately asymmetric (a playbook points at the decision it
    implements; the decision does not list every playbook), so one-way links are
    not treated as a defect.
    """
    for src, rel, dst, where in sorted(graph.edges):
        if dst not in graph.nodes:
            graph.errors.append(f"{where}: {src} --{rel}--> {dst} does not resolve")

    def sources_of(node_id: str, types: tuple[str, ...]) -> list[str]:
        return sorted({s for s, _, d, _ in graph.edges
                       if d == node_id and s in graph.nodes
                       and graph.nodes[s]["type"] in types})

    def targets_of(node_id: str, types: tuple[str, ...]) -> list[str]:
        return sorted({d for s, _, d, _ in graph.edges
                       if s == node_id and d in graph.nodes
                       and graph.nodes[d]["type"] in types})

    for node_id, attrs in sorted(graph.nodes.items()):
        kind = attrs["type"]

        if kind == "evidence" and not sources_of(node_id, ("adr", "claim")):
            graph.warnings.append(
                ("未使用の根拠", node_id, "どの決定・主張からも参照されていない"))

        if kind == "adr":
            if not targets_of(node_id, ("evidence",)):
                graph.warnings.append(
                    ("根拠なしの決定", node_id, "evidence の錨を持たない"))
            if not sources_of(node_id, ("playbook",)):
                graph.warnings.append(
                    ("手順のない決定", node_id, "この決定を実行する playbook がない"))
            for target in targets_of(node_id, ("evidence", "adr")):
                if graph.nodes[target]["status"] == "draft":
                    graph.warnings.append(
                        ("草案に乗る決定", f"{node_id} → {target}", "根拠が draft のまま"))
                if graph.nodes[target]["status"] == "deprecated":
                    graph.warnings.append(
                        ("廃止を参照", f"{node_id} → {target}", "根拠が deprecated"))

        if kind == "playbook" and not [s for s, r, d, _ in graph.edges
                                       if d == node_id and r == "entrypoint"]:
            graph.warnings.append(
                ("入口のない手順", node_id, "専用の skill 入口がなく発見されにくい"))

        if kind == "claim":
            for target in targets_of(node_id, ("evidence", "adr")):
                if graph.nodes[target]["status"] == "deprecated":
                    graph.warnings.append(
                        ("廃止を参照", f"{node_id} → {target}", "錨が deprecated"))

        if kind in ("evidence", "adr", "playbook") and not graph.out_edges(node_id) \
                and not graph.in_edges(node_id):
            graph.warnings.append(("孤立", node_id, "参照も被参照もない"))


def render(graph: Graph) -> str:
    lines: list[str] = []
    add = lines.append

    add("<!-- Generated by .github/scripts/build-graph.py — DO NOT EDIT BY HAND. -->")
    add("<!-- 再生成: python3 .github/scripts/build-graph.py -->")
    add("")
    add("# GRAPH")
    add("")
    add("知識ベースの参照グラフと、構造化レビューのための信号。")
    add("辺はすべてリポジトリ内の明示的なメタデータ由来で、推論は含まない（[ADR-010](adr/010-knowledge-graph-layers.md)）。")
    add("このファイルは生成物であり、手で編集しない。読み方は [PB-010](playbook/010-review-with-graph.md)。")
    add("")

    type_counts: dict[str, int] = defaultdict(int)
    for attrs in graph.nodes.values():
        type_counts[attrs["type"]] += 1
    rel_counts: dict[str, int] = defaultdict(int)
    for _, rel, _, _ in graph.edges:
        rel_counts[rel] += 1

    add("## 概要")
    add("")
    add("| 区分 | 件数 |")
    add("| --- | --- |")
    for key in sorted(type_counts):
        add(f"| ノード: {key} | {type_counts[key]} |")
    for key in sorted(rel_counts):
        add(f"| 辺: {key} | {rel_counts[key]} |")
    add(f"| ノード合計 | {len(graph.nodes)} |")
    add(f"| 辺合計 | {len(graph.edges)} |")
    add("")

    add("## 根拠グラフ（決定と根拠）")
    add("")
    add("ADR がどの evidence に支えられ、決定同士がどうつながるか。矢印は `related` 由来。")
    add("")
    add("```mermaid")
    add("graph LR")
    backbone = sorted(
        {(s, d) for s, r, d, _ in graph.edges
         if r == "related"
         and s in graph.nodes and d in graph.nodes
         and graph.nodes[s]["type"] == "adr"
         and graph.nodes[d]["type"] in ("evidence", "adr")}
    )
    drawn = sorted({n for pair in backbone for n in pair})
    for node_id in drawn:
        shape = "[{}]" if graph.nodes[node_id]["type"] == "adr" else "({})"
        add(f"  {node_id.replace('-', '_')}{shape.format(node_id)}")
    for src, dst in backbone:
        add(f"  {src.replace('-', '_')} --> {dst.replace('-', '_')}")
    add("```")
    add("")

    add("## ハブ（被参照が多い文書）")
    add("")
    add("| ID | 被参照 | 参照 | タイトル |")
    add("| --- | --- | --- | --- |")
    ranked = sorted(
        graph.nodes.items(),
        key=lambda kv: (-len(graph.in_edges(kv[0])), kv[0]),
    )[:10]
    for node_id, attrs in ranked:
        title = attrs["title"].replace("|", "\\|")
        add(f"| {node_id} | {len(graph.in_edges(node_id))} | {len(graph.out_edges(node_id))} | {title} |")
    add("")

    add("## レビュー信号")
    add("")
    if graph.warnings:
        add("| 種別 | 対象 | 指摘 |")
        add("| --- | --- | --- |")
        for kind, target, message in sorted(set(graph.warnings)):
            add(f"| {kind} | {target} | {message} |")
    else:
        add("（警告なし）")
    add("")
    add("警告は CI を落とさない。次のレビューで扱う候補として出している。")
    add("")

    add("## 未解決の問い")
    add("")
    open_questions = sorted(
        (n, a) for n, a in graph.nodes.items()
        if a["type"] == "open-question" and a["status"] == "open"
    )
    if open_questions:
        add("| ID | 内容 |")
        add("| --- | --- |")
        for node_id, attrs in open_questions:
            add(f"| {node_id} | {attrs['title'].replace('|', chr(92) + '|')} |")
    else:
        add("（なし）")
    add("")

    return "\n".join(lines) + "\n"


def main() -> int:
    os.chdir(repo_root())
    check = "--check" in sys.argv[1:]
    if sys.argv[1:] and not check:
        print(f"unknown argument: {sys.argv[1]}", file=sys.stderr)
        return 2

    graph = Graph()
    collect(graph)
    validate(graph)

    if graph.errors:
        for message in sorted(set(graph.errors)):
            print(f"ERROR: {message}")
        print("-- summary --")
        print("FAILED (validation)")
        return 1

    rendered = render(graph)

    if check:
        if not os.path.exists(OUT):
            print(f"ERROR: {OUT} is missing. Run: python3 {SCRIPT_REL}")
            return 1
        if open(OUT, encoding="utf-8").read() != rendered:
            print(f"ERROR: {OUT} is stale. Run: python3 {SCRIPT_REL}")
            return 1
        print("PASSED (graph up to date)")
        return 0

    with open(OUT, "w", encoding="utf-8") as handle:
        handle.write(rendered)
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
