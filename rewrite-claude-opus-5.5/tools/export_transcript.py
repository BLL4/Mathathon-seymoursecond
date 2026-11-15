#!/usr/bin/env python3
"""Export the conversation transcript of this Claude Code session to transcript.md.

Reads the session log (a JSONL file kept by Claude Code) and writes a Markdown
transcript containing, in order:
  * every message typed by the user, verbatim;
  * every reply written by Claude, verbatim;
  * each tool call as a one-line note (tool name and its short description);
  * a marker where the context window was compacted.
Tool outputs, file contents read by tools and Claude's private reasoning are
not included; they are far too large and are not part of the conversation.

Usage:  python3 tools/export_transcript.py [session.jsonl] [transcript.md]
"""
import json
import sys
from datetime import datetime
from pathlib import Path

DEFAULT_LOG = Path.home() / ".claude/projects/-Users-lidicky-claude-mathaton" / \
    "3ce2e957-d885-461a-bd37-fd214bf36439.jsonl"
DEFAULT_OUT = Path(__file__).resolve().parent.parent / "transcript.md"


def ts(entry):
    t = entry.get("timestamp")
    if not t:
        return ""
    try:
        return datetime.fromisoformat(t.replace("Z", "+00:00")).strftime("%Y-%m-%d %H:%M UTC")
    except ValueError:
        return t


def tool_line(block):
    name = block.get("name", "tool")
    inp = block.get("input") or {}
    desc = inp.get("description") or inp.get("prompt") or inp.get("command") or \
        inp.get("file_path") or inp.get("query") or ""
    desc = " ".join(str(desc).split())
    if len(desc) > 110:
        desc = desc[:107] + "..."
    return f"> 🔧 `{name}` — {desc}" if desc else f"> 🔧 `{name}`"


def user_text(entry):
    """Text typed by the user, or None if this entry is a tool result / meta message."""
    if entry.get("isMeta") or entry.get("isCompactSummary"):
        return None
    msg = entry.get("message") or {}
    content = msg.get("content")
    if isinstance(content, str):
        text = content.strip()
    else:
        parts = [b.get("text", "") for b in content or []
                 if isinstance(b, dict) and b.get("type") == "text"]
        text = "\n".join(parts).strip()
    if not text or text.startswith("<system-reminder>") or "<local-command-stdout>" in text \
            or "<command-name>" in text:
        return None
    return text


def main():
    log = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_LOG
    out = Path(sys.argv[2]) if len(sys.argv) > 2 else DEFAULT_OUT
    lines = []
    n_user = n_claude = 0
    last_role = None
    for raw in log.open():
        try:
            e = json.loads(raw)
        except json.JSONDecodeError:
            continue
        if e.get("isSidechain"):
            continue
        kind = e.get("type")
        if kind == "system" and e.get("subtype") == "compact_boundary":
            lines.append("\n---\n*[The context window was compacted here; the conversation continued from a summary.]*\n")
            last_role = None
            continue
        if kind not in ("user", "assistant"):
            continue
        if e.get("isCompactSummary"):
            continue
        if kind == "user":
            text = user_text(e)
            if text is None:
                continue
            n_user += 1
            lines.append(f"\n## User — {ts(e)}\n\n{text}\n")
            last_role = "user"
            continue
        # assistant: text and tool calls; several JSONL entries share one reply
        msg = e.get("message") or {}
        content = msg.get("content")
        blocks = content if isinstance(content, list) else [{"type": "text", "text": str(content)}]
        chunk = []
        for b in blocks:
            if not isinstance(b, dict):
                continue
            if b.get("type") == "text" and b.get("text", "").strip():
                chunk.append(b["text"].strip())
            elif b.get("type") == "tool_use":
                chunk.append(tool_line(b))
        if not chunk:
            continue
        if last_role != "assistant":
            n_claude += 1
            lines.append(f"\n## Claude — {ts(e)}\n")
        lines.append("\n".join(chunk) + "\n")
        last_role = "assistant"
    header = (
        "# Transcript of the Claude Code session on the Seymour paper\n\n"
        f"Session `{log.stem}`, exported {datetime.now().strftime('%Y-%m-%d %H:%M')} "
        f"by `tools/export_transcript.py`. {n_user} user messages, {n_claude} replies.\n\n"
        "What is included: every message typed by the user and every reply written by Claude, "
        "verbatim, in order; each tool call as a one-line note (🔧); and markers where the "
        "context window was compacted. Not included: tool outputs, file contents, and Claude's "
        "private reasoning. Re-run the script to bring this file up to date.\n"
    )
    out.write_text(header + "".join(lines))
    print(f"wrote {out} ({out.stat().st_size // 1024} KB): {n_user} user messages, {n_claude} replies")


if __name__ == "__main__":
    main()
