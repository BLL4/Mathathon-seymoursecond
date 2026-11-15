#!/usr/bin/env python3
"""Export this conversation's user/assistant messages from its local session log."""

import argparse
import json
import os
from pathlib import Path


HERE = Path(__file__).resolve().parent
SESSION_ID = "01a1d82d-6b7e-7691-b809-122bb7c9e998"


def read_messages(source):
    messages = []
    seen = set()
    with source.open(encoding="utf-8") as stream:
        for line_number, line in enumerate(stream, 1):
            # A live writer may not yet have completed the final JSON line.
            if not line.endswith("\n"):
                break
            try:
                record = json.loads(line)
            except json.JSONDecodeError as error:
                raise ValueError(f"Invalid complete record at line {line_number}") from error
            if record.get("type") != "response_item":
                continue
            payload = record.get("payload", {})
            if payload.get("type") != "message":
                continue
            role = payload.get("role")
            if role not in {"user", "assistant"}:
                continue
            phase = payload.get("channel") or payload.get("phase")
            if role == "assistant" and phase not in {None, "commentary", "final", "final_answer"}:
                continue
            if payload.get("status") not in {None, "completed"}:
                continue
            identity = payload.get("id")
            if identity is not None and identity in seen:
                continue
            parts = []
            for part in payload.get("content", []):
                if part.get("type") not in {"input_text", "output_text", "text"}:
                    raise ValueError(f"Unsupported message content: {part.get('type')!r}")
                parts.append(part["text"])
            body = "".join(parts)
            if not body:
                continue
            seen.add(identity)
            messages.append((record["timestamp"], role, phase, body))
    if not messages:
        raise ValueError("No conversation messages found; existing transcript was not changed")
    return messages


def render(messages):
    header = f"""# Conversation transcript

This is the user/assistant conversation from its first recorded message,
including assistant progress updates and user-provided project context.
Message text is preserved; headings and timestamps are added for navigation.
Tool execution logs and application-internal records are outside this export.

- First recorded message: {messages[0][0]}
- Last recorded message included: {messages[-1][0]}
- Messages included: {len(messages)}

Refresh with `python3 rewrite-codex/update-transcript.py` from the repository
root. The export reads completed messages from this conversation's local
session record, including those preceding context compaction. A final reply
sent after a refresh is included on the following refresh. Do not edit
exported message bodies by hand.

"""
    sections = [header]
    for number, (timestamp, role, phase, body) in enumerate(messages, 1):
        label = "User" if role == "user" else "Assistant"
        if role == "assistant" and phase == "commentary":
            label += " — progress update"
        elif role == "assistant":
            label += " — reply"
        sections.append(f"## {number:03d} · {label} · {timestamp}\n\n{body}")
        sections.append("\n\n" if not body.endswith("\n") else "\n")
    return "".join(sections)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--session-log", type=Path, help="Explicit path to this conversation's JSONL log")
    parser.add_argument("--codex-home", type=Path,
                        default=Path(os.environ.get("CODEX_HOME", Path.home() / ".codex")))
    args = parser.parse_args()
    if args.session_log:
        source = args.session_log
    else:
        matches = list((args.codex_home / "sessions").rglob(f"*{SESSION_ID}.jsonl"))
        if len(matches) != 1:
            parser.error(f"Expected one log for this conversation; found {len(matches)}. Use --session-log.")
        source = matches[0]
    messages = read_messages(source)
    output = HERE / "transcript.md"
    text = render(messages)
    if not output.exists() or output.read_text(encoding="utf-8") != text:
        output.write_text(text, encoding="utf-8")
    print(f"transcript.md: {len(messages)} messages; {messages[0][0]} through {messages[-1][0]}")


if __name__ == "__main__":
    main()
