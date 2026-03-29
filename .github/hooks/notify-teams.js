#!/usr/bin/env node
/**
 * Teams Notification Helper — sends Adaptive Card messages to a Teams channel.
 *
 * Usage (from any agent with `execute` tool):
 *
 *   node .github/hooks/notify-teams.js <type> [key=value ...]
 *
 * Types:
 *   pr-created        — @git-publisher created a PR
 *   review-ready      — @local-reviewer verdict READY
 *   review-blocked    — @local-reviewer verdict BLOCKED
 *   comments-resolved — @address-comments finished
 *   phase-complete    — @sprint-orchestrator phase done
 *   story-blocked     — story blocked by dependency
 *   custom            — free-form message (pass title=... message=...)
 *
 * Examples:
 *   node .github/hooks/notify-teams.js pr-created story=STORY-456 service=fund-transfer pr=https://github.com/org/repo/pull/42
 *   node .github/hooks/notify-teams.js review-ready story=STORY-456 service=fund-transfer critical=0 warnings=2
 *   node .github/hooks/notify-teams.js review-blocked story=STORY-456 service=fund-transfer critical=3 findings="BigDecimal violation, missing audit trail, PII in logs"
 *   node .github/hooks/notify-teams.js comments-resolved pr=#42 fixed=5 flagged=1 branch=feature/STORY-456-mortgage
 *   node .github/hooks/notify-teams.js phase-complete epic=EPIC-100 phase=2 totalPhases=4 storiesDone=3
 *   node .github/hooks/notify-teams.js custom title="Deploy Complete" message="Release 2.0.0 deployed to SIT"
 *
 * Webhook URL resolution (first match wins):
 *   1. --webhook=URL argument
 *   2. TEAMS_WEBHOOK_URL environment variable
 *   3. .notifications.env file in project root
 *
 * Exit codes:
 *   0 — notification sent (or silently skipped if no webhook configured)
 *   1 — malformed arguments (never fails on network errors — fire and forget)
 */

const https = require('https');
const http = require('http');
const tls = require('tls');
const fs = require('fs');
const path = require('path');

// ─── Parse arguments ────────────────────────────────────────────────────────
const args = process.argv.slice(2);
const type = args[0];

if (!type) {
  console.error('Usage: notify-teams.js <type> [key=value ...]');
  process.exit(1);
}

const params = {};
for (let i = 1; i < args.length; i++) {
  const eq = args[i].indexOf('=');
  if (eq > 0) {
    params[args[i].slice(0, eq)] = args[i].slice(eq + 1);
  }
}

// ─── Resolve webhook URL ────────────────────────────────────────────────────
function resolveWebhookUrl() {
  // 1. Explicit argument
  if (params.webhook) return params.webhook;

  // 2. Environment variable
  if (process.env.TEAMS_WEBHOOK_URL) return process.env.TEAMS_WEBHOOK_URL;

  // 3. .notifications.env / .notification.env file (walk up from cwd to find project root)
  const roots = [process.cwd(), path.join(process.cwd(), '..'), path.join(process.cwd(), '..', '..')];
  const envNames = ['.notifications.env', '.notification.env'];
  const candidates = roots.flatMap(r => envNames.map(n => path.join(r, n)));

  for (const candidate of candidates) {
    try {
      const content = fs.readFileSync(candidate, 'utf8');
      const match = content.match(/^TEAMS_WEBHOOK_URL=(.+)$/m);
      if (match) return match[1].trim();
    } catch (_) {
      // File not found — try next
    }
  }

  return null;
}

// ─── Resolve proxy URL ───────────────────────────────────────────────────────
function resolveProxyUrl() {
  // 1. Explicit argument
  if (params.proxy) return params.proxy;

  // 2. Standard proxy environment variables
  const fromEnv = process.env.HTTPS_PROXY || process.env.https_proxy
    || process.env.HTTP_PROXY || process.env.http_proxy;
  if (fromEnv) return fromEnv;

  // 3. .notifications.env / .notification.env file
  const roots = [process.cwd(), path.join(process.cwd(), '..'), path.join(process.cwd(), '..', '..')];
  const envNames = ['.notifications.env', '.notification.env'];
  const candidates = roots.flatMap(r => envNames.map(n => path.join(r, n)));

  for (const candidate of candidates) {
    try {
      const content = fs.readFileSync(candidate, 'utf8');
      const match = content.match(/^HTTPS_PROXY=(.+)$/m);
      if (match) return match[1].trim();
    } catch (_) {
      // File not found — try next
    }
  }

  return null;
}

