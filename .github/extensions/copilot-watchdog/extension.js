// Copilot Watchdog — Teams Notifications
// Monitors GitHub Copilot agent sessions and sends notifications on idle/error states.
// Zero dependencies: uses only Node.js built-ins + VS Code API.

const vscode = require('vscode');
const path = require('path');
const fs = require('fs');
const { execFile } = require('child_process');

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const ERROR_PATTERNS = [
  'rate limit',
  'try again',
  '429',
  '500',
  '503',
  'error',
  'failed',
  'timed out',
  'request failed',
  'ECONNREFUSED',
  'ETIMEDOUT',
];

const ERROR_REGEX = new RegExp(ERROR_PATTERNS.join('|'), 'i');

const ERROR_DEBOUNCE_MS = 5 * 60 * 1000; // 5 minutes
const OUTPUT_SCAN_INTERVAL_MS = 30 * 1000; // 30 seconds

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/** @type {vscode.OutputChannel} */
let outputChannel;

/** @type {vscode.StatusBarItem} */
let statusBarItem;

/** @type {NodeJS.Timeout | undefined} */
let idleTimer;

/** @type {NodeJS.Timeout | undefined} */
let scanInterval;

/** @type {vscode.FileSystemWatcher[]} */
let fileWatchers = [];

/** @type {vscode.Disposable[]} */
let disposables = [];

/** Session state: 'active' | 'idle' | 'notified' */
let sessionState = 'active';

/** Timestamp of last detected activity */
let lastActivityTime = Date.now();

/** Map of error pattern -> last notification timestamp for debouncing */
const errorNotificationTimes = new Map();

/** Whether monitoring is currently enabled */
let monitoringEnabled = false;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function getConfig() {
  const cfg = vscode.workspace.getConfiguration('copilotWatchdog');
  return {
    enabled: cfg.get('enabled', true),
    idleTimeoutMinutes: cfg.get('idleTimeoutMinutes', 2),
    teamsNotifications: cfg.get('teamsNotifications', true),
    desktopNotifications: cfg.get('desktopNotifications', true),
  };
}

function getWorkspaceRoot() {
  const folders = vscode.workspace.workspaceFolders;
  if (folders && folders.length > 0) {
    return folders[0].uri.fsPath;
  }
  return undefined;
}

function log(message) {
  const ts = new Date().toISOString();
  if (outputChannel) {
    outputChannel.appendLine(`[${ts}] ${message}`);
  }
}

// ---------------------------------------------------------------------------
// Status Bar
// ---------------------------------------------------------------------------

function createStatusBar() {
  statusBarItem = vscode.window.createStatusBarItem(
    vscode.StatusBarAlignment.Right,
    100
  );
  statusBarItem.command = 'copilotWatchdog.toggleFromStatusBar';
  updateStatusBar();
  statusBarItem.show();
  return statusBarItem;
}

function updateStatusBar() {
  if (!statusBarItem) return;

  if (!monitoringEnabled) {
    statusBarItem.text = '$(eye-closed) Watchdog OFF';
    statusBarItem.tooltip = 'Copilot Watchdog is disabled. Click to enable.';
    statusBarItem.backgroundColor = undefined;
  } else if (sessionState === 'idle' || sessionState === 'notified') {
    statusBarItem.text = '$(alert) Watchdog: Idle';
    statusBarItem.tooltip = 'Copilot agent appears idle. Click to toggle monitoring.';
    statusBarItem.backgroundColor = new vscode.ThemeColor(
      'statusBarItem.warningBackground'
    );
  } else {
    statusBarItem.text = '$(eye) Watchdog';
    statusBarItem.tooltip = 'Copilot Watchdog is monitoring. Click to disable.';
    statusBarItem.backgroundColor = undefined;
  }
}

// ---------------------------------------------------------------------------
// Teams Integration
// ---------------------------------------------------------------------------

