#!/usr/bin/env node
// ──────────────────────────────────────────────────────
// Test: "Connection failed." shown with Retry button when max retries exhausted
// Criterion: US3.AC3 — "Given all reconnection attempts have failed, When the retry limit
//   is reached, Then 'Connection failed.' is shown with a Retry button."
// Feature: 002-fix-terminal-websocket-initial-connection-failure
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// Prerequisites:
//   - Chrome running with --remote-debugging-port=9222
//   - kai-ui dev server running on http://localhost:3000
//   - Sidecar server NOT running (stop it before running this test)
//
// Run: node test-connection-failed-with-retry-button.mjs

import http from "node:http";

const CHROME_DEBUG_PORT = 9222;
const APP_URL = "http://localhost:3000";

// MAX_RECONNECT_ATTEMPTS = 5, max delay = 30s, so worst case ~63s
// 5 attempts with exponential backoff: 1+2+4+8+16 = 31s + margin
const MAX_WAIT_MS = 70000;

function cdpRequest(path) {
  return new Promise((resolve, reject) => {
    http.get({ hostname: "localhost", port: CHROME_DEBUG_PORT, path }, (res) => {
      let data = "";
      res.on("data", (c) => (data += c));
      res.on("end", () => resolve(JSON.parse(data)));
    }).on("error", reject);
  });
}

async function runTest() {
  console.log("Note: This test requires the sidecar to be STOPPED. It may take up to 70 seconds.");

  const targets = await cdpRequest("/json");
  const page = targets.find((t) => t.type === "page");
  if (!page) {
    console.error("FAIL: No Chrome page target found.");
    process.exit(1);
  }

  const { default: WebSocket } = await import("ws");
  const ws = new WebSocket(page.webSocketDebuggerUrl);
  let msgId = 0;
  const pending = new Map();
  const events = [];

  function send(method, params = {}) {
    return new Promise((resolve, reject) => {
      const id = ++msgId;
      pending.set(id, { resolve, reject });
      ws.send(JSON.stringify({ id, method, params }));
    });
  }

  ws.on("message", (raw) => {
    const msg = JSON.parse(raw.toString());
    if (msg.id && pending.has(msg.id)) {
      const { resolve, reject } = pending.get(msg.id);
      pending.delete(msg.id);
      if (msg.error) reject(new Error(msg.error.message));
      else resolve(msg.result);
    } else if (msg.method) {
      events.push(msg);
    }
  });

  await new Promise((r) => ws.on("open", r));
  await send("Page.enable");
  await send("Runtime.enable");

  await send("Page.navigate", { url: APP_URL });

  // Poll until "Connection failed." appears or timeout
  let failedStateReached = false;
  let retryButtonPresent = false;
  const start = Date.now();
  let elapsed = 0;

  while (elapsed < MAX_WAIT_MS) {
    await new Promise((r) => setTimeout(r, 1000));
    elapsed = Date.now() - start;

    const result = await send("Runtime.evaluate", {
      expression: `
        (() => {
          const text = document.body.innerText;
          const hasFailed = text.includes('Connection failed.');
          // Check for Retry button by looking for a button with "Retry" text
          const buttons = Array.from(document.querySelectorAll('button'));
          const hasRetry = buttons.some(b => b.innerText.trim() === 'Retry');
          return { hasFailed, hasRetry };
        })()
      `,
      returnByValue: true,
    });

    const { hasFailed, hasRetry } = result?.result?.value ?? {};
    if (hasFailed) {
      failedStateReached = true;
      retryButtonPresent = hasRetry;
      break;
    }

    if (elapsed % 10000 < 1100) {
      console.log(`  Waiting... ${Math.round(elapsed / 1000)}s elapsed`);
    }
  }

  ws.close();

  if (!failedStateReached) {
    console.error("FAIL");
    console.error(`Expected: "Connection failed." shown after max retries exhausted`);
    console.error(`Actual:   "Connection failed." never appeared within ${MAX_WAIT_MS / 1000}s — retry loop may be infinite`);
    process.exit(1);
  }

  if (!retryButtonPresent) {
    console.error("FAIL");
    console.error(`Expected: Retry button present alongside "Connection failed." message`);
    console.error(`Actual:   "Connection failed." shown but no Retry button found in DOM`);
    process.exit(1);
  }

  console.log(`PASS: "Connection failed." shown with Retry button after max retries exhausted (${Math.round(elapsed / 1000)}s).`);
  process.exit(0);
}

runTest().catch((err) => {
  console.error("FAIL: Unexpected error:", err.message);
  process.exit(1);
});
