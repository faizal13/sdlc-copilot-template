#!/usr/bin/env node
// log-session-end.js — Fired by VS Code when a Copilot session ends (Stop event)
//
// VS Code sends a JSON payload on stdin. Field names vary across builds:
//   { timestamp, sessionId|session_id, hookEventName, cwd, transcript_path, stop_hook_active }
//
// Writes one JSON line to: logs/copilot/session.log
// Computes duration by looking up the matching sessionStart in session.log
// Counts prompts by scanning prompts.log for matching sessionId
//
// FALLBACK: If sessionId is missing from the payload (common in some VS Code builds),
// we match against the MOST RECENT sessionStart entry instead — this is almost always
// correct since the Stop event fires for the currently active session.

'use strict';

const fs   = require('fs');
const path = require('path');

// ── Resolve a field from multiple possible key names ────────────────────────
function resolve(payload, ...keys) {
  for (const k of keys) {
    if (payload[k] !== undefined && payload[k] !== null && payload[k] !== '') return payload[k];
  }
  return '';
}

// ── Read stdin payload ────────────────────────────────────────────────────────
let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => { raw += chunk; });
process.stdin.on('end', () => {
  if (process.env.SKIP_LOGGING === 'true') process.exit(0);

  let payload = {};
  try { payload = JSON.parse(raw); } catch (_) { /* ignore malformed payload */ }

  const timestamp = payload.timestamp || new Date().toISOString();
  let   sessionId = resolve(payload, 'sessionId', 'session_id', 'id');

  const logDir      = path.join(process.cwd(), 'logs', 'copilot');
  const sessionFile = path.join(logDir, 'session.log');
  const promptsFile = path.join(logDir, 'prompts.log');

  // ── Find the matching sessionStart entry ──────────────────────────────────
  let durationSec = null;
  let promptCount = 0;
  let matchedSessionId = sessionId; // may be overridden by fallback

  if (fs.existsSync(sessionFile)) {
    const lines = fs.readFileSync(sessionFile, 'utf8').split('\n').filter(Boolean);

    // Parse all sessionStart entries
    const starts = [];
    for (const line of lines) {
      try {
        const entry = JSON.parse(line);
        if (entry.event === 'sessionStart') starts.push(entry);
      } catch (_) { /* skip malformed lines */ }
    }

    let startEntry = null;

    if (sessionId) {
      // ── Primary: match by sessionId ───────────────────────────────────────
      startEntry = starts.find(e => e.sessionId === sessionId);
    }

    if (!startEntry && starts.length > 0) {
      // ── Fallback: use the most recent sessionStart that doesn't already
      //    have a matching sessionEnd. This handles:
      //    1. Stop event with no sessionId
      //    2. Stop event with a sessionId that doesn't match any start
      //    (both common in certain VS Code builds)

      // Collect sessionIds that already have an end entry
      const endedSessions = new Set();
      for (const line of lines) {
        try {
          const entry = JSON.parse(line);
          if (entry.event === 'sessionEnd' && entry.sessionId) {
            endedSessions.add(entry.sessionId);
          }
        } catch (_) { /* skip */ }
      }

      // Find the most recent start that hasn't ended yet
      for (let i = starts.length - 1; i >= 0; i--) {
        if (!endedSessions.has(starts[i].sessionId)) {
          startEntry = starts[i];
          break;
        }
      }

      // If all sessions have ended, just use the very latest start
      if (!startEntry) {
        startEntry = starts[starts.length - 1];
      }

      // Use the start entry's sessionId for consistency
      matchedSessionId = startEntry.sessionId || sessionId || 'unknown';
    }

    // ── Compute duration ────────────────────────────────────────────────────
    if (startEntry && startEntry.timestamp) {
      const startMs = new Date(startEntry.timestamp).getTime();
      const endMs   = new Date(timestamp).getTime();
      if (!isNaN(startMs) && !isNaN(endMs) && endMs > startMs) {
        durationSec = Math.round((endMs - startMs) / 1000);
      }
    }
  }

  // ── Count prompts for this session ────────────────────────────────────────
  if (matchedSessionId && fs.existsSync(promptsFile)) {
    const lines = fs.readFileSync(promptsFile, 'utf8').split('\n').filter(Boolean);
    for (const line of lines) {
      try {
        const entry = JSON.parse(line);
        if (entry.sessionId === matchedSessionId) promptCount++;
      } catch (_) { /* skip malformed lines */ }
    }
  }

  // ── Ensure log directory exists ─────────────────────────────────────────
  fs.mkdirSync(logDir, { recursive: true });

  // ── Append one JSON line ──────────────────────────────────────────────────
  const entry = JSON.stringify({
    timestamp,
    event: 'sessionEnd',
    sessionId: matchedSessionId,
    durationSec,
    promptCount,
    // Include duration in human-readable format for quick scanning
    durationHuman: durationSec !== null
      ? `${Math.floor(durationSec / 60)}m ${durationSec % 60}s`
      : null
  });
  fs.appendFileSync(sessionFile, entry + '\n', 'utf8');

  process.exit(0);
});
