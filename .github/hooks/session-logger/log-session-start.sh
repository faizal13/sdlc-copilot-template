#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  log-session-start.sh — Fired by VS Code when a new Copilot session starts
#
#  VS Code sends a JSON payload on stdin with these fields:
#    {
#      "timestamp":      "2026-03-12T10:30:00.000Z",
#      "sessionId":      "abc-123",
#      "hookEventName":  "SessionStart",
#      "cwd":            "/path/to/workspace",
#      "transcript_path":"/path/to/transcript.json",
#      "source":         "new"
#    }
#
#  Output written to: logs/copilot/session.log  (one JSON line per session event)
#  Format:
#    {"timestamp":"...","event":"sessionStart","sessionId":"...","cwd":"..."}
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# Skip if logging disabled
if [[ "${SKIP_LOGGING:-}" == "true" ]]; then
  exit 0
fi

# ── Read payload from VS Code ─────────────────────────────────────────────────
INPUT=$(cat)

# ── Extract fields from the JSON payload ─────────────────────────────────────
TIMESTAMP=$(echo "$INPUT"  | jq -r '.timestamp // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.sessionId // empty')
CWD=$(echo "$INPUT"        | jq -r '.cwd // empty')

# Fallbacks if fields missing from payload
TIMESTAMP=${TIMESTAMP:-$(date -u +"%Y-%m-%dT%H:%M:%SZ")}
CWD=${CWD:-$(pwd)}

# ── Ensure log directory exists ───────────────────────────────────────────────
mkdir -p logs/copilot

# ── Append session start entry to session.log ─────────────────────────────────
jq -cn \
  --arg timestamp "$TIMESTAMP" \
  --arg sessionId "$SESSION_ID" \
  --arg event     "sessionStart" \
  --arg cwd       "$CWD" \
  '{
    timestamp: $timestamp,
    event:     $event,
    sessionId: $sessionId,
    cwd:       $cwd
  }' >> logs/copilot/session.log

exit 0