function sendTeamsNotification(type, details) {
  const config = getConfig();
  if (!config.teamsNotifications) {
    log(`Teams notifications disabled — skipping ${type}`);
    return;
  }

  const workspaceRoot = getWorkspaceRoot();
  if (!workspaceRoot) {
    log('No workspace root — cannot locate notify-teams.js');
    return;
  }

  const notifyScript = path.join(workspaceRoot, '.github', 'hooks', 'notify-teams.js');

  try {
    if (!fs.existsSync(notifyScript)) {
      log(`notify-teams.js not found at ${notifyScript} — skipping Teams notification`);
      return;
    }
  } catch {
    log(`Could not check for notify-teams.js — skipping Teams notification`);
    return;
  }

  const args = [notifyScript, type, 'agent=@copilot-watchdog'];
  if (details.reason) {
    args.push(`reason=${details.reason}`);
  }
  if (details.error) {
    args.push(`error=${details.error}`);
  }

  log(`Sending Teams notification: node ${args.join(' ')}`);

  execFile('node', args, { cwd: workspaceRoot, timeout: 15000 }, (err, stdout, stderr) => {
    if (err) {
      log(`Teams notification error: ${err.message}`);
      if (stderr) log(`  stderr: ${stderr}`);
    } else {
      log(`Teams notification sent successfully`);
      if (stdout) log(`  stdout: ${stdout.trim()}`);
    }
  });
}

// ---------------------------------------------------------------------------
// Idle Timer
// ---------------------------------------------------------------------------

function resetIdleTimer() {
  lastActivityTime = Date.now();

  if (sessionState === 'idle' || sessionState === 'notified') {
    sessionState = 'active';
    updateStatusBar();
    log('Activity detected — session marked active');
  }

  if (idleTimer) {
    clearTimeout(idleTimer);
    idleTimer = undefined;
  }

  if (!monitoringEnabled) return;

  const config = getConfig();
  const timeoutMs = config.idleTimeoutMinutes * 60 * 1000;

  idleTimer = setTimeout(() => {
    onIdleTimeout(config);
  }, timeoutMs);
}

function onIdleTimeout(config) {
  sessionState = 'notified';
  updateStatusBar();

  const minutes = config.idleTimeoutMinutes;
  const reason = `No activity for ${minutes} minute${minutes !== 1 ? 's' : ''}. Agent may be complete, stuck, or waiting for permission.`;

  log(`Idle timeout fired: ${reason}`);

  // Desktop notification
  if (config.desktopNotifications) {
    vscode.window
      .showWarningMessage(
        `Copilot Watchdog: ${reason}`,
        'Open Copilot Chat',
        'Dismiss'
      )
      .then((action) => {
        if (action === 'Open Copilot Chat') {
          vscode.commands.executeCommand('workbench.panel.chat.view.copilot.focus');
        }
      });
  }

  // Teams notification
  sendTeamsNotification('agent-waiting', { reason });
}

// ---------------------------------------------------------------------------
// Activity Watchers (VS Code native signals — no dependency on session-logger)
// ---------------------------------------------------------------------------

function setupActivityWatchers() {
  const workspaceRoot = getWorkspaceRoot();

  // ── Helper: only count real file:// edits inside the workspace ──────────
  function isRelevantFile(uri) {
    if (uri.scheme !== 'file') return false;
    if (!workspaceRoot) return true;
    const rel = path.relative(workspaceRoot, uri.fsPath);
    // Ignore noise: .git internals, node_modules, VS Code settings, logs
    if (rel.startsWith('.git') || rel.startsWith('node_modules')
      || rel.startsWith('.vscode') || rel.startsWith('logs/')) return false;
    return true;
  }

  // 1. Text document changes — agent editing/writing code (file:// only)
  disposables.push(
    vscode.workspace.onDidChangeTextDocument((e) => {
      if (e.contentChanges.length === 0) return;
      if (!isRelevantFile(e.document.uri)) return;
      log(`File edited: ${e.document.uri.fsPath}`);
      resetIdleTimer();
    })
  );

  // 2. File created — agent creating new files
  disposables.push(
    vscode.workspace.onDidCreateFiles((e) => {
      const relevant = e.files.filter(f => isRelevantFile(f));
      if (relevant.length === 0) return;
      for (const file of relevant) {
        log(`File created: ${file.fsPath}`);
      }
      resetIdleTimer();
    })
  );

  // 3. File saved — agent saving files
  disposables.push(
    vscode.workspace.onDidSaveTextDocument((doc) => {
      if (!isRelevantFile(doc.uri)) return;
      log(`File saved: ${doc.uri.fsPath}`);
      resetIdleTimer();
    })
  );

  // 4. Terminal opened — agent spawning terminals for execute tool
  disposables.push(
    vscode.window.onDidOpenTerminal((terminal) => {
      log(`Terminal opened: ${terminal.name}`);
      resetIdleTimer();
    })
  );

  // 5. Terminal closed — agent command finished
  disposables.push(
    vscode.window.onDidCloseTerminal((terminal) => {
      log(`Terminal closed: ${terminal.name}`);
      resetIdleTimer();
    })
  );

  log(`Activity watchers active: ${disposables.length} event listeners (file edits, file creates, file saves, terminal open/close)`);
}

