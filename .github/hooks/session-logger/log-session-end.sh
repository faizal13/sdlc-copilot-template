#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  log-session-end.sh — Fired by VS Code when a Copilot session ends
#
#  VS Code sends a JSON payload on stdin with these fields:
#    {
#      "timestamp":        "2026-03-12T10:55:00.000Z",
#      "sessionId":        "abc-123",
#      "hookEventName":    "Stop",
#      "cwd":              "/path/to/workspace",
#      "transcript_path":  "/path/to/transcript.json",
#      "stop_hook_active": false
#    }
#
#  Output written to: logs/copilot/session.log  (appended to same file as start)
#  Format:
#    {"timestamp":"...","event":"sessionEnd","sessionId":"...","durationSec":1500,"promptCount":12}
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

TIMESTAMP=${TIMESTAMP:-$(date -u +"%Y-%m-%dT%H:%M:%SZ")}

# ── Compute duration by looking up session start in session.log ───────────────
DURATION_SEC="null"
PROMPT_COUNT=0

if [ -n "$SESSION_ID" ] && [ -f logs/copilot/session.log ]; then
  # Find the sessionStart entry for this session
  START_TS=$(grep "\"sessionId\":\"$SESSION_ID\"" logs/copilot/session.log 2>/dev/null \
    | jq -r 'select(.event == "sessionStart") | .timestamp' 2>/dev/null \
    | head -1 || true)

  if [ -n "$START_TS" ]; then
    # Strip milliseconds (.000Z → Z) for cross-platform date parsing
    START_TS_CLEAN=$(echo "$START_TS" | sed 's/\.[0-9]*Z$/Z/')
    TIMESTAMP_CLEAN=$(echo "$TIMESTAMP"  | sed 's/\.[0-9]*Z$/Z/')
    # Cross-platform epoch conversion: try GNU date first, then BSD date (macOS)
    START_EPOCH=$(date -d "$START_TS_CLEAN" +%s 2>/dev/null \
      || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$START_TS_CLEAN" +%s 2>/dev/null \
      || true)
    END_EPOCH=$(date -d "$TIMESTAMP_CLEAN" +%s 2>/dev/null \
      || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$TIMESTAMP_CLEAN" +%s 2>/dev/null \
      || true)
    if [ -n "$START_EPOCH" ] && [ -n "$END_EPOCH" ]; then
      DURATION_SEC=$((END_EPOCH - START_EPOCH))
    fi
  fi
fi

# ── Count prompts sent during this session ────────────────────────────────────
if [ -n "$SESSION_ID" ] && [ -f logs/copilot/prompts.log ]; then
  PROMPT_COUNT=$(grep -c "\"sessionId\":\"$SESSION_ID\"" logs/copilot/prompts.log 2>/dev/null || true)
fi

# ── Ensure log directory exists ───────────────────────────────────────────────
mkdir -p logs/copilot

# ── Append session end entry to session.log ───────────────────────────────────
jq -cn \
  --arg  timestamp   "$TIMESTAMP" \
  --arg  sessionId   "$SESSION_ID" \
  --arg  event       "sessionEnd" \
  --argjson durationSec  "${DURATION_SEC}" \
  --argjson promptCount  "${PROMPT_COUNT}" \
  '{
    timestamp:   $timestamp,
    event:       $event,
    sessionId:   $sessionId,
    durationSec: $durationSec,
    promptCount: $promptCount
  }' >> logs/copilot/session.log

exit 0