const webhookUrl = resolveWebhookUrl();

if (!webhookUrl) {
  // Silently exit — no webhook configured, notifications are optional
  process.exit(0);
}

// ─── Card builders per notification type ────────────────────────────────────

function buildCard() {
  switch (type) {
    case 'pr-created':
      return prCreatedCard();
    case 'review-ready':
      return reviewReadyCard();
    case 'review-blocked':
      return reviewBlockedCard();
    case 'comments-resolved':
      return commentsResolvedCard();
    case 'phase-complete':
      return phaseCompleteCard();
    case 'story-blocked':
      return storyBlockedCard();
    case 'agent-complete':
      return agentCompleteCard();
    case 'agent-error':
      return agentErrorCard();
    case 'agent-waiting':
      return agentWaitingCard();
    case 'custom':
      return customCard();
    default:
      return customCard();
  }
}

function prCreatedCard() {
  return {
    type: 'AdaptiveCard', version: '1.4',
    body: [
      { type: 'TextBlock', text: '\u{1F680} PR Created', size: 'Large', weight: 'Bolder', color: 'Good' },
      {
        type: 'FactSet', facts: [
          { title: 'Story', value: params.story || 'N/A' },
          { title: 'Service', value: params.service || 'N/A' },
          { title: 'Branch', value: params.branch || 'N/A' },
          { title: 'Target', value: params.target || 'N/A' },
        ].filter(f => f.value !== 'N/A')
      },
      params.pr ? { type: 'TextBlock', text: `[View Pull Request](${params.pr})`, wrap: true } : null,
      { type: 'TextBlock', text: `_@git-publisher \u2022 ${new Date().toISOString().slice(0, 16).replace('T', ' ')}_`, isSubtle: true, size: 'Small' },
    ].filter(Boolean),
  };
}

function reviewReadyCard() {
  return {
    type: 'AdaptiveCard', version: '1.4',
    body: [
      { type: 'TextBlock', text: '\u2705 Review Passed — READY TO COMMIT', size: 'Large', weight: 'Bolder', color: 'Good' },
      {
        type: 'FactSet', facts: [
          { title: 'Story', value: params.story || 'N/A' },
          { title: 'Service', value: params.service || 'N/A' },
          { title: 'Critical', value: params.critical || '0' },
          { title: 'Warnings', value: params.warnings || '0' },
          { title: 'Suggestions', value: params.suggestions || '0' },
        ]
      },
      { type: 'TextBlock', text: 'Next: `@git-publisher` to create PR or `@instinct-extractor` to capture patterns.', wrap: true },
      { type: 'TextBlock', text: `_@local-reviewer \u2022 ${new Date().toISOString().slice(0, 16).replace('T', ' ')}_`, isSubtle: true, size: 'Small' },
    ],
  };
}

function reviewBlockedCard() {
  return {
    type: 'AdaptiveCard', version: '1.4',
    body: [
      { type: 'TextBlock', text: '\u{1F6D1} Review BLOCKED', size: 'Large', weight: 'Bolder', color: 'Attention' },
      {
        type: 'FactSet', facts: [
          { title: 'Story', value: params.story || 'N/A' },
          { title: 'Service', value: params.service || 'N/A' },
          { title: 'Critical Issues', value: params.critical || '?' },
        ]
      },
      params.findings ? { type: 'TextBlock', text: `**Findings:** ${params.findings}`, wrap: true } : null,
      { type: 'TextBlock', text: 'Fix critical issues and re-run `@local-reviewer`.', wrap: true },
      { type: 'TextBlock', text: `_@local-reviewer \u2022 ${new Date().toISOString().slice(0, 16).replace('T', ' ')}_`, isSubtle: true, size: 'Small' },
    ].filter(Boolean),
  };
}