function disposeActivityWatchers() {
  for (const watcher of fileWatchers) {
    watcher.dispose();
  }
  fileWatchers = [];
  // Note: disposables registered via context.subscriptions are cleaned up separately
}

// ---------------------------------------------------------------------------
// Output Channel Scanner
// ---------------------------------------------------------------------------

function startOutputScanner() {
  if (scanInterval) {
    clearInterval(scanInterval);
  }

  scanInterval = setInterval(() => {
    if (!monitoringEnabled || sessionState !== 'active') return;
    scanOutputChannels();
  }, OUTPUT_SCAN_INTERVAL_MS);

  log(`Output scanner started (every ${OUTPUT_SCAN_INTERVAL_MS / 1000}s)`);
}

function stopOutputScanner() {
  if (scanInterval) {
    clearInterval(scanInterval);
    scanInterval = undefined;
  }
  log('Output scanner stopped');
}

function scanOutputChannels() {
  const visibleDocs = vscode.workspace.textDocuments;

  for (const doc of visibleDocs) {
    // Output channels have a URI scheme of 'output'
    if (doc.uri.scheme !== 'output') continue;

    const text = doc.getText();
    if (!text) continue;

    // Only scan the last 2000 characters to keep it fast
    const tail = text.length > 2000 ? text.slice(-2000) : text;
    const match = ERROR_REGEX.exec(tail);

    if (match) {
      const pattern = match[0].toLowerCase();
      onErrorDetected(pattern, doc.uri.toString());
    }
  }
}

function onErrorDetected(pattern, source) {
  const now = Date.now();
  const lastNotified = errorNotificationTimes.get(pattern) || 0;

  if (now - lastNotified < ERROR_DEBOUNCE_MS) {
    return; // Debounced — already notified recently for this pattern
  }

  errorNotificationTimes.set(pattern, now);

  const config = getConfig();
  const errorMessage = `Error detected in output: "${pattern}"`;

  log(`${errorMessage} (source: ${source})`);

  // Desktop notification
  if (config.desktopNotifications) {
    vscode.window
      .showWarningMessage(
        `Copilot Watchdog: ${errorMessage}`,
        'Open Copilot Chat',
        'Dismiss'
      )
      .then((action) => {
        if (action === 'Open Copilot Chat') {
          vscode.commands.executeCommand('workbench.panel.chat.view.copilot.focus');
        }
      });
  }

  // Teams notification
  sendTeamsNotification('agent-error', { error: pattern });
}

// ---------------------------------------------------------------------------
// Monitoring Lifecycle
// ---------------------------------------------------------------------------

function enableMonitoring() {
  if (monitoringEnabled) return;

  monitoringEnabled = true;
  sessionState = 'active';
  lastActivityTime = Date.now();

  setupActivityWatchers();
  startOutputScanner();
  resetIdleTimer();
  updateStatusBar();

  log('Monitoring enabled');
}

function disableMonitoring() {
  monitoringEnabled = false;
  sessionState = 'active';

  if (idleTimer) {
    clearTimeout(idleTimer);
    idleTimer = undefined;
  }

  disposeActivityWatchers();
  stopOutputScanner();
  updateStatusBar();

  log('Monitoring disabled');
}

