#!/usr/bin/env node
// log-session-end.js — Fired by VS Code when a Copilot session ends
//
// VS Code sends a JSON payload on stdin:
//   { timestamp, sessionId, hookEventName, cwd, transcript_path, stop_hook_active }
//
// Writes one JSON line to: logs/copilot/session.log
// Computes duration by looking up the matching sessionStart in session.log
// Counts prompts by scanning prompts.log for matching sessionId

'use strict';

const fs   = require('fs');
const path = require('path');

// ── Read stdin payload ────────────────────────────────────────────────────────
let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => { raw += chunk; });
process.stdin.on('end', () => {
  if (process.env.SKIP_LOGGING === 'true') process.exit(0);

  let payload = {};
  try { payload = JSON.parse(raw); } catch (_) { /* ignore malformed payload */ }

  const timestamp = payload.timestamp || new Date().toISOString();
  const sessionId = payload.sessionId || '';

  const logDir      = path.join(process.cwd(), 'logs', 'copilot');
  const sessionFile = path.join(logDir, 'session.log');
  const promptsFile = path.join(logDir, 'prompts.log');

  // ── Compute duration by reading sessionStart from session.log ────────────────
  let durationSec  = null;
  let promptCount  = 0;

  if (sessionId && fs.existsSync(sessionFile)) {
    const lines = fs.readFileSync(sessionFile, 'utf8').split('\n').filter(Boolean);
    for (const line of lines) {
      try {
        const entry = JSON.parse(line);
        if (entry.sessionId === sessionId && entry.event === 'sessionStart') {
          const startMs = new Date(entry.timestamp).getTime();
          const endMs   = new Date(timestamp).getTime();
          if (!isNaN(startMs) && !isNaN(endMs)) {
            durationSec = Math.round((endMs - startMs) / 1000);
          }
          break;
        }
      } catch (_) { /* skip malformed lines */ }
    }
  }

  // ── Count prompts for this session ──────────────────────────────────────────
  if (sessionId && fs.existsSync(promptsFile)) {
    const lines = fs.readFileSync(promptsFile, 'utf8').split('\n').filter(Boolean);
    for (const line of lines) {
      try {
        const entry = JSON.parse(line);
        if (entry.sessionId === sessionId) promptCount++;
      } catch (_) { /* skip malformed lines */ }
    }
  }

  // ── Ensure log directory exists ─────────────────────────────────────────────
  fs.mkdirSync(logDir, { recursive: true });

  // ── Append one JSON line ────────────────────────────────────────────────────
  const entry = JSON.stringify({ timestamp, event: 'sessionEnd', sessionId, durationSec, promptCount });
  fs.appendFileSync(sessionFile, entry + '\n', 'utf8');

  process.exit(0);
});