function commentsResolvedCard() {
  return {
    type: 'AdaptiveCard', version: '1.4',
    body: [
      { type: 'TextBlock', text: '\u{1F4AC} PR Comments Addressed', size: 'Large', weight: 'Bolder', color: 'Good' },
      {
        type: 'FactSet', facts: [
          { title: 'PR', value: params.pr || 'N/A' },
          { title: 'Branch', value: params.branch || 'N/A' },
          { title: 'Fixed', value: params.fixed || '0' },
          { title: 'Replied', value: params.replied || '0' },
          { title: 'Delegated', value: params.delegated || '0' },
          { title: 'Flagged', value: params.flagged || '0' },
        ]
      },
      { type: 'TextBlock', text: 'Fixes pushed. Copilot re-review requested. Ready for human re-review.', wrap: true },
      { type: 'TextBlock', text: `_@address-comments \u2022 ${new Date().toISOString().slice(0, 16).replace('T', ' ')}_`, isSubtle: true, size: 'Small' },
    ],
  };
}

function phaseCompleteCard() {
  return {
    type: 'AdaptiveCard', version: '1.4',
    body: [
      { type: 'TextBlock', text: `\u{1F3C1} Phase ${params.phase || '?'} of ${params.totalPhases || '?'} Complete`, size: 'Large', weight: 'Bolder', color: 'Good' },
      {
        type: 'FactSet', facts: [
          { title: 'Epic', value: params.epic || 'N/A' },
          { title: 'Stories Delivered', value: params.storiesDone || '?' },
          { title: 'Next Phase', value: params.nextPhase || 'N/A' },
        ]
      },
      { type: 'TextBlock', text: `_@sprint-orchestrator \u2022 ${new Date().toISOString().slice(0, 16).replace('T', ' ')}_`, isSubtle: true, size: 'Small' },
    ],
  };
}

function storyBlockedCard() {
  return {
    type: 'AdaptiveCard', version: '1.4',
    body: [
      { type: 'TextBlock', text: '\u{1F6A8} Story Blocked', size: 'Large', weight: 'Bolder', color: 'Attention' },
      {
        type: 'FactSet', facts: [
          { title: 'Story', value: params.story || 'N/A' },
          { title: 'Blocked By', value: params.blockedBy || 'N/A' },
          { title: 'Reason', value: params.reason || 'N/A' },
        ]
      },
      { type: 'TextBlock', text: `_@sprint-orchestrator \u2022 ${new Date().toISOString().slice(0, 16).replace('T', ' ')}_`, isSubtle: true, size: 'Small' },
    ],
  };
}

function agentCompleteCard() {
  return {
    type: 'AdaptiveCard', version: '1.4',
    body: [
      { type: 'TextBlock', text: 'Agent Task Complete', size: 'Large', weight: 'Bolder', color: 'Good' },
      {
        type: 'FactSet', facts: [
          { title: 'Agent', value: params.agent || 'N/A' },
          { title: 'Story', value: params.story || 'N/A' },
          { title: 'Status', value: params.status || 'success' },
          { title: 'Summary', value: params.summary || 'Task completed successfully' },
        ]
      },
      { type: 'TextBlock', text: `_copilot-watchdog \u2022 ${new Date().toISOString().slice(0, 16).replace('T', ' ')}_`, isSubtle: true, size: 'Small' },
    ],
  };
}

function agentErrorCard() {
  return {
    type: 'AdaptiveCard', version: '1.4',
    body: [
      { type: 'TextBlock', text: 'Agent Error \u2014 Needs Attention', size: 'Large', weight: 'Bolder', color: 'Attention' },
      {
        type: 'FactSet', facts: [
          { title: 'Agent', value: params.agent || 'N/A' },
          { title: 'Story', value: params.story || 'N/A' },
          { title: 'Error', value: params.error || 'Unknown error' },
        ]
      },
      { type: 'TextBlock', text: 'Check VS Code for details. The agent may need to be re-run.', wrap: true },
      { type: 'TextBlock', text: `_copilot-watchdog \u2022 ${new Date().toISOString().slice(0, 16).replace('T', ' ')}_`, isSubtle: true, size: 'Small' },
    ],
  };
}

function agentWaitingCard() {
  return {
    type: 'AdaptiveCard', version: '1.4',
    body: [
      { type: 'TextBlock', text: 'Agent Waiting \u2014 Human Input Needed', size: 'Large', weight: 'Bolder', color: 'Warning' },
      {
        type: 'FactSet', facts: [
          { title: 'Agent', value: params.agent || 'N/A' },
          { title: 'Story', value: params.story || 'N/A' },
          { title: 'Reason', value: params.reason || 'Agent needs your input' },
        ]
      },
      { type: 'TextBlock', text: 'Open VS Code to respond to the agent.', wrap: true },
      { type: 'TextBlock', text: `_copilot-watchdog \u2022 ${new Date().toISOString().slice(0, 16).replace('T', ' ')}_`, isSubtle: true, size: 'Small' },
    ],
  };
}