// ---------------------------------------------------------------------------
// Extension Entry Points
// ---------------------------------------------------------------------------

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
  outputChannel = vscode.window.createOutputChannel('Copilot Watchdog');
  log('Copilot Watchdog activating...');

  // Status bar
  const sbi = createStatusBar();
  context.subscriptions.push(sbi);

  // Commands
  context.subscriptions.push(
    vscode.commands.registerCommand('copilotWatchdog.enable', () => {
      enableMonitoring();
      vscode.window.showInformationMessage('Copilot Watchdog: Monitoring enabled.');
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('copilotWatchdog.disable', () => {
      disableMonitoring();
      vscode.window.showInformationMessage('Copilot Watchdog: Monitoring disabled.');
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('copilotWatchdog.status', () => {
      const config = getConfig();
      const elapsed = Math.round((Date.now() - lastActivityTime) / 1000);
      const info = [
        `Monitoring: ${monitoringEnabled ? 'ON' : 'OFF'}`,
        `Session state: ${sessionState}`,
        `Last activity: ${elapsed}s ago`,
        `Idle timeout: ${config.idleTimeoutMinutes} min`,
        `Teams notifications: ${config.teamsNotifications ? 'ON' : 'OFF'}`,
        `Desktop notifications: ${config.desktopNotifications ? 'ON' : 'OFF'}`,
        `Log watchers: ${fileWatchers.length}`,
      ].join('\n');

      vscode.window.showInformationMessage(
        `Copilot Watchdog Status:\n${info}`,
        { modal: true }
      );
      log(`Status requested:\n${info}`);
    })
  );

  // Test command — manually trigger a notification to verify the pipeline works
  context.subscriptions.push(
    vscode.commands.registerCommand('copilotWatchdog.test', () => {
      log('Test notification triggered manually');
      const reason = 'TEST — This is a test notification from Copilot Watchdog. If you see this in Teams, the pipeline works!';

      vscode.window.showWarningMessage(
        `Copilot Watchdog: ${reason}`,
        'OK'
      );

      sendTeamsNotification('agent-waiting', {
        reason: 'TEST — Copilot Watchdog notification pipeline verified'
      });

      vscode.window.showInformationMessage('Copilot Watchdog: Test notification sent! Check Teams.');
    })
  );

  // Internal command for status bar toggle
  context.subscriptions.push(
    vscode.commands.registerCommand('copilotWatchdog.toggleFromStatusBar', () => {
      if (monitoringEnabled) {
        disableMonitoring();
      } else {
        enableMonitoring();
      }
    })
  );

  // Listen for configuration changes
  context.subscriptions.push(
    vscode.workspace.onDidChangeConfiguration((e) => {
      if (!e.affectsConfiguration('copilotWatchdog')) return;

      const config = getConfig();
      log(`Configuration changed — enabled=${config.enabled}, timeout=${config.idleTimeoutMinutes}m`);

      if (config.enabled && !monitoringEnabled) {
        enableMonitoring();
      } else if (!config.enabled && monitoringEnabled) {
        disableMonitoring();
      } else if (monitoringEnabled) {
        // Timeout may have changed, reset the timer
        resetIdleTimer();
      }
    })
  );

  // Auto-start if enabled in settings
  const config = getConfig();
  if (config.enabled) {
    enableMonitoring();
  }

  log('Copilot Watchdog activated');
}

function deactivate() {
  log('Copilot Watchdog deactivating...');

  // Clear idle timer
  if (idleTimer) {
    clearTimeout(idleTimer);
    idleTimer = undefined;
  }

  // Stop output scanner
  stopOutputScanner();

  // Dispose log watchers
  disposeActivityWatchers();

  // Dispose all registered disposables
  for (const d of disposables) {
    d.dispose();
  }
  disposables = [];

  // Status bar is disposed via context.subscriptions

  if (outputChannel) {
    outputChannel.appendLine(`[${new Date().toISOString()}] Copilot Watchdog deactivated`);
    outputChannel.dispose();
  }
}

module.exports = { activate, deactivate };
