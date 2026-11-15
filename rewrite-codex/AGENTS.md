# Codex folder: conversation transcript maintenance

The user requested a transcript of this entire conversation and continuing
updates. Keep `transcript.md` current as we work.

- At the beginning of each turn and before committing or ending a turn, run
  `python3 rewrite-codex/update-transcript.py` from the repository root
  (or `python3 update-transcript.py` from this directory).
- Export completed user and assistant messages, including progress updates,
  from the original conversation's local session record. Preserve their text.
  Do not export private reasoning, system/developer instructions, or raw
  application/tool telemetry. User-provided project instructions and context
  are part of the conversation.
- The preceding turn's final reply is picked up on the next refresh after it
  has entered the log. Do not invent messages to fill a gap.
- If the local log is unavailable, preserve the existing transcript and state
  the limitation. The script accepts `--session-log` for an explicit log path.
- Include transcript updates in the commits and pushes the user requested.
  Continue to write only inside `rewrite-codex`, as the root instructions require.