function customCard() {
  return {
    type: 'AdaptiveCard', version: '1.4',
    body: [
      { type: 'TextBlock', text: params.title || 'Notification', size: 'Large', weight: 'Bolder' },
      { type: 'TextBlock', text: params.message || '', wrap: true },
      { type: 'TextBlock', text: `_${new Date().toISOString().slice(0, 16).replace('T', ' ')}_`, isSubtle: true, size: 'Small' },
    ],
  };
}

// ─── Send the notification ──────────────────────────────────────────────────

const card = buildCard();

const payload = JSON.stringify({
  type: 'message',
  attachments: [{
    contentType: 'application/vnd.microsoft.card.adaptive',
    contentUrl: null,
    content: card,
  }],
});

const targetUrl = new URL(webhookUrl);
const proxyUrl = resolveProxyUrl();

if (proxyUrl) {
  // ── Route HTTPS through corporate proxy via HTTP CONNECT tunnel ──────────
  const proxy = new URL(proxyUrl);
  const targetPort = targetUrl.port || 443;

  const connectReq = http.request({
    hostname: proxy.hostname,
    port: parseInt(proxy.port, 10) || 8080,
    method: 'CONNECT',
    path: `${targetUrl.hostname}:${targetPort}`,
    headers: { 'Host': `${targetUrl.hostname}:${targetPort}`, 'Proxy-Connection': 'keep-alive' },
    timeout: 10000,
  });

  connectReq.on('connect', (res, socket) => {
    if (res.statusCode !== 200) {
      console.error(`Proxy CONNECT failed: ${res.statusCode}`);
      return;
    }

    const tlsSocket = tls.connect({
      socket,
      servername: targetUrl.hostname,
      rejectUnauthorized: true,
    });

    tlsSocket.on('secureConnect', () => {
      const requestLine = `POST ${targetUrl.pathname}${targetUrl.search} HTTP/1.1\r\n`;
      const headers = [
        `Host: ${targetUrl.hostname}`,
        `Content-Type: application/json`,
        `Content-Length: ${Buffer.byteLength(payload)}`,
        `Connection: close`,
      ].join('\r\n');
      tlsSocket.write(`${requestLine}${headers}\r\n\r\n${payload}`);

      let responseData = '';
      tlsSocket.on('data', (chunk) => { responseData += chunk.toString(); });
      tlsSocket.on('end', () => {
        const statusLine = responseData.split('\r\n')[0] || '';
        const statusCode = parseInt(statusLine.split(' ')[1], 10);
        if (!statusCode || (statusCode >= 200 && statusCode < 300)) {
          // Success — silent
        } else {
          console.error(`Teams webhook returned ${statusCode}`);
        }
      });
    });

    tlsSocket.on('error', (err) => {
      console.error(`Teams notification failed (proxy TLS): ${err.message}`);
    });

    tlsSocket.on('timeout', () => {
      tlsSocket.destroy();
      console.error('Teams notification timed out (proxy TLS)');
    });

    tlsSocket.setTimeout(10000);
  });

  connectReq.on('error', (err) => {
    console.error(`Teams notification failed (proxy CONNECT): ${err.message}`);
  });

  connectReq.on('timeout', () => {
    connectReq.destroy();
    console.error('Teams notification timed out (proxy CONNECT)');
  });

  connectReq.end();

} else {
  // ── Direct connection ─────────────────────────────────────────────────────
  const transport = targetUrl.protocol === 'https:' ? https : http;

  const req = transport.request(
    {
      hostname: targetUrl.hostname,
      port: targetUrl.port,
      path: targetUrl.pathname + targetUrl.search,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload),
      },
      timeout: 10000,
    },
    (res) => {
      res.resume();
      if (res.statusCode >= 200 && res.statusCode < 300) {
        // Success — silent
      } else {
        console.error(`Teams webhook returned ${res.statusCode}`);
      }
    },
  );

  req.on('error', (err) => {
    console.error(`Teams notification failed: ${err.message}`);
  });

  req.on('timeout', () => {
    req.destroy();
    console.error('Teams notification timed out');
  });

  req.write(payload);
  req.end();
}
